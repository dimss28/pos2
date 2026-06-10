import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_banner.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/components/app_sticky_footer.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/sync/sync_bloc.dart';

/// Sinkronisasi Data page. Reads everything from [SyncBloc] (built in Phase 1).
///
/// Maps to `.claude/new-design/screens/sync-data.jsx`.
class SyncDataPage extends StatelessWidget {
  const SyncDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: const AppAppBar(
        title: 'Sinkronisasi Data',
        subtitle: 'Tarik data dari server, kirim order offline',
      ),
      body: BlocBuilder<SyncBloc, SyncState>(
        builder: (context, state) {
          final snap = state.maybeWhen(
            ready: (s) => s,
            orElse: () => null,
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              _ConnectionBanner(snap: snap),
              const AppSectionLabel('Data untuk disinkronkan'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SyncRow(
                      icon: Icons.inventory_2_outlined,
                      title: 'Produk',
                      detail: snap == null
                          ? '—'
                          : '${snap.productCount} item lokal',
                      lastSync: snap?.lastSyncProductsAt,
                      inProgress: snap?.inProgress == 'products',
                      error: snap?.errors['products'],
                      direction: SyncDirection.pull,
                      onSync: () => context
                          .read<SyncBloc>()
                          .add(const SyncEvent.pullProducts()),
                    ),
                    Container(height: 1, color: p.outlineSoft),
                    _SyncRow(
                      icon: Icons.category_outlined,
                      title: 'Kategori',
                      detail: snap == null
                          ? '—'
                          : '${snap.categoryCount} kategori lokal',
                      lastSync: snap?.lastSyncCategoriesAt,
                      inProgress: snap?.inProgress == 'categories',
                      error: snap?.errors['categories'],
                      direction: SyncDirection.pull,
                      onSync: () => context
                          .read<SyncBloc>()
                          .add(const SyncEvent.pullCategories()),
                    ),
                    Container(height: 1, color: p.outlineSoft),
                    _SyncRow(
                      icon: Icons.local_offer_outlined,
                      title: 'Promo',
                      detail: snap == null
                          ? '—'
                          : '${snap.promoCount} promo lokal',
                      lastSync: snap?.lastSyncPromosAt,
                      inProgress: snap?.inProgress == 'promos',
                      error: snap?.errors['promos'],
                      direction: SyncDirection.pull,
                      onSync: () => context
                          .read<SyncBloc>()
                          .add(const SyncEvent.pullPromos()),
                    ),
                    Container(height: 1, color: p.outlineSoft),
                    _SyncRow(
                      icon: Icons.cloud_upload_outlined,
                      title: 'Order Pending',
                      detail: snap == null
                          ? '—'
                          : snap.pendingOrderCount == 0
                              ? 'Tidak ada pending'
                              : '${snap.pendingOrderCount} order menunggu dikirim',
                      lastSync: snap?.lastSyncOrdersAt,
                      inProgress: snap?.inProgress == 'orders',
                      error: snap?.errors['orders'],
                      direction: SyncDirection.push,
                      onSync: () => context
                          .read<SyncBloc>()
                          .add(const SyncEvent.pushOrders()),
                    ),
                  ],
                ),
              ),
              if (snap != null && snap.errors.isNotEmpty) ...[
                const SizedBox(height: 12),
                AppBanner(
                  kind: AppBannerKind.error,
                  leadingIcon: Icons.error_outline,
                  title: '${snap.errors.length} domain gagal sinkron',
                  body: snap.errors.values.first,
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<SyncBloc, SyncState>(
        builder: (context, state) {
          final snap = state.maybeWhen(
            ready: (s) => s,
            orElse: () => null,
          );
          final syncing = snap?.inProgress != null;
          return AppStickyFooter(
            child: AppButton.primaryWithArrow(
              label: syncing
                  ? 'Menyinkron...'
                  : 'Sinkronkan semua',
              loading: syncing,
              onPressed: syncing
                  ? null
                  : () => context
                      .read<SyncBloc>()
                      .add(const SyncEvent.syncAll()),
            ),
          );
        },
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  final SyncSnapshot? snap;
  const _ConnectionBanner({required this.snap});

  String _lastSyncLabel() {
    final dts = [
      snap?.lastSyncProductsAt,
      snap?.lastSyncCategoriesAt,
      snap?.lastSyncPromosAt,
      snap?.lastSyncOrdersAt,
    ].whereType<DateTime>().toList();
    if (dts.isEmpty) return 'Belum pernah sinkron';
    dts.sort((a, b) => b.compareTo(a));
    final diff = DateTime.now().difference(dts.first);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) {
      return 'Terakhir ${diff.inMinutes} menit lalu';
    }
    if (diff.inHours < 24) {
      return 'Terakhir ${diff.inHours} jam lalu';
    }
    return 'Terakhir ${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final hasErrors = snap?.errors.isNotEmpty ?? false;
    return AppBanner(
      kind: hasErrors ? AppBannerKind.warning : AppBannerKind.success,
      leadingIcon: hasErrors
          ? Icons.cloud_off_outlined
          : Icons.cloud_done_outlined,
      title: hasErrors ? 'Sebagian sync gagal' : 'Terhubung ke server',
      body: _lastSyncLabel(),
    );
  }
}

enum SyncDirection { pull, push }

class _SyncRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final DateTime? lastSync;
  final bool inProgress;
  final String? error;
  final SyncDirection direction;
  final VoidCallback onSync;

  const _SyncRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.lastSync,
    required this.inProgress,
    required this.error,
    required this.direction,
    required this.onSync,
  });

  String _lastLabel() {
    if (lastSync == null) return 'Belum';
    final diff = DateTime.now().difference(lastSync!);
    if (diff.inMinutes < 1) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasError = error != null;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: hasError ? p.errorContainer : p.primaryContainer,
              borderRadius: AppRadius.smAll,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: hasError ? p.error : p.primary,
              size: 18,
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
                    Text(
                      title,
                      style: AppTypography.bodyL.copyWith(
                        color: p.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AppStatusPill(
                      label: direction == SyncDirection.pull
                          ? 'PULL'
                          : 'PUSH',
                      kind: AppStatusKind.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hasError ? error! : '$detail · ${_lastLabel()}',
                  style: AppTypography.bodyS.copyWith(
                    color: hasError ? p.error : p.onSurfaceVar,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppButton(
            label: inProgress ? '...' : 'Sync',
            size: AppButtonSize.sm,
            variant: AppButtonVariant.outline,
            fullWidth: false,
            loading: inProgress,
            onPressed: inProgress ? null : onSync,
          ),
        ],
      ),
    );
  }
}
