import 'package:flutter/material.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_banner.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/payment_settings_remote_datasource.dart';
import '../../../data/models/response/payment_settings_model.dart';

/// Status QRIS dari server — konfigurasi hanya di web admin (Pengaturan Toko).
class SaveServerKeyPage extends StatefulWidget {
  const SaveServerKeyPage({super.key});

  @override
  State<SaveServerKeyPage> createState() => _SaveServerKeyPageState();
}

class _SaveServerKeyPageState extends State<SaveServerKeyPage> {
  final _ds = PaymentSettingsRemoteDatasource();
  PaymentSettingsModel? _settings;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await _ds.fetch();
      if (!mounted) return;
      setState(() {
        _settings = s;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = _settings;
    final active = s?.qrisAvailable ?? false;

    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppAppBar(
        title: 'Pembayaran QRIS',
        subtitle: 'Dikelola dari server',
        trailing: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: p.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const AppBanner(
                  kind: AppBannerKind.info,
                  leadingIcon: Icons.cloud_outlined,
                  title: 'QRIS terpusat di server',
                  body:
                      'Server Key Midtrans diatur sekali di web admin '
                      '(Pengaturan Toko). Berlaku untuk kasir di app ini '
                      'dan pelanggan yang scan QR meja.',
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: p.error)),
                ],
                const AppSectionLabel('Status'),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      AppStatusPill(
                        label: active ? 'AKTIF' : 'NONAKTIF',
                        kind: active
                            ? AppStatusKind.success
                            : AppStatusKind.warning,
                        showDot: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          active
                              ? 'QRIS tersedia saat checkout'
                              : 'QRIS belum siap — cek Pengaturan Toko',
                          style: AppTypography.bodyL.copyWith(
                            color: p.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const AppSectionLabel('Detail'),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row(p, 'QRIS diaktifkan', s?.qrisEnabled == true),
                      _row(p, 'Server key terpasang',
                          s?.midtransConfigured == true),
                      const SizedBox(height: 8),
                      Text(
                        'Environment: ${s?.environment ?? '—'}',
                        style: AppTypography.bodyS
                            .copyWith(color: p.onSurfaceVar),
                      ),
                    ],
                  ),
                ),
                const AppSectionLabel('Untuk admin / owner'),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Login ke web admin → menu Pengaturan Toko:\n'
                    '1. Centang Aktifkan QRIS\n'
                    '2. Isi Server Key Midtrans\n'
                    '3. Pilih Sandbox atau Production\n'
                    '4. Simpan',
                    style: AppTypography.bodyS.copyWith(
                      color: p.onSurfaceVar,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Perbarui status',
                  variant: AppButtonVariant.outline,
                  onPressed: _load,
                ),
              ],
            ),
    );
  }

  Widget _row(AppPalette p, String label, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 18,
            color: ok ? p.success : p.onSurfaceVar,
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.bodyS.copyWith(color: p.onSurface)),
        ],
      ),
    );
  }
}
