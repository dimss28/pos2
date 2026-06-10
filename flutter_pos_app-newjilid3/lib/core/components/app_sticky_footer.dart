import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Page footer that pins to the bottom of a `Scaffold.body`. Adds a 1px top
/// border in [AppPalette.outlineSoft] and respects safe-area insets.
///
/// Use when you have a sticky CTA but also want a bottom nav above the
/// system gesture pill — passing this in `bottomNavigationBar` is fine when
/// there is no [AppBottomNav] on the screen.
class AppStickyFooter extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppStickyFooter({
    super.key,
    required this.child,
    this.padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.outlineSoft)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
