# 09 — Atoms: Domain (ProductImg, Avatar, MethodBadge, BrandMark, AppQrView, AppTrendChart, ScannerOverlay)

## Goal

7 atom yang **spesifik untuk domain POS**: gambar produk dengan fallback inisial, avatar bulat, badge metode bayar, brand mark coffee cup, QR view, trend chart 7-hari, dan overlay scanner kamera.

## Prerequisite

- Step 08 selesai.
- Package sudah ada di pubspec (step 01): `cached_network_image`, `qr_flutter`, `fl_chart`.

## Konsep yang diajarkan

- **`CachedNetworkImage`** — image loading + cache + placeholder + errorWidget.
- **`HSLColor`** — generate warna deterministik dari id (hue rotation).
- **`CustomPaint` + `CustomPainter`** — gambar manual (coffee cup) tanpa SVG.
- **`Stack` + `Positioned`** — overlay (QR brand letter, scanner brackets).
- **`fl_chart` `LineChartData`** — chart minimal tanpa axis berisik.
- **`Path.evenOdd` fill type** — cutout (vignette dengan lubang).

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada `AppPalette` (context.palette), `AppTypography`, `AppRadius`. Package `cached_network_image`, `qr_flutter`, `fl_chart` sudah di-install.

Generate 7 file di `lib/core/components/`.

═══════════════════════════════════════════════
FILE 1: lib/core/components/product_img.dart
═══════════════════════════════════════════════
`class ProductImg extends StatelessWidget` — 3 mode rendering: foto network, fallback inisial-tile hue-tinted, placeholder pas loading.

Field: `name: String, hue: int = 28, imageUrl?: String, size = 56, radius = AppRadius.smAll`.

Getters:
- `Color get _bg => HSLColor.fromAHSL(1, hue.toDouble(), 0.35, 0.88).toColor();` (pastel)
- `Color get _fg => HSLColor.fromAHSL(1, hue.toDouble(), 0.45, 0.32).toColor();` (gelap)

Build:
- initial = `name.isEmpty ? '?' : name.characters.first.toUpperCase()` (pakai `import 'package:flutter/widgets.dart'` untuk `characters`).
- Helper `buildFallback(double tileSize)` → Container(size×size, decoration bg `_bg`, radius) > Center > Text(initial, `titleM.copyWith(color: _fg, fontSize: tileSize*0.42, w700)`).
- Helper `withResolvedSize(Widget Function(double))` → kalau `size.isFinite` panggil builder dengan size, else `LayoutBuilder` pakai max constraint.
- Kalau `imageUrl == null || empty` → `withResolvedSize(buildFallback)`.
- Else: `withResolvedSize((resolved) => ClipRRect(radius) > SizedBox(size×size) > CachedNetworkImage(imageUrl, BoxFit.cover, placeholder: buildFallback(resolved), errorWidget: Container(bg p.surfaceVariant, Icon image_not_supported_outlined, color p.onSurfaceVar, size resolved*0.4)))`.

═══════════════════════════════════════════════
FILE 2: lib/core/components/avatar.dart
═══════════════════════════════════════════════
- `enum AppAvatarKind { primary, primaryContainer }`
- `class AppAvatar extends StatelessWidget`:
  - Field: `name: String, size=44, kind=primary`.
  - Static `String initialsOf(String name)`: split spasi, kalau 1 kata → 1 huruf, kalau >=2 → first+last huruf, semua uppercase. Empty → '?'.
  - Switch color: primary → (bg p.primary, fg p.onPrimary), primaryContainer → (bg p.primaryContainer, fg p.onPrimaryContainer).
  - Container(size×size, bg, shape BoxShape.circle) > Center > Text(initialsOf, `titleM.copyWith(color: fg, fontSize: size*0.38, w700)`).

═══════════════════════════════════════════════
FILE 3: lib/core/components/method_badge.dart
═══════════════════════════════════════════════
- `enum PaymentMethod { cash, qris, transfer }`
- `class MethodBadge extends StatelessWidget`:
  - Field: `method: PaymentMethod, size = 40`.
  - Switch (bg, fg, label, icon):
    - cash → (p.successContainer, p.success, 'CASH', Icons.payments_outlined)
    - qris → (p.primaryContainer, p.primary, 'QRIS', Icons.qr_code_2)
    - transfer → (p.warningContainer, 0xFF7C4A0E, 'TF', Icons.account_balance_outlined)
  - Container(size×size, bg, radius `AppRadius.smAll`) > Column.min:
    - Icon(icon, size*0.42, fg)
    - Text(label, `labelM.copyWith(color: fg, fontSize: 8, w700, letterSpacing: 0.4)`)

