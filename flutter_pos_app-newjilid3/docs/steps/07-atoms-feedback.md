# 07 — Atoms: Feedback (AppEmptyState, AppBanner, AppStatusPill, AppBadge, AppNumberedStep, feedback helpers)

## Goal

6 atom untuk komunikasi state ke user: empty state, banner inline, status pill (badge container-tinted), badge stock/qty, numbered step explainer, dan helper `AppSnackbar`/`AppConfirm`/`AppLoadingDialog`/`showAppActionSheet`.

## Prerequisite

- Step 06 (AppButton, layout atoms) selesai.

## Konsep yang diajarkan

- **State visual** di Flutter: loading vs error vs empty vs success — masing-masing butuh treatment berbeda.
- **`ScaffoldMessenger`** vs `Scaffold` — modern way untuk show SnackBar.
- **`showDialog` vs `showModalBottomSheet`** — dialog untuk yes/no kecil, bottom sheet untuk konten besar/menu.
- **`SingleTickerProviderStateMixin` + `AnimationController`** — animasi minimal (pulse dot di status pill).
- **Generic `T` di Dart** — `showAppActionSheet<T>(...)` return typed value.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada `AppPalette` (extension `context.palette`), `AppTypography`, `AppRadius`, `AppSpacing`, `AppButton`, `AppIconButton` (placeholder, akan dibuat di step 08).

Generate 6 file di `lib/core/components/`.

═══════════════════════════════════════════════
FILE 1: lib/core/components/app_status_pill.dart
═══════════════════════════════════════════════
- `enum AppStatusKind { success, warning, error, info, neutral }`
- `class AppStatusPill extends StatelessWidget`:
  - Field: `label, kind = neutral, showDot=false, pulse=false`.
  - Color map (switch on kind):
    - success → bg `p.successContainer`, fg `p.success`
    - warning → bg `p.warningContainer`, fg `const Color(0xFF7C4A0E)` (warning text agak gelap)
    - error → bg `p.errorContainer`, fg `p.error`
    - info → bg `p.primaryContainer`, fg `p.onPrimaryContainer`
    - neutral → bg `p.surfaceVariant`, fg `p.onSurfaceVar`
  - Container padding (h:8, v:3), radius pill.
  - Row min: optional dot (6x6, color fg) + spacing 6 + Text label (`labelM.copyWith(color: fg, fontSize:11, letterSpacing:0.4)`).
- Private `_Dot extends StatefulWidget` dengan `SingleTickerProviderStateMixin`:
  - Kalau `pulse`, AnimationController duration 1300ms `repeat(reverse: true)`.
  - Render Container 6x6 circle dengan color alpha animated (`color.withValues(alpha: 0.5 + 0.5 * _c.value)`).

═══════════════════════════════════════════════
FILE 2: lib/core/components/app_badge.dart
═══════════════════════════════════════════════
- `enum AppBadgeKind { stockLow, stockOut, qty, neutral }`
- `class AppBadge extends StatelessWidget`:
  - Field: `label, kind=neutral, leadingIcon?`.
  - Switch color:
    - stockLow → bg `p.warningContainer`, fg `const Color(0xFF92400E)`
    - stockOut → bg `p.errorContainer`, fg `p.error`
    - qty → bg `p.primary`, fg `p.onPrimary`
    - neutral → bg `p.surfaceVariant`, fg `p.onSurfaceVar`
  - Container padding (h:8, v:4), radius pill, Row.min: optional icon 12px + spacing 4 + Text (`labelM.copyWith(color: fg, fontSize:11)`).

- `class AppCountBadge extends StatelessWidget`:
  - Field: `count: int, background?, foreground?, border?`.
  - Container constraints minWidth:18, minHeight:18, padding h:5, decoration bg (default `p.primary`), borderRadius 9, optional border 2px.
  - Center child Text `count > 99 ? '99+' : '$count'` (`labelM.copyWith(color: fg, fontSize:10, fontWeight:w700)`).

═══════════════════════════════════════════════
FILE 3: lib/core/components/app_numbered_step.dart
═══════════════════════════════════════════════
- `enum AppStepStyle { filled, outlined }`
- `class AppNumberedStep extends StatelessWidget`:
  - Field: `n: int, text: String, style = filled`.
  - Padding(v:6) > Row.start:
    - Container 20x20 circle. Filled: bg `p.primary`, no border. Outlined: transparent + border 1.5px `p.primary`. Text `$n` (`labelM.copyWith(color: filled ? p.onPrimary : p.primary, fontSize:11, w700)`).
    - SpaceWidth 10.
    - Expanded > Padding(top:1) > Text(text, `bodyM.copyWith(color: p.onSurface)`).

