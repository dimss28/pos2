import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'core/services/auth_interceptor.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/midtrans_remote_datasource.dart';
import 'data/datasources/product_local_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/report_remote_datasource.dart';
import 'presentation/auth/bloc/delete_account/delete_account_bloc.dart';
import 'presentation/auth/bloc/login/login_bloc.dart';
import 'presentation/auth/pages/login_page.dart';
import 'presentation/auth/pages/splash_page.dart';
import 'presentation/cash_session/bloc/cash_session/cash_session_bloc.dart';
import 'presentation/connectivity/bloc/connectivity/connectivity_bloc.dart';
import 'presentation/draft_order/bloc/draft_order/draft_order_bloc.dart';
import 'presentation/history/bloc/history/history_bloc.dart';
import 'presentation/home/bloc/category/category_bloc.dart';
import 'presentation/home/bloc/checkout/checkout_bloc.dart';
import 'presentation/home/bloc/logout/logout_bloc.dart';
import 'presentation/home/bloc/product/product_bloc.dart';
import 'presentation/order/bloc/order/order_bloc.dart';
import 'presentation/order/bloc/qris/qris_bloc.dart';
import 'presentation/promo/bloc/promo/promo_bloc.dart';
import 'presentation/refund/bloc/refund/refund_bloc.dart';
import 'presentation/setting/bloc/report/close_cashier/close_cashier_bloc.dart';
import 'presentation/setting/bloc/report/product_sales/product_sales_bloc.dart';
import 'presentation/setting/bloc/report/summary/summary_bloc.dart';
import 'presentation/setting/bloc/sync/sync_bloc.dart';
import 'presentation/setting/bloc/theme/theme_bloc.dart';

/// Navigator key global supaya AuthInterceptor bisa redirect ke LoginPage
/// dari handler 401 tanpa context dari widget tree spesifik.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  // Warmup cache tax % supaya UI rebuild order_page sync (tidak butuh await).
  await AuthLocalDatasource().getTaxPercent();
  if (kDebugMode) Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<void> _unauthorizedSub;

  @override
  void initState() {
    super.initState();
    // Auto-logout saat ada response 401 dari API. Pattern: kalau token Sanctum
    // di-revoke BE (logout di device lain, password berubah, akun dinonaktifkan,
    // atau token expire 90 hari), FE auto-clear auth data + redirect ke login.
    _unauthorizedSub = AuthInterceptor.instance.onUnauthorized.listen((_) async {
      await AuthLocalDatasource().removeAuthData();
      final nav = rootNavigatorKey.currentState;
      if (nav == null) return;
      // Kalau sudah di LoginPage, jangan stack lagi.
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _unauthorizedSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc()..add(const ThemeEvent.loaded()),
        ),
        BlocProvider(
          create: (context) => LoginBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => LogoutBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => DeleteAccountBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => ProductBloc(ProductRemoteDatasource()),
        ),
        BlocProvider(create: (context) => CheckoutBloc()),
        BlocProvider(create: (context) => OrderBloc()),
        BlocProvider(
          create: (context) => QrisBloc(MidtransRemoteDatasource()),
        ),
        BlocProvider(create: (context) => HistoryBloc()),
        BlocProvider(
          create: (context) => CategoryBloc(ProductRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => DraftOrderBloc(ProductLocalDatasource.instance),
        ),
        BlocProvider(
          create: (context) => SummaryBloc(ReportRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => ProductSalesBloc(ReportRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CloseCashierBloc(ReportRemoteDatasource()),
        ),
        BlocProvider(create: (context) => CashSessionBloc()),
        BlocProvider(create: (context) => RefundBloc()),
        BlocProvider(
          create: (context) =>
              SyncBloc()..add(const SyncEvent.refreshSnapshot()),
        ),
        BlocProvider(
          create: (context) =>
              PromoBloc()..add(const PromoEvent.loadFromCache()),
        ),
        BlocProvider(
          create: (context) =>
              ConnectivityBloc()..add(const ConnectivityEvent.started()),
        ),
      ],
      // Auto-sync hook: when connectivity flips from offline → online,
      // push any pending orders + refresh promo catalog in the background.
      child: BlocListener<ConnectivityBloc, ConnectivityState>(
        listenWhen: (prev, next) =>
            next.maybeWhen(restored: () => true, orElse: () => false),
        listener: (context, _) {
          context.read<SyncBloc>().add(const SyncEvent.pushOrders());
          context.read<SyncBloc>().add(const SyncEvent.pullPromos());
        },
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final palette = AppPalette.byKey(themeState.paletteKey);
            return MaterialApp(
              navigatorKey: rootNavigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'POS',
              theme: AppTheme.fromPalette(palette),
              home: const SplashPage(),
            );
          },
        ),
      ),
    );
  }
}
