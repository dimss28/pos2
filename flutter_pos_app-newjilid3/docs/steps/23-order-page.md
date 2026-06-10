# 23 — OrderPage (Detail Keranjang + Pilih Metode Bayar)

## Goal

`OrderPage` lengkap: list item cart (stepper per row, hapus, tambah catatan), summary (subtotal, diskon, total), customer/table info dari cart, segmented toggle metode bayar (Cash / QRIS / Transfer), tombol "Bayar Rp. X →" yang trigger sheet sesuai metode. Empty state kalau cart kosong.

## Prerequisite

- Step 22 (CheckoutBloc) selesai. Atom `AppStepper`, `AppKeyValueRow`, `AppButton.primaryWithArrow`, `AppSegmentedToggle`, `AppBottomSheet` ready.
- `PaymentConfirmSheet`, `PaymentQRISSheet`, `OrderBloc` belum ada — stub & TODO ke step 25/26/28.

## Konsep yang diajarkan

- **2-state UI**: empty cart vs items.
- **Subtotal vs Total**: subtotal = sum items, total = subtotal − discount (discount step 42).
- **Bottom sheet trigger** dari sticky footer.
- **`BlocConsumer`** listener pop ke HomePage saat cart kosong setelah remove.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada `CheckoutBloc`, `CheckoutSummary`, atom AppStepper/AppKeyValueRow/AppButton/AppSegmentedToggle/AppBottomSheet/AppEmptyState/AppCard/AppListGroup/AppSectionLabel/AppStickyFooter/AppAppBar/AppIconButton/ProductImg/feedback.dart, ext currency.

Generate `lib/presentation/order/pages/order_page.dart` (replace stub).

═══════════════════════════════════════════════
STRUKTUR PAGE
═══════════════════════════════════════════════
`OrderPage extends StatefulWidget` (state simpan `_paymentMethod: String = 'cash'`, `_customerCtrl: TextEditingController`).

Build:
- `Scaffold(bg p.surface)`:
- `appBar: AppAppBar(title: 'Detail Order', subtitle: '#ORD-DRAFT', trailing: [AppIconButton(more_horiz, onPressed: showActions)])`.
- body: `BlocBuilder<CheckoutBloc, CheckoutState>` extract `cart` (default empty).
  - Kalau `cart.isEmpty`:
    - `AppEmptyState(visual: Container 88×88 bg primaryContainer Icon shopping_cart_outlined 40 primary, title: 'Keranjang kosong', body: 'Pilih produk dari Home untuk mulai order.', primaryAction: AppButton.outline(label: 'Ke Home', fullWidth: false, onPressed: () { DashboardScope.of(context)?.switchTo(0); context.pop(); }))`.
  - Else:
    - `Column`:
      - Expanded > ListView padding 16:
        1. **Customer & meja card** (kalau `cart.linkedTableLabel != null`):
           - `AppCard` Row: Icon table_restaurant 20 onSurface, SpaceWidth 8, Column Text 'Meja' bodyS onSurfaceVar, Text cart.linkedTableLabel bodyL w600. Spacer. Column Text 'Customer' bodyS onSurfaceVar, Text cart.linkedCustomerName bodyL w600.
        2. **AppSectionLabel('Item Pesanan')**.
        3. **`AppListGroup` of `_CartRow(item)`** untuk setiap `cart.products`.
        4. SpaceHeight 18.
        5. **AppSectionLabel('Metode Pembayaran')**.
        6. `AppSegmentedToggle<String>(options: [SegmentOption('cash', 'Cash'), ('qris', 'QRIS'), ('transfer', 'Transfer')], value: _paymentMethod, onChanged: setState)`.
        7. SpaceHeight 18.
        8. **AppSectionLabel('Ringkasan')** dalam AppCard:
           - `AppKeyValueRow(label: 'Subtotal', value: cart.totalPrice.currencyFormatRp)`.
           - (Step 42 nanti) `AppKeyValueRow(label: 'Diskon', value: '- Rp. 0', variant: muted)`.
           - `AppKeyValueRow(label: 'Total', value: cart.totalPrice.currencyFormatRp, variant: big)`.
      - **Sticky footer** `AppStickyFooter`:
        - Row:
          - AppButton.outline(label: 'Simpan ke Draft', fullWidth: false, onPressed: showOpenBillSheet).
          - SpaceWidth 12.
          - Expanded > AppButton.primaryWithArrow(label: 'Bayar ${cart.totalPrice.currencyFormatRp.trim()}', onPressed: _onPayTap).