═══════════════════════════════════════════════
FILE 4: lib/core/components/app_banner.dart
═══════════════════════════════════════════════
- `enum AppBannerKind { success, warning, error, info, primary }`
- `class AppBanner extends StatelessWidget`:
  - Field: `title, body?, kind=info, leadingIcon?, trailing?, padding = EdgeInsets.all(14)`.
  - Color records (record syntax Dart 3) per kind:
    - success → (bg: p.successContainer, border: p.success @0.25, fg: p.onSurface, accent: p.success)
    - warning → (bg: p.warningContainer, border: p.warning @0.25, fg: 0xFF7C4A0E, accent: p.warning)
    - error → (bg: p.errorContainer, border: p.error @0.25, fg: p.onSurface, accent: p.error)
    - info → (bg: p.surfaceVariant, border: p.outlineSoft, fg: p.onSurface, accent: p.primary)
    - primary → (bg: p.primary, border: transparent, fg: p.onPrimary, accent: p.onPrimary)
  - Container(decoration: bg, radius `AppRadius.mdAll`, border 1px border) > Row.start:
    - Kalau leadingIcon: Container 36x36 (bg `accent @0.15` atau `fg @0.18` kalau primary kind), radius `AppRadius.smAll`, center Icon(leadingIcon, 20px, accent). SpaceWidth 12.
    - Expanded > Column.start.min:
      - Text title (`bodyM.copyWith(color: fg, w700)`)
      - Kalau body: SpaceHeight 2, Text body (`bodyS.copyWith(color: fg.withValues(alpha: 0.78))` — atau 0.85 untuk primary kind).
    - Kalau trailing: SpaceWidth 12 + trailing.

═══════════════════════════════════════════════
FILE 5: lib/core/components/app_empty_state.dart
═══════════════════════════════════════════════
`class AppEmptyState extends StatelessWidget`:
- Field: `title: String, visual?: Widget, body?, helperCard?: Widget, primaryAction?: AppButton, secondaryAction?: AppButton`.
- Factory `AppEmptyState.error({required String message, VoidCallback? onRetry})`:
  - title: 'Terjadi kesalahan', body: message, primaryAction: kalau onRetry ada → AppButton(label: 'Coba lagi', variant: primary, onPressed: onRetry, fullWidth: false).
- Render: Center > SingleChildScrollView(padding h:24, v:32) > Column.min.stretch:
  - Kalau visual: Center(visual), SpaceHeight `AppSpacing.xl`.
  - Text title (center align, `titleL.copyWith(color: p.onSurface)`).
  - Kalau body: SpaceHeight `sm`, Text body (center, `bodyM.copyWith(color: p.onSurfaceVar)`).
  - Kalau helperCard: SpaceHeight `xl`, Container(padding:14, bg `p.surfaceVariant`, radius `mdAll`) > helperCard.
  - Kalau primaryAction: SpaceHeight `xl`, primaryAction.
  - Kalau secondaryAction: SpaceHeight `md`, secondaryAction.

═══════════════════════════════════════════════
FILE 6: lib/core/components/feedback.dart
═══════════════════════════════════════════════
4 class/helper:

**`class AppSnackbar`** dengan private constructor `_()`:
- Static private `_show(context, message, bg, fg, {IconData? icon})`:
  - ScaffoldMessenger.of(context).hideCurrentSnackBar().showSnackBar(SnackBar(bg, behavior: floating, shape rounded `AppRadius.smAll`, margin 16, content Row optional Icon + Text)).
- Static `success(context, message)` → bg p.success, fg white, icon check_circle_outline.
- Static `error(context, message)` → bg p.error, fg white, icon error_outline.
- Static `info(context, message)` → bg p.onSurface, fg p.surface, icon info_outline.
(Tiap method baca palette via `Theme.of(context).extension<AppPalette>() ?? AppPalette.caramel`.)

**`class AppConfirm`** dengan private constructor:
- Static `Future<bool> show(context, {required title, required body, confirmLabel='Lanjut', cancelLabel='Batal', destructive=false})`:
  - showDialog<bool>(Dialog(bg p.surface, shape rounded `AppRadius.lgAll`) > Padding(24) > Column.min.stretch):
    - Text title (titleM, p.onSurface)
    - SpaceHeight 8, Text body (bodyM, p.onSurfaceVar)
    - SpaceHeight 24, Row:
      - Expanded > AppButton(cancelLabel, outline, sm... actually size md, onPressed: Nav.pop(false))
      - SpaceWidth 12
      - Expanded(flex: 2) > AppButton(confirmLabel, destructive ? danger : primary, size md, onPressed: Nav.pop(true))
  - Return `result ?? false`.

