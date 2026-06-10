import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

/// Single shift card in the 3-up picker on BukaKasirPage.
/// Active state shows a tick badge on the top-right.
class ShiftOptionCard extends StatelessWidget {
  final String label;
  final String time;
  final bool active;
  final VoidCallback onTap;

  const ShiftOptionCard({
    super.key,
    required this.label,
    required this.time,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: active ? p.primaryContainer : Colors.white,
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: active ? p.primary : p.outlineSoft,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: AppTypography.labelL.copyWith(
                    color: active ? p.onPrimaryContainer : p.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTypography.bodyS.copyWith(
                    color: active ? p.primary : p.onSurfaceVar,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (active)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: p.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.surface, width: 2),
                ),
                child: Icon(
                  Icons.check,
                  size: 11,
                  color: p.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
