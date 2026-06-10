# 08 — Atoms: Form (AppStepper, AppStepperField, AppSwitchTile, AppSegmentedToggle, AppIconButton, AppKeyValueRow, AppBottomSheet)

## Goal

7 atom yang dipakai di form & input: stepper qty (cart), stepper field (form stok), switch row, segmented toggle (env tabs), icon button 44×44, key-value row (summary), dan bottom sheet shell.

## Prerequisite

- Step 07 selesai.

## Konsep yang diajarkan

- **Stateless vs stateful** — kapan butuh state lokal (focus, animation) vs cukup props.
- **Generic `T`** di `AppSegmentedToggle<T>` & `AppSegmentOption<T>` — type-safe pilihan.
- **`showModalBottomSheet`** dengan `isScrollControlled: true` — supaya tinggi bisa fleksibel + keyboard avoiding.
- **`MediaQuery.viewInsets.bottom`** — sisakan tinggi untuk keyboard.
- **`Switch` Material 3 + `Transform.scale`** — adapt size.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada `AppPalette`, `AppTypography`, `AppRadius`, `AppSpacing` di theme.

Generate 7 file di `lib/core/components/`.

═══════════════════════════════════════════════
FILE 1: lib/core/components/app_icon_button.dart
═══════════════════════════════════════════════
- `enum AppIconButtonVariant { transparent, surfaceVariant, surface }`
- `class AppIconButton extends StatelessWidget`:
  - Field: `icon, onPressed?, variant = transparent, size = 44, iconSize = 22, iconColor?, tooltip?`.
  - bg switch: transparent → Colors.transparent, surfaceVariant → p.surfaceVariant, surface → Colors.white.
  - fg = iconColor ?? p.onSurface.
  - Material(bg, radius `AppRadius.smAll`) > InkWell(onTap: onPressed, radius `smAll`) > SizedBox(size×size, Icon(icon, iconSize, fg)).
  - Bungkus `Tooltip(message: tooltip!, child: btn)` kalau ada tooltip.

═══════════════════════════════════════════════
FILE 2: lib/core/components/app_stepper.dart
═══════════════════════════════════════════════
- `enum AppStepperSize { sm, md }`
- `class AppStepper extends StatelessWidget`:
  - Field: `qty, onChanged: ValueChanged<int>, min=0, max?, size=md`.
  - Compute: sm → h:32, btn:28, iconSize:16; md → h:40, btn:36, iconSize:18.
  - `canDec = qty > min`, `canInc = max == null || qty < max!`.
  - Container(h, padding h:3, bg `p.primaryContainer`, radius `AppRadius.smAll`) > Row.min:
    - `_Btn` (minus, color canDec ? primary : primary @0.35, onTap canDec ? decrement : null)
    - SizedBox(width: sm?22:28) > Text('$qty', center, `labelL.copyWith(color: p.onPrimaryContainer, fontSize: sm?13:14, w700)`)
    - `_Btn` (plus, color canInc ? primary : primary @0.35, onTap canInc ? increment : null)
- Private `_Btn extends StatelessWidget`: Material(transparent) > InkWell(onTap, radius 6) > SizedBox(btn×btn, Icon(icon, iconSize, color)).

═══════════════════════════════════════════════
FILE 3: lib/core/components/app_stepper_field.dart
═══════════════════════════════════════════════
`class AppStepperField extends StatelessWidget`:
- Field: `value, onChanged, min=0, max?`.
- Container(h:52, bg white, radius `AppRadius.mdAll`, border 1.5px `p.outline`) > Row:
  - `_SquareBtn` (minus, color canDec ? onSurface : onSurfaceVar @0.4, onTap, default rounding kiri).
  - Expanded > Center > Text('$value', titleM, p.onSurface).
  - `_SquareBtn` (plus, color canInc ? primary : primary @0.4, onTap, **highlighted=true**, bg canInc ? primaryContainer : surfaceVariant).
- Private `_SquareBtn`: Material(bg) > InkWell(onTap) > SizedBox(50×50, Icon(icon, 22, color)). Rounding: kanan dari `BorderRadius.horizontal(right: Radius.circular(12))`; jika highlighted false, sambungkan juga kiri.

