# 35 — TutupKasirPage + CloseKasirSuccessSheet

## Goal

Halaman tutup kasir: recap penjualan (cash revenue, qris, transfer), expected cash, input physical count, hitung variance, checklist, tombol "Tutup Shift". Setelah sukses → CloseKasirSuccessSheet → logout / kembali login.

## Prerequisite

- Step 34 selesai.
- `CashSessionLocalDatasource.cashRevenueOf(sessionId)` ready.

## Konsep yang diajarkan

- **Variance math**: `expected = opening + cashIn − cashOut + cashRevenue`; `variance = physical − expected`.
- **Pre-close guard** (Step 40 nanti): cek pendingOrderCount = 0 sebelum allow close.
- **Checklist confirmation** UI pattern — kasir confirm step-by-step.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `CashSessionBloc.close(...)` ready. `CashSessionLocalDatasource.cashRevenueOf` ready.

Generate 2 file.

═══════════════════════════════════════════════
FILE 1: lib/presentation/cash_session/pages/tutup_kasir_page.dart
═══════════════════════════════════════════════
`StatefulWidget`. State:
- `_physicalCount: int = 0`.
- `_cashIn: int = 0`, `_cashOut: int = 0`.
- `_noteCtrl: TextEditingController`.
- `_cashRevenue: int = 0` (loaded from DB).
- `_checkPrintRecap, _checkPhysicalCount, _checkSecureDrawer: bool = false`.

initState: `_loadRevenue()`.

`_loadRevenue()`:
- Read state CashSessionBloc.maybeWhen(open: (s) => s, orElse: () => null).
- `_cashRevenue = await CashSessionLocalDatasource.instance.cashRevenueOf(session.id!)`.
- setState.

Compute getters:
- `_expected = session.openingFloat + _cashIn - _cashOut + _cashRevenue`.
- `_variance = _physicalCount - _expected`.
- `_isBalanced => _variance == 0`.
- `_isShort => _variance < 0` (lebih sedikit, ada selisih kurang).
- `_isOver => _variance > 0` (lebih banyak).
- `_canClose => _checkPrintRecap && _checkPhysicalCount && _checkSecureDrawer && _physicalCount > 0`.

Build:
- Scaffold(bg surface) > AppAppBar(title: 'Tutup Kasir', subtitle: 'Shift ${session.shiftLabel} · dibuka ${session.openedAt.toFormattedTime()}').
- body: ListView padding 16 (Expanded di Column dengan sticky footer):
  1. **Recap penjualan** AppCard:
     - AppKeyValueRow(label: 'Modal Awal', value: openingFloat.currencyFormatRp).
     - AppKeyValueRow(label: 'Penjualan Cash', value: _cashRevenue.currencyFormatRp).
     - AppKeyValueRow(label: 'Cash In tambahan', value: '+${_cashIn.currencyFormatRp}', variant: muted).
     - AppKeyValueRow(label: 'Cash Out tambahan', value: '-${_cashOut.currencyFormatRp}', variant: muted).
     - AppKeyValueRow(label: 'Estimasi Kas Akhir', value: _expected.currencyFormatRp, variant: highlight).
  2. SpaceHeight 16.
  3. **AppSectionLabel('Kas Fisik')**.
  4. AppMoneyTextField(label: 'Jumlah uang aktual di laci', autofocus: false, onChanged: (v) => setState(_physicalCount = v)).
  5. **Variance banner** (kalau _physicalCount > 0):
     - AppBanner:
       - balanced → kind: success, title: 'BALANCED', body: 'Kas sesuai estimasi'.
       - short → kind: warning, title: 'KURANG ${_variance.abs().currencyFormatRp}', body: 'Cek transaksi terakhir'.
       - over → kind: info, title: 'LEBIH ${_variance.currencyFormatRp}', body: 'Mungkin ada kembalian yang belum dicatat'.
  6. SpaceHeight 16.
  7. **(opsional)** AppSectionLabel('Cash In/Out tambahan') + 2 AppMoneyTextField untuk `_cashIn` dan `_cashOut` (default 0).
  8. SpaceHeight 16.
  9. **AppSectionLabel('Checklist sebelum tutup')** AppListGroup:
     - `_ChecklistRow(label: 'Cetak struk recap shift', value: _checkPrintRecap, onChanged: setState)`.
     - `_ChecklistRow(label: 'Hitung kas fisik selesai', value: _checkPhysicalCount, onChanged: setState)`.
     - `_ChecklistRow(label: 'Kas dimasukkan ke brankas', value: _checkSecureDrawer, onChanged: setState)`.
  10. SpaceHeight 16.
  11. AppTextField(label: 'Catatan (opsional)', controller: _noteCtrl, maxLines: 2).
  12. SpaceHeight 80 (untuk sticky footer).
