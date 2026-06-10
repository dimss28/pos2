import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/components/app_bottom_sheet.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_key_value_row.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/dataoutputs/cwb_print.dart';
import '../../../data/datasources/product_local_datasource.dart';
import '../../draft_order/bloc/draft_order/draft_order_bloc.dart';
import '../../home/bloc/checkout/checkout_bloc.dart';
import '../../setting/bloc/sync/sync_bloc.dart';
import '../bloc/order/order_bloc.dart';
import '../models/order_summary.dart';

/// Success confirmation sheet after [OrderEvent.persistLocal] resolves.
/// Mirrors `.claude/new-design/screens/payment-flow.jsx` PaymentSuccessSheet:
/// big check + LUNAS pill, total card, detail rows, items recap, actions.
Future<void> showPaymentSuccessSheet(
  BuildContext context, {
  required OrderSummary summary,
}) {
  // Side-effects fired once on sheet open:
  // 1. if cart was linked to an Open Bill, drop that draft now (paid)
  // 2. clear cart so HomePage shows empty
  // 3. nudge SyncBloc to push the new pending order
  final cart = context.read<CheckoutBloc>().state.maybeWhen(
        success: (s) => s,
        orElse: () => null,
      );
  if (cart?.linkedDraftId != null) {
    ProductLocalDatasource.instance
        .removeDraftOrderById(cart!.linkedDraftId!);
    context.read<DraftOrderBloc>().add(const DraftOrderEvent.getAllDraftOrder());
  }
  context.read<CheckoutBloc>().add(const CheckoutEvent.started());
  context.read<SyncBloc>().add(const SyncEvent.refreshSnapshot());
  context.read<SyncBloc>().add(const SyncEvent.pushOrders());

  return showAppBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    headerBuilder: (ctx) => _Header(summary: summary),
    bottomActions: _Actions(summary: summary),
    child: _Body(summary: summary),
  );
}

class _Header extends StatelessWidget {
  final OrderSummary summary;
  const _Header({required this.summary});

