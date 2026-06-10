import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Overlay drawn on top of `MobileScanner` to render the corner brackets
/// + animated scan line, plus a centred caption.
///
/// Maps to: `.claude/new-design/screens/scanner.jsx` viewport.
class ScannerOverlay extends StatefulWidget {
  final double viewport;

  const ScannerOverlay({super.key, this.viewport = 260});

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IgnorePointer(
      child: Stack(
        children: [
          // Vignette overlay using shrink-wrap CustomPaint for the cut-out
          Positioned.fill(
            child: CustomPaint(
              painter: _VignettePainter(viewport: widget.viewport),
            ),
          ),
          // Brackets + scan line
          Center(
            child: SizedBox(
              width: widget.viewport,
              height: widget.viewport,
              child: Stack(
                children: [
                  _Corner(alignment: Alignment.topLeft, color: p.primary),
                  _Corner(alignment: Alignment.topRight, color: p.primary),
                  _Corner(alignment: Alignment.bottomLeft, color: p.primary),
                  _Corner(alignment: Alignment.bottomRight, color: p.primary),
                  AnimatedBuilder(
                    animation: _c,
                    builder: (context, _) {
                      return Positioned(
                        left: 16,
                        right: 16,
                        top: 16 + (widget.viewport - 32) * _c.value,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: p.primary,
                            boxShadow: [
                              BoxShadow(
                                color: p.primary.withValues(alpha: 0.6),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

class _Corner extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  static const double _len = 28;
  static const double _thick = 3.5;

  const _Corner({required this.alignment, required this.color});

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: _len,
        height: _len,
        child: Stack(
          children: [
            Positioned(
              top: isTop ? 0 : null,
              bottom: isTop ? null : 0,
              left: isLeft ? 0 : null,
              right: isLeft ? null : 0,
              child: Container(width: _len, height: _thick, color: color),
            ),
            Positioned(
              top: isTop ? 0 : null,
              bottom: isTop ? null : 0,
              left: isLeft ? 0 : null,
              right: isLeft ? null : 0,
              child: Container(width: _thick, height: _len, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _VignettePainter extends CustomPainter {
  final double viewport;
  _VignettePainter({required this.viewport});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xE60A0703);
    final hole = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: viewport,
      height: viewport,
    );
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _VignettePainter old) =>
      old.viewport != viewport;
}
