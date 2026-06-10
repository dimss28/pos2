# 27 — PaymentSuccessSheet + PrinterService + Cetak Struk Bluetooth

## Goal

`PaymentSuccessSheet` muncul setelah persistLocal sukses: avatar success, ringkasan transaksi, tombol "Cetak Struk" (Bluetooth thermal) + "Selesai". Plus `PrinterService` singleton wrapper + `CwbPrint` formatter ESC/POS.

## Prerequisite

- Step 26 selesai.
- Package `print_bluetooth_thermal`, `esc_pos_utils_plus`. Atom `AppAvatar`, `AppKeyValueRow`, `AppButton`.

## Konsep yang diajarkan

- **ESC/POS commands** — bahasa printer thermal (text, alignment, cut, drawer).
- **`Generator` esc_pos_utils** — builder pattern untuk encode commands.
- **Best-effort print**: kalau gagal printer → fallback snackbar info, jangan crash.
- **`PrinterService.ensureConnected`** sebelum tiap print.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `OrderState.persisted(id, summary)` ada (step 26). `ReceiptBranding` + `AuthLocalDatasource.getReceiptBranding/getPaperSize/getPrinter` ada (step 13).

Generate 3 file.

═══════════════════════════════════════════════
FILE 1: lib/core/services/printer_service.dart
═══════════════════════════════════════════════
Singleton wrapper:
```dart
import 'dart:async';
import 'dart:developer' as dev;

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../data/datasources/auth_local_datasource.dart';
import '../../data/models/receipt_branding.dart';

class PrinterService {
  PrinterService._();
  static final PrinterService instance = PrinterService._();

  static const Duration connectTimeout = Duration(seconds: 8);

  static PaperSize parsePaperSize(String raw) =>
      raw == '80' ? PaperSize.mm80 : PaperSize.mm58;

  Future<PaperSize> currentPaperSize() async =>
      parsePaperSize(await AuthLocalDatasource().getPaperSize());

  Future<ReceiptBranding> getBranding() =>
      AuthLocalDatasource().getReceiptBranding();

  Future<bool> connect(String mac) async {
    try {
      return await PrintBluetoothThermal.connect(macPrinterAddress: mac)
          .timeout(connectTimeout, onTimeout: () => false);
    } catch (e) { dev.log('connect failed', name: 'PrinterService', error: e); return false; }
  }

  Future<void> disconnect() async {
    try { await PrintBluetoothThermal.disconnect; }
    catch (e) { dev.log('disconnect failed', name: 'PrinterService', error: e); }
  }

  Future<bool> isConnected() async {
    try { return await PrintBluetoothThermal.connectionStatus; }
    catch (_) { return false; }
  }

  Future<void> autoConnectSaved() async {
    final mac = await AuthLocalDatasource().getPrinter();
    if (mac.isEmpty) return;
    if (await isConnected()) return;
    final ok = await connect(mac);
    dev.log('autoConnectSaved mac=$mac ok=$ok', name: 'PrinterService');
  }

  Future<bool> ensureConnected() async {
    if (await isConnected()) return true;
    final mac = await AuthLocalDatasource().getPrinter();
    if (mac.isEmpty) return false;
    return connect(mac);
  }
}
```

