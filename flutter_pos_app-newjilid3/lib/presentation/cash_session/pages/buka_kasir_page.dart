import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_banner.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_money_text_field.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/components/app_sticky_footer.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/avatar.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/response/auth_response_model.dart';
import '../../../data/models/response/cash_session_model.dart';
import '../../home/pages/dashboard_page.dart';
import '../../setting/pages/manage_printer_page.dart';
import '../../setting/pages/save_server_key_page.dart';
import '../../setting/pages/sync_data_page.dart';
import '../bloc/cash_session/cash_session_bloc.dart';
import '../widgets/checklist_row.dart';
import '../widgets/shift_option_card.dart';

class BukaKasirPage extends StatefulWidget {
  const BukaKasirPage({super.key});

  @override
  State<BukaKasirPage> createState() => _BukaKasirPageState();
}

class _BukaKasirPageState extends State<BukaKasirPage> {
  static const List<_ShiftDef> _shifts = [
    _ShiftDef(label: 'Pagi', time: '06:00 – 14:00', startHour: 6),
    _ShiftDef(label: 'Siang', time: '14:00 – 22:00', startHour: 14),
    _ShiftDef(label: 'Malam', time: '22:00 – 06:00', startHour: 22),
  ];

  late String _selectedShift;
  int _openingFloat = 0;
  String _note = '';
  String? _floatError;

  AuthResponseModel? _auth;
  bool _printerOk = false;
  bool _qrisKeyOk = false;

  @override
  void initState() {
    super.initState();
    _selectedShift = _autoShiftForNow();
    _loadDeviceState();
  }

  static String _autoShiftForNow() {
    final h = DateTime.now().hour;
    if (h >= 6 && h < 14) return 'Pagi';
    if (h >= 14 && h < 22) return 'Siang';
    return 'Malam';
  }

  Future<void> _loadDeviceState() async {
    final ds = AuthLocalDatasource();
    final auth = await ds.getAuthData();
    final printer = await ds.getPrinter();
    final qrisKey = await ds.getMitransServerKey();
    final qrisOn = await ds.isMidtransEnabled();
    if (!mounted) return;
    setState(() {
      _auth = auth;
      _printerOk = printer.isNotEmpty;
      _qrisKeyOk = qrisKey.isNotEmpty && qrisOn;
    });
  }

  void _submit() {
    if (_openingFloat <= 0) {
      setState(() => _floatError = 'Masukkan jumlah modal awal');
      return;
    }
    setState(() => _floatError = null);
    FocusScope.of(context).unfocus();
    context.read<CashSessionBloc>().add(
          CashSessionEvent.open(
            shiftLabel: _selectedShift,
            openingFloat: _openingFloat,
            note: _note.trim().isEmpty ? null : _note.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return BlocConsumer<CashSessionBloc, CashSessionState>(
      listener: (context, state) {
        state.maybeWhen(
          open: (_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DashboardPage()),
              (route) => false,
            );
          },
          error: (msg) => AppSnackbar.error(context, msg),
          orElse: () {},
        );
      },
      builder: (context, state) {
        final loading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        final lastClosed = state.maybeWhen(
          noSession: (last) => last,
          orElse: () => null,
        );

        return Scaffold(
          backgroundColor: p.surface,
          appBar: const AppAppBar(
            title: 'Buka Kasir',
            subtitle: 'Mulai shift baru',
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                _IdentityCard(auth: _auth),
                const _SectionLabel('Shift sebelumnya'),
                _PreviousShiftRecap(last: lastClosed),
                const _SectionLabel('Pilih shift'),
                Row(
                  children: [
                    for (var i = 0; i < _shifts.length; i++) ...[
                      Expanded(
                        child: ShiftOptionCard(
                          label: _shifts[i].label,
                          time: _shifts[i].time,
                          active: _shifts[i].label == _selectedShift,
                          onTap: () =>
                              setState(() => _selectedShift = _shifts[i].label),
                        ),
                      ),
                      if (i < _shifts.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                ),
                const _RequiredSectionLabel('Modal awal kas'),
                AppMoneyTextField(
                  initialValue: _openingFloat,
                  errorText: _floatError,
                  onChanged: (v) {
                    _openingFloat = v;
                    if (_floatError != null && v > 0) {
                      setState(() => _floatError = null);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _QuickAmountRow(
                  selected: _openingFloat,
                  onPick: (v) => setState(() {
                    _openingFloat = v;
                    _floatError = null;
                  }),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Uang fisik yang sudah disiapkan di laci kasir untuk kembalian.',
                    style: AppTypography.bodyS.copyWith(
                      color: p.onSurfaceVar,
                      fontSize: 11,
                    ),
                  ),
                ),
                const _SectionLabel('Cek persiapan'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ChecklistRow(
                        title: 'Printer Thermal',
                        detail: _printerOk
                            ? 'Tersambung'
                            : 'Belum di-pair',
                        status: _printerOk
                            ? ChecklistStatus.ok
                            : ChecklistStatus.warn,
                        actionLabel: _printerOk ? null : 'Atur',
                        onAction: _printerOk ? null : _openPrinterSettings,
                      ),
                      ChecklistRow(
                        title: 'Server Key QRIS',
                        detail: _qrisKeyOk ? 'Tersimpan' : 'Belum diatur',
                        status: _qrisKeyOk
                            ? ChecklistStatus.ok
                            : ChecklistStatus.warn,
                        actionLabel: _qrisKeyOk ? null : 'Atur',
                        onAction: _qrisKeyOk ? null : _openServerKey,
                      ),
                      ChecklistRow(
                        title: 'Sinkronisasi data',
                        detail: 'Pastikan produk & stok terbaru',
                        status: ChecklistStatus.warn,
                        actionLabel: 'Sync',
                        onAction: _openSync,
                        last: true,
                      ),
                    ],
                  ),
                ),
                const _SectionLabel('Catatan (opsional)'),
                AppTextField(
                  hint:
                      'mis. promo happy hour 17–19, espresso machine baru di-service...',
                  maxLines: 3,
                  minLines: 3,
                  onChanged: (v) => _note = v,
                ),
              ],
            ),
          ),
          bottomNavigationBar: AppStickyFooter(
            child: AppButton.primaryWithArrow(
              label: 'Mulai Shift $_selectedShift',
              loading: loading,
              onPressed: loading ? null : _submit,
            ),
          ),
        );
      },
    );
  }

  Future<void> _openPrinterSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManagePrinterPage()),
    );
    if (mounted) _loadDeviceState();
  }

  Future<void> _openServerKey() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SaveServerKeyPage()),
    );
    if (mounted) _loadDeviceState();
  }

  Future<void> _openSync() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SyncDataPage()),
    );
  }
}

