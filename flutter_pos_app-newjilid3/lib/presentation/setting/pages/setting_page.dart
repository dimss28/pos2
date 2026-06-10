import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_list_group.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/components/avatar.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/datasources/payment_settings_remote_datasource.dart';
import '../../../data/datasources/table_order_remote_datasource.dart';
import '../../../data/models/response/auth_response_model.dart';
import '../../auth/bloc/delete_account/delete_account_bloc.dart';
import '../../auth/pages/login_page.dart';
import '../../cash_session/bloc/cash_session/cash_session_bloc.dart';
import '../../cash_session/pages/tutup_kasir_page.dart';
import '../../home/bloc/logout/logout_bloc.dart';
import '../../promo/pages/manage_promo_page.dart';
import '../bloc/sync/sync_bloc.dart';
import 'manage_printer_page.dart';
import 'receipt_settings_page.dart';
import 'admin_shift_page.dart';
import 'table_orders_page.dart';
import 'manage_category_page.dart';
import 'manage_product_page.dart';
import 'manage_user_page.dart';
import 'privacy_policy_page.dart';
import 'report/report_page.dart';
import 'save_server_key_page.dart';
import 'sync_data_page.dart';

/// Settings hub. Each tile shows live status (printer connected, QRIS key
/// present, last-sync ago) so the cashier sees at a glance what needs
/// attention. Maps to `.claude/new-design/screens/settings.jsx`.
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  AuthResponseModel? _auth;
  bool _printerPaired = false;
  bool _qrisActive = false;
  int _tableOrderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final ds = AuthLocalDatasource();
    final auth = await ds.getAuthData();
    final printer = await ds.getPrinter();
    final payment = await PaymentSettingsRemoteDatasource().fetch();
    final tableOrders = await TableOrderRemoteDatasource().pendingCount();
    if (!mounted) return;
    setState(() {
      _auth = auth;
      _printerPaired = printer.isNotEmpty;
      _qrisActive = payment.qrisAvailable;
      _tableOrderCount = tableOrders;
    });
  }

  void _openPrivacyPolicy() {
    // In-app WebView so the user never leaves the app (Play Store
    // reviewers expect the policy to be reachable without bouncing out).
    context.push(const PrivacyPolicyPage());
  }

  Future<void> _confirmDelete() async {
    final firstOk = await AppConfirm.show(
      context,
      title: 'Hapus akun secara permanen?',
      body:
          'Semua data identitas Anda akan dihapus dari server, semua sesi '
          'akan keluar. Riwayat transaksi tetap tersimpan tapi tidak lagi '
          'terkait dengan identitas Anda. Aksi ini tidak bisa dibatalkan.',
      confirmLabel: 'Lanjutkan',
      destructive: true,
    );
    if (!firstOk || !mounted) return;

    final secondOk = await AppConfirm.show(
      context,
      title: 'Konfirmasi sekali lagi',
      body:
          'Tekan "Hapus" untuk benar-benar menghapus akun ini. '
          'Anda akan dikeluarkan setelah ini.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!secondOk || !mounted) return;

    context.read<DeleteAccountBloc>().add(const DeleteAccountEvent.submit());
  }

  void _onDeleteAccountState(
    BuildContext context,
    DeleteAccountState state,
  ) {
    state.maybeWhen(
      success: () async {
        AppSnackbar.success(context, 'Akun berhasil dihapus');
        await AuthLocalDatasource().removeAuthData();
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      },
      error: (msg) => AppSnackbar.error(context, 'Gagal hapus akun: $msg'),
      orElse: () {},
    );
  }

  String _lastSyncLabel(DateTime? at) {
    if (at == null) return 'Belum pernah';
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  List<Widget> _productTiles(bool isAdmin) {
    return [
      _Tile(
        icon: Icons.inventory_2_outlined,
        label: 'Kelola Produk',
        subtitle: 'Tambah, edit, hapus menu',
        onTap: () => context.push(const ManageProductPage()),
      ),
      if (isAdmin) ...[
        _Tile(
          icon: Icons.category_outlined,
          label: 'Kelola Kategori',
          subtitle: 'Atur kategori menu',
          onTap: () => context.push(const ManageCategoryPage()),
        ),
        _Tile(
          icon: Icons.group_outlined,
          label: 'Kelola Karyawan',
          subtitle: 'Tambah / ubah akun kasir, admin',
          onTap: () => context.push(const ManageUserPage()),
        ),
        _Tile(
          icon: Icons.lock_clock_outlined,
          label: 'Kelola Shift',
          subtitle: 'Force-close shift kasir yang lupa tutup',
          onTap: () => context.push(const AdminShiftPage()),
        ),
        _Tile(
          icon: Icons.local_offer_outlined,
          label: 'Promo & Voucher',
          subtitle: 'Diskon otomatis dan kode voucher',
          onTap: () => context.push(const ManagePromoPage()),
        ),
        _Tile(
          icon: Icons.insights_outlined,
          label: 'Laporan Penjualan',
          subtitle: 'Ringkasan + export PDF',
          onTap: () => context.push(const ReportPage()),
        ),
      ],
      _Tile(
        icon: Icons.restaurant_menu,
        label: 'Pesanan Meja',
        subtitle: _tableOrderCount > 0
            ? '$_tableOrderCount pesanan menunggu diproses'
            : 'Order dari scan QR pelanggan',
        trailing: _tableOrderCount > 0
            ? AppStatusPill(
                label: '$_tableOrderCount',
                kind: AppStatusKind.warning,
              )
            : null,
        onTap: () async {
          await context.push(const TableOrdersPage());
          if (!mounted) return;
          final count = await TableOrderRemoteDatasource().pendingCount();
          if (!mounted) return;
          setState(() => _tableOrderCount = count);
        },
      ),
      BlocBuilder<CashSessionBloc, CashSessionState>(
        builder: (context, shiftState) {
          final hasOpen = shiftState.maybeWhen(
            open: (_) => true,
            orElse: () => false,
          );
          return _Tile(
            icon: Icons.lock_clock,
            label: 'Tutup Kasir',
            subtitle:
                hasOpen ? 'Akhiri shift & hitung kas' : 'Tidak ada shift aktif',
            trailing: hasOpen
                ? null
                : const AppStatusPill(
                    label: 'TIDAK AKTIF',
                    kind: AppStatusKind.neutral),
            onTap: hasOpen ? () => context.push(const TutupKasirPage()) : null,
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isAdmin = _auth?.user.isAdmin ?? false;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: const AppAppBar(
        title: 'Pengaturan',
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _ProfileCard(auth: _auth),
          const AppSectionLabel('Produk & Penjualan'),
          AppListGroup(children: _productTiles(isAdmin)),
          const AppSectionLabel('Perangkat & Pembayaran'),
          AppListGroup(children: [
            _Tile(
              icon: Icons.print_outlined,
              label: 'Printer Thermal',
              subtitle: _printerPaired
                  ? 'Terhubung ke MAC tersimpan'
                  : 'Belum di-pair',
              trailing: AppStatusPill(
                label: _printerPaired ? 'TERHUBUNG' : 'BELUM',
                kind: _printerPaired
                    ? AppStatusKind.success
                    : AppStatusKind.warning,
                showDot: true,
              ),
              onTap: () async {
                await context.push(const ManagePrinterPage());
                _loadStatus();
              },
            ),
            _Tile(
              icon: Icons.receipt_long_outlined,
              label: 'Pengaturan Struk',
              subtitle: 'Logo, identitas toko, footer',
              onTap: () => context.push(const ReceiptSettingsPage()),
            ),
            _Tile(
              icon: Icons.qr_code_2,
              label: 'Pembayaran QRIS',
              subtitle:
                  _qrisActive ? 'Aktif untuk checkout' : 'Belum diaktifkan',
              trailing: AppStatusPill(
                label: _qrisActive ? 'AKTIF' : 'NONAKTIF',
                kind: _qrisActive
                    ? AppStatusKind.success
                    : AppStatusKind.neutral,
                showDot: true,
              ),
              onTap: () async {
                await context.push(const SaveServerKeyPage());
                _loadStatus();
              },
            ),
          ]),
          const AppSectionLabel('Data'),
          AppListGroup(children: [
            BlocBuilder<SyncBloc, SyncState>(
              builder: (context, syncState) {
                final snap = syncState.maybeWhen(
                  ready: (s) => s,
                  orElse: () => null,
                );
                final pending = snap?.pendingOrderCount ?? 0;
                return _Tile(
                  icon: Icons.sync,
                  label: 'Sinkronisasi Data',
                  subtitle:
                      'Produk · kategori · promo · order pending: $pending',
                  trailing: pending > 0
                      ? AppStatusPill(
                          label: '$pending PENDING',
                          kind: AppStatusKind.warning,
                          showDot: true,
                        )
                      : Text(
                          _lastSyncLabel(snap?.lastSyncProductsAt),
                          style: AppTypography.bodyS.copyWith(
                            color: context.palette.onSurfaceVar,
                            fontSize: 11,
                          ),
                        ),
                  onTap: () => context.push(const SyncDataPage()),
                );
              },
            ),
          ]),
          const AppSectionLabel('Akun'),
          AppListGroup(children: [
            _Tile(
              icon: Icons.privacy_tip_outlined,
              label: 'Kebijakan Privasi',
              subtitle: 'Bagaimana data Anda diperlakukan',
              onTap: _openPrivacyPolicy,
            ),
            BlocConsumer<LogoutBloc, LogoutState>(
              listener: (context, state) {
                state.maybeMap(
                  orElse: () {},
                  success: (_) {
                    AuthLocalDatasource().removeAuthData();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (_) => false,
                    );
                  },
                );
              },
              builder: (context, state) {
                final loading = state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );
                return _Tile(
                  icon: Icons.logout,
                  label: 'Keluar',
                  subtitle: 'Logout dari akun ini',
                  destructive: true,
                  onTap: loading
                      ? null
                      : () async {
                          final ok = await AppConfirm.show(
                            context,
                            title: 'Logout sekarang?',
                            body:
                                'Kalau ada shift aktif, sebaiknya Tutup Kasir dulu.',
                            confirmLabel: 'Logout',
                            destructive: true,
                          );
                          if (!ok || !context.mounted) return;
                          context
                              .read<LogoutBloc>()
                              .add(const LogoutEvent.logout());
                        },
                );
              },
            ),
            BlocConsumer<DeleteAccountBloc, DeleteAccountState>(
              listener: _onDeleteAccountState,
              builder: (context, state) {
                final loading = state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );
                return _Tile(
                  icon: Icons.delete_forever_outlined,
                  label: 'Hapus Akun',
                  subtitle: 'Hapus akun & PII dari server',
                  destructive: true,
                  onTap: loading ? null : _confirmDelete,
                );
              },
            ),
          ]),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'POS · v1.0.0',
              style:
                  AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final AuthResponseModel? auth;
  const _ProfileCard({required this.auth});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final name = auth?.user.name ?? 'Memuat...';
    final email = auth?.user.email ?? '';
    final role = auth?.user.roleLabel ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: p.outlineSoft),
        ),
        child: Row(
          children: [
            AppAvatar(
                name: name, size: 48, kind: AppAvatarKind.primaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name,
                      style: AppTypography.titleM
                          .copyWith(color: p.onSurface, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(email,
                      style: AppTypography.bodyS
                          .copyWith(color: p.onSurfaceVar)),
                  if (role.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(role,
                        style: AppTypography.bodyS.copyWith(
                          color: p.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        )),
                  ],
                ],
              ),
            ),
            BlocBuilder<CashSessionBloc, CashSessionState>(
              builder: (context, state) {
                final open = state.maybeWhen(
                  open: (_) => true,
                  orElse: () => false,
                );
                return AppStatusPill(
                  label: open ? 'AKTIF' : 'IDLE',
                  kind: open ? AppStatusKind.success : AppStatusKind.neutral,
                  showDot: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  const _Tile({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final iconBg = destructive ? p.errorContainer : p.primaryContainer;
    final iconFg = destructive ? p.error : p.primary;
    final titleFg = destructive ? p.error : p.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: AppRadius.smAll,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconFg, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyL.copyWith(
                      color: titleFg,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodyS.copyWith(
                      color: p.onSurfaceVar,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (trailing != null) trailing!,
            if (!destructive && onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: p.onSurfaceVar, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
