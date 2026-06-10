import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_banner.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_numbered_step.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_segmented_toggle.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/components/app_sticky_footer.dart';
import '../../../core/components/feedback.dart';
import '../../../core/services/printer_service.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/auth_local_datasource.dart';

class ManagePrinterPage extends StatefulWidget {
  const ManagePrinterPage({super.key});

  @override
  State<ManagePrinterPage> createState() => _ManagePrinterPageState();
}

class _ManagePrinterPageState extends State<ManagePrinterPage> {
  List<BluetoothInfo> _devices = const [];
  String _activeMac = '';
  bool _connected = false;
  bool _scanning = false;
  String? _connectingMac;
  String? _permissionError;
  String _paperSize = '58';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final savedMac = await AuthLocalDatasource().getPrinter();
    final savedPaper = await AuthLocalDatasource().getPaperSize();
    if (!mounted) return;
    setState(() {
      _activeMac = savedMac;
      _paperSize = savedPaper;
    });
    // Reflect actual link state (boot autoconnect may already have linked it).
    final live = await PrinterService.instance.isConnected();
    if (mounted) setState(() => _connected = live && savedMac.isNotEmpty);
    await _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _scanning = true;
      _permissionError = null;
    });
    try {
      var status = await Permission.bluetoothScan.status;
      if (status.isDenied) status = await Permission.bluetoothScan.request();
      var connectStatus = await Permission.bluetoothConnect.status;
      if (connectStatus.isDenied) {
        connectStatus = await Permission.bluetoothConnect.request();
      }
      if (!status.isGranted || !connectStatus.isGranted) {
        if (!mounted) return;
        setState(() {
          _scanning = false;
          _permissionError = 'Izin Bluetooth ditolak';
        });
        return;
      }
      final list = await PrintBluetoothThermal.pairedBluetooths;
      if (!mounted) return;
      setState(() {
        _devices = list;
        _scanning = false;
      });
    } on PlatformException catch (e) {
      dev.log('printer scan failed', name: 'ManagePrinterPage', error: e);
      if (!mounted) return;
      setState(() => _scanning = false);
      AppSnackbar.error(context, 'Gagal scan: ${e.message}');
    }
  }

  Future<void> _connect(String mac) async {
    if (_connectingMac != null) return; // ignore taps while connecting
    setState(() => _connectingMac = mac);
    try {
      // If a different printer is already linked, drop it first so the
      // ESC/POS session targets the newly selected device.
      if (_activeMac.isNotEmpty && _activeMac != mac) {
        await PrinterService.instance.disconnect();
      }
      final ok = await PrinterService.instance.connect(mac);
      if (!mounted) return;
      if (ok) {
        await AuthLocalDatasource().savePrinter(mac);
        if (!mounted) return;
        setState(() {
          _activeMac = mac;
          _connected = true;
        });
        AppSnackbar.success(context, 'Printer terhubung');
      } else {
        AppSnackbar.error(
          context,
          'Gagal koneksi printer. Pastikan printer menyala dan dalam jangkauan.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Gagal koneksi: $e');
    } finally {
      if (mounted) setState(() => _connectingMac = null);
    }
  }

  Future<void> _disconnect() async {
    try {
      await PrinterService.instance.disconnect();
      await AuthLocalDatasource().savePrinter('');
      if (!mounted) return;
      setState(() {
        _activeMac = '';
        _connected = false;
      });
      AppSnackbar.info(context, 'Printer dilepas');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Gagal disconnect: $e');
    }
  }

  Future<void> _changePaper(String size) async {
    setState(() => _paperSize = size);
    await AuthLocalDatasource().savePaperSize(size);
    if (mounted) AppSnackbar.info(context, 'Ukuran kertas: $size mm');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: const AppAppBar(
        title: 'Printer Thermal',
        subtitle: 'Pilih printer untuk cetak struk',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _connected
              ? AppBanner(
                  kind: AppBannerKind.success,
                  leadingIcon: Icons.print_outlined,
                  title: 'Printer tersambung',
                  body: _activeMac,
                  trailing: TextButton(
                    onPressed: _disconnect,
                    child: Text(
                      'Lepas',
                      style: AppTypography.labelL.copyWith(color: p.error),
                    ),
                  ),
                )
              : const AppBanner(
                  kind: AppBannerKind.warning,
                  leadingIcon: Icons.print_disabled_outlined,
                  title: 'Belum ada printer tersambung',
                  body:
                      'Struk akan disimpan sebagai PDF sampai printer di-pair.',
                ),
          if (_permissionError != null) ...[
            const SizedBox(height: 12),
            const AppBanner(
              kind: AppBannerKind.error,
              leadingIcon: Icons.lock_outline,
              title: 'Izin Bluetooth diperlukan',
              body: 'Buka Pengaturan untuk berikan akses scan + connect.',
              trailing: AppButton(
                label: 'Buka',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.outline,
                fullWidth: false,
                onPressed: openAppSettings,
              ),
            ),
          ],
          const AppSectionLabel('Ukuran kertas'),
          AppCard(
            padding: const EdgeInsets.all(12),
            child: AppSegmentedToggle<String>(
              value: _paperSize,
              onChanged: _changePaper,
              options: const [
                AppSegmentOption(value: '58', label: '58 mm', subtitle: 'Default thermal'),
                AppSegmentOption(value: '80', label: '80 mm', subtitle: 'Lebar — kitchen / kasir'),
              ],
            ),
          ),
          const AppSectionLabel('Perangkat tersedia'),
          if (_scanning)
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: p.primary),
                    const SizedBox(height: 12),
                    Text('Mencari perangkat...',
                        style: AppTypography.bodyM
                            .copyWith(color: p.onSurfaceVar)),
                  ],
                ),
              ),
            )
          else if (_devices.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.bluetooth_disabled,
                      color: p.onSurfaceVar, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada perangkat ditemukan',
                    style: AppTypography.bodyL.copyWith(color: p.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pastikan printer dalam jangkauan dan dalam mode pairing.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyS
                        .copyWith(color: p.onSurfaceVar),
                  ),
                ],
              ),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _devices.length; i++) ...[
                    _DeviceRow(
                      device: _devices[i],
                      active: _devices[i].macAdress == _activeMac && _connected,
                      connecting: _devices[i].macAdress == _connectingMac,
                      disabled: _connectingMac != null &&
                          _connectingMac != _devices[i].macAdress,
                      onTap: () => _connect(_devices[i].macAdress),
                    ),
                    if (i < _devices.length - 1)
                      Container(height: 1, color: p.outlineSoft),
                  ],
                ],
              ),
            ),
          const AppSectionLabel('Cara pairing'),
          const AppCard(
            padding: EdgeInsets.all(14),
            child: Column(
              children: [
                AppNumberedStep(n: 1, text: 'Nyalakan printer thermal'),
                AppNumberedStep(n: 2, text: 'Aktifkan Bluetooth di HP'),
                AppNumberedStep(
                    n: 3,
                    text: 'Tekan Pindai untuk mulai mencari, lalu tap nama printer'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppStickyFooter(
        child: AppButton(
          label: _scanning ? 'Memindai...' : 'Pindai perangkat',
          leadingIcon: Icons.search,
          loading: _scanning,
          onPressed: _scanning ? null : _scan,
        ),
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final BluetoothInfo device;
  final bool active;
  final bool connecting;
  final bool disabled;
  final VoidCallback onTap;

  const _DeviceRow({
    required this.device,
    required this.active,
    required this.connecting,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: InkWell(
        onTap: (disabled || connecting) ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.primaryContainer,
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.bluetooth, color: p.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      device.name,
                      style: AppTypography.bodyL.copyWith(
                        color: p.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      device.macAdress,
                      style: AppTypography.bodyS.copyWith(
                        color: p.onSurfaceVar,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (connecting)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: p.primary,
                  ),
                )
              else if (active)
                const AppStatusPill(
                  label: 'TERPILIH',
                  kind: AppStatusKind.success,
                  showDot: true,
                )
              else
                Icon(Icons.chevron_right, color: p.onSurfaceVar),
            ],
          ),
        ),
      ),
    );
  }
}
