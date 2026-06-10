import 'package:flutter/material.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_banner.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_segmented_toggle.dart';
import '../../../core/components/app_sticky_footer.dart';
import '../../../core/components/app_switch_tile.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/feedback.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/auth_local_datasource.dart';

class SaveServerKeyPage extends StatefulWidget {
  const SaveServerKeyPage({super.key});

  @override
  State<SaveServerKeyPage> createState() => _SaveServerKeyPageState();
}

class _SaveServerKeyPageState extends State<SaveServerKeyPage> {
  final _ctrl = TextEditingController();
  String _env = 'sandbox';
  bool _masked = true;
  bool _loaded = false;
  bool _saving = false;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final key = await AuthLocalDatasource().getMitransServerKey();
    final enabled = await AuthLocalDatasource().isMidtransEnabled();
    if (!mounted) return;
    setState(() {
      _ctrl.text = key;
      _env = key.startsWith('SB-') ? 'sandbox' : 'production';
      _enabled = enabled;
      _loaded = true;
    });
  }

  Future<void> _toggleEnabled(bool v) async {
    if (v && _ctrl.text.trim().isEmpty) {
      AppSnackbar.error(
          context, 'Simpan server key dulu sebelum mengaktifkan QRIS');
      return;
    }
    await AuthLocalDatasource().setMidtransEnabled(v);
    if (!mounted) return;
    setState(() => _enabled = v);
    AppSnackbar.success(
        context, v ? 'QRIS diaktifkan' : 'QRIS dinonaktifkan');
  }

  String _maskedDisplay() {
    final raw = _ctrl.text;
    if (raw.length <= 8) return raw;
    final head = raw.substring(0, 4);
    final tail = raw.substring(raw.length - 4);
    return '$head${'•' * (raw.length - 8)}$tail';
  }

  Future<void> _save() async {
    final key = _ctrl.text.trim();
    if (key.isEmpty) {
      AppSnackbar.error(context, 'Masukkan server key dulu');
      return;
    }
    setState(() => _saving = true);
    await AuthLocalDatasource().saveMidtransServerKey(key);
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.success(context, 'Server key tersimpan');
    Navigator.of(context).maybePop();
  }

  Future<void> _delete() async {
    final ok = await AppConfirm.show(
      context,
      title: 'Hapus server key?',
      body: 'Pembayaran QRIS akan dinonaktifkan sampai key baru diatur.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await AuthLocalDatasource().saveMidtransServerKey('');
    await AuthLocalDatasource().setMidtransEnabled(false);
    if (!mounted) return;
    setState(() {
      _ctrl.clear();
      _enabled = false;
    });
    AppSnackbar.info(context, 'Server key dihapus, QRIS dinonaktifkan');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasKey = _ctrl.text.isNotEmpty;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: const AppAppBar(
        title: 'Pembayaran QRIS',
        subtitle: 'Konfigurasi token gateway pembayaran',
      ),
      body: !_loaded
          ? Center(child: CircularProgressIndicator(color: p.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                const AppBanner(
                  kind: AppBannerKind.info,
                  leadingIcon: Icons.info_outline,
                  title: 'Aktifkan pembayaran QRIS',
                  body:
                      'QRIS dibangkitkan via gateway pembayaran. Token disimpan '
                      'di perangkat ini dan dipakai hanya saat checkout. '
                      'Bisa dinonaktifkan kapan saja.',
                ),
                const AppSectionLabel('Pembayaran QRIS'),
                AppSwitchTile(
                  title: 'Aktifkan QRIS saat checkout',
                  subtitle: _enabled
                      ? 'Pelanggan bisa pilih bayar QR di order'
                      : 'Bayar QR akan disembunyikan di order',
                  value: _enabled,
                  onChanged: _toggleEnabled,
                ),
                const AppSectionLabel('Status token'),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: hasKey ? p.success : p.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hasKey ? 'Key tersimpan' : 'Belum ada key',
                              style: AppTypography.bodyL.copyWith(
                                color: p.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasKey ? _maskedDisplay() : '—',
                              style: AppTypography.bodyS.copyWith(
                                color: p.onSurfaceVar,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (hasKey)
                        TextButton(
                          onPressed: _delete,
                          child: Text(
                            'Hapus',
                            style: AppTypography.labelL
                                .copyWith(color: p.error),
                          ),
                        ),
                    ],
                  ),
                ),
                const AppSectionLabel('Environment'),
                AppSegmentedToggle<String>(
                  value: _env,
                  onChanged: (v) => setState(() => _env = v),
                  options: const [
                    AppSegmentOption(
                        value: 'sandbox',
                        label: 'Sandbox',
                        subtitle: 'Untuk testing'),
                    AppSegmentOption(
                        value: 'production',
                        label: 'Production',
                        subtitle: 'Transaksi asli'),
                  ],
                ),
                const AppSectionLabel('Token Gateway'),
                AppTextField(
                  hint: _env == 'sandbox'
                      ? 'Server key sandbox dari dashboard Midtrans'
                      : 'Server key production dari dashboard Midtrans',
                  controller: _ctrl,
                  leadingIcon: Icons.key_outlined,
                  obscure: _masked,
                  valueStyle: AppTypography.bodyL.copyWith(
                    color: p.onSurface,
                    fontFamily: 'monospace',
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      _masked
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: p.onSurfaceVar,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _masked = !_masked),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.lock_outline,
                        size: 14, color: p.onSurfaceVar),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Token bersifat rahasia. Disimpan di perangkat ini saja '
                        'dan tidak dikirim ke server kami.',
                        style: AppTypography.bodyS.copyWith(
                          color: p.onSurfaceVar,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: AppStickyFooter(
        child: AppButton(
          label: 'Simpan Token',
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ),
    );
  }
}
