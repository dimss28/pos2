import 'dart:convert';
import 'dart:developer' as dev;

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_app/core/extensions/int_ext.dart';
import 'package:flutter_pos_app/core/extensions/string_ext.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../presentation/home/models/order_item.dart';
import '../models/receipt_branding.dart';

class CwbPrint {
  CwbPrint._init();

  static final CwbPrint instance = CwbPrint._init();

  Future<void> printReceipt(List<int> printValue) async {
    try {
      await PrintBluetoothThermal.writeBytes(printValue);
    } on PlatformException catch (e) {
      dev.log('write failed', name: 'CwbPrint.printReceipt', error: e);
    }
  }

  Future<List<int>> printOrder(
    List<OrderItem> products,
    int totalQuantity,
    int totalPrice,
    String paymentMethod,
    int nominalBayar,
    String namaKasir,
  ) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    final ByteData data = await rootBundle.load('assets/logo/mylogo.png');
    final Uint8List bytesData = data.buffer.asUint8List();
    final img.Image? orginalImage = img.decodeImage(bytesData);
    bytes += generator.reset();

    if (orginalImage != null) {
      final img.Image grayscalledImage = img.grayscale(orginalImage);
      final img.Image resizedImage =
          img.copyResize(grayscalledImage, width: 240);
      bytes += generator.imageRaster(resizedImage, align: PosAlign.center);
      bytes += generator.feed(2);
    }

