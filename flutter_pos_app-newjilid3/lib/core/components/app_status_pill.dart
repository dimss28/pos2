import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum AppStatusKind { success, warning, error, info, neutral }

/// Tiny container-tinted pill with optional leading dot.
///
/// Maps to: BALANCED (`.claude/new-design/screens/buka-kasir.jsx:120`),
/// LUNAS (`.claude/new-design/screens/transaction-detail.jsx`),
/// MENUNGGU (`.claude/new-design/screens/payment-qris.jsx`).
class AppStatusPill extends StatelessWidget {
  final String label;
  final AppStatusKind kind;
  final bool showDot;
  final bool pulse;

  const AppStatusPill({
    super.key,
    required this.label,
    this.kind = AppStatusKind.neutral,
    this.showDot = false,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg) = switch (kind) {
      AppStatusKind.success => (p.successContainer, p.success),
      AppStatusKind.warning => (p.warningContainer, const Color(0xFF7C4A0E)),
      AppStatusKind.error => (p.errorContainer, p.error),
      AppStatusKind.info => (p.primaryContainer, p.onPrimaryContainer),
      AppStatusKind.neutral => (p.surfaceVariant, p.onSurfaceVar),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            _Dot(color: fg, pulse: pulse),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTypography.labelM.copyWith(
              color: fg,
              fontSize: 11,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final Color color;
  final bool pulse;
  const _Dot({required this.color, required this.pulse});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    if (widget.pulse) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) {
      return Container(
        width: 6,
        height: 6,
        decoration:
            BoxDecoration(color: widget.color, shape: BoxShape.circle),
      );
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.5 + 0.5 * _c.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
