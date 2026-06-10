import 'package:flutter/material.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/table_order_remote_datasource.dart';
import '../../../data/models/response/table_order_model.dart';
import '../widgets/table_order_detail_sheet.dart';

class TableOrdersPage extends StatefulWidget {
  const TableOrdersPage({super.key});

  @override
  State<TableOrdersPage> createState() => _TableOrdersPageState();
}

class _TableOrdersPageState extends State<TableOrdersPage>
    with WidgetsBindingObserver {
  final _ds = TableOrderRemoteDatasource();
  List<TableOrderModel>? _items;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load(silent: true);
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final result = await _ds.list();
    if (!mounted) return;
    result.fold(
      (msg) => setState(() {
        _error = msg;
        _items = [];
        _loading = false;
      }),
      (items) => setState(() {
        _items = items;
        _error = null;
        _loading = false;
      }),
    );
  }

  Future<void> _reject(TableOrderModel o) async {
    final ok = await AppConfirm.show(
      context,
      title: 'Tolak pesanan?',
      body: 'Pesanan ${o.tableLabel ?? ''} akan dibatalkan.',
      confirmLabel: 'Tolak',
      destructive: true,
    );
    if (!ok || !mounted) return;
    final result = await _ds.updateStatus(o.id, 'cancelled');
    result.fold(
      (msg) => AppSnackbar.error(context, msg),
      (_) {
        AppSnackbar.info(context, 'Pesanan ditolak');
        _load();
      },
    );
  }

  Future<void> _advance(TableOrderModel o, String next) async {
    final result = await _ds.updateStatus(o.id, next);
    result.fold(
      (msg) => AppSnackbar.error(context, msg),
      (_) => _load(),
    );
  }

  Future<void> _openDetail(TableOrderModel order) async {
    final result = await _ds.show(order.id);
    if (!mounted) return;
    await result.fold(
      (msg) async => AppSnackbar.error(context, msg),
      (detail) async {
        await showTableOrderDetailSheet(
          context,
          order: detail,
          onReject: () => _reject(detail),
          onAdvance: (s) => _advance(detail, s),
        );
        if (mounted) _load(silent: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppAppBar(
        title: 'Pesanan Meja',
        subtitle: 'Order dari scan QR pelanggan',
        trailing: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading && _items == null
          ? Center(child: CircularProgressIndicator(color: p.primary))
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: p.error)))
              : (_items?.isEmpty ?? true)
                  ? const AppEmptyState(
                      title: 'Belum ada pesanan meja',
                      body: 'Tarik ke bawah untuk refresh. Pastikan pelanggan sudah tekan Kirim pesanan.',
                    )
                  : RefreshIndicator(
                      onRefresh: () => _load(),
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + context.shellBottomPadding),
                        itemCount: _items!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _OrderCard(
                          order: _items![i],
                          onTap: () => _openDetail(_items![i]),
                          onReject: () => _reject(_items![i]),
                          onAdvance: (s) => _advance(_items![i], s),
                        ),
                      ),
                    ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final TableOrderModel order;
  final VoidCallback onTap;
  final VoidCallback onReject;
  final void Function(String status) onAdvance;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onReject,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: p.outlineSoft),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.tableLabel ?? 'Meja',
                      style: AppTypography.titleM.copyWith(fontSize: 16),
                    ),
                  ),
                  Text(
                    order.statusLabel ?? order.status,
                    style: AppTypography.labelM.copyWith(color: p.primary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${order.paymentMethod.toUpperCase()} · ${order.totalPrice.currencyFormatRp.trim()}',
                style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
              ),
              if (order.customerName != null && order.customerName!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  order.customerName!,
                  style: AppTypography.bodyS.copyWith(color: p.onSurface),
                ),
              ],
              if (order.customerWhatsapp != null &&
                  order.customerWhatsapp!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'WA: ${order.customerWhatsapp}',
                  style: AppTypography.bodyS.copyWith(
                    color: p.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (order.hasPaymentProof) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.receipt_long, size: 16, color: p.warning),
                    const SizedBox(width: 6),
                    Text(
                      'Ada bukti TF · ketuk untuk lihat',
                      style: AppTypography.bodyS.copyWith(
                        color: p.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              if (order.status == 'awaiting_payment') ...[
                Text(
                  'Menunggu pelanggan bayar QRIS',
                  style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
                ),
              ] else if (order.status == 'paid' ||
                  order.status == 'awaiting_confirmation') ...[
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Diproses',
                        onPressed: () => onAdvance('preparing'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'Tolak',
                        variant: AppButtonVariant.danger,
                        onPressed: onReject,
                      ),
                    ),
                  ],
                ),
              ] else if (order.status == 'preparing' ||
                  order.status == 'ready') ...[
                AppButton(
                  label: 'Selesai',
                  onPressed: () => onAdvance('completed'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
