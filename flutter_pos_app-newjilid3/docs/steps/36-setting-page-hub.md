# 36 — SettingPage (Hub) + Logout + Hapus Akun + Theme Picker

## Goal

SettingPage sebagai hub: grouped tiles dengan status live (printer connected, server key set, last sync), pilih palette, logout, hapus akun, privacy policy link.

## Prerequisite

- Step 35 selesai. Bloc Logout + DeleteAccount + Theme ada.

## Konsep yang diajarkan

- **Hub page pattern** — grouped tiles, masing-masing push ke sub-page.
- **Status live** dari multiple bloc — gabungkan via nested BlocBuilder.
- **Destructive confirmation** untuk hapus akun (2-step: confirm + type 'HAPUS AKUN').

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada: ThemeBloc, LogoutBloc, DeleteAccountBloc, AuthLocalDatasource.

Replace `lib/presentation/setting/pages/setting_page.dart`.

═══════════════════════════════════════════════
STRUKTUR
═══════════════════════════════════════════════
StatefulWidget. State:
- `User? _user`, `String _palette = 'caramel'`.
- `String _printerMac = ''`, `bool _qrisEnabled = false`, `String _qrisKey = ''`.
- `String _paperSize = '58'`.

initState: `_loadAll()` parallel:
- auth, palette, printer, qris key/enabled, paper size — set ke state.

Build:
- Scaffold(bg surface, appBar: AppAppBar(title: 'Setting')).
- body: ListView padding 16 dengan section:

  1. **Profile card** AppCard:
     - Row: AppAvatar(name: _user?.name ?? '?', size: 56), SpaceWidth 12.
     - Column: Text user.name titleM, Text user.email bodyS onSurfaceVar, Text user.roles labelM uppercase primary.
     - Spacer. Icon edit_outlined (placeholder TODO).

  2. AppSectionLabel('Produk & Penjualan').
     AppListGroup:
     - tile 'Kelola Produk' → push ManageProductPage (step 37). Trailing: count produk dari `SyncBloc.snapshot.productCount`.
     - tile 'Kelola Promo' → push ManagePromoPage (step 41).
     - tile 'Sinkronisasi Data' → push SyncDataPage (step 40). Trailing: pending count from snapshot.

  3. AppSectionLabel('Perangkat').
     AppListGroup:
     - tile 'Printer Bluetooth' → push ManagePrinterPage (step 38). Trailing: AppStatusPill(connected ? success 'TERHUBUNG' : neutral 'BELUM').
     - tile 'Pengaturan Struk' → push ReceiptSettingsPage (step 45). Trailing: chevron.
     - tile 'Kunci Server QRIS' → push SaveServerKeyPage (step 39). Trailing: AppStatusPill(_qrisEnabled && _qrisKey.isNotEmpty ? success 'AKTIF' : warning 'BELUM').

  4. AppSectionLabel('Tampilan').
     - `_PalettePickerRow`:
       - Row: 3 InkWell circle (caramel #B8743D, espresso #5C3A21, matcha #6B8E3D).
       - Active ada outline + check icon.
       - onTap: setState + `ThemeBloc.add(changed('caramel'/'espresso'/'matcha'))`.

  5. AppSectionLabel('Laporan').
     AppListGroup:
     - tile 'Laporan Penjualan' → push ReportPage (step 43).

  6. AppSectionLabel('Akun').
     AppListGroup:
     - tile 'Tutup Kasir' (icon logout_outlined, color warning) → push TutupKasirPage.
     - tile 'Privacy Policy' → push PrivacyPolicyPage (step 45).

  7. SpaceHeight 24.

  8. **Logout button** AppButton.outline(label: 'Logout', leadingIcon: logout, onPressed: _onLogout).
  9. SpaceHeight 12.
  10. **Hapus akun button** AppButton.danger(label: 'Hapus Akun Permanen', leadingIcon: delete_forever, onPressed: _onDeleteAccount).

═══════════════════════════════════════════════
HANDLERS
═══════════════════════════════════════════════
- `_onLogout`:
  - `AppConfirm.show(title: 'Logout?', body: 'Tutup shift dulu kalau sedang aktif.', confirmLabel: 'Logout')`.
  - Kalau confirm: `LogoutBloc.add(logout())`. Listener (BlocConsumer wrap di SettingPage): on success → `AuthLocalDatasource().removeAuthData()` → `pushAndRemoveUntil(LoginPage, (_) => false)`.

- `_onDeleteAccount`:
  - Custom AppBottomSheet 2-step:
    1. Warning text: 'Hapus akun bersifat permanen. Semua data Anda akan dihapus. Ketik HAPUS AKUN untuk konfirmasi.'
    2. AppTextField (controller, validation: match exact 'HAPUS AKUN').
    3. AppButton.danger enabled if match → `DeleteAccountBloc.add(submit())`.
  - Listener: success → removeAuthData + push LoginPage. error → snackbar.

═══════════════════════════════════════════════
WIRING UPDATES
═══════════════════════════════════════════════
- DashboardPage bottom nav badge `pendingSync`: dari `SyncBloc.snapshot.pendingOrderCount` (step 40 nanti).
- main.dart: pastikan semua bloc terdaftar.
````

---

## Verifikasi

1. Setting page render dengan section + status live.
2. Tap printer tile → push ManagePrinterPage (step 38 stub).
3. Tap palette caramel/espresso/matcha → seluruh app re-color live.
4. Tap Logout → confirm → kembali ke Login. Token hilang.
5. Tap Hapus Akun → sheet → ketik "HAPUS AKUN" → tap → BE delete + logout.

## Talking points

1. **Status live**:
   `AppStatusPill` berubah real-time. UX: kasir buka Setting, langsung tahu printer terhubung atau belum.

2. **Palette picker as 3 circles**:
   Lebih visual + cepat dari dropdown. Active dengan check icon overlay.

3. **2-step delete account** (Play Store compliance):
   - Confirm sheet + type-to-confirm.
   - Hindari "Yes" by accident yang permanen hapus.

4. **Logout vs Tutup Kasir**:
   Beda concept. Tutup kasir = close shift + recon. Logout = sign out user. UI tile dipisah.

5. **`_loadAll()` parallel**:
   Pakai `await Future.wait([...])` untuk paralelkan 5 read. Lebih cepat dari sequential 5x await.

## Commit suggestion

```bash
git add lib/presentation/setting/pages/setting_page.dart
git commit -m "Step 36: SettingPage hub with status pills + palette picker + delete account"
```

---

➡️ Lanjut ke [Step 37 — Manage Product](./37-manage-product.md)
