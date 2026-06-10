import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/components/app_bottom_sheet.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_switch_tile.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/services/printer_service.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/dataoutputs/cwb_print.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../home/bloc/checkout/checkout_bloc.dart';
import '../../home/models/checkout_summary.dart';

/// Open-bill / save-draft sheet — replaces the inline AlertDialog flow.
/// Captures meja/lokasi + nama pelanggan, shows a recap of the cart,
/// optional toggle for printing the order chit, then dispatches
/// [CheckoutEvent.saveDraftOrder].
///
/// Maps to `OpenBillSheet` in `.claude/new-design/screens/draft-order.jsx`.
Future<bool> showOpenBillSheet(BuildContext context) async {
  final result = await showAppBottomSheet<bool>(
    context: context,
    title: 'Simpan Open Bill',
    subtitle: 'Tandai order untuk dibayar nanti',
    child: const _OpenBillBody(),
  );
  return result == true;
}

class _OpenBillBody extends StatefulWidget {
  const _OpenBillBody();

  @override
  State<_OpenBillBody> createState() => _OpenBillBodyState();
}

class _OpenBillBodyState extends State<_OpenBillBody> {
  final _tableCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _printChit = true;
  String? _tableError;

  @override
  void initState() {
    super.initState();
    // If the cart was loaded from an existing Open Bill, pre-fill so the
    // user only needs to confirm/edit rather than retype.
    final cur = context.read<CheckoutBloc>().state.maybeWhen(
          success: (s) => s,
          orElse: () => const CheckoutSummary(),
        );
    if (cur.linkedTableLabel != null && cur.linkedTableLabel!.isNotEmpty) {
      _tableCtrl.text = cur.linkedTableLabel!;
    }
    if (cur.linkedCustomerName != null && cur.linkedCustomerName!.isNotEmpty) {
      _nameCtrl.text = cur.linkedCustomerName!;
    }
  }

  @override
  void dispose() {
    _tableCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final label = _tableCtrl.text.trim();
    if (label.isEmpty) {
      setState(() => _tableError = 'Wajib diisi (cth. Meja 4 atau Takeaway)');
      return;
    }
    FocusScope.of(context).unfocus();

    final cart = context.read<CheckoutBloc>().state.maybeWhen(
          success: (s) => s,
          orElse: () => const CheckoutSummary(),
        );
    final customerName = _nameCtrl.text.trim();
    final tableNumber =
        int.tryParse(label.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    context.read<CheckoutBloc>().add(
          CheckoutEvent.saveDraftOrder(
            tableLabel: label,
            customerName: customerName,
            tableNumber: tableNumber,
          ),
        );

    if (_printChit && cart.products.isNotEmpty) {
      await _printOrderChits(
        cart: cart,
        tableNumber: tableNumber,
        customerName: customerName,
      );
    }

    if (!mounted) return;
    AppSnackbar.success(context, 'Open Bill "$label" tersimpan');
    Navigator.of(context).pop(true);
  }

  /// Cetak dua tiket berurutan: DAPUR (kitchen work order, no harga) + MEJA
  /// (pre-bill dengan harga untuk pelanggan). 80mm akan auto-cut antar tiket.
  Future<void> _printOrderChits({
    required CheckoutSummary cart,
    required int tableNumber,
    required String customerName,
  }) async {
    try {
      final connected = await PrinterService.instance.ensureConnected();
      if (!connected) {
        if (!mounted) return;
        AppSnackbar.error(
          context,
          'Printer belum terhubung. Pair dulu di Pengaturan > Printer.',
        );
        return;
      }
      final paperSize = await PrinterService.instance.currentPaperSize();
      final auth = await AuthLocalDatasource().getAuthData();

      final kitchenBytes = await CwbPrint.instance.printKitchen(
        cart.products,
        tableNumber: tableNumber,
        customerName: customerName,
        paperSize: paperSize,
      );
      await PrintBluetoothThermal.writeBytes(kitchenBytes);

      final tableBytes = await CwbPrint.instance.printTable(
        cart.products,
        tableNumber,
        customerName,
        auth.user.name,
        cart.totalQuantity,
        cart.totalPrice,
        paperSize: paperSize,
      );
      await PrintBluetoothThermal.writeBytes(tableBytes);
    } catch (e) {
      dev.log('order chit print failed', name: 'OpenBillSheet', error: e);
      if (!mounted) return;
      AppSnackbar.error(context, 'Gagal cetak bukti pesanan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        final cart = state.maybeWhen(
          success: (s) => s,
          orElse: () => const CheckoutSummary(),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Meja / Lokasi',
              hint: 'cth. Meja 4 / Takeaway',
              leadingIcon: Icons.table_restaurant_outlined,
              controller: _tableCtrl,
              autofocus: true,
              errorText: _tableError,
              onChanged: (_) {
                if (_tableError != null) {
                  setState(() => _tableError = null);
                }
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Nama Pelanggan',
              hint: 'opsional',
              leadingIcon: Icons.person_outline,
              controller: _nameCtrl,
              subtle: true,
            ),
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: p.surfaceVariant,
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      color: p.onSurfaceVar, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodyM
                            .copyWith(color: p.onSurface, fontSize: 13),
                        children: [
                          TextSpan(text: '${cart.totalQuantity} item dipesan · '),
                          TextSpan(
                            text: cart.totalPrice.currencyFormatRp.trim(),
                            style:
                                const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: p.outlineSoft),
              ),
              child: AppSwitchTile(
                title: 'Cetak bukti pesanan',
                subtitle: 'Untuk dapur / barista',
                value: _printChit,
                onChanged: (v) => setState(() => _printChit = v),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Batal',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: _printChit ? 'Simpan & Cetak' : 'Simpan',
                    onPressed: cart.isEmpty ? null : _submit,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
