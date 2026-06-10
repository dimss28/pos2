# 20 — HomePage (Grid + Filter + Search + Floating Cart Bar)

## Goal

`HomePage` lengkap: header, search bar dengan tombol scan, chips kategori, view toggle grid/list, grid produk dengan stepper langsung di card, empty state "Belum ada produk", floating cart bar.

## Prerequisite

- Step 19 (ProductBloc, CategoryBloc) selesai.
- Cart belum ada — pakai dummy `CheckoutSummary` placeholder. Step 22 nanti akan integrate `CheckoutBloc` beneran.

## Konsep yang diajarkan

- **`Stack` untuk floating overlay** (cart bar di atas grid).
- **`GridView.builder` + `SliverGridDelegateWithFixedCrossAxisCount`** — grid responsif.
- **`AspectRatio`** untuk product image.
- **In-memory search dengan debounce minimal length** (>= 3 chars).
- **Stock state machine**: `outOfStock | atCap | lowStock | normal`.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada: `ProductBloc`, `CategoryBloc` (step 19), atom `AppChip`, `AppButton`, `AppEmptyState`, `AppStepper`, `AppIconButton`, `AppCountBadge`, `ProductImg`, `feedback.dart`. Cart belum ada — sementara pakai placeholder `CheckoutSummary` dummy class di file ini.

Generate `lib/presentation/home/pages/home_page.dart` (replace stub).

═══════════════════════════════════════════════
SECTION 1: imports + page state
═══════════════════════════════════════════════
- Class `HomePage extends StatefulWidget`.
- State punya:
  - `_searchCtrl: TextEditingController` (dispose di dispose).
  - `_activeCategoryId: int = 0` (0 = 'Semua').
  - `_view: _ViewMode = _ViewMode.grid` (enum private `{ grid, list }`).
- initState:
  - `context.read<ProductBloc>().add(const ProductEvent.fetchLocal())`.
  - `context.read<CategoryBloc>().add(const CategoryEvent.getCategoriesLocal())`.
  - Auto-reconnect printer: `AuthLocalDatasource().getPrinter().then((mac) async { if (mac.isNotEmpty) await PrintBluetoothThermal.connect(macPrinterAddress: mac); })`.

═══════════════════════════════════════════════
SECTION 2: search handler
═══════════════════════════════════════════════
`_onSearch(String v)`:
- Kalau `v.length >= 3` → `ProductEvent.searchProduct(v)`.
- Kalau `v.isEmpty` → `ProductEvent.fetchAllFromState()`.
- Else: do nothing (debounce minimal length).

═══════════════════════════════════════════════
SECTION 3: category tap handler
═══════════════════════════════════════════════
`_onCategoryTap(Category? c)`:
- setState `_activeCategoryId = c?.id ?? 0`.
- Kalau null → `fetchLocal` (semua).
- Else → `fetchByCategory(c.name)`.

═══════════════════════════════════════════════
SECTION 4: build
═══════════════════════════════════════════════
`Scaffold(bg p.surface) > SafeArea(bottom:false) > BlocBuilder<CheckoutBloc, CheckoutState>(builder)` — extract cart (default `const CheckoutSummary()` placeholder, totalQuantity=0). Untuk step ini, **gunakan placeholder `CheckoutSummary` minimal**:
```dart
// Placeholder sampai step 22. Real CheckoutSummary di lib/presentation/home/models/checkout_summary.dart.
class CheckoutSummary {
  final int totalQuantity;
  final int totalPrice;
  final List<dynamic> products;
  const CheckoutSummary({this.totalQuantity = 0, this.totalPrice = 0, this.products = const []});
}
```