═══════════════════════════════════════════════
FILE 4: lib/core/components/app_switch_tile.dart
═══════════════════════════════════════════════
`class AppSwitchTile extends StatelessWidget`:
- Field: `title, value, onChanged, subtitle?, leading?, compact=false`.
- InkWell(onTap: () => onChanged(!value)) > Padding(h:compact?12:16, v:compact?10:14) > Row:
  - Optional leading + SpaceWidth 12.
  - Expanded > Column.start.min:
    - Text title (`bodyM.copyWith(color: p.onSurface, w600)`).
    - Kalau subtitle: SpaceHeight 2, Text subtitle (`bodyS, p.onSurfaceVar`).
  - SpaceWidth 12. Transform.scale(scale: compact?0.85:1.0) > Switch(value, onChanged).

═══════════════════════════════════════════════
FILE 5: lib/core/components/app_segmented_toggle.dart
═══════════════════════════════════════════════
- `class AppSegmentOption<T>`: `value: T, label, subtitle?` — const constructor.
- `class AppSegmentedToggle<T> extends StatelessWidget`:
  - Field: `options: List<AppSegmentOption<T>>, value: T, onChanged: ValueChanged<T>`.
  - Container(padding:3, bg `p.surfaceVariant`, radius `AppRadius.smAll`) > Row(Expanded per option, `_Segment`).
- Private `_Segment<T>`: InkWell(onTap, radius 8) > AnimatedContainer(200ms, padding v:10/h:12, bg `active ? Colors.white : transparent`, radius 8, shadow `active ? BoxShadow(p.onSurface @0.08, blur 4, offset (0,1))` : null) > Column.min:
  - Text label (center, `labelL.copyWith(color: active ? p.onSurface : p.onSurfaceVar, w700 if active else w600)`).
  - Kalau subtitle: SpaceHeight 2, Text subtitle (center, `bodyS, p.onSurfaceVar`).

═══════════════════════════════════════════════
FILE 6: lib/core/components/app_key_value_row.dart
═══════════════════════════════════════════════
- `enum AppKVVariant { regular, big, accent, muted, highlight }`
- `class AppKeyValueRow extends StatelessWidget`:
  - Field: `label, value, variant=regular, padding=EdgeInsets.symmetric(vertical:8)`.
  - Switch label & value style per variant:
    - regular: label `bodyM, onSurfaceVar`; value `bodyM.copyWith(onSurface, w600)`.
    - big: label `bodyL.copyWith(onSurface, w700)`; value `priceL.copyWith(onSurface)`.
    - accent: label `bodyM, onSurfaceVar`; value `bodyM.copyWith(p.success, w700)`.
    - muted: label & value `bodyM, onSurfaceVar`.
    - highlight: label & value `bodyM.copyWith(onSurface, w700)` — DAN row dibungkus Container dengan border-top 1px `p.outlineSoft`.
  - Row: Expanded(label) + SpaceWidth 12 + Text(value).

═══════════════════════════════════════════════
FILE 7: lib/core/components/app_bottom_sheet.dart
═══════════════════════════════════════════════
Top-level function:
```dart
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  String? subtitle,
  Widget Function(BuildContext context)? headerBuilder,
  Widget? bottomActions,
  double maxHeightFactor = 0.92,
  bool isDismissible = true,
  bool enableDrag = true,
})
```
Call `showModalBottomSheet<T>` dengan: `isScrollControlled: true, isDismissible, enableDrag, useSafeArea: true, backgroundColor: Colors.transparent, builder: (ctx) => _AppBottomSheetShell(...)`.

Private `_AppBottomSheetShell extends StatelessWidget`:
- Field: child, maxHeightFactor, title?, subtitle?, headerBuilder?, bottomActions?.
- maxH = `MediaQuery.size.height * maxHeightFactor`.
- Container(constraints maxHeight: maxH, decoration: bg `p.surface`, border top corners 28) > Column.min:
  - SpaceHeight `AppSpacing.sm`.
  - **Drag handle**: Container 40×4, bg `p.onSurface @0.18`, radius 2.
  - SpaceHeight `md`.
  - Header: kalau ada `headerBuilder` → padding (20,0,20,md) + builder. Else kalau ada `title` → padding sama + Column.start: Text title (`titleM, onSurface`) + optional Text subtitle (`bodyS, onSurfaceVar`).
  - Flexible > SingleChildScrollView(padding 20,0,20,20) > child.
  - Kalau ada `bottomActions`: Container(padding 20,12,20,16, bg `p.surface`, border-top 1px `p.outlineSoft`) > bottomActions.
  - SizedBox(height: `MediaQuery.viewInsets.bottom`) — buat ruang keyboard.
