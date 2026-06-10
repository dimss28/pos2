import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/brand_mark.dart';
import '../../../core/components/feedback.dart';
import '../../../core/services/printer_service.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../cash_session/bloc/cash_session/cash_session_bloc.dart';
import '../../cash_session/pages/buka_kasir_page.dart';
import '../../home/pages/dashboard_page.dart';
import '../../setting/bloc/sync/sync_bloc.dart';
import 'login_page.dart';

/// Post-auth router and bootstrap-sync gate.
///
/// Flow:
/// 1. Check token (SharedPreferences) — if absent → [LoginPage].
/// 2. Fire `SyncBloc.bootstrap()` and `CashSessionBloc.loaded()` in parallel.
/// 3. Wait for **both** to settle. Sync failures don't block: the app falls
///    back to whatever's cached locally. Shift errors do block (likely an
///    invalid token) → fall back to [LoginPage] with a snackbar.
/// 4. Route to [BukaKasirPage] or [DashboardPage] based on shift state.
///
/// While waiting, render the brand splash with a progress message that
/// reflects the current sync phase (Produk / Kategori / Order pending).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _routed = false;

  // Track whether each gate has resolved at least once.
  bool _syncBootstrapDone = false;
  bool _shiftResolved = false;
  // We see two Ready emits at boot: one from `refreshSnapshot` (which is
  // already idle so inProgress=null), and many from `bootstrap` (transient
  // inProgress for each pull, then null at the end). We must NOT route on
  // the first null — that's pre-bootstrap. Flip this once we've observed an
  // in-flight phase, so a subsequent null means real completion.
  bool _sawBootstrapInFlight = false;

  // Captured states (latest seen).
  CashSessionState _shiftState = const CashSessionState.initial();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final isAuth = await AuthLocalDatasource().isAuth();
    if (!mounted) return;
    if (!isAuth) {
      _replace(const LoginPage());
      return;
    }

    // Kick off both bootstrap operations. They run in parallel; gating
    // happens via the BlocListeners below.
    context.read<SyncBloc>().add(const SyncEvent.bootstrap());
    context.read<CashSessionBloc>().add(const CashSessionEvent.loaded());
    // Fire-and-forget printer autoconnect — failure here is silent; the
    // next actual print attempt will surface any real error.
    unawaited(PrinterService.instance.autoConnectSaved());
  }

  void _replace(Widget destination) {
    if (_routed) return;
    _routed = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  /// Try to route. Only triggers when both gates have resolved.
  void _maybeRoute() {
    if (_routed || !_syncBootstrapDone || !_shiftResolved) return;
    _shiftState.maybeWhen(
      open: (_) => _replace(const DashboardPage()),
      noSession: (_) => _replace(const BukaKasirPage()),
      error: (msg) {
        AppSnackbar.error(context, msg);
        _replace(const LoginPage());
      },
      orElse: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return MultiBlocListener(
      listeners: [
        BlocListener<SyncBloc, SyncState>(
          listener: (context, state) {
            state.maybeWhen(
              ready: (snap) {
                if (snap.inProgress != null) {
                  _sawBootstrapInFlight = true;
                  return;
                }
                // inProgress is null AND we've already seen an in-flight
                // phase — bootstrap finished. Without the seen-flag we'd
                // route on the pre-bootstrap `refreshSnapshot` emit.
                if (_sawBootstrapInFlight) {
                  _syncBootstrapDone = true;
                  _maybeRoute();
                }
              },
              orElse: () {},
            );
          },
        ),
        BlocListener<CashSessionBloc, CashSessionState>(
          listener: (context, state) {
            // Wait for any terminal-ish state.
            state.maybeWhen(
              open: (_) {
                _shiftResolved = true;
                _shiftState = state;
                _maybeRoute();
              },
              noSession: (_) {
                _shiftResolved = true;
                _shiftState = state;
                _maybeRoute();
              },
              error: (_) {
                _shiftResolved = true;
                _shiftState = state;
                _maybeRoute();
              },
              orElse: () {},
            );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: p.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 96),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'POS',
                style: AppTypography.titleL.copyWith(color: p.onSurface),
              ),
              const SizedBox(height: AppSpacing.huge),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: p.primary,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              BlocBuilder<SyncBloc, SyncState>(
                builder: (context, state) {
                  final phase = state.maybeWhen(
                    ready: (snap) => _phaseLabel(snap.inProgress),
                    orElse: () => 'Memuat...',
                  );
                  return Text(
                    phase,
                    style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _phaseLabel(String? domain) {
    switch (domain) {
      case 'products':
        return 'Sinkron produk...';
      case 'categories':
        return 'Sinkron kategori...';
      case 'orders':
        return 'Kirim order pending...';
      default:
        return 'Menyiapkan kasir...';
    }
  }
}