Body = `Stack`:
- Column children:
  1. `_Header(today: _today(), cartCount: cart.totalQuantity)` — Row: Expanded Text 'Sudut Kopi · Bandung' (FittedBox scaleDown, titleL), spacing 12, Text cartCount > 0 ? '$cartCount di keranjang' : today (bodyS, onSurfaceVar).
  2. `_SearchAndScan(controller: _searchCtrl, onChanged: _onSearch)` — Container 48h, bg `p.surfaceVariant`, radius `mdAll`, padding 14/0/6/0. Row: Icon search 18 onSurfaceVar, spacing 10, Expanded TextField (placeholder 'Cari produk atau scan...', no border via `InputBorder.none`), InkWell scan icon 36×36 bg `p.primary` radius `smAll` → push ScannerPage (step 21 stub kalau belum ada).
  3. `_CategoryChipsRow(activeId, onPick: _onCategoryTap, view: _view, onViewChanged)` — Row:
     - Expanded SizedBox(h:36) > BlocBuilder<CategoryBloc>: extract list (loaded or loadedLocal). ListView horizontal: leading AppChip 'Semua' (active activeId==0), lalu for each category AppChip(name, active activeId==c.id).
     - SpaceWidth 10, `_ViewToggleWidget(view, onChanged)` — Container padding:3 bg `p.surfaceVariant` radius `smAll`. Dua sel grid_view_rounded / view_list_rounded; aktif → AnimatedContainer 150ms bg white + shadow ringan.
  4. Expanded `_ProductsBody(view: _view, cart)`:
     - BlocBuilder<ProductBloc>:
       - loading/orElse → CircularProgressIndicator.
       - error(msg) → `AppEmptyState.error(message: msg, onRetry: () => fetchLocal())`.
       - success(products):
         - Kalau empty → `_HomeEmpty` (AppEmptyState dengan visual coffee_outlined 88×88 bg primaryContainer, title 'Belum ada produk', body sinkron pesan, primaryAction "Sinkronkan sekarang" → trigger `SyncBloc.syncAll()` (kalau SyncBloc belum ada di step ini, sementara pakai snackbar info).
         - Else: pad = cart.totalQuantity > 0 ? 180 : 100. Grid (`SliverGridDelegateWithFixedCrossAxisCount(crossAxis:2, spacing:10, childAspectRatio:0.68)`) atau ListView.separated (8px spacer) tergantung _view. Item = `_ProductGridCard(product, qty)` / `_ProductListRow(product, qty)`.
- Kalau `cart.totalQuantity > 0`, di Stack juga: `Positioned(bottom:16, left:16, right:16, child: _FloatingCartBar(cart))`.

═══════════════════════════════════════════════
SECTION 5: _ProductGridCard
═══════════════════════════════════════════════
`StatelessWidget` dengan `product`, `qty`. Internal:
- hueFor: `((product.productId ?? product.id ?? 0) * 47) % 360`.
- Compute: inCart = qty>0, stock = product.stock, outOfStock = stock<=0, atCap = !outOfStock && qty>=stock, lowStock = !outOfStock && stock<5, disabled = outOfStock || atCap.
- Opacity(outOfStock ? 0.55 : 1) > Material(white, radius mdAll) > InkWell(onTap: disabled ? null : addCheckout, radius mdAll) > Container(padding:10, border 1.5px primary@55% kalau inCart else 1px outlineSoft, radius mdAll):
  - Column.start:
    - Stack(clipBehavior:none):
      - AspectRatio 1:1 > ProductImg(name, hue, imageUrl: product.displayImageUrl, size:double.infinity).
      - Kalau inCart: Positioned(top:-6, right:-6, AppCountBadge(qty, border: p.surface)).
      - Kalau outOfStock: Positioned(left:4, top:4, `_StockBadge.outOfStock(p)`).
      - Else kalau lowStock: Positioned `_StockBadge.low(p, stock)`.
    - SpaceHeight 8.
    - Text name (bodyM.copyWith(onSurface, 13, w600), ellipsis).
    - Text category (bodyS.copyWith(onSurfaceVar, 11), ellipsis).
    - Spacer.
    - Row spaceBetween:
      - Expanded Text price (`product.price.currencyFormatRp.trim()`, priceM.copyWith(onSurface, 15)).
      - Kalau inCart: AppStepper(qty, max:stock, size:sm, onChanged: v > qty ? addCheckout : removeCheckout).
      - Else: Container 32×32 bg disabled ? surfaceDim : primary, radius smAll, Icon add 18 onPrimary/onSurfaceVar.

`_StockBadge` (private):
- 2 factory: `outOfStock(p)` → bg errorContainer, fg error, 'HABIS'. `low(p, stock)` → bg warningContainer, fg warning, 'Sisa $stock'.
- Container padding h:8/v:3, radius pill (999), Text labelM.copyWith(fontSize:9, w700, letterSpacing:0.4).

═══════════════════════════════════════════════
SECTION 6: _ProductListRow
═══════════════════════════════════════════════
Mirip GridCard tapi layout horizontal. ProductImg 64×64 di kiri, Column info di tengah (Expanded), stepper/AppIconButton di kanan.

═══════════════════════════════════════════════
SECTION 7: _FloatingCartBar
═══════════════════════════════════════════════
Material(bg p.primary, radius lgAll) > InkWell(onTap: push OrderPage) > Container(padding 18/10/10/10, shadow primary@33% blur:24 offset(0,12)):
- Row:
  - Stack: Container 36×36 bg p.onPrimary @18% radius smAll Icon shopping_cart_outlined 18 onPrimary. Positioned top/right -4: AppCountBadge(qty, background: p.onSurface, foreground: p.surface).
  - SpaceWidth 12.
  - Expanded Column.start: Text '$qty item dipilih' (bodyS, onPrimary@85%, 11), Text totalPrice (titleM, onPrimary, 16, w700).
  - Container 40h padding 14/0/10/0 bg p.onPrimary radius mdAll: Row Text 'Bayar' (labelL, p.primary, 13, w700), SpaceWidth 6, Icon arrow_forward 16 p.primary.

═══════════════════════════════════════════════
SECTION 8: _today() helper
═══════════════════════════════════════════════
Static method return `'${days[weekday-1]}, ${day} ${months[month-1]}'` dengan months 3-letter ID (Jan, Feb, Mar, ..., Mei, ..., Des) dan days 3-letter (Sen, Sel, ..., Min).

═══════════════════════════════════════════════
CATATAN UNTUK STEP INI
═══════════════════════════════════════════════
- ScannerPage belum dibuat (step 21). Sementara `Navigator.push(MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('TODO step 21'))))`.
- `CheckoutBloc` belum dibuat. Sementara `BlocBuilder<CheckoutBloc, CheckoutState>` REPLACE dengan widget langsung tanpa wrap, kosongkan cart (totalQuantity = 0). Atau lebih bersih: bikin `CheckoutBloc` stub satu file dengan state initial yang punya `CheckoutSummary` cell, registrasi di `main.dart`. Note untuk peserta: cart logic asli ada di step 22.
- `SyncBloc` belum ada → tombol "Sinkronkan sekarang" sementara hanya snackbar info.
````

---

## Verifikasi

1. Run app → login → splash → dashboard. Tab Home aktif.
2. Kalau DB kosong (fresh install) → empty state tampil dengan tombol "Sinkronkan sekarang".
3. Kalau ada data lokal (via test atau dari step 19 manual insert) → grid produk render.
4. Toggle grid/list works.
5. Search > 3 char filter, search kosong reset.

## Talking points

1. **`Stack` untuk floating cart bar**:
   Alternatif: pakai `bottomSheet` Scaffold. Tapi cart bar harus selalu visible (tidak draggable) dan posisinya 16px dari bottom (di atas bottom nav). Stack lebih akurat untuk ini.

2. **`SliverGridDelegateWithFixedCrossAxisCount` vs `Wrap`**:
   - Grid → uniform sizing, scrollable.
   - Wrap → responsive sizing.
   POS pakai grid karena tile produk butuh ukuran konsisten untuk grid visual.

3. **`childAspectRatio: 0.68`**:
   Width / height ratio. <1 = tall (portrait-like). Tile produk butuh ruang vertikal untuk image + name + harga + stepper.

4. **Search debounce dengan length threshold (≥3)**:
   Hindari hit operation tiap karakter. Pakai 3 sebagai kompromi UX (kebanyakan kata produk >3 huruf). Production: Tambah debounce timer 300ms juga.

5. **Floating cart bar conditional render**:
   `if (cart.totalQuantity > 0)` → cart bar tidak muncul saat cart kosong. Lebih clean dari render-with-opacity-0.

6. **Stock state machine eksplisit**:
   `outOfStock`, `atCap`, `lowStock`, `normal` — bukan 1 `disabled` bool. Eksplisit memudahkan: kasih badge berbeda untuk out vs low; tap behavior beda untuk at-cap.

7. **`_StockBadge` factory** vs constructor biasa:
   2 use case berbeda → 2 factory bernama. Lebih readable: `_StockBadge.outOfStock(p)` vs `_StockBadge('HABIS', p.errorContainer, p.error)`.

8. **`AspectRatio` + `ProductImg(size: double.infinity)`**:
   ProductImg punya `LayoutBuilder` fallback kalau size tidak finite → resolve dari constraint parent.

## Commit suggestion

```bash
git add lib/presentation/home/pages/home_page.dart
git commit -m "Step 20: HomePage grid/list with search, filter, floating cart bar"
```

---

➡️ Lanjut ke [Step 21 — ScannerPage](./21-scanner-page.md)
