import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_banner.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_money_text_field.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_sticky_footer.dart';
import '../../../core/components/app_switch_tile.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/avatar.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/cash_session_local_datasource.dart';
import '../../../data/models/response/cash_session_model.dart';
import '../../auth/pages/splash_page.dart';
import '../../home/bloc/logout/logout_bloc.dart';
import '../../setting/bloc/sync/sync_bloc.dart';
import '../bloc/cash_session/cash_session_bloc.dart';
import '../bloc/cash_session_summary/cash_session_summary_bloc.dart';
import '../widgets/payment_breakdown_row.dart';
import '../widgets/recon_row.dart';
import '../widgets/summary_grid_cell.dart';
import '../widgets/variance_banner.dart';
import 'close_kasir_success_sheet.dart';

/// End-of-shift reconciliation page.
///
/// Layout per `.claude/new-design/screens/close-kasir.jsx`:
/// shift identity → metrics grid → revenue by method → cash reconciliation
/// (with live variance) → notes → cetak struk toggle → sticky CTA.
///
/// Pre-close guard: if `SyncBloc.snapshot.pendingOrderCount > 0`, a warning
/// banner is shown at the top with a "Kirim sekarang" action; the submit
/// button stays disabled until all orders are pushed. This is mandatory —
/// closing offline would let the BE-computed variance run against incomplete
/// data, corrupting the audit trail.
class TutupKasirPage extends StatelessWidget {
  const TutupKasirPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shift = context.read<CashSessionBloc>().state.maybeWhen(
          open: (s) => s,
          orElse: () => null,
        );

    if (shift == null || shift.id == null) {
      // Defensive — should never happen, the page is only reachable from
      // Settings while a shift is open. Bail out gracefully.
      return Scaffold(
        appBar: const AppAppBar(title: 'Tutup Kasir'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tidak ada shift aktif untuk ditutup.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyL
                      .copyWith(color: context.palette.onSurface),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Kembali',
                  fullWidth: false,
                  onPressed: () => Navigator.maybePop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => CashSessionSummaryBloc()
        ..add(CashSessionSummaryEvent.load(shift.id!)),
      child: _TutupKasirView(shift: shift),
    );
  }
}

class _TutupKasirView extends StatefulWidget {
  final CashSessionModel shift;
  const _TutupKasirView({required this.shift});

  @override
  State<_TutupKasirView> createState() => _TutupKasirViewState();
}

class _TutupKasirViewState extends State<_TutupKasirView> {
  int _physicalCount = 0;
  int _cashIn = 0;
  int _cashOut = 0;
  String _note = '';
  bool _printSlip = true;
  String? _physicalError;
  bool _physicalTouched = false;
  int _localCashRevenue = 0;

  @override
  void initState() {
    super.initState();
    _loadLocalCashRevenue();
  }

  Future<void> _loadLocalCashRevenue() async {
    final sid = widget.shift.id;
    if (sid == null) return;
    final revenue =
        await CashSessionLocalDatasource.instance.cashRevenueForSession(sid);
    if (mounted) setState(() => _localCashRevenue = revenue);
  }

  /// Uses the higher of remote (server-synced) or local cash revenue,
  /// so unsynced Tunai orders are still counted.
  int _expectedCash(Map<String, dynamic>? summary) {
    final remoteCashRevenue =
        (summary?['cash_revenue'] as num?)?.toInt() ?? 0;
    final cashRevenue =
        remoteCashRevenue > _localCashRevenue ? remoteCashRevenue : _localCashRevenue;
    return widget.shift.openingFloat + _cashIn - _cashOut + cashRevenue;
  }

  int? _variancePreview(Map<String, dynamic>? summary) {
    if (!_physicalTouched) return null;
    return _physicalCount - _expectedCash(summary);
  }

