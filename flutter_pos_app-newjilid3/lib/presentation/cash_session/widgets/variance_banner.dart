import 'package:flutter/material.dart';

import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

/// Container-colored banner showing live variance below the physical-cash
/// input. Three states:
/// - variance == 0 → success ("BALANCED")
/// - variance != 0 → warning with magnitude + direction
/// - physical not entered yet → neutral hint
///
/// Maps to the variance card in `.claude/new-design/screens/close-kasir.jsx:106`.
class VarianceBanner extends StatelessWidget {
  /// physical - expected. Null = user hasn't entered physical yet.
  final int? variance;

  const VarianceBanner({super.key, required this.variance});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (variance == null) {
      return _Card(
        bg: p.surfaceVariant,
        icon: Icons.info_outline,
        iconBg: p.onSurfaceVar.withValues(alpha: 0.18),
        iconFg: p.onSurfaceVar,
        title: 'Masukkan kas fisik untuk menghitung selisih',
        body: 'Hitung total uang fisik di laci kasir saat ini.',
        titleColor: p.onSurface,
        bodyColor: p.onSurfaceVar,
      );
    }

    if (variance == 0) {
      return _Card(
        bg: p.successContainer,
        icon: Icons.check_circle_outline,
        iconBg: p.success,
        iconFg: Colors.white,
        title: 'BALANCED — kas fisik sesuai estimasi',
        body: 'Tidak ada selisih, siap ditutup.',
        titleColor: p.success,
        bodyColor: p.onSurface,
      );
    }

    final isShort = variance! < 0;
    final magnitude = variance!.abs().currencyFormatRp.trim();
    final headline = isShort
        ? 'Selisih kurang $magnitude'
        : 'Selisih lebih $magnitude';
    final hint = isShort
        ? 'Hitung ulang atau jelaskan di catatan.'
        : 'Kelebihan kas — jelaskan di catatan.';

    return _Card(
      bg: p.warningContainer,
      icon: Icons.error_outline,
      iconBg: p.warning,
      iconFg: Colors.white,
      title: headline,
      body: hint,
      titleColor: const Color(0xFF7C4A0E),
      bodyColor: const Color(0xFF8A5A20),
    );
  }
}

class _Card extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String body;
  final Color titleColor;
  final Color bodyColor;

  const _Card({
    required this.bg,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.body,
    required this.titleColor,
    required this.bodyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: iconFg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.labelL.copyWith(
                    color: titleColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  body,
                  style: AppTypography.bodyS.copyWith(
                    color: bodyColor,
                    fontSize: 11,
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
