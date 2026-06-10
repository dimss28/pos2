import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_banner.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/response/promo_model.dart';
import '../bloc/promo/promo_bloc.dart';
import 'add_edit_promo_page.dart';

class ManagePromoPage extends StatefulWidget {
  const ManagePromoPage({super.key});

  @override
  State<ManagePromoPage> createState() => _ManagePromoPageState();
}

class _ManagePromoPageState extends State<ManagePromoPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<PromoBloc>()
        .add(const PromoEvent.refreshFromRemote());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: const AppAppBar(
        title: 'Promo & Voucher',
        subtitle: 'Kelola diskon kasir',
      ),
      body: BlocBuilder<PromoBloc, PromoState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () =>
                Center(child: CircularProgressIndicator(color: p.primary)),
            error: (msg) => Center(
              child: AppEmptyState.error(
                message: msg,
                onRetry: () => context
                    .read<PromoBloc>()
                    .add(const PromoEvent.refreshFromRemote()),
              ),
            ),
            success: (list) {
              if (list.isEmpty) return _EmptyPromo();
              final live = list.where((p) => p.isLive()).toList();
              final scheduled =
                  list.where((p) => !p.isLive() && p.active).toList();
              final inactive = list.where((p) => !p.active).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  if (live.isNotEmpty)
                    AppBanner(
                      kind: AppBannerKind.primary,
                      leadingIcon: Icons.local_offer,
                      title: '${live.length} promo aktif sekarang',
                      body: live.first.name,
                    ),
                  if (live.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionHeader(label: 'Aktif', count: live.length),
                    for (final p in live) ...[
                      _PromoRow(promo: p),
                      const SizedBox(height: 8),
                    ],
                  ],
                  if (scheduled.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _SectionHeader(
                        label: 'Terjadwal / belum mulai',
                        count: scheduled.length),
                    for (final p in scheduled) ...[
                      _PromoRow(promo: p),
                      const SizedBox(height: 8),
                    ],
                  ],
                  if (inactive.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _SectionHeader(
                        label: 'Nonaktif', count: inactive.length),
                    for (final p in inactive) ...[
                      _PromoRow(promo: p),
                      const SizedBox(height: 8),
                    ],
                  ],
                ],
              );
            },
            orElse: () =>
                Center(child: CircularProgressIndicator(color: p.primary)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Buat Promo'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditPromoPage()),
        ),
      ),
    );
  }
}

class _EmptyPromo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppEmptyState(
      visual: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: p.primaryContainer,
          borderRadius: AppRadius.lgAll,
        ),
        alignment: Alignment.center,
        child: Icon(Icons.local_offer_outlined,
            color: p.primary, size: 44),
      ),
      title: 'Belum ada promo',
      body:
          'Buat promo untuk menawarkan diskon ke pelanggan — bisa dipakai otomatis (auto) atau lewat kode voucher.',
      primaryAction: AppButton(
        label: 'Buat promo pertama',
        leadingIcon: Icons.add,
        fullWidth: false,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditPromoPage()),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(left: 2, top: 8, bottom: 8),
      child: Text(
        '${label.toUpperCase()} · $count',
        style: AppTypography.labelM.copyWith(
          color: p.onSurfaceVar,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PromoRow extends StatelessWidget {
  final PromoModel promo;
  const _PromoRow({required this.promo});

  String _valueLabel() {
    switch (promo.type) {
      case PromoType.percent:
        return '${promo.value}%';
      case PromoType.rupiah:
        return promo.value >= 1000
            ? 'Rp${promo.value ~/ 1000}rb'
            : 'Rp${promo.value}';
      case PromoType.b1g1:
        return 'B1G1';
    }
  }

  String _scheduleLabel() {
    if (promo.startsAt == null && promo.endsAt == null) {
      return 'Tanpa jadwal';
    }
    if (promo.startsAt != null && promo.endsAt != null) {
      return '${_fmt(promo.startsAt!)} → ${_fmt(promo.endsAt!)}';
    }
    if (promo.startsAt != null) return 'Mulai ${_fmt(promo.startsAt!)}';
    return 'Sampai ${_fmt(promo.endsAt!)}';
  }

  static String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final live = promo.isLive();
    return Material(
      color: Colors.white,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddEditPromoPage(existing: promo),
        )),
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: p.outlineSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: p.primaryContainer,
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: Text(
                  _valueLabel(),
                  style: AppTypography.labelL.copyWith(
                    color: p.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            promo.name,
                            style: AppTypography.bodyL.copyWith(
                              color: p.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (live)
                          const AppStatusPill(
                            label: 'LIVE',
                            kind: AppStatusKind.error,
                            showDot: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      promo.code?.isNotEmpty == true
                          ? 'Kode: ${promo.code} · ${_scheduleLabel()}'
                          : 'Auto · ${_scheduleLabel()}',
                      style: AppTypography.bodyS.copyWith(
                        color: p.onSurfaceVar,
                        fontSize: 11,
                      ),
                    ),
                    if (promo.minSubtotal > 0)
                      Text(
                        'Min belanja ${promo.minSubtotal.currencyFormatRp.trim()}',
                        style: AppTypography.bodyS.copyWith(
                          color: p.onSurfaceVar,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: promo.active,
                  onChanged: (_) {
                    if (promo.id != null) {
                      context
                          .read<PromoBloc>()
                          .add(PromoEvent.toggle(promo.id!));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