  void _submit(int pendingOrderCount) {
    if (!_physicalTouched) {
      setState(() {
        _physicalError = 'Hitung kas fisik di laci dulu';
        _physicalTouched = true;
      });
      return;
    }
    if (pendingOrderCount > 0) {
      AppSnackbar.error(
        context,
        'Masih ada $pendingOrderCount order pending. '
        'Kirim semuanya dulu sebelum menutup shift.',
      );
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<CashSessionBloc>().add(
          CashSessionEvent.close(
            physicalCount: _physicalCount,
            cashIn: _cashIn > 0 ? _cashIn : null,
            cashOut: _cashOut > 0 ? _cashOut : null,
            note: _note.trim().isEmpty ? null : _note.trim(),
          ),
        );
  }

  Future<void> _onShiftClosed(CashSessionModel closed) async {
    final root = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final continueFlow = await CloseKasirSuccessSheet.show(
      context,
      closed: closed,
      printSlip: _printSlip,
    );
    if (!mounted) return;
    if (continueFlow != true) {
      // User dismissed — still go back to splash so Buka Kasir is offered.
      root.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashPage()),
        (_) => false,
      );
      return;
    }

    // Logout flow: clear BE token, clear local auth, return to Login.
    context.read<LogoutBloc>().add(const LogoutEvent.logout());
    // Don't wait for LogoutBloc state — UX prefers fast exit. The auth
    // local store is cleared by the bloc on success; Splash will route to
    // Login on next boot.
    messenger.showSnackBar(
      const SnackBar(content: Text('Shift ditutup. Sampai jumpa! 👋')),
    );
    root.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return MultiBlocListener(
      listeners: [
        BlocListener<CashSessionBloc, CashSessionState>(
          listenWhen: (prev, next) => prev != next,
          listener: (context, state) {
            state.maybeWhen(
              noSession: (closed) {
                if (closed != null) _onShiftClosed(closed);
              },
              error: (msg) => AppSnackbar.error(context, msg),
              orElse: () {},
            );
          },
        ),
        // When a push-orders pass finishes (success or failure), re-fetch
        // the summary so cash_revenue + expected_cash reflect newly
        // uploaded orders.
        BlocListener<SyncBloc, SyncState>(
          listenWhen: (prev, next) {
            String? inProgressOf(SyncState s) =>
                s.maybeWhen(ready: (snap) => snap.inProgress, orElse: () => null);
            return inProgressOf(prev) == 'orders' &&
                inProgressOf(next) == null;
          },
          listener: (context, _) {
            context
                .read<CashSessionSummaryBloc>()
                .add(const CashSessionSummaryEvent.refresh());
          },
        ),
      ],
      child: BlocBuilder<SyncBloc, SyncState>(
        builder: (context, syncState) {
          final pending = syncState.maybeWhen(
            ready: (s) => s.pendingOrderCount,
            orElse: () => 0,
          );
          final syncing = syncState.maybeWhen(
            ready: (s) => s.inProgress == 'orders',
            orElse: () => false,
          );
          return BlocBuilder<CashSessionSummaryBloc, CashSessionSummaryState>(
            builder: (context, summaryState) {
              final summary = summaryState.maybeWhen(
                loaded: (_, s) => s,
                orElse: () => null,
              );
              return BlocBuilder<CashSessionBloc, CashSessionState>(
                buildWhen: (prev, next) =>
                    prev.runtimeType != next.runtimeType,
                builder: (context, shiftState) {
                  final closing = shiftState.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  );

                  return Scaffold(
                    backgroundColor: p.surface,
                    appBar: const AppAppBar(
                      title: 'Tutup Kasir',
                      subtitle: 'Rekonsiliasi akhir shift',
                    ),
                    body: SafeArea(
                      top: false,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        children: [
                          _IdentityCard(shift: widget.shift),
                          if (pending > 0) ...[
                            const SizedBox(height: 12),
                            AppBanner(
                              kind: AppBannerKind.warning,
                              leadingIcon: Icons.cloud_upload_outlined,
                              title: '$pending order belum tersinkron',
                              body:
                                  'Variance akan salah sampai semuanya terkirim ke server.',
                              trailing: AppButton(
                                label: syncing ? 'Mengirim...' : 'Kirim',
                                size: AppButtonSize.sm,
                                fullWidth: false,
                                variant: AppButtonVariant.outline,
                                onPressed: syncing
                                    ? null
                                    : () => context
                                        .read<SyncBloc>()
                                        .add(const SyncEvent.pushOrders()),
                              ),
                            ),
                          ],
                          const _SectionLabel('Ringkasan Shift'),
                          _SummaryGrid(summary: summary),
                          const _SectionLabel('Pendapatan per Metode'),
                          _PaymentBreakdown(summary: summary),
                          const _SectionLabel('Rekonsiliasi Kas'),
                          AppCard(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ReconRow(
                                  label: 'Modal awal',
                                  value:
                                      widget.shift.openingFloat.currencyFormatRp.trim(),
                                ),
                                ReconRow(
                                  label: '+ Pemasukan cash',
                                  value: _cashIn.currencyFormatRp.trim(),
                                ),
                                ReconRow(
                                  label: '− Pengeluaran cash',
                                  value: _cashOut.currencyFormatRp.trim(),
                                ),
                                ReconRow(
                                  label: 'Estimasi kas akhir',
                                  value: _expectedCash(summary)
                                      .currencyFormatRp
                                      .trim(),
                                  highlight: true,
                                  last: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _CashFlowInputs(
                            cashIn: _cashIn,
                            cashOut: _cashOut,
                            onCashInChanged: (v) =>
                                setState(() => _cashIn = v),
                            onCashOutChanged: (v) =>
                                setState(() => _cashOut = v),
                          ),
                          const SizedBox(height: 16),
                          const _RequiredLabel('Kas fisik di laci'),
                          const SizedBox(height: 6),
                          AppMoneyTextField(
                            initialValue: _physicalCount,
                            errorText: _physicalError,
                            onChanged: (v) {
                              setState(() {
                                _physicalCount = v;
                                _physicalTouched = true;
                                _physicalError = null;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          VarianceBanner(
                              variance: _variancePreview(summary)),
                          const _SectionLabel('Catatan (opsional)'),
                          AppTextField(
                            hint:
                                'mis. selisih kurang Rp4.000 — kemungkinan kembalian customer...',
                            maxLines: 3,
                            minLines: 3,
                            onChanged: (v) => _note = v,
                          ),
                          const SizedBox(height: 14),
                          AppCard(
                            padding: EdgeInsets.zero,
                            child: AppSwitchTile(
                              title: 'Cetak struk closing',
                              subtitle: 'Print rekap untuk arsip & owner',
                              value: _printSlip,
                              onChanged: (v) =>
                                  setState(() => _printSlip = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottomNavigationBar: AppStickyFooter(
                      child: AppButton.primaryWithArrow(
                        label: 'Tutup Kasir & Akhiri Shift',
                        loading: closing,
                        onPressed: closing ? null : () => _submit(pending),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ─── identity card ───────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  final CashSessionModel shift;
  const _IdentityCard({required this.shift});

  static final _hhmm = DateFormat('HH:mm');

  String _durationLabel() {
    final now = DateTime.now();
    final diff = now.difference(shift.openedAt);
    final h = diff.inHours;
    final m = diff.inMinutes - h * 60;
    return '${h}j ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final period =
        'Shift ${shift.shiftLabel} · ${_hhmm.format(shift.openedAt)} → ${_hhmm.format(DateTime.now())} (${_durationLabel()})';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.primary,
        borderRadius: AppRadius.mdAll,
        boxShadow: [
          BoxShadow(
            color: p.primary.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.onPrimary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              AppAvatar.initialsOf(shift.userName),
              style: AppTypography.titleM.copyWith(
                color: p.onPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.userName,
                  style: AppTypography.titleS.copyWith(
                    color: p.onPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  period,
                  style: AppTypography.bodyS.copyWith(
                    color: p.onPrimary.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── summary grid (2x2 cells) ────────────────────────────────────────────
class _SummaryGrid extends StatelessWidget {
  final Map<String, dynamic>? summary;
  const _SummaryGrid({required this.summary});

  static String _short(int rupiah) {
    if (rupiah >= 1000000) {
      final juta = rupiah / 1000000;
      return 'Rp${juta.toStringAsFixed(juta >= 10 ? 0 : 2)}jt';
    }
    if (rupiah >= 1000) {
      final ribu = rupiah / 1000;
      return 'Rp${ribu.toStringAsFixed(ribu >= 100 ? 0 : 0)}rb';
    }
    return 'Rp$rupiah';
  }

  @override
  Widget build(BuildContext context) {
    final orderCount = (summary?['order_count'] as num?)?.toInt() ?? 0;
    final items = (summary?['items_sold'] as num?)?.toInt() ?? 0;
    final gross = (summary?['gross_revenue'] as num?)?.toInt() ?? 0;
    // Cancelled orders not tracked yet; placeholder 0.
    const cancelled = 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryGridCell(
                label: 'Transaksi',
                value: '$orderCount',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SummaryGridCell(
                label: 'Item Terjual',
                value: '$items',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(
              child: SummaryGridCell(
                label: 'Order Batal',
                value: '$cancelled',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SummaryGridCell(
                label: 'Total Pendapatan',
                value: _short(gross),
                accent: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── payment breakdown card ──────────────────────────────────────────────
class _PaymentBreakdown extends StatelessWidget {
  final Map<String, dynamic>? summary;
  const _PaymentBreakdown({required this.summary});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final byMethod =
        (summary?['by_method'] as Map?)?.cast<String, dynamic>() ?? {};

    if (byMethod.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: p.outlineSoft),
        ),
        child: Row(
          children: [
            Icon(Icons.payments_outlined, color: p.onSurfaceVar, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Belum ada transaksi pada shift ini.',
                style: AppTypography.bodyM.copyWith(color: p.onSurfaceVar),
              ),
            ),
          ],
        ),
      );
    }

    final entries = byMethod.entries.toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: p.outlineSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            PaymentBreakdownRow(
              method: entries[i].key,
              count: ((entries[i].value as Map)['count'] as num?)?.toInt() ?? 0,
              amount:
                  ((entries[i].value as Map)['amount'] as num?)?.toInt() ?? 0,
              last: i == entries.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── cash in/out inputs (collapsible row) ────────────────────────────────
class _CashFlowInputs extends StatefulWidget {
  final int cashIn;
  final int cashOut;
  final ValueChanged<int> onCashInChanged;
  final ValueChanged<int> onCashOutChanged;

  const _CashFlowInputs({
    required this.cashIn,
    required this.cashOut,
    required this.onCashInChanged,
    required this.onCashOutChanged,
  });

  @override
  State<_CashFlowInputs> createState() => _CashFlowInputsState();
}

class _CashFlowInputsState extends State<_CashFlowInputs> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasFlow = widget.cashIn > 0 || widget.cashOut > 0;
    final shouldShow = _expanded || hasFlow;

    if (!shouldShow) {
      return Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () => setState(() => _expanded = true),
          borderRadius: AppRadius.smAll,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16, color: p.primary),
                const SizedBox(width: 4),
                Text(
                  'Catat pemasukan / pengeluaran cash',
                  style: AppTypography.labelL.copyWith(color: p.primary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            '+ Pemasukan cash',
            style: AppTypography.labelL.copyWith(
              color: p.onSurface,
              fontSize: 12,
            ),
          ),
        ),
        AppMoneyTextField(
          initialValue: widget.cashIn,
          onChanged: widget.onCashInChanged,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            '− Pengeluaran cash',
            style: AppTypography.labelL.copyWith(
              color: p.onSurface,
              fontSize: 12,
            ),
          ),
        ),
        AppMoneyTextField(
          initialValue: widget.cashOut,
          onChanged: widget.onCashOutChanged,
        ),
      ],
    );
  }
}

// ─── section labels ──────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) =>
      AppSectionLabel(label, margin: const EdgeInsets.only(top: 18, bottom: 8));
}

class _RequiredLabel extends StatelessWidget {
  final String label;
  const _RequiredLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 2),
      child: RichText(
        text: TextSpan(
          style: AppTypography.labelL.copyWith(
            color: p.onSurface,
            fontSize: 13,
          ),
          children: [
            TextSpan(text: label),
            TextSpan(text: ' *', style: TextStyle(color: p.error)),
          ],
        ),
      ),
    );
  }
}