    bytes += generator.text('POS',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));
    bytes += generator.text(
        'Date : ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    bytes += generator.feed(1);
    bytes += generator.text('Order Items:',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    for (final product in products) {
      bytes += generator.text(product.product.name,
          styles: const PosStyles(align: PosAlign.left));

      bytes += generator.row([
        PosColumn(
          text: '${product.product.price} x ${product.quantity}',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '${product.product.price * product.quantity}'.currencyFormatRp,
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.feed(1);

    bytes += generator.row([
      PosColumn(
        text: 'Total',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: totalPrice.currencyFormatRp,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Pay',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: nominalBayar.currencyFormatRp,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Payment Method',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: paymentMethod == 'QRIS' ? 'QRIS' : 'Cash',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.feed(1);
    bytes += generator.text('Thank you for coming',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.feed(3);

    return bytes;
  }

  /// Kitchen / barista work order. No prices, big items.
  ///
  /// Identifier line prefers `tableNumber` (Open Bill case), falls back to
  /// `customerName` (walk-in pay-first case), otherwise "Walk-in".
  /// 80mm receives `generator.cut()` at the end (kasir-class printers).
  Future<List<int>> printKitchen(
    List<OrderItem> products, {
    int? tableNumber,
    String? customerName,
    PaperSize paperSize = PaperSize.mm58,
  }) async {
    final bool is80 = paperSize == PaperSize.mm80;
    final String divider = is80
        ? '================================================'
        : '================================';
    final String identifier;
    if (tableNumber != null && tableNumber > 0) {
      identifier = 'MEJA: $tableNumber';
    } else if (customerName != null && customerName.trim().isNotEmpty) {
      identifier = customerName.trim().toUpperCase();
    } else {
      identifier = 'WALK-IN';
    }

    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);

    bytes += generator.reset();

    bytes += generator.text('DAPUR',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    bytes += generator.feed(1);
    bytes += generator.text(identifier,
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    bytes += generator.feed(1);
    bytes += generator.text(
        DateFormat('dd MMM yy HH:mm').format(DateTime.now()),
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(divider,
        styles: const PosStyles(align: PosAlign.center));

    for (final product in products) {
      bytes += generator.text(
          '${product.quantity}x ${product.product.name}',
          styles: const PosStyles(
            bold: true,
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));
    }

    bytes += generator.feed(1);
    bytes += generator.text(divider,
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('-- KITCHEN --',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(is80 ? 2 : 3);

    if (is80) bytes += generator.cut();
    return bytes;
  }

  /// Pre-bill / meja receipt — items with prices, subtotal, "BELUM DIBAYAR"
  /// stamp. Pelanggan baca ini di meja sebelum membayar di kasir.
  Future<List<int>> printTable(
    List<OrderItem> products,
    int tableNumber,
    String customerName,
    String cashierName,
    int totalQuantity,
    int totalPrice, {
    PaperSize paperSize = PaperSize.mm58,
  }) async {
    final bool is80 = paperSize == PaperSize.mm80;
    final String divider = is80
        ? '================================================'
        : '================================';
    final String thinDivider = is80
        ? '------------------------------------------------'
        : '--------------------------------';

    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);

    bytes += generator.reset();

    bytes += generator.text('ORDER MEJA',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    bytes += generator.feed(1);
    bytes += generator.text('MEJA: $tableNumber',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
        ));
    bytes += generator.feed(1);

    bytes += generator.text(
        'Pelanggan: ${customerName.isEmpty ? '-' : customerName}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(
        DateFormat('dd MMM yy HH:mm').format(DateTime.now()),
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Kasir: $cashierName',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(thinDivider,
        styles: const PosStyles(align: PosAlign.center));

    for (final product in products) {
      bytes += generator.row([
        PosColumn(
          text: '${product.quantity} ${product.product.name}',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text:
              '${product.product.price * product.quantity}'.currencyFormatRpV2,
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.text(thinDivider,
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.row([
      PosColumn(
        text: 'Subtotal $totalQuantity item',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: totalPrice.currencyFormatRpV2,
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.text(divider,
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('** BELUM DIBAYAR **',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
        ));
    bytes += generator.text('Silakan bayar di kasir',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(is80 ? 2 : 3);

    if (is80) bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> printOrderV2(
    List<OrderItem> products,
    int totalQuantity,
    int totalPrice,
    String paymentMethod,
    int nominalBayar,
    String namaKasir,
    String customerName, {
    PaperSize paperSize = PaperSize.mm58,
    ReceiptBranding branding = const ReceiptBranding(),
    int discountAmount = 0,
    String discountLabel = '',
  }) async {
    final bool is80 = paperSize == PaperSize.mm80;
    final String divider = is80
        ? '================================================'
        : '================================';
    final String thinDivider = is80
        ? '------------------------------------------------'
        : '--------------------------------';
    final int logoWidth = is80 ? 360 : 240;
    // Empty-or-Walk-in friendly. Avoids printing "Order By : " with blank
    // value when checkout came from OrderPage (no Open Bill).
    final String resolvedCustomer =
        customerName.trim().isEmpty ? 'Walk-in' : customerName.trim();

    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.reset();

    // ── Optional user-supplied logo ───────────────────────────────────────
    if (branding.hasLogo) {
      try {
        final raw = base64Decode(branding.logoBase64);
        final decoded = img.decodeImage(raw);
        if (decoded != null) {
          final gs = img.grayscale(decoded);
          final resized = img.copyResize(gs, width: logoWidth);
          bytes += generator.imageRaster(resized, align: PosAlign.center);
          bytes += generator.feed(1);
        }
      } catch (e) {
        dev.log('logo decode failed', name: 'CwbPrint', error: e);
      }
    }

    // ── Header (only emit non-empty lines) ────────────────────────────────
    if (branding.storeName.isNotEmpty) {
      bytes += generator.text(branding.storeName,
          styles: const PosStyles(
            bold: true,
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ));
    }
    if (branding.addressLine1.isNotEmpty) {
      bytes += generator.text(branding.addressLine1,
          styles: const PosStyles(align: PosAlign.center));
    }
    if (branding.addressLine2.isNotEmpty) {
      bytes += generator.text(branding.addressLine2,
          styles: const PosStyles(align: PosAlign.center));
    }
    if (branding.email.isNotEmpty) {
      bytes += generator.text(branding.email,
          styles: const PosStyles(align: PosAlign.center));
    }
    if (branding.phone.isNotEmpty) {
      bytes += generator.text(branding.phone,
          styles: const PosStyles(align: PosAlign.center));
    }

    bytes += generator.feed(1);

    bytes += generator.text(divider,
        styles: const PosStyles(bold: false, align: PosAlign.center));

    bytes += generator.row([
      PosColumn(
        text: 'No Nota',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ':',
        width: 1,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'JF-${DateFormat('yyyyMMddhhmm').format(DateTime.now())}',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Waktu',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ':',
        width: 1,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: DateFormat('dd MMM yy HH:mm').format(DateTime.now()),
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Order By',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ':',
        width: 1,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: resolvedCustomer,
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Kasir',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ':',
        width: 1,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: namaKasir,
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);
    bytes += generator.text(thinDivider,
        styles: const PosStyles(bold: false, align: PosAlign.center));

    for (final product in products) {
      bytes += generator.row([
        PosColumn(
          text: '${product.quantity} ${product.product.name}',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text:
              '${product.product.price * product.quantity}'.currencyFormatRpV2,
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.text(thinDivider,
        styles: const PosStyles(bold: false, align: PosAlign.center));

    final int subtotal = discountAmount > 0
        ? totalPrice + discountAmount
        : totalPrice;

    bytes += generator.row([
      PosColumn(
        text: 'Subtotal $totalQuantity Produk',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: subtotal.currencyFormatRpV2,
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (discountAmount > 0) {
      final label = discountLabel.isNotEmpty ? discountLabel : 'Diskon';
      bytes += generator.row([
        PosColumn(
          text: label,
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '-${discountAmount.currencyFormatRpV2}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.row([
      PosColumn(
        text: 'Total Tagihan',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: totalPrice.currencyFormatRpV2,
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.text(thinDivider,
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.row([
      PosColumn(
        text: 'Metode Pembayaran',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: paymentMethod == 'QRIS' ? 'QRIS' : 'Cash',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total Bayar',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: nominalBayar.currencyFormatRpV2,
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.text(divider,
        styles: const PosStyles(bold: false, align: PosAlign.center));
    if (branding.footerLine1.isNotEmpty) {
      bytes += generator.text(branding.footerLine1,
          styles: const PosStyles(align: PosAlign.center));
    }
    if (branding.footerLine2.isNotEmpty) {
      bytes += generator.text(branding.footerLine2,
          styles: const PosStyles(align: PosAlign.center));
    }
    if (branding.footerLine1.isNotEmpty || branding.footerLine2.isNotEmpty) {
      bytes += generator.feed(1);
    }
    bytes += generator.text(
        'Terbayar: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('dicetak oleh: $namaKasir',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(is80 ? 2 : 3);

    if (is80) bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> printQRIS(
    int totalPrice,
    Uint8List imageQris,
  ) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    final img.Image? orginalImage = img.decodeImage(imageQris);
    bytes += generator.reset();

    bytes += generator.text('Scan QRIS Below for Payment',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.feed(2);
    if (orginalImage != null) {
      final img.Image grayscalledImage = img.grayscale(orginalImage);
      final img.Image resizedImage =
          img.copyResize(grayscalledImage, width: 330);
      bytes += generator.imageRaster(resizedImage, align: PosAlign.center);
      bytes += generator.feed(4);
    }
    bytes += generator.text('Price : ${totalPrice.currencyFormatRp}',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    bytes += generator.feed(3);

    return bytes;
  }
}