═══════════════════════════════════════════════
FILE 2: lib/data/dataoutputs/cwb_print.dart
═══════════════════════════════════════════════
ESC/POS formatter untuk struk:
```dart
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../core/services/printer_service.dart';
import '../../core/extensions/int_ext.dart';
import '../models/receipt_branding.dart';
import '../../presentation/order/models/order_summary.dart';

class CwbPrint {
  CwbPrint._();
  static final CwbPrint instance = CwbPrint._();

  /// Cetak struk dari OrderSummary + id local. Best-effort.
  Future<bool> printReceipt({
    required OrderSummary summary,
    required int localOrderId,
  }) async {
    final connected = await PrinterService.instance.ensureConnected();
    if (!connected) return false;

    final paper = await PrinterService.instance.currentPaperSize();
    final profile = await CapabilityProfile.load();
    final gen = Generator(paper, profile);

    final branding = await PrinterService.instance.getBranding();
    final List<int> bytes = [];

    // Header
    bytes.addAll(gen.text(branding.storeName,
        styles: const PosStyles(bold: true, align: PosAlign.center)));
    if (branding.addressLine1.isNotEmpty) {
      bytes.addAll(gen.text(branding.addressLine1, styles: const PosStyles(align: PosAlign.center)));
    }
    if (branding.addressLine2.isNotEmpty) {
      bytes.addAll(gen.text(branding.addressLine2, styles: const PosStyles(align: PosAlign.center)));
    }
    if (branding.phone.isNotEmpty) {
      bytes.addAll(gen.text('Telp: ${branding.phone}', styles: const PosStyles(align: PosAlign.center)));
    }
    bytes.addAll(gen.hr());

    // Order header
    bytes.addAll(gen.row([
      PosColumn(text: 'No', width: 6),
      PosColumn(text: '#$localOrderId', width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]));
    bytes.addAll(gen.row([
      PosColumn(text: 'Kasir', width: 6),
      PosColumn(text: summary.namaKasir, width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]));
    bytes.addAll(gen.hr());

    // Items
    for (final item in summary.products) {
      bytes.addAll(gen.text(item.product.name));
      bytes.addAll(gen.row([
        PosColumn(
          text: '${item.quantity}x ${item.product.price.currencyFormatRpV2}',
          width: 6,
        ),
        PosColumn(
          text: (item.quantity * item.product.price).currencyFormatRpV2,
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));
    }
    bytes.addAll(gen.hr());

    // Totals
    bytes.addAll(gen.row([
      PosColumn(text: 'Subtotal', width: 6),
      PosColumn(text: summary.subtotal.currencyFormatRpV2, width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]));
    if (summary.discountAmount > 0) {
      bytes.addAll(gen.row([
        PosColumn(text: 'Diskon', width: 6),
        PosColumn(text: '-${summary.discountAmount.currencyFormatRpV2}', width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]));
    }
    bytes.addAll(gen.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: summary.totalPrice.currencyFormatRpV2, width: 6, styles: const PosStyles(bold: true, align: PosAlign.right)),
    ]));
    if (summary.paymentMethod == 'cash') {
      bytes.addAll(gen.row([
        PosColumn(text: 'Diterima', width: 6),
        PosColumn(text: summary.nominalBayar.currencyFormatRpV2, width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]));
      bytes.addAll(gen.row([
        PosColumn(text: 'Kembali', width: 6),
        PosColumn(text: summary.change.currencyFormatRpV2, width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]));
    } else {
      bytes.addAll(gen.row([
        PosColumn(text: 'Metode', width: 6),
        PosColumn(text: summary.paymentMethod.toUpperCase(), width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]));
    }

    bytes.addAll(gen.hr());

    // Footer
    if (branding.footerLine1.isNotEmpty) {
      bytes.addAll(gen.text(branding.footerLine1, styles: const PosStyles(align: PosAlign.center)));
    }
    if (branding.footerLine2.isNotEmpty) {
      bytes.addAll(gen.text(branding.footerLine2, styles: const PosStyles(align: PosAlign.center)));
    }
    bytes.addAll(gen.feed(2));
    bytes.addAll(gen.cut());

    final result = await PrintBluetoothThermal.writeBytes(bytes);
    return result;
  }
}
```

