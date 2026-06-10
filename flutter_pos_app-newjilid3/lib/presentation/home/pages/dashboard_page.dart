import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_bottom_nav.dart';
import '../../../core/theme/app_palette.dart';
import '../../history/pages/history_page.dart';
import '../../order/pages/order_page.dart';
import '../../setting/bloc/sync/sync_bloc.dart';
import '../../setting/pages/setting_page.dart';
import '../bloc/checkout/checkout_bloc.dart';
import 'home_page.dart';

/// Bottom-nav shell after a shift is opened. Hosts Home / Order / History
/// / Setting; nav badges are wired live from [CheckoutBloc] (cart qty) and
/// [SyncBloc] (pending order push count).
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _index = 0;

  final _orderKey = GlobalKey<OrderPageState>();

  late final List<Widget> _pages = <Widget>[
    const HomePage(),
    OrderPage(key: _orderKey),
    const HistoryPage(),
    const SettingPage(),
  ];

  void _switchTo(int i) {
    if (i < 0 || i >= _pages.length) return;
    setState(() => _index = i);
    if (i == 1) _orderKey.currentState?.refreshQrisAvailability();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DashboardScope(
      switchTo: _switchTo,
      child: Scaffold(
        backgroundColor: p.surface,
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar:
            BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, checkoutState) {
            final cartCount = checkoutState.maybeWhen(
              success: (summary) => summary.totalQuantity,
              orElse: () => 0,
            );
            return BlocBuilder<SyncBloc, SyncState>(
              builder: (context, syncState) {
                final pending = syncState.maybeWhen(
                  ready: (s) => s.pendingOrderCount,
                  orElse: () => 0,
                );
                return AppBottomNav.standard(
                  activeIndex: _index,
                  onTap: _switchTo,
                  cartCount: cartCount,
                  pendingSync: pending,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Lets child pages inside DashboardPage switch the active bottom-nav tab
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

  @override
  bool updateShouldNotify(DashboardScope oldWidget) =>
      switchTo != oldWidget.switchTo;
}
