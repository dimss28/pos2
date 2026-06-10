import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';

/// Groups a list of rows inside a single rounded card with 1px
/// [AppPalette.outlineSoft] separators between rows.
///
/// Maps to: settings tiles in `.claude/new-design/screens/settings.jsx`,
/// info rows in `.claude/new-design/screens/transaction-detail.jsx`.
class AppListGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final Color? background;
  final BorderRadius radius;

  const AppListGroup({
    super.key,
    required this.children,
    this.padding,
    this.background,
    this.radius = AppRadius.mdAll,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final divider = Container(height: 1, color: p.outlineSoft);

    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i < children.length - 1) separated.add(divider);
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: radius,
        border: Border.all(color: p.outlineSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: separated,
      ),
    );
  }
}
