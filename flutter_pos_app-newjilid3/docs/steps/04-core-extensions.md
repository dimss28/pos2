# 04 — Core Extensions (currency, date, parse, navigator, context)

## Goal

4 file extension Dart yang dipakai di seluruh app:
- `int_ext.dart` — format Rupiah dari `int`
- `string_ext.dart` — parse `'Rp. 22.000'` → 22000, format ISO date
- `date_time_ext.dart` — format `DateTime` ke 'dd Bulan yyyy, HH:mm' (bahasa Indonesia)
- `build_context_ext.dart` — shortcut navigator (`context.push`, `context.pop`) & device size (`context.deviceWidth`)

## Prerequisite

- Step 02 selesai (`AppPaletteContext` extension sudah ada di `app_palette.dart` — kita complement, bukan duplicate).

## Konsep yang diajarkan

- **Dart extensions** — cara nambah method ke class yang tidak kita miliki sourcenya (mis. `int`, `String`, `DateTime`, `BuildContext`).
- **`NumberFormat.currency`** — formatter Rupiah dengan locale 'id'.
- **Navigator 1.0** vs declarative routing — kita pakai imperative push/pop (lebih simple untuk POS yang gak butuh deep link / web).
- **Naming**: extension biasa diberi suffix `Ext` (`IntegerExt`, `StringExt`).

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Generate 4 file extension di `lib/core/extensions/`.

═══════════════════════════════════════════════
FILE 1: lib/core/extensions/int_ext.dart
═══════════════════════════════════════════════
```dart
import 'package:intl/intl.dart';

extension IntegerExt on int {
  /// "Rp. 22.000" — pakai locale id_ID, simbol "Rp. ", 0 desimal.
  String get currencyFormatRp => NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp. ',
        decimalDigits: 0,
      ).format(this);

  /// "22.000" tanpa simbol — buat input field & tabel.
  String get currencyFormatRpV2 => NumberFormat.currency(
        locale: 'id',
        symbol: '',
        decimalDigits: 0,
      ).format(this);
}
```

═══════════════════════════════════════════════
FILE 2: lib/core/extensions/string_ext.dart
═══════════════════════════════════════════════
```dart
import 'package:intl/intl.dart';

extension StringExt on String {
  /// "Rp. 22.000" / "22,000" / "22.000" → 22000
  /// Hapus semua non-digit, parse aman.
  int get toIntegerFromText {
    final cleaned = replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  /// Parse ISO "2026-06-07T13:45:00" → "07-06 13:45"
  String get toFormattedTime {
    final dt = DateTime.parse(this);
    return DateFormat('dd-MM HH:mm').format(dt);
  }

  /// "22000" → "Rp. 22.000"
  String get currencyFormatRp {
    final parsed = int.tryParse(this) ?? 0;
    return NumberFormat.currency(
      locale: 'id', symbol: 'Rp. ', decimalDigits: 0,
    ).format(parsed);
  }

  String get currencyFormatRpV2 {
    final parsed = int.tryParse(this) ?? 0;
    return NumberFormat.currency(
      locale: 'id', symbol: '', decimalDigits: 0,
    ).format(parsed);
  }

  /// "42" → 42; non-digit gracefully → 0
  int get toInt => int.tryParse(this) ?? 0;
}
```

═══════════════════════════════════════════════
FILE 3: lib/core/extensions/date_time_ext.dart
═══════════════════════════════════════════════
```dart
extension DateTimeExt on DateTime {
  /// "7 Juni 2026, 13:45" — manual mapping nama bulan (hindari ketergantungan
  /// initializeDateFormatting('id') di tempat-tempat yang belum init).
  String toFormattedTime() {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Desember',
    ];
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$day ${months[month - 1]} $year, $hh:$mm';
  }
}
```

═══════════════════════════════════════════════
FILE 4: lib/core/extensions/build_context_ext.dart
═══════════════════════════════════════════════
```dart
import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  double get deviceHeight => MediaQuery.of(this).size.height;
  double get deviceWidth => MediaQuery.of(this).size.width;
}

extension NavigatorExt on BuildContext {
  void pop<T extends Object>([T? result]) {
    Navigator.pop(this, result);
  }

  void popToRoot<T extends Object>() {
    Navigator.popUntil(this, (route) => route.isFirst);
  }

  Future<T?> push<T extends Object>(Widget widget, [String? name]) async {
    return Navigator.push<T>(
      this,
      MaterialPageRoute(
        builder: (context) => widget,
        settings: RouteSettings(name: name),
      ),
    );
  }

  Future<T?> pushReplacement<T extends Object, TO extends Object>(
      Widget widget) async {
    return Navigator.pushReplacement<T, TO>(
      this,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  Future<T?> pushAndRemoveUntil<T extends Object>(
      Widget widget, bool Function(Route<dynamic> route) predicate) async {
    return Navigator.pushAndRemoveUntil<T>(
      this,
      MaterialPageRoute(builder: (context) => widget),
      predicate,
    );
  }
}
```

Beri saya juga ringkasan singkat cara pakai ekstensi di atas dalam kode app POS (contoh: `22000.currencyFormatRp` → `"Rp. 22.000"`, `'Rp. 22.000'.toIntegerFromText` → `22000`, `context.push(OrderPage())`, `context.pushAndRemoveUntil(LoginPage(), (_) => false)`).
````

---

## Verifikasi

Test di `main.dart` placeholder body:

```dart
body: Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(22000.currencyFormatRp),                                 // Rp. 22.000
      Text('Rp. 35.500'.toIntegerFromText.toString()),              // 35500
      Text(DateTime.now().toFormattedTime()),                       // 7 Juni 2026, ...
      ElevatedButton(
        onPressed: () => context.push(const _DummyPage()),
        child: const Text('Push'),
      ),
    ],
  ),
),
```
(Buat `_DummyPage` minimal di file yang sama untuk test push.)

## Talking points

1. **Kenapa extension dan bukan helper function?**
   `22000.currencyFormatRp` lebih readable daripada `formatRupiah(22000)`. Discoverable di IDE (autocomplete setelah ketik `.`).

2. **`tryParse(...) ?? 0`** vs `parse(...)`:
   - `parse` throw exception kalau gagal.
   - `tryParse` return `null`.
   - Fallback `?? 0` adalah trade-off: input invalid jadi 0, tidak crash. Untuk currency POS, ini aman karena UI sudah validasi.

3. **Kenapa `toFormattedTime` di `DateTimeExt` manual mapping bulan, bukan `DateFormat`?**
   `DateFormat('d MMMM yyyy', 'id')` butuh `initializeDateFormatting('id', null)` jalan dulu — bisa lupa init di test/tools. Manual mapping = zero dependency.

4. **Navigator 1.0 vs `go_router`**:
   `go_router` cocok kalau ada deep link / web / nested routes. POS kita simple: push/pop. 1.0 cukup. Pindah ke 2.0 nanti kalau butuh.

5. **Generic `<T extends Object>`** di `push`:
   Supaya bisa return value typed dari halaman: `final int? selectedId = await context.push<int>(PickerPage());`.

6. **`pushAndRemoveUntil(LoginPage(), (_) => false)`**:
   Predicate `(_) => false` artinya "buang semua route di bawah". Dipakai setelah logout supaya peserta tidak bisa back ke Dashboard.

## Commit suggestion

```bash
git add lib/core/extensions/
git commit -m "Step 04: core extensions (currency, date, parse, navigator, device)"
```

---

➡️ Lanjut ke [Step 05 — Atoms: Button, TextField, Chip](./05-atoms-button-textfield-chip.md)
