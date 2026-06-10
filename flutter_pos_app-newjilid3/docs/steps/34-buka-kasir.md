# 34 — BukaKasirPage (Mulai Shift)

## Goal

Halaman buka kasir: pilih shift (Pagi / Siang / Malam) → input modal awal (opening float) + opsional catatan → tombol "Mulai Shift" → trigger `CashSessionBloc.open(...)` → routing ke Dashboard.

## Prerequisite

- Step 33 selesai.

## Konsep yang diajarkan

- **Form 2-step**: pilih shift → input modal. Mengurangi cognitive load.
- **Recap card** untuk last closed session — context untuk kasir baru.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `CashSessionBloc.open(shiftLabel, openingFloat, note?)` ada.

Generate `lib/presentation/cash_session/pages/buka_kasir_page.dart`.

═══════════════════════════════════════════════
STRUKTUR
═══════════════════════════════════════════════
`StatefulWidget`. State:
- `_shift: String?` (null awal).
- `_openingFloat: int = 0`.
- `_noteCtrl: TextEditingController`.

Build:
- Scaffold(bg surface) > SafeArea(bottom:false):
  - AppAppBar(title: 'Buka Kasir', automaticallyImplyLeading: false, trailing: [TextButton 'Logout' → LogoutBloc.add()]).
  - body: ListView padding 16:
    1. **Greeting card** AppCard:
       - Row: AppAvatar(name: auth.user.name, size:48).
       - SpaceWidth 12.
       - Column.start: Text 'Selamat datang' bodyS onSurfaceVar, Text auth.user.name titleM. SpaceHeight 2. Text DateTime.now().toFormattedTime() bodyS onSurfaceVar.
    2. SpaceHeight 16.
    3. **Recap last closed** (kalau ada — dari `state.maybeWhen(noSession: (last) => last)`):
       - AppBanner(kind: info, title: 'Shift terakhir', body: 'Tutup ${last.closedAt?.toFormattedTime()}, kas akhir Rp ${last.physicalCount?.currencyFormatRp}').
    4. SpaceHeight 16.
    5. **AppSectionLabel('Pilih Shift')**.
    6. Row (Expanded for each):
       - `_ShiftCard(label: 'Pagi', subtitle: '06–14', icon: wb_sunny, active: _shift == 'Pagi', onTap: setState)`.
       - `_ShiftCard(label: 'Siang', subtitle: '14–22', icon: wb_twilight, active: ...)`.
       - `_ShiftCard(label: 'Malam', subtitle: '22–06', icon: nightlight_round, active: ...)`.
    7. SpaceHeight 24.
    8. **AppSectionLabel('Modal Awal Kas')**.
    9. AppMoneyTextField(label: 'Jumlah uang di kasir', autofocus: false, onChanged: (v) => setState(_openingFloat = v)).
    10. SpaceHeight 8.
    11. Wrap quick chips: [50rb, 100rb, 200rb, 500rb] → setState `_openingFloat = ...`.
    12. SpaceHeight 16.
    13. AppTextField(label: 'Catatan (opsional)', controller: _noteCtrl, maxLines: 2).
    14. SpaceHeight 24.
    15. **BlocConsumer<CashSessionBloc>**:
        - listener:
          - open(_) → `pushAndRemoveUntil(DashboardPage, (_) => false)`.
          - error(msg) → AppSnackbar.error.
        - builder:
          - loading = state.maybeWhen(loading: () => true, orElse: () => false).
          - canSubmit = _shift != null && _openingFloat > 0.
          - AppButton.primaryWithArrow(label: 'Mulai Shift', loading, onPressed: canSubmit && !loading ? () {
              context.read<CashSessionBloc>().add(CashSessionEvent.open(
                shiftLabel: _shift!, openingFloat: _openingFloat,
                note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
              ));
            } : null).

`_ShiftCard`:
- Field: `label, subtitle, icon, active, onTap`.
- AppCard(onTap, padding 14, background: active ? primaryContainer : null) > Column.center:
  - Icon icon 24 active ? onPrimaryContainer : onSurfaceVar.
  - SpaceHeight 8.
  - Text label titleS active ? onPrimaryContainer : onSurface.
  - Text subtitle bodyS onSurfaceVar.
````

---

## Verifikasi

1. Login user yang belum ada open shift → SplashPage routing ke BukaKasirPage.
2. Pilih shift "Pagi" → input modal 500.000 (via chip) → "Mulai Shift".
3. Loading spinner → BE POST → success → DashboardPage.
4. Re-open app → splash → langsung DashboardPage (skip BukaKasirPage).

## Talking points

1. **`automaticallyImplyLeading: false`** + Logout di trailing:
   User belum bisa back (dia harus buka shift dulu atau logout). Tapi escape route via logout tetap ada.

2. **Shift card sebagai 3 chunky button**:
   Lebih besar dari segmented toggle — kasir bisa tap dengan sarung tangan / di luar. UX targeting first-time-action.

3. **`canSubmit` enabled only if shift && opening > 0**:
   Validation soft. Visual: tombol disabled (opacity 0.5).

4. **Recap card optional**:
   `state.maybeWhen(noSession: (last) => last, orElse: () => null)` — tampil cuma kalau ada last.

5. **`pushAndRemoveUntil`** after open:
   Buang stack BukaKasirPage. Kalau user back, gak balik ke buka kasir (sudah open) — langsung exit app.

## Commit suggestion

```bash
git add lib/presentation/cash_session/pages/buka_kasir_page.dart
git commit -m "Step 34: BukaKasirPage with shift card + opening float"
```

---

➡️ Lanjut ke [Step 35 — TutupKasirPage](./35-tutup-kasir.md)
