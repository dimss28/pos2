import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../theme/app_palette.dart';

/// Wraps [QrImageView] with the redesign defaults: white background,
/// onSurface modules, optional centre brand-letter overlay.
///
/// Replaces `FauxQR` in `.claude/new-design/screens/payment-qris.jsx`.
class AppQrView extends StatelessWidget {
  final String data;
  final double size;

  /// One-letter brand mark drawn in the centre. Pass null to skip.
  final String? brandLetter;

  const AppQrView({
    super.key,
    required this.data,
    this.size = 220,
    this.brandLetter = 'K',
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: size,
            backgroundColor: Colors.white,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: p.onSurface,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: p.onSurface,
            ),
            errorCorrectionLevel: QrErrorCorrectLevel.H,
          ),
          if (brandLetter != null)
            Container(
              width: size * 0.20,
              height: size * 0.20,
              decoration: BoxDecoration(
                color: p.primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                brandLetter!,
                style: TextStyle(
                  color: p.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