═══════════════════════════════════════════════
FILE 4: lib/core/components/brand_mark.dart
═══════════════════════════════════════════════
`class BrandMark extends StatelessWidget`:
- Field: `size = 76, color?, accent?`.
- bg = color ?? p.primary; fg = accent ?? p.onPrimary.
- Container(size×size, bg, radius `BorderRadius.circular(size * 0.32)`, shadow `BoxShadow(bg @0.20, blur 20, offset (0,8))`).
- Center > CustomPaint(size: size*0.6, painter: `_CoffeeCupPainter(color: fg)`).

`class _CoffeeCupPainter extends CustomPainter`:
- Field: `color`. Constructor const.
- `paint(canvas, size)`:
  - stroke = Paint, color, style stroke, strokeCap round, strokeJoin round.
  - scale = size.width / 24.
  - Helper `Offset p(double x, double y) => Offset(x*scale, y*scale)`.
  - Steam 2 garis (path moveTo(p(9,2)) + relativeCubicTo bezier wavy; sama untuk p(13,2)), strokeWidth 1.5*scale.
  - strokeWidth = 2*scale untuk cup body & handle.
  - Cup body: Path moveTo p(4,10) → lineTo p(17,10) → lineTo p(17,16) → arcToPoint(p(12,21), radius 5*scale, clockwise) → lineTo p(9,21) → arcToPoint(p(4,16), radius 5*scale, clockwise) → close. drawPath.
  - Handle: moveTo p(17,12) → lineTo p(19,12) → arcToPoint(p(19,17), radius 2.5*scale, clockwise) → lineTo p(17,17). drawPath.
- `shouldRepaint` → old.color != color.

Tambahan `class BrandMarkSoft extends StatelessWidget` (variant kecil untuk hero band login):
- Field: `size = 52`.
- Container(size×size, bg `p.onPrimary @0.14`, radius `AppRadius.md`) > Center > CustomPaint(size*0.6, _CoffeeCupPainter(p.onPrimary)).

═══════════════════════════════════════════════
FILE 5: lib/core/components/qr_view.dart
═══════════════════════════════════════════════
Import `package:qr_flutter/qr_flutter.dart`.

`class AppQrView extends StatelessWidget`:
- Field: `data: String, size = 220, brandLetter: String? = 'K'`.
- SizedBox(size×size) > Stack.center:
  - `QrImageView(data, version: QrVersions.auto, size, backgroundColor: white, eyeStyle: QrEyeStyle(square, color: p.onSurface), dataModuleStyle: QrDataModuleStyle(square, color: p.onSurface), errorCorrectionLevel: QrErrorCorrectLevel.H)`.
  - Kalau brandLetter != null: Container size*0.20 (bg p.primary, radius 8, border white 3px) > Center > Text(brandLetter, color p.onPrimary, w700, fontSize size*0.10).

═══════════════════════════════════════════════
FILE 6: lib/core/components/trend_chart.dart
═══════════════════════════════════════════════
Import `package:fl_chart/fl_chart.dart`.

`class AppTrendChart extends StatelessWidget`:
- Field: `data: List<double>, labels: List<String>, highlightIndex?, height=120`.
- Assert `data.length == labels.length`.
- hi = highlightIndex ?? data.length - 1.
- maxY = data.empty ? 1.0 : data.reduce max.
- spots = `[for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i])]`.
- SizedBox(height) > LineChart(LineChartData):
  - minX 0, maxX (data.length-1), minY 0, maxY maxY*1.2.
  - gridData show:false, borderData show:false.
  - titlesData: top/left/right hide. bottom: showTitles, interval 1, reservedSize 24, getTitlesWidget render labels[i] (`labelM, p.onSurfaceVar, 11px`).
  - lineTouchData enabled:false.
  - lineBarsData: [
      LineChartBarData(spots, isCurved: true, color: p.primary, barWidth: 2.5,
        dotData: FlDotData(show:true, getDotPainter: (spot,_,__,___) → FlDotCirclePainter(radius: isHi ? 5 : 3, color: isHi ? p.primary : white, strokeColor: p.primary, strokeWidth: 2)),
        belowBarData: BarAreaData(show:true, gradient: LinearGradient(top→bottom, [p.primary @0.22, p.primary @0.0])))
    ].

