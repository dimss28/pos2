# 37 — ManageProductPage + AddProductPage + ProductDetailSheet

## Goal

CRUD produk: list dengan filter kategori + status stock badge, FAB ke AddProduct, tap card buka detail sheet (info + stats + edit + hapus).

## Prerequisite

- Step 36 selesai. `ProductBloc.addProduct/updateProduct` ada.

## Konsep yang diajarkan

- **`image_picker`** + compress sebelum upload.
- **Form validation per field** dengan error state lokal.
- **Edit vs add reuse** — sama page, beda mode.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. ProductBloc punya addProduct(Product, XFile) dan updateProduct(...). Package `image_picker`, `image` (untuk compress).

Generate 3 file.

═══════════════════════════════════════════════
FILE 1: lib/presentation/setting/pages/manage_product_page.dart
═══════════════════════════════════════════════
StatefulWidget. State: `_filter: String = 'all'`.

initState: `ProductBloc.fetchLocal` + `CategoryBloc.getCategoriesLocal`.

Build:
- Scaffold(bg surface, appBar: AppAppBar(title: 'Kelola Produk', trailing: [AppIconButton(search, onPressed: showSearch)])).
- floatingActionButton: FloatingActionButton.extended(icon: add, label: 'Produk Baru', backgroundColor: p.primary, foregroundColor: p.onPrimary, onPressed: () => push AddProductPage()).
- body: Column:
  1. Chips filter row (Wrap horizontal, padding 16):
     - AppChip('Semua', active: _filter == 'all').
     - For each category: AppChip(c.name, active: _filter == c.name).
  2. Expanded > BlocBuilder<ProductBloc>:
     - success(list):
       - filtered = list.where(_filter == 'all' || _.category == _filter).
       - Empty: AppEmptyState 'Belum ada produk'.
       - Else: ListView.separated padding 16:
         - For each product: AppCard(onTap: () => showAppBottomSheet(ProductDetailSheet(product, onEdit, onDelete))):
           - Row: ProductImg 56, SpaceWidth 12.
           - Expanded Column: Text name bodyL w600, Text price.currencyFormatRp bodyS onSurfaceVar, Row: AppBadge stockLow/stockOut/qty kalau perlu, plus category text.
           - Icon chevron_right onSurfaceVar.

═══════════════════════════════════════════════
FILE 2: lib/presentation/setting/widgets/product_detail_sheet.dart
═══════════════════════════════════════════════
StatelessWidget. Field: `product, onEdit, onDelete`.

Column:
- Center ProductImg 88 + Text name titleL center + Text price priceL center.
- SpaceHeight 16.
- AppCard 3-stat row:
  - Stat 'Stok' (product.stock).
  - Stat 'Kategori' (product.category).
  - Stat 'Status' (product.isBestSeller ? 'Bestseller' : 'Reguler').
- SpaceHeight 16.
- AppKeyValueRow 'Harga jual' price.currencyFormatRp.
- AppKeyValueRow 'ID Produk' '#${product.id}'.
- SpaceHeight 20.
- Row:
  - Expanded AppButton.outline('Hapus', danger style? variant danger, onPressed: () => AppConfirm → onDelete()).
  - SpaceWidth 12.
  - Expanded AppButton.primary('Edit', onPressed: () { pop sheet; onEdit(); }).

═══════════════════════════════════════════════
FILE 3: lib/presentation/setting/pages/add_product_page.dart
═══════════════════════════════════════════════
StatefulWidget. Field: `Product? existing` (kalau edit). State: name, priceCtrl (with money formatter), stockCtrl, category, categoryId, _image: XFile?, isBestSeller.

initState: kalau `existing != null`, prefill semua field.

Build:
- Scaffold appBar 'Produk Baru' atau 'Edit Produk'.
- body: ListView padding 16:
  - Center _ImagePicker:
    - InkWell tap → showAppActionSheet(['Ambil foto kamera', 'Pilih dari galeri']) → image_picker.
    - Container 120×120 bg surfaceVariant radius mdAll. Tampilkan _image kalau ada (atau existing.displayImageUrl). Else: Icon add_photo_alternate 40 onSurfaceVar.
  - SpaceHeight 24.
  - AppTextField 'Nama Produk', controller _nameCtrl.
  - AppTextField 'Harga' (prefix Rp, money formatter via AppMoneyTextField).
  - AppSectionLabel 'Stok'.
  - AppStepperField(value: _stock, min: 0, onChanged).
  - AppSectionLabel 'Kategori'.
  - Dropdown / chips pilih kategori from `CategoryBloc.state`.
  - AppSwitchTile('Tandai sebagai Bestseller', value: _isBestSeller, onChanged).
- bottomNavigationBar AppStickyFooter:
  - BlocConsumer<ProductBloc>:
    - listener: success → snackbar + pop.
    - builder: loading → AppButton.primary loading.
  - AppButton.primary(label: existing == null ? 'Simpan' : 'Update', onPressed: _submit).

`_submit()`:
- Validate semua field. Kalau image null & existing null → error 'Pilih foto'.
- Compress image (kalau >500KB pakai package `image`).
- Kalau existing → `ProductBloc.add(updateProduct(productId: existing.id!, product: ..., image: _image))`.
- Else → `ProductBloc.add(addProduct(product, _image!))`.

═══════════════════════════════════════════════
PERMISSION ANDROID
═══════════════════════════════════════════════
Untuk Android 13+, butuh `<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>` di AndroidManifest.
Plus rationale dialog ditangani oleh image_picker plugin.
````

---

## Verifikasi

1. SettingPage → Kelola Produk → list produk.
2. FAB → AddProductPage → fill form → pick image → Simpan → produk muncul di list.
3. Tap produk → detail sheet → Edit → AddProductPage prefilled → ubah → Update.
4. Detail sheet → Hapus → konfirm → produk hilang (manual hapus belum kita implement di datasource — tambahkan `ProductBloc.add(removeProduct)` + `ProductRemoteDatasource.delete` kalau perlu).

## Talking points

1. **Image compress sebelum upload**: foto HP modern bisa 5MB. Resize ke ~512px width + quality 80 → ~100KB. Cepat upload + hemat storage BE.

2. **Edit vs Add 1 page**: parameter `existing: Product?`. UX consistent, kode reuse.

3. **`AppStepperField`** untuk stock: lebih ergonomis daripada TextField numeric — kasir UMKM gak suka ngetik angka di HP.

4. **`is_best_seller` toggle**: visible bestseller di HomePage grid (badge ⭐).

5. **Dropdown kategori vs chips**: dropdown saat banyak (>10), chips saat sedikit. POS UMKM biasanya <10.

## Commit suggestion

```bash
git add lib/presentation/setting/pages/manage_product_page.dart lib/presentation/setting/widgets/product_detail_sheet.dart lib/presentation/setting/pages/add_product_page.dart android/app/src/main/AndroidManifest.xml
git commit -m "Step 37: Manage product (list, detail sheet, add/edit)"
```

---

➡️ Lanjut ke [Step 38 — Manage Printer](./38-manage-printer.md)
