# 38 — ManagePrinterPage + Permission Bluetooth

## Goal

Halaman pairing printer: list paired Bluetooth devices, status connection, pilih → save MAC ke prefs + connect. Test print. Pilih paper size (58/80mm).

## Prerequisite

- Step 37 selesai. `PrinterService` (step 27), `print_bluetooth_thermal` package.

## Konsep yang diajarkan

- **Bluetooth permission Android 12+**: `BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN`.
- **`BluetoothInfo`** model dari `print_bluetooth_thermal`: name + macAddress.
- **AppSegmentedToggle** untuk pilih paper size.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `PrinterService.instance` (connect/disconnect/isConnected) ada. `AuthLocalDatasource.savePrinter/getPrinter/savePaperSize/getPaperSize` ada.

═══════════════════════════════════════════════
STEP 1: AndroidManifest permission
═══════════════════════════════════════════════
Tambah di `<manifest>`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
<!-- Android 11 fallback (sebagian device perlu untuk scan classic BT): -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

═══════════════════════════════════════════════
FILE: lib/presentation/setting/pages/manage_printer_page.dart
═══════════════════════════════════════════════
StatefulWidget. State:
- `List<BluetoothInfo> _devices = []` (dari `PrintBluetoothThermal.pairedBluetooths`).
- `String _connectedMac = ''`.
- `bool _loading = false, _connecting = false`.
- `String _paperSize = '58'`.

initState: `_refresh()`.

`_refresh()`:
- Cek permission `Permission.bluetoothConnect.request()`. Kalau denied → tampilkan empty state dengan tombol "Buka Pengaturan" (openAppSettings).
- `_devices = await PrintBluetoothThermal.pairedBluetooths`.
- `_connectedMac = await AuthLocalDatasource().getPrinter()`.
- `_paperSize = await AuthLocalDatasource().getPaperSize()`.

Build:
- Scaffold(bg surface) > AppAppBar(title: 'Printer Bluetooth', trailing: [AppIconButton(refresh, onPressed: _refresh)]).
- body: ListView padding 16:
  1. **Status banner**:
     - Kalau ada connectedMac & isConnected → AppBanner(success, icon: print_outlined, title: 'Terhubung', body: deviceName/mac, trailing: AppButton.outline('Putus', onPressed: disconnect)).
     - Else → AppBanner(warning, icon: print_disabled_outlined, title: 'Belum terhubung', body: 'Pasangkan printer Bluetooth dulu di pengaturan sistem.', trailing: AppButton.outline('Buka Setting', onPressed: openAppSettings)).
  2. SpaceHeight 16.
  3. **AppSectionLabel('Pilih Printer')**.
  4. AppListGroup:
     - For each device:
       - InkWell(onTap: _connect(device)) Padding 14: Row icon print_outlined 24 onSurfaceVar + Column [Text device.name bodyL w600, Text device.macAddress bodyS onSurfaceVar] + trailing (_connectedMac == device.macAddress ? Icon check_circle success : Icon chevron_right onSurfaceVar).
     - Kalau _devices.empty: tile dengan text 'Tidak ada printer ter-pairing. Pair lewat Setting Android dulu.'
  5. SpaceHeight 16.
  6. **AppSectionLabel('Ukuran Kertas Struk')**.
  7. AppSegmentedToggle<String>(
       options: [SegmentOption('58', '58mm'), SegmentOption('80', '80mm')],
       value: _paperSize,
       onChanged: (v) async { setState(_paperSize = v); await AuthLocalDatasource().savePaperSize(v); },
     ).
  8. SpaceHeight 24.
  9. AppButton.outline('Test Cetak', leadingIcon: print, onPressed: _testPrint).

`_connect(device)`:
- setState `_connecting = true`.
- `ok = await PrinterService.instance.connect(device.macAddress)`.
- Kalau ok: `AuthLocalDatasource().savePrinter(device.macAddress)`, setState `_connectedMac = device.macAddress`, AppSnackbar.success 'Terhubung ke ${device.name}'.
- Kalau gagal: AppSnackbar.error 'Gagal konek. Pastikan printer menyala dan dalam jangkauan.'
- setState `_connecting = false`.

`disconnect()`:
- `PrinterService.instance.disconnect()`.
- `AuthLocalDatasource().savePrinter('')`.
- setState.

`_testPrint()`:
- Print 1 baris "TEST PRINT - ${DateTime.now()}" + cut.
- Snackbar success/error.
````

---

## Verifikasi

1. Aktifkan Bluetooth HP + pair printer thermal (di Pengaturan Android).
2. Setting → Printer → permission request → grant → list paired devices.
3. Tap device → "Terhubung ke X".
4. Test Cetak → struk test keluar.
5. Reboot app → splash auto-reconnect.

## Talking points

1. **Bluetooth Permission Android 12+**:
   API berubah dari `BLUETOOTH` jadi `BLUETOOTH_CONNECT/SCAN` (runtime). Tanpa minta runtime → method call throw.

2. **Pairing harus dari Setting Android**:
   `print_bluetooth_thermal` cuma list **paired** devices. Pair sendiri di sistem, app tinggal connect.

3. **`pairedBluetooths`** return classic BT (bukan BLE):
   Printer thermal mayoritas pakai BT classic. Untuk BLE-only printer, butuh package lain.

4. **Paper size persist**:
   58mm = printer mini (Bluetooth handheld), 80mm = desktop printer. Pilihan affect formatter ESC/POS (Generator(paper, profile)).

5. **Test print sebelum produksi**:
   Pastikan printer connected + paper. Better fail di test daripada di tengah transaksi.

## Commit suggestion

```bash
git add lib/presentation/setting/pages/manage_printer_page.dart android/app/src/main/AndroidManifest.xml
git commit -m "Step 38: ManagePrinterPage with permission + pairing + paper size"
```

---

➡️ Lanjut ke [Step 39 — Server Key QRIS](./39-server-key-qris.md)
