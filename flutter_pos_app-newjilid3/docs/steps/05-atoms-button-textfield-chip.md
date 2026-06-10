# 05 — Atoms: AppButton, AppTextField, AppMoneyTextField, AppChip

## Goal

4 widget atom yang dipakai paling sering: tombol primer (dengan loading state), input teks (dengan focus halo), input uang (auto thousand-separator), dan chip pill (filter/quick-amount).

## Prerequisite

- Step 02 (theme), 04 (extensions) selesai.

## Konsep yang diajarkan

- **Atomic Design** — pisahkan komponen jadi atom (terkecil), molecule, organism. Atom = tombol, input, chip.
- **`enum` di Dart** — untuk variant API yang clean (`AppButtonVariant.primary`).
- **Named constructors** sebagai sugar (`AppButton.primary(label: ...)` lebih readable daripada `AppButton(variant: AppButtonVariant.primary, ...)`).
- **`switch` expression Dart 3** — `final bg = switch (variant) { ... };`
- **`InkWell` + `Material`** — ripple effect material. `Material` parent menyediakan canvas; `InkWell` paint ripple di atasnya.
- **`AnimatedContainer`** — transisi state visual (focus, active) tanpa setState manual animation.
- **`TextEditingController` + `inputFormatters`** — control input keyboard secara presisi.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app` sudah punya `AppPalette` (ThemeExtension dengan getter `context.palette`), `AppTypography`, `AppRadius`, `AppSpacing` di `lib/core/theme/`.

Generate 4 widget atom di `lib/core/components/`. Semua pakai `context.palette` untuk warna, jangan hardcode hex.

═══════════════════════════════════════════════
FILE 1: lib/core/components/app_button.dart
═══════════════════════════════════════════════
- `enum AppButtonVariant { primary, primaryWithArrow, outline, ghost, danger }`
- `enum AppButtonSize { sm, md, lg }` — height 40 / 48 / 56
- Class `AppButton extends StatelessWidget` dengan field:
  `label, leadingIcon?, trailingIcon?, variant, size, loading=false, fullWidth=true, onPressed?`
- 5 named constructors sugar: `.primary(...)`, `.primaryWithArrow(...)`, `.outline(...)`, `.ghost(...)`, `.danger(...)` — masing-masing set `variant` ke value yang sesuai. `primaryWithArrow` extra: `trailingIcon = null`.
- Style per variant:
  - **primary / primaryWithArrow**: bg `p.primary`, fg `p.onPrimary`, kalau enabled tambah `BoxShadow(color: p.primary.withValues(alpha: 0.25), blurRadius: 16, offset: Offset(0,6))`.
  - **outline**: bg transparent, fg `p.onSurface`, border 1.5px `p.outline`.
  - **ghost**: bg transparent, fg `p.primary`, no border.
  - **danger**: bg transparent, fg `p.error`, border 1.5px `p.error.withValues(alpha: 0.55)`.
- Disabled (onPressed null atau loading true) → `Opacity(0.5)` di seluruh button + shadow tidak dipasang.
- Loading state: replace label dengan `CircularProgressIndicator(strokeWidth: 2.5, color: fg)` ukuran iconSize.
- `primaryWithArrow` layout: `Row(mainAxisAlignment: spaceBetween, [SizedBox(width:40), label, Container 40x40 dengan icon arrow])` — chip belakang `fg.withValues(alpha: 0.18)` + `Icons.arrow_forward_rounded`.
- Padding horizontal: 6 untuk primaryWithArrow, 16 untuk lainnya.
- Bungkus `Material(transparent) > InkWell(onTap) > Container(decoration)` dengan radius `AppRadius.mdAll`.
- Icon size: sm=18, md=20, lg=22. Font size: sm=13, md=15, lg=16.

═══════════════════════════════════════════════
FILE 2: lib/core/components/app_text_field.dart
═══════════════════════════════════════════════
`AppTextField extends StatefulWidget` dengan field:
`label?, hint?, leadingIcon?, trailing?, prefixText?, controller?, obscure=false, autofocus=false, readOnly=false, keyboardType, inputFormatters?, errorText?, maxLines=1, minLines?, maxLength?, valueStyle?, onChanged?, onTap?, subtle=false`

Layout:
- Kalau ada `label` → text di atas (titleS, onSurface), spacing `AppSpacing.sm`.
- `AnimatedContainer` (duration 150ms) sebagai bingkai:
  - Background `Colors.white`
  - Border radius `AppRadius.mdAll`
  - Border 1.5px:
    - error → `p.error`
    - focused → `p.primary`
    - subtle → `p.outlineSoft`
    - default → `p.outline`
  - Saat focused & tidak error: tambahkan `BoxShadow(color: p.primary.withValues(alpha: 0.10), blurRadius: 0, spreadRadius: 4)` — bikin halo glow.
- Isi: Row dengan optional `leadingIcon` (Icon 20px, color `_focused ? primary : onSurfaceVar`), optional `prefixText` (titleM, onSurfaceVar), TextField utama (`isCollapsed: true`, contentPadding h:16/12 dependent on icon presence, vertical:18, semua border `InputBorder.none`, hint style `bodyL.copyWith(color: onSurfaceVar)`, `counterText: ''`), optional `trailing`.
- Setelah container, kalau `errorText != null` → padding atas 6, text `bodyS.copyWith(color: p.error)`.

Pakai `FocusNode` internal untuk track `_focused` via listener; dispose di dispose().

═══════════════════════════════════════════════
FILE 3: lib/core/components/app_money_text_field.dart
═══════════════════════════════════════════════
`AppMoneyTextField extends StatefulWidget` dengan field:
`label?, hint?, initialValue: int?, onChanged: void Function(int rupiah)?, autofocus=false, errorText?`

Behavior:
- Pakai `NumberFormat.decimalPattern('id')` (static, init di field deklarasi) untuk format `1234567` → `1.234.567`.
- TextEditingController internal di-init dengan `_format(initialValue)`.
- `didUpdateWidget`: kalau `initialValue` beda → reformat dan set controller value (jangan trigger onChanged).
- `_onChanged(String raw)`: strip non-digit, parse int, reformat, set controller value, panggil `widget.onChanged?.call(parsed)`.
- Render pakai `AppTextField(prefixText: 'Rp', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], valueStyle: AppTypography.displayM.copyWith(color: p.onSurface, fontSize: 24), ...)`.

═══════════════════════════════════════════════
FILE 4: lib/core/components/app_chip.dart
═══════════════════════════════════════════════
- `enum AppChipVariant { filter, primary, outline }`
- Class `AppChip extends StatelessWidget`:
  `label, active=false, leadingIcon?, variant=filter, onTap?`
- Saat **active**, style per variant:
  - filter → bg `p.onSurface`, fg `p.surface`, border transparent
  - primary → bg `p.primaryContainer`, fg `p.onPrimaryContainer`, border transparent
  - outline → bg transparent, fg `p.primary`, border `p.primary`
- Saat **inactive**: bg transparent, fg `p.onSurface`, border 1.5px `p.outline`.
- Wrap `Material > InkWell > Container` dengan `AppRadius.pillAll`. Padding horizontal:14, vertical:8.
- Isi: Row(mainAxisSize.min) dengan optional `leadingIcon` 16px, spacing 6, label `AppTypography.labelL.copyWith(color: fg, fontSize: 13)`.
````

---

## Verifikasi (visual)

Tambahkan di `main.dart` placeholder body:

```dart
body: SafeArea(
  child: ListView(
    padding: const EdgeInsets.all(16),
    children: [
      AppButton.primary(label: 'Login', onPressed: () {}),
      const SizedBox(height: 12),
      AppButton.primaryWithArrow(label: 'Bayar Rp. 25.000', onPressed: () {}),
      const SizedBox(height: 12),
      AppButton.outline(label: 'Batal', onPressed: () {}),
      const SizedBox(height: 12),
      AppButton.danger(label: 'Hapus', onPressed: () {}),
      const SizedBox(height: 24),
      const AppTextField(label: 'Email', hint: 'kamu@toko.com', leadingIcon: Icons.mail_outline),
      const SizedBox(height: 12),
      AppMoneyTextField(label: 'Modal awal', initialValue: 500000, onChanged: (v) => print(v)),
      const SizedBox(height: 24),
      Wrap(spacing: 8, children: [
        AppChip(label: 'Semua', active: true, onTap: () {}),
        AppChip(label: 'Kopi', onTap: () {}),
        AppChip(label: 'Pas', variant: AppChipVariant.primary, active: true, onTap: () {}),
      ]),
    ],
  ),
),
```

## Talking points

1. **Kenapa named constructors (`AppButton.primary(...)`)?**
   API jadi declarative: pembaca tahu ini primary tanpa scroll ke parameter. Trade-off: kalau variant tambah banyak (10+), pakai positional enum saja.

2. **`BoxShadow` ditint dengan primary**, bukan hitam: bikin kesan brand. Ini detail kecil yang membedakan UI biasa dan UI berkesan.

3. **Focus halo di AppTextField**: kombinasi border tebal + outer `BoxShadow(blurRadius: 0, spreadRadius: 4)` — bukan blur, tapi "ring" solid 4px. Lebih accessible (jelas focused) tanpa look heavy.

4. **`AppMoneyTextField` pakai TextEditingController internal** dan `_format` tiap onChange. Hati-hati: setting `.text` tanpa `selection` bikin cursor lompat — kita pakai `TextEditingValue(text:..., selection: TextSelection.collapsed(offset:...))`.

5. **`FilteringTextInputFormatter.digitsOnly`**: hard-limit input ke digit. User tidak bisa ketik huruf sama sekali. Ini lebih baik daripada validate setelah ketik.

6. **Disabled state pakai `Opacity(0.5)`** bukan ganti warna: lebih mudah, dan tetap menjaga konsistensi warna brand.

## Commit suggestion

```bash
git add lib/core/components/app_button.dart lib/core/components/app_text_field.dart lib/core/components/app_money_text_field.dart lib/core/components/app_chip.dart
git commit -m "Step 05: atoms — button, text field, money field, chip"
```

---

➡️ Lanjut ke [Step 06 — Atoms: Layout](./06-atoms-layout.md)
