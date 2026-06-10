import 'dart:async';
import 'dart:developer' as dev;

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../data/datasources/auth_local_datasource.dart';
import '../../data/models/receipt_branding.dart';

/// Thin wrapper over `PrintBluetoothThermal` for the parts that need to be
/// shared between the manage-printer page, the boot auto-connect, and the
/// per-receipt print callers.
class PrinterService {
  PrinterService._();
  static final PrinterService instance = PrinterService._();

  static const Duration connectTimeout = Duration(seconds: 8);

  /// Map persisted `'58'`/`'80'` to an esc/pos `PaperSize`.
  static PaperSize parsePaperSize(String raw) =>
      raw == '80' ? PaperSize.mm80 : PaperSize.mm58;

  Future<PaperSize> currentPaperSize() async =>
      parsePaperSize(await AuthLocalDatasource().getPaperSize());

  Future<ReceiptBranding> getBranding() =>
      AuthLocalDatasource().getReceiptBranding();

  /// Connect to a MAC with a timeout so the UI never hangs forever when the
  /// printer is off / out of range.
  Future<bool> connect(String mac) async {
    try {
      return await PrintBluetoothThermal.connect(macPrinterAddress: mac)
          .timeout(connectTimeout, onTimeout: () => false);
    } catch (e) {
      dev.log('connect failed', name: 'PrinterService', error: e);
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
    } catch (e) {
      dev.log('disconnect failed', name: 'PrinterService', error: e);
    }
  }

  Future<bool> isConnected() async {
    try {
      return await PrintBluetoothThermal.connectionStatus;
    } catch (_) {
      return false;
    }
  }

  /// Best-effort autoconnect on app start. Silent on failure — if the saved
  /// printer is off, the next print attempt will surface the error.
  Future<void> autoConnectSaved() async {
    final mac = await AuthLocalDatasource().getPrinter();
    if (mac.isEmpty) return;
    if (await isConnected()) return;
    final ok = await connect(mac);
    dev.log('autoConnectSaved mac=$mac ok=$ok', name: 'PrinterService');
  }

  /// Ensure the saved printer is connected before issuing a print job.
  /// Returns true if connection was established (or already up).
  Future<bool> ensureConnected() async {
    if (await isConnected()) return true;
    final mac = await AuthLocalDatasource().getPrinter();
    if (mac.isEmpty) return false;
    return connect(mac);
  }
}
