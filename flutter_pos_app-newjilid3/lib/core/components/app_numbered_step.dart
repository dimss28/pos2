import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

enum AppStepStyle { filled, outlined }

/// Numbered step row used in explainer cards.
/// Filled circle: `.claude/new-design/screens/draft-order-empty.jsx`,
/// `.claude/new-design/screens/printer.jsx`.
/// Outlined circle: `.claude/new-design/screens/order-detail-empty.jsx`.
class AppNumberedStep extends StatelessWidget {
  final int n;
  final String text;
  final AppStepStyle style;

  const AppNumberedStep({
    super.key,
    required this.n,
    required this.text,
    this.style = AppStepStyle.filled,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final filled = style == AppStepStyle.filled;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: filled ? p.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: filled
                  ? null
                  : Border.all(color: p.primary, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '$n',
              style: AppTypography.labelM.copyWith(
                color: filled ? p.onPrimary : p.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                text,
                style: AppTypography.bodyM.copyWith(color: p.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
