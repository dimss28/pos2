import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_banner.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_sticky_footer.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/feedback.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/receipt_branding.dart';

/// Pengaturan branding struk thermal. Semua field opsional — kosongkan untuk
/// menyembunyikan baris di struk.
class ReceiptSettingsPage extends StatefulWidget {
  const ReceiptSettingsPage({super.key});

  @override
  State<ReceiptSettingsPage> createState() => _ReceiptSettingsPageState();
}

class _ReceiptSettingsPageState extends State<ReceiptSettingsPage> {
  final _store = TextEditingController();
  final _addr1 = TextEditingController();
  final _addr2 = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _footer1 = TextEditingController();
  final _footer2 = TextEditingController();
  final _taxPct = TextEditingController();

  String _logoB64 = '';
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _store.dispose();
    _addr1.dispose();
    _addr2.dispose();
    _email.dispose();
    _phone.dispose();
    _footer1.dispose();
    _footer2.dispose();
    _taxPct.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = AuthLocalDatasource();
    final b = await auth.getReceiptBranding();
    final tax = await auth.getTaxPercent();
    if (!mounted) return;
    setState(() {
      _store.text = b.storeName;
      _addr1.text = b.addressLine1;
      _addr2.text = b.addressLine2;
      _email.text = b.email;
      _phone.text = b.phone;
      _footer1.text = b.footerLine1;
      _footer2.text = b.footerLine2;
      _logoB64 = b.logoBase64;
      _taxPct.text = tax > 0 ? tax.toString() : '';
      _loaded = true;
    });
  }

  Future<void> _pickLogo() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (!mounted) return;
      AppSnackbar.error(
          context, 'Izin galeri ditolak. Aktifkan di Pengaturan.');
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 720,
    );
    if (picked == null || !mounted) return;
    try {
      final raw = await File(picked.path).readAsBytes();
      final decoded = img.decodeImage(raw);
      if (decoded == null) {
        if (!mounted) return;
        AppSnackbar.error(context, 'Format gambar tidak didukung');
        return;
      }
      // Resize to max width 360 (good for 80mm; will be re-sized down for 58
      // at print time). Encode as PNG so the thermal raster keeps crisp edges.
      final resized = img.copyResize(decoded, width: 360);
      final png = Uint8List.fromList(img.encodePng(resized));
      setState(() => _logoB64 = base64Encode(png));
    } catch (e) {
      dev.log('logo pick failed', name: 'ReceiptSettings', error: e);
      if (!mounted) return;
      AppSnackbar.error(context, 'Gagal memproses gambar: $e');
    }
  }

  void _removeLogo() => setState(() => _logoB64 = '');

  Future<void> _save() async {
    setState(() => _saving = true);
    final b = ReceiptBranding(
      storeName: _store.text.trim(),
      addressLine1: _addr1.text.trim(),
      addressLine2: _addr2.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      footerLine1: _footer1.text.trim(),
      footerLine2: _footer2.text.trim(),
      logoBase64: _logoB64,
    );
    final tax = int.tryParse(_taxPct.text.trim()) ?? 0;
    final auth = AuthLocalDatasource();
    await auth.saveReceiptBranding(b);
    await auth.setTaxPercent(tax);
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.success(context, 'Pengaturan struk tersimpan');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (!_loaded) {
      return Scaffold(
        backgroundColor: p.surface,
        appBar: const AppAppBar(title: 'Pengaturan Struk'),
        body: Center(child: CircularProgressIndicator(color: p.primary)),
      );
    }
    return Scaffold(
      backgroundColor: p.surface,
      appBar: const AppAppBar(
        title: 'Pengaturan Struk',
        subtitle: 'Logo, identitas toko, dan footer',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          const AppBanner(
            kind: AppBannerKind.info,
            leadingIcon: Icons.info_outline,
            title: 'Kosongkan kalau tidak ingin ditampilkan',
            body:
                'Field yang kosong otomatis disembunyikan dari struk pelanggan.',
          ),
          const AppSectionLabel('Logo struk'),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _LogoPreview(base64: _logoB64),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: _logoB64.isEmpty ? 'Pilih logo' : 'Ganti logo',
                        leadingIcon: Icons.image_outlined,
                        variant: AppButtonVariant.outline,
                        onPressed: _pickLogo,
                      ),
                    ),
                    if (_logoB64.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Hapus',
                          leadingIcon: Icons.delete_outline,
                          variant: AppButtonVariant.ghost,
                          onPressed: _removeLogo,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'PNG/JPG. Otomatis di-resize maksimal 360px (cocok 58 & 80 mm).',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
                ),
              ],
            ),
          ),
          const AppSectionLabel('Identitas toko'),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                AppTextField(
                  label: 'Nama toko',
                  hint: 'cth: Toko Anda',
                  controller: _store,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Alamat baris 1',
                  hint: 'cth: Jl. Palagan Tentara Pelajar No.2',
                  controller: _addr1,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Alamat baris 2',
                  hint: 'cth: Kab. Sleman, DI Yogyakarta',
                  controller: _addr2,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Email',
                  hint: 'cth: info@tokoanda.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Telepon',
                  hint: 'cth: 0856-4089-9224',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          const AppSectionLabel('Footer struk'),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                AppTextField(
                  label: 'Baris 1',
                  hint: 'cth: Password WiFi: tokoanda',
                  controller: _footer1,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Baris 2',
                  hint: 'cth: IG: @tokoanda',
                  controller: _footer2,
                ),
              ],
            ),
          ),
          const AppSectionLabel('Pajak (PB1)'),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Persentase pajak (%)',
                  hint: 'cth: 10 untuk PB1 10%. Kosongkan kalau tidak pakai',
                  controller: _taxPct,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pajak diterapkan ke subtotal sebelum total. Set 0 atau kosongkan kalau harga produk sudah termasuk pajak.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppStickyFooter(
        child: AppButton(
          label: 'Simpan',
          leadingIcon: Icons.save_outlined,
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ),
    );
  }
}

class _LogoPreview extends StatelessWidget {
  final String base64;
  const _LogoPreview({required this.base64});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (base64.isEmpty) {
      return Container(
        height: 110,
        decoration: BoxDecoration(
          color: p.surfaceVariant,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: p.outline, style: BorderStyle.solid),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: p.onSurfaceVar, size: 28),
            const SizedBox(height: 6),
            Text(
              'Belum ada logo',
              style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
            ),
          ],
        ),
      );
    }
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: p.outlineSoft),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Image.memory(
        base64Decode(base64),
        fit: BoxFit.contain,
      ),
    );
  }
}
