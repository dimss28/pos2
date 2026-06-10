import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';

/// Coffee-cup brand mark. Reproduces the SVG inline so it can be tinted
/// purely with palette tokens without bundling an SVG file.
///
/// Maps to: `BrandMark` in `.claude/new-design/screens/login.jsx:14-34`.
class BrandMark extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? accent;

  const BrandMark({
    super.key,
    this.size = 76,
    this.color,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = color ?? p.primary;
    final fg = accent ?? p.onPrimary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: _CoffeeCupPainter(color: fg),
        ),
      ),
    );
  }
}

class _CoffeeCupPainter extends CustomPainter {
  final Color color;
  _CoffeeCupPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24;
    Offset p(double x, double y) => Offset(x * scale, y * scale);

    // Steam
    stroke.strokeWidth = 1.5 * scale;
    final s1 = Path()
      ..moveTo(p(9, 2).dx, p(9, 2).dy)
      ..relativeCubicTo(
        -0.5 * scale, 1 * scale, 0.5 * scale, 1.5 * scale, 0,
        2.5 * scale,
      )
      ..relativeCubicTo(
        -0.5 * scale, 1 * scale, 0.5 * scale, 1.5 * scale, 0,
        2.5 * scale,
      );
    canvas.drawPath(s1, stroke);
    final s2 = Path()
      ..moveTo(p(13, 2).dx, p(13, 2).dy)
      ..relativeCubicTo(
        -0.5 * scale, 1 * scale, 0.5 * scale, 1.5 * scale, 0,
        2.5 * scale,
      )
      ..relativeCubicTo(
        -0.5 * scale, 1 * scale, 0.5 * scale, 1.5 * scale, 0,
        2.5 * scale,
      );
    canvas.drawPath(s2, stroke);

    // Cup body
    stroke.strokeWidth = 2 * scale;
    final cup = Path()
      ..moveTo(p(4, 10).dx, p(4, 10).dy)
      ..lineTo(p(17, 10).dx, p(17, 10).dy)
      ..lineTo(p(17, 16).dx, p(17, 16).dy)
      ..arcToPoint(
        p(12, 21),
        radius: Radius.circular(5 * scale),
        clockwise: true,
      )
      ..lineTo(p(9, 21).dx, p(9, 21).dy)
      ..arcToPoint(
        p(4, 16),
        radius: Radius.circular(5 * scale),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(cup, stroke);

    // Handle
    final handle = Path()
      ..moveTo(p(17, 12).dx, p(17, 12).dy)
      ..lineTo(p(19, 12).dx, p(19, 12).dy)
      ..arcToPoint(
        p(19, 17),
        radius: Radius.circular(2.5 * scale),
        clockwise: true,
      )
      ..lineTo(p(17, 17).dx, p(17, 17).dy);
    canvas.drawPath(handle, stroke);
  }

  @override
  bool shouldRepaint(covariant _CoffeeCupPainter old) => old.color != color;
}

/// Variant: brand mark inside a soft container (used on login Variation B's
/// hero band where the icon sits on the primary surface).
class BrandMarkSoft extends StatelessWidget {
  final double size;
  const BrandMarkSoft({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: _CoffeeCupPainter(color: p.onPrimary),
        ),
      ),
    );
  }
}