**`class AppLoadingDialog`** dengan private constructor:
- Static bool `_showing = false`.
- Static `show(context, {String? message})`:
  - Kalau `_showing` skip; else set true dan showDialog(barrierDismissible:false) PopScope(canPop:false) > Center > Container(padding:24, bg p.surface, radius lgAll) > Column.min: CircularProgressIndicator(p.primary) + optional message.
- Static `hide(context)`: kalau showing, set false, `Navigator.of(context, rootNavigator: true).pop()`.

**Top-level `Future<T?> showAppActionSheet<T>({context, items: List<AppActionItem<T>>, title?})`**:
- showModalBottomSheet(transparent bg) > SafeArea(top:false) > Container(margin:12, bg p.surface, radius lgAll) > Column.min:
  - Optional title row (padding 20,16,20,4 — titleS color p.onSurfaceVar)
  - For each item: InkWell(onTap: Nav.pop(item.value)) > Padding(20,14) > Row [optional Icon 20px + SpaceWidth 12, Text label bodyL w600 (color destructive ? p.error : p.onSurface)].
  - SpaceHeight 4, Padding(20,4,20,12) > AppIconButton(close_rounded, surfaceVariant variant, size 40, onPressed: Nav.pop()).

**`class AppActionItem<T>`**: `value: T, label, icon?, destructive=false` — semua final, constructor const.
````

---

## Verifikasi

```dart
body: Padding(
  padding: const EdgeInsets.all(16),
  child: Column(children: [
    const AppBanner(kind: AppBannerKind.warning, leadingIcon: Icons.warning_amber_outlined,
        title: 'Belum sinkron', body: 'Ada 3 order pending.'),
    const SizedBox(height: 12),
    Wrap(spacing: 8, children: const [
      AppStatusPill(label: 'LUNAS', kind: AppStatusKind.success, showDot: true),
      AppStatusPill(label: 'MENUNGGU', kind: AppStatusKind.warning, showDot: true, pulse: true),
      AppBadge(label: 'Sisa 3', kind: AppBadgeKind.stockLow),
      AppBadge(label: '12', kind: AppBadgeKind.qty),
    ]),
    const SizedBox(height: 12),
    AppNumberedStep(n: 1, text: 'Pilih produk', style: AppStepStyle.filled),
    AppNumberedStep(n: 2, text: 'Atur jumlah', style: AppStepStyle.outlined),
    const SizedBox(height: 12),
    Row(children: [
      AppButton.outline(label: 'Snackbar success', onPressed: () => AppSnackbar.success(context, 'OK!')),
    ]),
    Row(children: [
      AppButton.outline(label: 'Confirm', onPressed: () async {
        final ok = await AppConfirm.show(context, title: 'Yakin?', body: 'Aksi ini tidak bisa di-undo.', destructive: true);
        debugPrint('confirmed: $ok');
      }),
    ]),
  ]),
)
```

## Talking points

1. **Container-tinted styling** (banner success bg = `successContainer`, fg = onSurface): pattern Material 3 yang gentle. Bukan pakai full-color bg yang loud.

2. **Animated pulse dot** untuk `AppStatusPill(pulse: true)`: pakai `SingleTickerProviderStateMixin` di `_DotState`, AnimationController repeat reverse. Pulse cuma reasonable untuk status yang aktif berubah (QRIS menunggu).

3. **`ScaffoldMessenger.hideCurrentSnackBar().showSnackBar(...)`**:
   `hideCurrent` mencegah snackbar tumpuk kalau user trigger action cepat berurutan.

4. **`PopScope(canPop: false)`** di `AppLoadingDialog`:
   Mencegah user back-button pas loading. Lebih bagus daripada `WillPopScope` (deprecated di Flutter 3.13+).

5. **Static `_showing` flag**: guard supaya `show` 2x berturut-turut tidak bikin 2 dialog tumpuk. Trade-off: kalau context berbeda (multi-window) bisa bug — untuk POS HP single-window aman.

6. **`Color(0xFF7C4A0E)` hardcoded warning text**: kompromi karena 3 palette punya warning yang sama; readable di warning container.

## Commit suggestion

```bash
git add lib/core/components/app_status_pill.dart lib/core/components/app_badge.dart lib/core/components/app_numbered_step.dart lib/core/components/app_banner.dart lib/core/components/app_empty_state.dart lib/core/components/feedback.dart
git commit -m "Step 07: atoms — status pill, badge, numbered step, banner, empty state, feedback helpers"
```

---

➡️ Lanjut ke [Step 08 — Atoms: Form](./08-atoms-form.md)
