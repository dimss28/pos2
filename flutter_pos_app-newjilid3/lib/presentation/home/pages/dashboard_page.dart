import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_bottom_nav.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/datasources/table_order_remote_datasource.dart';
import '../../history/pages/history_page.dart';
import '../../order/pages/order_page.dart';
import '../../setting/bloc/sync/sync_bloc.dart';
import '../../setting/pages/setting_page.dart';
import '../../setting/pages/table_orders_page.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../dashboard_scope.dart';
import 'home_page.dart';

/// Bottom-nav shell after a shift is opened. Hosts Home / Order / Meja /
/// History / Setting; nav badges from cart qty, table orders, and sync queue.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _index = 0;
  int _tableOrderCount = 0;

  final _orderKey = GlobalKey<OrderPageState>();
  final _tableOrdersKey = GlobalKey<TableOrdersPageState>();

  late final List<Widget> _pages = <Widget>[
    const HomePage(),
    OrderPage(key: _orderKey),
    TableOrdersPage(
      key: _tableOrdersKey,
      onQueueChanged: _refreshTableOrderCount,
    ),
    const HistoryPage(),
    const SettingPage(),
  ];

  @override
  void initState() {
    super.initState();
    _refreshTableOrderCount();
  }

  Future<void> _refreshTableOrderCount() async {
    final count = await TableOrderRemoteDatasource().pendingCount();
    if (mounted) setState(() => _tableOrderCount = count);
  }

  void _switchTo(int i) {
    if (i < 0 || i >= _pages.length) return;
    setState(() => _index = i);
    if (i == 1) _orderKey.currentState?.refreshQrisAvailability();
    if (i == DashboardScope.tableOrdersTabIndex) {
      _tableOrdersKey.currentState?.refresh();
      _refreshTableOrderCount();
    }
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
                  tableOrderCount: _tableOrderCount,
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