````

---

## Verifikasi

```dart
ElevatedButton(
  onPressed: () => showAppBottomSheet(
    context: context,
    title: 'Demo sheet',
    subtitle: 'Test atom bottom sheet',
    bottomActions: AppButton.primary(label: 'OK', onPressed: () => Navigator.pop(context)),
    child: Column(children: [
      AppStepper(qty: 1, onChanged: (v) {}),
      const SizedBox(height: 12),
      AppStepperField(value: 5, onChanged: (v) {}),
      const SizedBox(height: 12),
      AppSwitchTile(title: 'Cetak struk', value: true, onChanged: (v) {}),
      const SizedBox(height: 12),
      AppSegmentedToggle<String>(
        options: const [
          AppSegmentOption(value: 'sandbox', label: 'Sandbox'),
          AppSegmentOption(value: 'prod', label: 'Production'),
        ],
        value: 'sandbox',
        onChanged: (v) {},
      ),
      const SizedBox(height: 12),
      const AppKeyValueRow(label: 'Subtotal', value: 'Rp. 50.000'),
      const AppKeyValueRow(label: 'Diskon', value: '- Rp. 5.000', variant: AppKVVariant.muted),
      const AppKeyValueRow(label: 'Total', value: 'Rp. 45.000', variant: AppKVVariant.big),
      const AppKeyValueRow(label: 'Kembalian', value: 'Rp. 5.000', variant: AppKVVariant.accent),
    ]),
  ),
  child: const Text('Open sheet'),
)
```

## Talking points

1. **`isScrollControlled: true`**:
   Default `showModalBottomSheet` max 50% screen. Dengan `isScrollControlled` kita kontrol pakai constraints sendiri (`maxHeightFactor: 0.92`). Wajib untuk sheet yang berisi form/keyboard.

2. **`MediaQuery.viewInsets.bottom`**:
   Ini insets dari keyboard. Kalau gak diakomodasi, keyboard nutupin input. Ada juga `useSafeArea: true` di `showModalBottomSheet` yang menangani notch atas.

3. **Generic `T` di `AppSegmentedToggle<T>`**:
   `T` bisa `String`, `enum`, atau apapun. Compiler check tipe `value` cocok dengan `options[].value` dan callback `onChanged(T)`. Ini contoh nyata gunanya generics.

4. **`AppStepperField` vs `AppStepper`**:
   - `AppStepper` ramping 32–40px untuk cart row (tap cepat).
   - `AppStepperField` 52px untuk form stok (tap di antara field lain, ergonomis).
   Beda use case → beda komponen, jangan overload satu komponen dengan size variant berlebih.

5. **`AppKeyValueRow.highlight`** menambahkan border-top:
   Cara mendeklarasikan "ini summary akhir penting" (mis. 'Estimasi kas akhir' di close-kasir). Decorasi struktur via design, bukan via icon.

6. **`Transform.scale(scale: 0.85)` untuk Switch compact**:
   `Switch` Material 3 fixed 32px tinggi. Kalau mau lebih kecil tanpa override theme, scale via Transform. Tidak ideal (touch target tetap diam), tapi acceptable untuk row compact.

## Commit suggestion

```bash
git add lib/core/components/app_icon_button.dart lib/core/components/app_stepper.dart lib/core/components/app_stepper_field.dart lib/core/components/app_switch_tile.dart lib/core/components/app_segmented_toggle.dart lib/core/components/app_key_value_row.dart lib/core/components/app_bottom_sheet.dart
git commit -m "Step 08: atoms — icon button, stepper, switch tile, segmented toggle, kv row, bottom sheet"
```

---

➡️ Lanjut ke [Step 09 — Atoms: Domain](./09-atoms-domain.md)
