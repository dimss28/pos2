import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/components/app_app_bar.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_banner.dart';
import '../../core/components/app_bottom_nav.dart';
import '../../core/components/app_bottom_sheet.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_chip.dart';
import '../../core/components/app_empty_state.dart';
import '../../core/components/app_icon_button.dart';
import '../../core/components/app_key_value_row.dart';
import '../../core/components/app_list_group.dart';
import '../../core/components/app_money_text_field.dart';
import '../../core/components/app_numbered_step.dart';
import '../../core/components/app_section_label.dart';
import '../../core/components/app_segmented_toggle.dart';
import '../../core/components/app_status_pill.dart';
import '../../core/components/app_stepper.dart';
import '../../core/components/app_stepper_field.dart';
import '../../core/components/app_sticky_footer.dart';
import '../../core/components/app_switch_tile.dart';
import '../../core/components/app_text_field.dart';
import '../../core/components/avatar.dart';
import '../../core/components/brand_mark.dart';
import '../../core/components/feedback.dart';
import '../../core/components/method_badge.dart';
import '../../core/components/product_img.dart';
import '../../core/components/qr_view.dart';
import '../../core/components/trend_chart.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../setting/bloc/theme/theme_bloc.dart';

/// Debug-only catalog of every shared widget. Open via a long-press on the
/// app version label in Settings, or push directly from `main.dart` while
/// QA-ing the design system. Not linked from any production route.
class ComponentGalleryPage extends StatefulWidget {
  const ComponentGalleryPage({super.key});

  @override
  State<ComponentGalleryPage> createState() => _ComponentGalleryPageState();
}

