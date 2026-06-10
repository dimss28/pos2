import 'package:flutter/material.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/table_order_remote_datasource.dart';
import '../../../data/models/response/table_order_model.dart';

class TableOrdersPage extends StatefulWidget {
  const TableOrdersPage({super.key});

  @override
  State<TableOrdersPage> createState() => _TableOrdersPageState();
}

class _TableOrdersPageState extends State<TableOrdersPage> {
  final _ds = TableOrderRemoteDatasource();
  List<TableOrderModel>? _items;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
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
        _loading = false;
      }),
    );
  }

  Future<void> _confirm(TableOrderModel o) async {
    final ok = await AppConfirm.show(
      context,
      title: 'Terima pembayaran?',
      body: '${o.tableLabel ?? 'Meja'} — ${o.totalPrice.currencyFormatRp.trim()}',
      confirmLabel: 'Terima',
    );
    if (!ok || !mounted) return;
    final result = await _ds.confirm(o.id);
    result.fold(
      (msg) => AppSnackbar.error(context, msg),
      (_) {
        AppSnackbar.success(context, 'Pembayaran dikonfirmasi');
        _load();
      },
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
    final result = await _ds.reject(o.id);
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
                      body: 'Muncul setelah pelanggan scan QR & checkout.',
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _OrderCard(
                          order: _items![i],
                          onConfirm: () => _confirm(_items![i]),
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
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final void Function(String status) onAdvance;

  const _OrderCard({
    required this.order,
    required this.onConfirm,
    required this.onReject,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.outlineSoft),
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
          if (order.customerWhatsapp != null && order.customerWhatsapp!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'WA: ${order.customerWhatsapp}',
              style: AppTypography.bodyS.copyWith(color: p.primary, fontWeight: FontWeight.w600),
            ),
          ],
          if (order.paymentProofUrl != null && order.paymentProofUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Ada bukti transfer', style: AppTypography.bodyS.copyWith(color: p.warning)),
          ],
          const SizedBox(height: 10),
          if (order.status == 'awaiting_confirmation') ...[
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Terima',
                    onPressed: onConfirm,
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
          ] else if (order.status == 'paid') ...[
            AppButton(label: 'Mulai siapkan', onPressed: () => onAdvance('preparing')),
          ] else if (order.status == 'preparing') ...[
            AppButton(label: 'Siap disajikan', onPressed: () => onAdvance('ready')),
          ] else if (order.status == 'ready') ...[
            AppButton(label: 'Selesai', onPressed: () => onAdvance('completed')),
          ],
        ],
      ),
    );
  }
}
