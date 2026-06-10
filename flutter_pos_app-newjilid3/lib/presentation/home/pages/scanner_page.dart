import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/components/feedback.dart';
import '../../../core/components/scanner_overlay.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/product/product_bloc.dart';

/// Full-screen barcode/QR scanner. On detection, searches the product
/// catalog and pops back so HomePage's filter updates.
///
/// Visual matches `.claude/new-design/screens/scanner.jsx`:
/// dark vignette + 4 corner brackets + animated scan line via
/// [ScannerOverlay]; top action row (close + torch + flip camera);
/// bottom hint banner.
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with WidgetsBindingObserver {
  final _controller = MobileScannerController(
    autoStart: false,
    torchEnabled: false,
    useNewCameraSelector: true,
  );

  StreamSubscription<BarcodeCapture>? _sub;
  bool _processed = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_bootstrap());
  }

  /// Request camera permission explicitly before starting the scanner.
  /// mobile_scanner does an implicit request internally, but doing it
  /// here lets us show a graceful "permission denied" state instead of a
  /// black screen if the user refuses.
  Future<void> _bootstrap() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() => _permissionDenied = true);
      return;
    }
    _sub = _controller.barcodes.listen(_onBarcode);
    unawaited(_controller.start());
  }

  void _onBarcode(BarcodeCapture capture) {
    if (_processed || !mounted) return;
    final code = capture.barcodes.firstOrNull?.displayValue;
    if (code == null || code.isEmpty) return;
    _processed = true;
    unawaited(_controller.stop());
    context.read<ProductBloc>().add(ProductEvent.searchProduct(code));
    AppSnackbar.info(context, 'Ditemukan: $code');
    Navigator.of(context).maybePop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _sub ??= _controller.barcodes.listen(_onBarcode);
        unawaited(_controller.start());
      case AppLifecycleState.inactive:
        unawaited(_sub?.cancel());
        _sub = null;
        unawaited(_controller.stop());
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_sub?.cancel());
    _sub = null;
    super.dispose();
    await _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) return _PermissionDeniedView();
    return Scaffold(
      backgroundColor: const Color(0xFF0E0A06),
      body: Stack(
        children: [
          MobileScanner(controller: _controller),
          const Positioned.fill(child: ScannerOverlay()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  _RoundDarkButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  Text(
                    'Scan Produk',
                    style: AppTypography.titleM.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, state, _) {
                      final on = state.torchState == TorchState.on;
                      return _RoundDarkButton(
                        icon: on
                            ? Icons.flash_on
                            : Icons.flash_off_outlined,
                        onTap: () => _controller.toggleTorch(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Arahkan kamera ke barcode atau QR',
                style:
                    AppTypography.bodyM.copyWith(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xE60E0A06)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: AppRadius.pillAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.palette.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mencari kode...',
                            style: AppTypography.labelM
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _BottomAction(
                            label: 'Balik kamera',
                            icon: Icons.cameraswitch_outlined,
                            onTap: () => _controller.switchCamera(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BottomAction(
                            label: 'Input manual',
                            icon: Icons.keyboard_outlined,
                            highlighted: true,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0A06),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _RoundDarkButton(
                  icon: Icons.close,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
              const Spacer(),
              Icon(Icons.no_photography_outlined,
                  size: 56, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              Text(
                'Akses kamera ditolak',
                style: AppTypography.titleM.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Untuk memindai barcode atau QR produk, izinkan akses '
                'kamera di pengaturan perangkat.',
                style: AppTypography.bodyM
                    .copyWith(color: Colors.white.withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: double.infinity,
                child: _BottomAction(
                  label: 'Buka Pengaturan',
                  icon: Icons.settings_outlined,
                  highlighted: true,
                  onTap: openAppSettings,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _BottomAction(
                  label: 'Input manual',
                  icon: Icons.keyboard_outlined,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundDarkButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundDarkButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;
  const _BottomAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = highlighted ? p.primary : Colors.white.withValues(alpha: 0.18);
    final fg = highlighted ? p.onPrimary : Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.mdAll,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelL
                  .copyWith(color: fg, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
