import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'app_badge.dart';

class AppBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int badge;

  const AppBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge = 0,
  });
}

/// Material 3-style bottom navigation matching `BottomNav`
/// in `.claude/new-design/screens/home.jsx:510`.
///
/// Active pill: `primaryContainer` background, `onPrimaryContainer` icon.
class AppBottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
    required this.items,
  });

  /// Convenience constructor for the standard 5-tab POS shell.
  factory AppBottomNav.standard({
    Key? key,
    required int activeIndex,
    required ValueChanged<int> onTap,
    int cartCount = 0,
    int tableOrderCount = 0,
    int pendingSync = 0,
  }) {
    return AppBottomNav(
      key: key,
      activeIndex: activeIndex,
      onTap: onTap,
      items: [
        const AppBottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: 'Home',
        ),
        AppBottomNavItem(
          icon: Icons.shopping_cart_outlined,
          activeIcon: Icons.shopping_cart_rounded,
          label: 'Order',
          badge: cartCount,
        ),
        AppBottomNavItem(
          icon: Icons.restaurant_menu_outlined,
          activeIcon: Icons.restaurant_menu,
          label: 'Meja',
          badge: tableOrderCount,
        ),
        const AppBottomNavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          label: 'Riwayat',
        ),
        AppBottomNavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
          label: 'Setting',
          badge: pendingSync,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.outlineSoft)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavCell(
                      item: items[i],
                      active: i == activeIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  final AppBottomNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavCell({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? p.primaryContainer
                        : Colors.transparent,
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Icon(
                    active && item.activeIcon != null
                        ? item.activeIcon
                        : item.icon,
                    size: 20,
                    color: active ? p.onPrimaryContainer : p.onSurface,
                  ),
                ),
                if (item.badge > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: AppCountBadge(
                      count: item.badge,
                      background: p.error,
                      foreground: Colors.white,
                      border: p.surface,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: AppTypography.labelM.copyWith(
                color: active ? p.onSurface : p.onSurfaceVar,
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