class _ComponentGalleryPageState extends State<ComponentGalleryPage> {
  int _stepperQty = 2;
  int _stockField = 12;
  bool _switchA = true;
  bool _switchB = false;
  String _env = 'sandbox';
  String _discountType = 'percent';
  int _navTab = 0;
  int _money = 22000;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppAppBar(
        title: 'Component Gallery',
        subtitle: 'Phase 2 — atoms preview',
        trailing: [
          AppIconButton(
            icon: Icons.color_lens_outlined,
            variant: AppIconButtonVariant.surfaceVariant,
            onPressed: () => _showPalettePicker(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        children: [
          const AppSectionLabel('Buttons'),
          _row([
            const Expanded(child: AppButton(label: 'Primary')),
          ]),
          const SizedBox(height: 8),
          AppButton.primaryWithArrow(label: 'Bayar', onPressed: () {}),
          const SizedBox(height: 8),
          _row([
            const Expanded(
                child: AppButton(label: 'Outline', variant: AppButtonVariant.outline)),
            const SizedBox(width: 12),
            const Expanded(
                child: AppButton(label: 'Ghost', variant: AppButtonVariant.ghost)),
          ]),
          const SizedBox(height: 8),
          _row([
            const Expanded(
                child: AppButton(label: 'Danger', variant: AppButtonVariant.danger)),
            const SizedBox(width: 12),
            const Expanded(
                child: AppButton(label: 'Loading', loading: true)),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              AppIconButton(icon: Icons.arrow_back, onPressed: () {}),
              AppIconButton(
                icon: Icons.calendar_today_outlined,
                variant: AppIconButtonVariant.surfaceVariant,
                onPressed: () {},
              ),
              AppIconButton(
                icon: Icons.share_outlined,
                variant: AppIconButtonVariant.surface,
                onPressed: () {},
              ),
            ],
          ),

          const AppSectionLabel('Text fields'),
          const AppTextField(
            label: 'Email',
            hint: 'kasir@cafe.id',
            leadingIcon: Icons.mail_outline,
          ),
          const SizedBox(height: 12),
          const AppTextField(
            label: 'Password',
            hint: '••••••••',
            leadingIcon: Icons.lock_outline,
            obscure: true,
          ),
          const SizedBox(height: 12),
          AppMoneyTextField(
            label: 'Modal awal kas',
            initialValue: _money,
            onChanged: (v) => setState(() => _money = v),
          ),

          const AppSectionLabel('Chips, badges, status'),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChip(label: 'Semua', active: true),
              AppChip(label: 'Kopi'),
              AppChip(label: 'Snack'),
              AppChip(label: 'Pas', variant: AppChipVariant.primary, active: true),
              AppChip(label: '+5rb', variant: AppChipVariant.primary),
            ],
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              AppStatusPill(label: 'LUNAS', kind: AppStatusKind.success, showDot: true),
              AppStatusPill(label: 'MENUNGGU', kind: AppStatusKind.warning, showDot: true, pulse: true),
              AppStatusPill(label: 'GAGAL', kind: AppStatusKind.error, showDot: true),
              AppStatusPill(label: 'BARU', kind: AppStatusKind.info),
            ],
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              AppBadge(label: 'Stok 4', kind: AppBadgeKind.stockLow),
              AppBadge(label: 'Habis', kind: AppBadgeKind.stockOut),
              AppBadge(label: 'BEST'),
              AppCountBadge(count: 3),
            ],
          ),

          const AppSectionLabel('Stepper'),
          Row(
            children: [
              AppStepper(
                qty: _stepperQty,
                onChanged: (v) => setState(() => _stepperQty = v),
              ),
              const SizedBox(width: 12),
              AppStepper(
                qty: _stepperQty,
                size: AppStepperSize.sm,
                onChanged: (v) => setState(() => _stepperQty = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppStepperField(
            value: _stockField,
            onChanged: (v) => setState(() => _stockField = v),
          ),

          const AppSectionLabel('Switches & segmented'),
          AppListGroup(children: [
            AppSwitchTile(
              title: 'Cetak struk closing',
              subtitle: 'Print otomatis saat tutup kasir',
              value: _switchA,
              onChanged: (v) => setState(() => _switchA = v),
            ),
            AppSwitchTile(
              title: 'Tandai sebagai Bestseller',
              value: _switchB,
              onChanged: (v) => setState(() => _switchB = v),
            ),
          ]),
          const SizedBox(height: 12),
          AppSegmentedToggle<String>(
            value: _env,
            onChanged: (v) => setState(() => _env = v),
            options: const [
              AppSegmentOption(value: 'sandbox', label: 'Sandbox', subtitle: 'Untuk testing'),
              AppSegmentOption(value: 'production', label: 'Production', subtitle: 'Transaksi asli'),
            ],
          ),
          const SizedBox(height: 12),
          AppSegmentedToggle<String>(
            value: _discountType,
            onChanged: (v) => setState(() => _discountType = v),
            options: const [
              AppSegmentOption(value: 'percent', label: 'Persen %'),
              AppSegmentOption(value: 'rupiah', label: 'Rupiah Rp'),
            ],
          ),

          const AppSectionLabel('Cards & groups'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card sederhana',
                  style: AppTypography.titleM.copyWith(color: p.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'Putih, 1px outlineSoft, R.md.',
                  style: AppTypography.bodyM.copyWith(color: p.onSurfaceVar),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const AppCard(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                AppKeyValueRow(label: 'Subtotal', value: 'Rp 67.000'),
                AppKeyValueRow(label: 'Pajak (10%)', value: 'Rp 6.700'),
                AppKeyValueRow(label: 'Diskon promo', value: '−Rp 5.000', variant: AppKVVariant.muted),
                AppKeyValueRow(label: 'Total', value: 'Rp 68.700', variant: AppKVVariant.big),
                AppKeyValueRow(label: 'Uang diterima', value: 'Rp 100.000', variant: AppKVVariant.highlight),
                AppKeyValueRow(label: 'Kembalian', value: 'Rp 31.300', variant: AppKVVariant.accent),
              ],
            ),
          ),

          const AppSectionLabel('Banners'),
          const AppBanner(
            kind: AppBannerKind.success,
            leadingIcon: Icons.check_circle_outline,
            title: 'Terhubung ke server',
            body: 'Terakhir sinkron: 2 jam lalu',
          ),
          const SizedBox(height: 8),
          const AppBanner(
            kind: AppBannerKind.warning,
            leadingIcon: Icons.warning_amber_rounded,
            title: 'Belum pernah sinkron',
            body: 'Data produk tersimpan di server, belum di-load ke perangkat ini.',
          ),
          const SizedBox(height: 8),
          const AppBanner(
            kind: AppBannerKind.error,
            leadingIcon: Icons.error_outline,
            title: 'Printer tidak terdeteksi',
            body: 'Cek koneksi Bluetooth dan pairing.',
          ),
          const SizedBox(height: 8),
          const AppBanner(
            kind: AppBannerKind.primary,
            leadingIcon: Icons.auto_awesome,
            title: 'Happy Hour Coffee aktif',
            body: '20% off · sampai 17:00 hari ini',
          ),

          const AppSectionLabel('Numbered steps'),
          AppCard(
            background: p.surfaceVariant,
            child: const Column(
              children: [
                AppNumberedStep(n: 1, text: 'Tambahkan menu di Home'),
                AppNumberedStep(n: 2, text: 'Buka keranjang, tekan Simpan Draft'),
                AppNumberedStep(n: 3, text: 'Draft muncul di halaman ini'),
                SizedBox(height: 8),
                AppNumberedStep(n: 1, text: 'Outlined variant', style: AppStepStyle.outlined),
              ],
            ),
          ),

          const AppSectionLabel('Domain helpers'),
          const Row(
            children: [
              ProductImg(name: 'Kopi Susu Gula Aren', hue: 28),
              SizedBox(width: 12),
              ProductImg(name: 'Matcha Latte', hue: 130, size: 72),
              SizedBox(width: 12),
              AppAvatar(name: 'Rina Astuti'),
              SizedBox(width: 12),
              AppAvatar(
                name: 'Kasir',
                kind: AppAvatarKind.primaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              MethodBadge(method: PaymentMethod.cash),
              SizedBox(width: 12),
              MethodBadge(method: PaymentMethod.qris),
              SizedBox(width: 12),
              MethodBadge(method: PaymentMethod.transfer),
              SizedBox(width: 20),
              BrandMark(size: 56),
            ],
          ),
          const SizedBox(height: 16),
          const Center(
            child: AppQrView(data: 'https://example.com/pay/123', size: 180),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tren 7 Hari',
                    style: AppTypography.titleM.copyWith(color: p.onSurface)),
                const SizedBox(height: 12),
                const AppTrendChart(
                  data: [12, 18, 14, 22, 28, 35, 26],
                  labels: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
                ),
              ],
            ),
          ),

          const AppSectionLabel('Feedback helpers'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppButton(
                label: 'Snackbar sukses',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.outline,
                fullWidth: false,
                onPressed: () => AppSnackbar.success(context, 'Tersimpan'),
              ),
              AppButton(
                label: 'Snackbar error',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.outline,
                fullWidth: false,
                onPressed: () =>
                    AppSnackbar.error(context, 'Gagal menyimpan'),
              ),
              AppButton(
                label: 'Confirm dialog',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.outline,
                fullWidth: false,
                onPressed: () async {
                  final ok = await AppConfirm.show(
                    context,
                    title: 'Hapus produk?',
                    body: 'Aksi ini tidak bisa dibatalkan.',
                    confirmLabel: 'Hapus',
                    destructive: true,
                  );
                  if (context.mounted) {
                    AppSnackbar.info(context, ok ? 'Dihapus' : 'Dibatalkan');
                  }
                },
              ),
              AppButton(
                label: 'Bottom sheet',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.outline,
                fullWidth: false,
                onPressed: () => _showSampleSheet(context),
              ),
            ],
          ),

          const AppSectionLabel('Empty state'),
          AppCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 360,
              child: AppEmptyState(
                visual: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: p.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.shopping_basket_outlined,
                    color: p.primary,
                    size: 40,
                  ),
                ),
                title: 'Keranjang kosong',
                body: 'Pilih menu dari halaman utama untuk mulai order.',
                primaryAction: AppButton(
                  label: 'Pilih menu',
                  fullWidth: false,
                  onPressed: () {},
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.huge),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStickyFooter(
            child: AppButton.primaryWithArrow(
              label: 'Sticky CTA',
              onPressed: () {},
            ),
          ),
          AppBottomNav.standard(
            activeIndex: _navTab,
            onTap: (i) => setState(() => _navTab = i),
            cartCount: 3,
          ),
        ],
      ),
    );
  }

  Widget _row(List<Widget> children) => Row(children: children);

  Future<void> _showSampleSheet(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      title: 'Simpan ke Draft',
      subtitle: 'Tandai order untuk dibayar nanti',
      bottomActions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Batal',
              variant: AppButtonVariant.outline,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AppButton(
              label: 'Simpan',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      child: const Column(
        children: [
          AppTextField(label: 'Meja / Lokasi', hint: 'cth. Meja 4 / Takeaway'),
          SizedBox(height: 12),
          AppTextField(label: 'Nama Pelanggan (opsional)'),
        ],
      ),
    );
  }

  void _showPalettePicker(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      title: 'Palette',
      child: Column(
        children: [
          for (final key in const ['caramel', 'espresso', 'matcha'])
            InkWell(
              onTap: () {
                context.read<ThemeBloc>().add(ThemeEvent.changed(key));
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppPalette.byKey(key).primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppPalette.byKey(key).name,
                      style: AppTypography.bodyL
                          .copyWith(color: context.palette.onSurface),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