- bottomNavigationBar: AppStickyFooter > BlocConsumer<CashSessionBloc>:
  - listener:
    - noSession(closed) → showAppBottomSheet CloseKasirSuccessSheet(closed) → after close sheet, pushAndRemoveUntil LoginPage.
    - error(msg) → AppSnackbar.error.
  - builder: loading: AppButton.danger(label: 'Tutup Shift', loading, onPressed: _canClose && !loading ? submit : null).

`_ChecklistRow`:
- InkWell onTap toggle. Padding 14. Row:
  - Icon `value ? Icons.check_circle : Icons.radio_button_unchecked` 22 `value ? success : onSurfaceVar`.
  - SpaceWidth 12.
  - Expanded Text label bodyM color value ? onSurface : onSurfaceVar.

submit():
- `context.read<CashSessionBloc>().add(CashSessionEvent.close(physicalCount: _physicalCount, cashIn: _cashIn, cashOut: _cashOut, note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim()))`.

═══════════════════════════════════════════════
FILE 2: lib/presentation/cash_session/pages/close_kasir_success_sheet.dart
═══════════════════════════════════════════════
`StatelessWidget` dengan `CashSessionModel closed`. Build:
- Column.center:
  - Container 84×84 bg successContainer circle, Icon check_rounded 48 success.
  - SpaceHeight 16.
  - Text 'Shift Ditutup' titleL.
  - SpaceHeight 4.
  - Text 'Terima kasih, shift ${closed.shiftLabel} selesai' bodyM onSurfaceVar.
  - SpaceHeight 20.
  - AppCard recap:
    - AppKeyValueRow('Dibuka', closed.openedAt.toFormattedTime()).
    - AppKeyValueRow('Ditutup', closed.closedAt!.toFormattedTime()).
    - AppKeyValueRow('Modal Awal', closed.openingFloat.currencyFormatRp).
    - AppKeyValueRow('Kas Akhir', closed.physicalCount?.currencyFormatRp ?? '-').
    - AppKeyValueRow('Variance', (closed.variance ?? 0).currencyFormatRp, variant: (closed.variance ?? 0) == 0 ? accent : muted).
  - SpaceHeight 20.
  - Row:
    - Expanded AppButton.outline(label: 'Cetak Recap', leadingIcon: print_outlined, onPressed: _printRecap).
    - SpaceWidth 12.
    - Expanded AppButton.primary(label: 'Logout', onPressed: () { context.read<LogoutBloc>().add(LogoutEvent.logout()); }).

═══════════════════════════════════════════════
STEP 3: Wiring
═══════════════════════════════════════════════
- SettingPage (step 36): "Tutup Kasir" tile → `context.push(const TutupKasirPage())`.
- LogoutBloc listener (di SettingPage): success → removeAuthData → pushAndRemoveUntil LoginPage.
````

---

## Verifikasi

1. Login + open shift → bikin beberapa order cash.
2. Setting → Tutup Kasir → recap tampil dengan estimasi correct.
3. Input physical count = expected → variance banner "BALANCED".
4. Input less → "KURANG Rp X".
5. Check all 3 checklist → tombol enabled → "Tutup Shift" → success sheet → Logout → LoginPage.
6. Re-login → BukaKasirPage (no open session).

## Talking points

1. **Expected vs actual = variance**:
   Formula transparent. Kasir tahu sumber selisih (kurang/lebih), action item jelas.

2. **Checklist sebagai friction**:
   Sengaja friction supaya kasir checklist dulu — bukan langsung tap close → tutup tanpa hitung kas.

3. **`AppButton.danger` untuk close**:
   Visual cue: aksi serius. Red border supaya gak tap by accident.

4. **Cash in/out tambahan**:
   Misal kasir withdraw petty cash mid-shift, atau receive setoran dari outlet lain. Optional tapi penting untuk audit.

5. **Logout setelah close**:
   Konvensi: kasir tutup shift = kerja selesai. Login lagi besok. Bisa juga "Ganti Kasir" tanpa logout — out of scope V1.

## Commit suggestion

```bash
git add lib/presentation/cash_session/pages/tutup_kasir_page.dart lib/presentation/cash_session/pages/close_kasir_success_sheet.dart
git commit -m "Step 35: TutupKasirPage with variance math + checklist + success sheet"
```

---

➡️ Lanjut ke [Step 36 — SettingPage Hub](./36-setting-page-hub.md)