class _ShiftDef {
  final String label;
  final String time;
  final int startHour;
  const _ShiftDef({
    required this.label,
    required this.time,
    required this.startHour,
  });
}

// ─── identity card ───────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  final AuthResponseModel? auth;
  const _IdentityCard({required this.auth});

  static final _df = DateFormat('EEEE, d MMM · HH:mm', 'id');

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final name = auth?.user.name ?? 'Memuat...';
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
              AppAvatar.initialsOf(name),
              style: AppTypography.titleM.copyWith(
                color: p.onPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleS.copyWith(
                    color: p.onPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _df.format(DateTime.now()),
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

// ─── previous shift recap ────────────────────────────────────────────────
class _PreviousShiftRecap extends StatelessWidget {
  final CashSessionModel? last;
  const _PreviousShiftRecap({required this.last});

  static final _df = DateFormat('d MMM HH:mm', 'id');

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (last == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: p.surfaceVariant,
          borderRadius: AppRadius.mdAll,
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: p.onSurfaceVar, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Belum ada riwayat shift di perangkat ini.',
                style:
                    AppTypography.bodyM.copyWith(color: p.onSurfaceVar),
              ),
            ),
          ],
        ),
      );
    }
    final s = last!;
    final closedAt = s.closedAt!;
    final variance = s.variance ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: p.surfaceVariant,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.smAll,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.access_time,
              size: 16,
              color: p.onSurfaceVar,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodyM.copyWith(
                      color: p.onSurface,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: s.userName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' tutup ${_df.format(closedAt)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  variance == 0
                      ? 'Selisih ${0.currencyFormatRp.trim()}'
                      : 'Selisih ${variance.abs().currencyFormatRp.trim()} '
                          '(${variance > 0 ? 'lebih' : 'kurang'})',
                  style: AppTypography.bodyS.copyWith(
                    color: p.onSurfaceVar,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppStatusPill(
            label: variance == 0 ? 'BALANCED' : 'SELISIH',
            kind: variance == 0
                ? AppStatusKind.success
                : AppStatusKind.warning,
          ),
        ],
      ),
    );
  }
}

// ─── quick amount chips ──────────────────────────────────────────────────
class _QuickAmountRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onPick;

  const _QuickAmountRow({required this.selected, required this.onPick});

  static const _values = [100000, 200000, 300000, 500000];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        for (var i = 0; i < _values.length; i++) ...[
          Expanded(
            child: InkWell(
              onTap: () => onPick(_values[i]),
              borderRadius: AppRadius.smAll,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected == _values[i]
                      ? p.primaryContainer
                      : p.surfaceVariant,
                  borderRadius: AppRadius.smAll,
                  border: Border.all(
                    color: selected == _values[i]
                        ? p.primary.withValues(alpha: 0.27)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  'Rp${_values[i] ~/ 1000}rb',
                  style: AppTypography.labelM.copyWith(
                    color: selected == _values[i]
                        ? p.primary
                        : p.onSurface,
                    fontSize: 11,
                    fontWeight: selected == _values[i]
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          if (i < _values.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

// ─── small wrappers around AppSectionLabel ───────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) =>
      AppSectionLabel(label, margin: const EdgeInsets.only(top: 18, bottom: 8));
}

class _RequiredSectionLabel extends StatelessWidget {
  final String label;
  const _RequiredSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: RichText(
        text: TextSpan(
          style: AppTypography.labelM.copyWith(
            color: p.onSurfaceVar,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
          children: [
            TextSpan(text: label.toUpperCase()),
            TextSpan(
              text: ' *',
              style: TextStyle(color: p.error),
            ),
          ],
        ),
      ),
    );
  }
}

// Reuse the empty banner helper for the no-recap state above (currently
// unused but kept for future "first ever shift" copy).
// ignore: unused_element
class _NoRecapBanner extends StatelessWidget {
  const _NoRecapBanner();

  @override
  Widget build(BuildContext context) {
    return const AppBanner(
      kind: AppBannerKind.info,
      leadingIcon: Icons.info_outline,
      title: 'Shift pertama di perangkat ini',
      body: 'Belum ada riwayat shift sebelumnya.',
    );
  }
}