═══════════════════════════════════════════════
FILE 7: lib/core/components/scanner_overlay.dart
═══════════════════════════════════════════════
`class ScannerOverlay extends StatefulWidget`:
- Field: `viewport = 260`.

`_ScannerOverlayState` with `SingleTickerProviderStateMixin`:
- AnimationController duration 2200ms `repeat(reverse: true)`.
- Build: IgnorePointer > Stack:
  - Positioned.fill > CustomPaint(painter: `_VignettePainter(viewport)`).
  - Center > SizedBox(viewport×viewport) > Stack:
    - 4 `_Corner` di Alignment.topLeft/topRight/bottomLeft/bottomRight, color p.primary.
    - AnimatedBuilder(_c) > Positioned(left:16, right:16, top: 16 + (viewport-32) * _c.value) > Container(h:2, bg p.primary, shadow `BoxShadow(p.primary @0.6, blur 10, spread 1)`) — garis scan animated.

`_Corner extends StatelessWidget`:
- Field: `alignment: Alignment, color`.
- Static const `_len = 28, _thick = 3.5`.
- Align(alignment) > SizedBox(28×28) > Stack:
  - 2 Container (horizontal & vertical), Positioned di sudut sesuai alignment.

`_VignettePainter extends CustomPainter`:
- Field: `viewport`.
- paint: paint color `const Color(0xE60A0703)` (hampir hitam 90% opacity).
- path = Path > addRect(seluruh canvas) > addRRect(hole rect viewport×viewport centered, radius 24) > fillType evenOdd.
- drawPath. shouldRepaint → old.viewport != viewport.
````

---

## Verifikasi

```dart
Column(children: [
  Row(children: [
    const ProductImg(name: 'Kopi Susu', hue: 28, size: 64),
    const SizedBox(width: 12),
    const AppAvatar(name: 'Saiful Bahri'),
    const SizedBox(width: 12),
    const MethodBadge(method: PaymentMethod.cash),
    const SizedBox(width: 8),
    const MethodBadge(method: PaymentMethod.qris),
  ]),
  const SizedBox(height: 16),
  const Center(child: BrandMark()),
  const SizedBox(height: 16),
  const AppQrView(data: 'https://example.com/qris/abc123'),
  const SizedBox(height: 16),
  const AppTrendChart(
    data: [12, 18, 9, 24, 30, 22, 35],
    labels: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
  ),
])
```

ScannerOverlay diuji nanti di step 21 saat kita pakai mobile_scanner.

## Talking points

1. **Hue rotation di `ProductImg`**:
   Setiap produk butuh fallback tile berbeda warnanya supaya cepat dikenali. Pakai `hue = productId * 47 % 360` (47 prime mengurangi clustering) saat migrate.

2. **`CustomPaint` vs SVG**:
   Untuk BrandMark, kita pakai CustomPaint inline supaya bisa di-tint murni via palette (tidak bisa kalau dari SVG asset, kecuali kita pakai `colorFilter`). Trade-off: kode lebih panjang vs zero-asset dependency.

3. **`Path` `evenOdd` fill** untuk vignette:
   Trick standar untuk bikin "lubang" di overlay. Tambahkan 2 rect ke path → fill akan render area antara keduanya. Sangat berguna untuk modal cutout.

4. **`fl_chart` minimal styling**:
   Default `LineChart` ada axis berisik. Hide semua titles kecuali bottom labels, no grid, no border. Tampil clean dan fokus ke data.

5. **`SingleTickerProviderStateMixin` vs `TickerProviderStateMixin`**:
   Single = 1 AnimationController. Multi = banyak. Pakai single kalau cukup; saving small memory.

6. **`QrImageView.errorCorrectionLevel: H`**:
   H = High = 30% data bisa rusak dan QR masih kebaca. Trade-off: QR lebih dense. Untuk QRIS dengan logo overlay 20%, H wajib.

## Commit suggestion

```bash
git add lib/core/components/product_img.dart lib/core/components/avatar.dart lib/core/components/method_badge.dart lib/core/components/brand_mark.dart lib/core/components/qr_view.dart lib/core/components/trend_chart.dart lib/core/components/scanner_overlay.dart
git commit -m "Step 09: atoms — domain (product img, avatar, method badge, brand mark, qr view, trend chart, scanner overlay)"
```

---

➡️ Lanjut ke [Step 10 — Models: Request & Response](./10-models-request-response.md)
