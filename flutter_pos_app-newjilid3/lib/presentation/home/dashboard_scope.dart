import 'package:flutter/material.dart';

/// Lets child pages inside [DashboardPage] switch the active bottom-nav tab
/// without owning their own Navigator.
class DashboardScope extends InheritedWidget {
  final void Function(int index) switchTo;

  const DashboardScope({
    super.key,
    required this.switchTo,
    required super.child,
  });

  static DashboardScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DashboardScope>();

  /// Bottom-nav index for the table-order queue tab (QR guest orders).
  static const int tableOrdersTabIndex = 2;

  @override
  bool updateShouldNotify(DashboardScope oldWidget) =>
      switchTo != oldWidget.switchTo;
}