═══════════════════════════════════════════════
FILE 3: lib/presentation/order/widgets/payment_success_sheet.dart
═══════════════════════════════════════════════
```dart
import 'package:flutter/material.dart';

import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_key_value_row.dart';
import '../../../core/components/avatar.dart';
import '../../../core/components/feedback.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/dataoutputs/cwb_print.dart';
import '../models/order_summary.dart';

class PaymentSuccessSheet extends StatefulWidget {
  final int localOrderId;
  final OrderSummary summary;
  const PaymentSuccessSheet({super.key, required this.localOrderId, required this.summary});

  @override
  State<PaymentSuccessSheet> createState() => _PaymentSuccessSheetState();
}

class _PaymentSuccessSheetState extends State<PaymentSuccessSheet> {
  bool _printing = false;

  Future<void> _print() async {
    setState(() => _printing = true);
    final ok = await CwbPrint.instance.printReceipt(
      summary: widget.summary, localOrderId: widget.localOrderId);
    if (!mounted) return;
    setState(() => _printing = false);
    ok
      ? AppSnackbar.success(context, 'Struk dicetak')
      : AppSnackbar.error(context, 'Printer tidak terhubung. Cek pengaturan.');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = widget.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 84, height: 84,
            decoration: BoxDecoration(color: p.successContainer, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: p.success, size: 48),
          ),
        ),
        const SpaceHeight(16),
        Text('Pembayaran Berhasil',
            textAlign: TextAlign.center,
            style: AppTypography.titleL.copyWith(color: p.onSurface)),
        const SpaceHeight(4),
        Text('Order #${widget.localOrderId} berhasil disimpan',
            textAlign: TextAlign.center,
            style: AppTypography.bodyM.copyWith(color: p.onSurfaceVar)),
        const SpaceHeight(20),
        AppCard(
          child: Column(children: [
            AppKeyValueRow(label: 'Metode', value: s.paymentMethod.toUpperCase()),
            AppKeyValueRow(label: 'Total', value: s.totalPrice.currencyFormatRp),
            if (s.paymentMethod == 'cash') ...[
              AppKeyValueRow(label: 'Diterima', value: s.nominalBayar.currencyFormatRp),
              AppKeyValueRow(label: 'Kembalian', value: s.change.currencyFormatRp, variant: AppKVVariant.accent),
            ],
          ]),
        ),
        const SpaceHeight(20),
        Row(children: [
          Expanded(child: AppButton.outline(
            label: 'Cetak Struk',
            leadingIcon: Icons.print_outlined,
            loading: _printing,
            onPressed: _printing ? null : _print,
          )),
          const SpaceWidth(12),
          Expanded(child: AppButton.primary(
            label: 'Selesai',
            onPressed: () => Navigator.of(context).pop(),
          )),
        ]),
      ],
    );
  }
}
```

═══════════════════════════════════════════════
STEP 4: Update OrderPage BlocListener (step 26)
═══════════════════════════════════════════════
```dart
persisted: (id, summary) {
  context.read<CheckoutBloc>().add(const CheckoutEvent.started());
  showAppBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    child: PaymentSuccessSheet(localOrderId: id, summary: summary),
  ).then((_) {
    // Setelah sheet ditutup, kembali ke Home tab.
    DashboardScope.of(context)?.switchTo(0);
    context.pop();
  });
}
```

═══════════════════════════════════════════════
STEP 5: Splash autoConnect printer
═══════════════════════════════════════════════
Di `splash_page.dart` (step 16) `_start()`, tambah:
```dart
import 'package:flutter_pos_app/core/services/printer_service.dart';
unawaited(PrinterService.instance.autoConnectSaved());
```
````

---

## Verifikasi

1. Pair printer (step 38 nanti) atau set MAC manual.
2. Checkout cash → setelah konfirmasi → success sheet muncul.
3. Tap "Cetak Struk" → ada delay 1-2 detik → struk keluar dari printer.
4. Kalau printer off → snackbar error "Printer tidak terhubung".
5. Tap "Selesai" → kembali ke Home, cart kosong.

## Talking points

1. **ESC/POS** = bahasa de-facto printer thermal kasir. `esc_pos_utils_plus` translate Dart → byte commands. `Generator(paper, profile).text/row/hr/cut` build byte list.

2. **`PaperSize.mm58 vs mm80`**: thermal paper standar 58mm (kasir kecil) atau 80mm (kafe/resto). User pilih di settings.

3. **`CapabilityProfile.load()`**: profile printer (font width, code page). `default` cocok untuk mayoritas printer ESC/POS generik.

4. **`PosColumn(width: 6)`** + 6 = 12 total grid:
   Split tiap row jadi 2 kolom equal-width.

5. **Best-effort print (return bool, jangan throw)**:
   Kasir tidak rugi kalau gagal print — order sudah saved. Worst case: customer minta struk tulis tangan.

6. **`autoConnectSaved` di splash**:
   Background — kalau printer nyala dan dalam range, connected sebelum user pertama checkout. Kalau gagal, ensureConnected akan retry saat print.

## Commit suggestion

```bash
git add lib/core/services/printer_service.dart lib/data/dataoutputs/cwb_print.dart lib/presentation/order/widgets/payment_success_sheet.dart lib/presentation/order/pages/order_page.dart lib/presentation/auth/pages/splash_page.dart
git commit -m "Step 27: PaymentSuccessSheet + PrinterService + ESC/POS receipt"
```

---

➡️ Lanjut ke [Step 28 — PaymentQRISSheet (Midtrans)](./28-payment-qris.md)