═══════════════════════════════════════════════
`_CartRow(OrderItem item)`:
═══════════════════════════════════════════════
Padding 12:
- Row.start:
  - ProductImg(name, hue, imageUrl: item.product.displayImageUrl, size: 56).
  - SpaceWidth 12.
  - Expanded Column.start:
    - Text product.name bodyL w600.
    - Text product.price.currencyFormatRp bodyS onSurfaceVar.
    - SpaceHeight 6.
    - InkWell 'Tambah catatan' / item.note → tap pop bottom sheet input text → setState note.
  - Column.end:
    - Text `(item.quantity * item.product.price).currencyFormatRp` priceM.
    - SpaceHeight 6.
    - AppStepper(qty: item.quantity, max: item.product.stock, onChanged: v > qty ? add : remove).

═══════════════════════════════════════════════
HANDLERS
═══════════════════════════════════════════════
- `_onPayTap()`:
  - Validasi cart not empty.
  - **Step 25 nanti**: kalau cash → `showAppBottomSheet(PaymentConfirmSheet(cart))`.
  - **Step 28**: qris → `PaymentQRISSheet`.
  - Sementara: `AppSnackbar.info(context, 'TODO step 25-28')`.
- `showActions()`:
  - `showAppActionSheet` dengan menu: 'Hapus semua' (destructive → AppConfirm → `CheckoutBloc.add(started())`).
- `showOpenBillSheet()`:
  - **Step 24**: `showAppBottomSheet(OpenBillSheet)`. Sementara stub.

═══════════════════════════════════════════════
BLOCLISTENER (di build atas Scaffold, wrap):
═══════════════════════════════════════════════
- `BlocListener<CheckoutBloc, CheckoutState>(listener: (ctx, state) {`:
  - `savedDraftOrder()` → AppSnackbar.success 'Disimpan sebagai draft' + context.pop().
- `}, child: Scaffold(...))`.
````

---

## Verifikasi

1. Tambah 3 item dari Home → tap badge Order di bottom nav → masuk OrderPage.
2. Tampil 3 row item, total = subtotal.
3. Tap +/− di stepper → total update live.
4. Tap "Tambah catatan" → bottom sheet input → setelah save, catatan tampil di bawah produk.
5. Toggle Cash/QRIS/Transfer → state berubah (warna segmented).
6. Tap "Bayar..." → snackbar TODO.

## Talking points

1. **`Column` + Expanded + ListView + sticky footer** pattern:
   Body bagi 2: list scrollable (Expanded) + footer fixed bottom. Tanpa Expanded ListView, ListView tidak tahu maxHeight → crash.

2. **`DashboardScope.of(context)?.switchTo(0)`**:
   Pakai inheritedWidget dari step 18 untuk pindah tab tanpa rebuild dashboard.

3. **Customer/meja card conditional**:
   Tampil hanya kalau cart loaded dari draft (`linkedTableLabel != null`). New cart langsung biasanya gak punya — user input pas save draft.

4. **Catatan per item**:
   Stored di `OrderItem.note`. Pakai bottom sheet kecil (TextField + AppButton.primary) — bukan inline TextField. Lebih clear separation.

5. **Pay button enabled meski cart kosong?**
   UI sebaiknya disabled. Tapi cart kosong → empty state ditampilkan, jadi tombol Pay tidak terjangkau visual. Aman.

6. **Sticky footer 2 tombol** (Draft + Bayar):
   Row dengan AppButton.outline(fullWidth: false) + Expanded(AppButton.primaryWithArrow). Width berbeda → primary tetap dominan.

## Commit suggestion

```bash
git add lib/presentation/order/pages/order_page.dart
git commit -m "Step 23: OrderPage cart detail + payment method toggle + sticky footer"
```

---

➡️ Lanjut ke [Step 24 — OpenBillSheet (Simpan Draft)](./24-open-bill-sheet.md)
