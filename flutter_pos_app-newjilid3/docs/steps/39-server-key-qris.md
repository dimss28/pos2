# 39 — SaveServerKeyPage (QRIS Midtrans)

## Goal

Halaman input server key Midtrans: opt-in toggle, segmented env (sandbox/production), masked input dengan eye toggle, save ke `flutter_secure_storage` (di-route lewat `AuthLocalDatasource`).

## Prerequisite

- Step 38 selesai.

## Konsep yang diajarkan

- **Opt-in toggle pattern** — fitur QRIS off by default supaya Play Store gak flag "payment feature without setup".
- **Masked input** dengan `obscure` toggle (mata icon).
- **Env switcher** sandbox vs production.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `AuthLocalDatasource.saveMidtransServerKey/getMitransServerKey/setMidtransEnabled/isMidtransEnabled` ada.

Generate `lib/presentation/setting/pages/save_server_key_page.dart`:

StatefulWidget. State:
- `_keyCtrl: TextEditingController`, `_obscure = true`.
- `_enabled = false`, `_env = 'sandbox'`.

initState: load _key + _enabled + (optional env saved in pref `'pt_v1_env'`).

Build:
- Scaffold > AppAppBar(title: 'Kunci Server QRIS').
- body: ListView padding 16:
  1. AppBanner(info, icon: shield_outlined, title: 'Privasi Kunci Anda', body: 'Server key disimpan terenkripsi di perangkat ini. Tidak pernah dikirim ke server kami.').
  2. SpaceHeight 16.
  3. AppSwitchTile('Aktifkan Pembayaran QRIS', subtitle: 'Tampilkan opsi QRIS di halaman bayar', value: _enabled, onChanged: (v) async {
       setState(_enabled = v);
       await AuthLocalDatasource().setMidtransEnabled(v);
     }).
  4. SpaceHeight 8.
  5. AnimatedOpacity(opacity: _enabled ? 1 : 0.4, duration: 200ms) > IgnorePointer(ignoring: !_enabled) > Column:
     - AppSectionLabel('Environment').
     - AppSegmentedToggle<String>(
         options: [SegmentOption('sandbox', 'Sandbox', subtitle: 'Untuk testing'), SegmentOption('production', 'Production', subtitle: 'Live transactions')],
         value: _env, onChanged: (v) => setState(_env = v),
       ).
     - SpaceHeight 16.
     - AppSectionLabel('Server Key').
     - AppTextField(
         hint: _env == 'sandbox' ? 'SB-Mid-server-...' : 'Mid-server-...',
         controller: _keyCtrl, obscure: _obscure,
         trailing: InkWell(
           onTap: () => setState(_obscure = !_obscure),
           child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: p.onSurfaceVar),
         ),
       ).
     - SpaceHeight 12.
     - Text('Dapatkan server key di Midtrans Dashboard → Settings → Access Keys.', bodyS onSurfaceVar).
     - SpaceHeight 20.
     - AppButton.primary('Simpan', onPressed: _save).
     - SpaceHeight 12.
     - AppButton.outline('Test Koneksi', onPressed: _testConnection).

`_save()`:
- validate not empty.
- `AuthLocalDatasource().saveMidtransServerKey(_keyCtrl.text.trim())`.
- save env ke prefs.
- snackbar success.

`_testConnection()`:
- `MidtransRemoteDatasource().generateQRCode('TEST-${now.ms}', 1000)` — kalau tidak throw, snackbar success. Else error.
````

---

## Verifikasi

1. Setting → Server Key. Default disabled (UI di-grey).
2. Toggle ON → input field enabled.
3. Pilih Sandbox, input "SB-Mid-server-test" → Save → snackbar.
4. Test Koneksi → BE call → result.
5. Toggle OFF → OrderPage segmented toggle QRIS hidden (perlu update OrderPage cek `isMidtransEnabled`).

## Talking points

1. **Opt-in default OFF**:
   Banyak app POS auto-enable payment provider → Play Store review flag "ada fitur payment tanpa kontrak". Toggle eksplisit aman.

2. **Server key sensitivity**:
   Setara password. Pakai obscure default, eye toggle untuk reveal saat input. Save ke prefs (bukan secure storage) — karena user yang punya HP = trust full.

3. **Env switcher**:
   Trip ke production berarti real money. Sandbox = test mode (no real transaction). UX visual distinguish.

4. **`AnimatedOpacity + IgnorePointer`**:
   Pattern untuk soft-disable (gak hide tapi gak interactive). Reveal context: user tahu fitur ada, tapi perlu enable.

5. **Test koneksi**:
   Trigger generate QR dengan amount 1000. Sukses → key valid. Gagal → wrong key / network. Sangat membantu UX.

## Commit suggestion

```bash
git add lib/presentation/setting/pages/save_server_key_page.dart
git commit -m "Step 39: SaveServerKeyPage with opt-in + env + masked input"
```

---

➡️ Lanjut ke [Step 40 — SyncData + SyncBloc](./40-sync-data.md)