  static final _df = DateFormat('d MMM yyyy · HH:mm', 'id');

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: p.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: p.success.withValues(alpha: 0.40),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pembayaran berhasil',
                  style:
                      AppTypography.titleM.copyWith(color: p.onSurface)),
              const SizedBox(height: 2),
              Text(
                _df.format(DateTime.now()),
                style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
              ),
            ],
          ),
        ),
        const AppStatusPill(label: 'LUNAS', kind: AppStatusKind.success),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final OrderSummary summary;
  const _Body({required this.summary});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.successContainer,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: p.success.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: p.success, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'TOTAL DIBAYAR',
                    style: AppTypography.labelM.copyWith(
                      color: p.success,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                summary.totalPrice.currencyFormatRp.trim(),
                style: AppTypography.displayM.copyWith(
                  color: p.success,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Terima kasih, transaksi sudah lunas',
                style: AppTypography.bodyS.copyWith(
                  color: p.success.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              AppKeyValueRow(
                label: 'Metode',
                value: summary.paymentMethod.isEmpty
                    ? '-'
                    : summary.paymentMethod,
              ),
              if (summary.discountAmount > 0) ...[
                AppKeyValueRow(
                  label: 'Subtotal',
                  value: summary.subtotal.currencyFormatRp.trim(),
                ),
                AppKeyValueRow(
                  label: summary.appliedDiscount?.displayLabel() ?? 'Diskon',
                  value: '-${summary.discountAmount.currencyFormatRp.trim()}',
                  variant: AppKVVariant.muted,
                ),
              ],
              if (summary.paymentMethod == 'Tunai') ...[
                AppKeyValueRow(
                  label: 'Uang diterima',
                  value: summary.nominalBayar.currencyFormatRp.trim(),
                ),
                AppKeyValueRow(
                  label: 'Kembalian',
                  value: summary.change.currencyFormatRp.trim(),
                  variant: AppKVVariant.accent,
                ),
              ],
              AppKeyValueRow(label: 'Kasir', value: summary.namaKasir),
              AppKeyValueRow(
                label: 'Item',
                value: '${summary.totalQuantity}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatefulWidget {
  final OrderSummary summary;
  const _Actions({required this.summary});

  @override
  State<_Actions> createState() => _ActionsState();
}

class _ActionsState extends State<_Actions> {
  // Default OFF — kasir hanya cetak struk pelanggan. Aktifkan kalau
  // "bayar dulu baru makan" → struk + tiket dapur untuk diproses.
  bool _alsoKitchen = false;
  final _kitchenIdCtrl = TextEditingController();
  String? _kitchenIdError;

  @override
  void dispose() {
    _kitchenIdCtrl.dispose();
    super.dispose();
  }

  void _toggleKitchen(bool v) {
    setState(() {
      _alsoKitchen = v;
      if (!v) _kitchenIdError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: p.surfaceVariant,
            borderRadius: AppRadius.mdAll,
          ),
          child: Row(
            children: [
              Icon(Icons.soup_kitchen_outlined,
                  color: p.onSurfaceVar, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Cetak dapur',
                        style: AppTypography.labelL.copyWith(
                            color: p.onSurface,
                            fontWeight: FontWeight.w600)),
                    Text('Tiket pesanan ke dapur/barista',
                        style: AppTypography.bodyS
                            .copyWith(color: p.onSurfaceVar)),
                  ],
                ),
              ),
              Switch(
                value: _alsoKitchen,
                onChanged: _toggleKitchen,
              ),
            ],
          ),
        ),
        if (_alsoKitchen) ...[
          const SizedBox(height: 10),
          AppTextField(
            label: 'No Meja / Nama',
            hint: 'cth: 5 atau Meja A',
            leadingIcon: Icons.confirmation_number_outlined,
            controller: _kitchenIdCtrl,
            autofocus: true,
            errorText: _kitchenIdError,
            onChanged: (_) {
              if (_kitchenIdError != null) {
                setState(() => _kitchenIdError = null);
              }
            },
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: AppButton(
                label: 'Cetak',
                leadingIcon: Icons.print_outlined,
                variant: AppButtonVariant.outline,
                onPressed: () => _print(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: AppButton.primaryWithArrow(
                label: 'Selesai',
                onPressed: () {
                  context.read<OrderBloc>().add(const OrderEvent.reset());
                  // Pop the sheet AND the OrderPage so user lands on Home.
                  Navigator.of(context).pop();
                  Navigator.of(context).maybePop();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _print(BuildContext context) async {
    final summary = widget.summary;

    // Validasi identifier kalau "Cetak dapur" aktif — dapur perlu tau ini
    // untuk meja/nama siapa. Numeric → MEJA: N, text → nama uppercase.
    String? kitchenId;
    int? kitchenIdAsTable;
    if (_alsoKitchen) {
      kitchenId = _kitchenIdCtrl.text.trim();
      if (kitchenId.isEmpty) {
        setState(() => _kitchenIdError = 'Wajib diisi (cth: 5 atau Meja A)');
        return;
      }
      kitchenIdAsTable = int.tryParse(kitchenId);
    }

    // "Order By" di struk customer: kalau kasir mengisi field dapur,
    // gunakan itu juga supaya konsisten antara struk + tiket dapur.
    // Else, pakai customerName dari OrderSummary (biasanya dari Open Bill).
    String receiptCustomer = summary.customerName;
    if (_alsoKitchen && kitchenId != null) {
      receiptCustomer =
          kitchenIdAsTable != null ? 'Meja $kitchenIdAsTable' : kitchenId;
    }

    try {
      final connected = await PrinterService.instance.ensureConnected();
      if (!connected) {
        if (context.mounted) {
          AppSnackbar.error(context,
              'Printer belum terhubung. Pair dulu di Pengaturan > Printer.');
        }
        return;
      }
      final paperSize = await PrinterService.instance.currentPaperSize();
      final branding = await PrinterService.instance.getBranding();

      final receiptBytes = await CwbPrint.instance.printOrderV2(
        summary.products,
        summary.totalQuantity,
        summary.totalPrice,
        summary.paymentMethod,
        summary.nominalBayar,
        summary.namaKasir,
        receiptCustomer,
        paperSize: paperSize,
        branding: branding,
        discountAmount: summary.discountAmount,
        discountLabel: summary.appliedDiscount?.displayLabel() ?? '',
      );
      await PrintBluetoothThermal.writeBytes(receiptBytes);

      if (_alsoKitchen && kitchenId != null) {
        final kitchenBytes = await CwbPrint.instance.printKitchen(
          summary.products,
          tableNumber: kitchenIdAsTable,
          customerName: kitchenIdAsTable == null ? kitchenId : null,
          paperSize: paperSize,
        );
        await PrintBluetoothThermal.writeBytes(kitchenBytes);
      }

      if (context.mounted) {
        AppSnackbar.success(
          context,
          _alsoKitchen
              ? 'Struk + tiket dapur dikirim ke printer'
              : 'Struk dikirim ke printer',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.error(
          context,
          'Gagal cetak — pastikan printer terpasang. ($e)',
        );
      }
    }
  }
}
