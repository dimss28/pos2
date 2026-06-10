# Design System — Flutter POS App

Source of truth for visual design: `.claude/new-design/theme.jsx` (tokens) + `.claude/new-design/icons.jsx` (icons) + the 24 `screens/*.jsx` files.

This document translates those JSX tokens and atoms into Flutter conventions. Anything in `.claude/new-design/` is **specification, not code** — translate to idiomatic Flutter.

---

## 1. Theme location

New folder to create under `lib/core/theme/`:

```
lib/core/theme/
├── app_theme.dart            # ThemeData builder; registers extensions
├── app_palette.dart          # AppPalette ThemeExtension (color tokens)
├── app_spacing.dart          # AppSpacing constants
├── app_radius.dart           # AppRadius constants
└── app_typography.dart       # AppTypography (TextStyles built from Quicksand)
```

`AppColors` (legacy, in `lib/core/constants/colors.dart`) stays for legacy pages, marked `@Deprecated`.

---

## 2. Palettes (3 themes — user picks one in Settings)

From `theme.jsx`:

| Token | Espresso | Caramel Latte (default) | Matcha |
|---|---|---|---|
| `primary` | `#5C3A21` | `#B8743D` | `#6B8E3D` |
| `primaryDark` | `#3E2613` | `#8A5527` | `#4F6B2A` |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` | `#FFFFFF` |
| `primaryContainer` | `#F1E4D4` | `#F8E6D0` | `#E4ECCD` |
| `onPrimaryContainer` | `#3E2613` | `#4A2810` | `#2A3815` |
| `secondary` | `#2A1F14` | `#1F1812` | `#1B2014` |
| `surface` | `#FAF5EE` | `#FBF6EE` | `#F8FAF0` |
| `surfaceVariant` | `#ECE0D0` | `#EFE4D2` | `#E8ECD8` |
| `surfaceDim` | `#D9CAB6` | `#DECDB2` | `#D2D9BD` |
| `outline` | `#C8B89E` | `#C9B59A` | `#BAC3A0` |
| `outlineSoft` | `#E8DCC8` | `#EBDFCB` | `#E2E8CF` |
| `onSurface` | `#2A1F14` | `#241B12` | `#1C2114` |
| `onSurfaceVar` | `#6B5C4A` | `#6E5E48` | `#5E6650` |
| `success` | `#5A7A3A` | `#5A7A3A` | `#5A7A3A` |
| `successContainer` | `#E3EFD0` | `#E3EFD0` | `#E4ECCD` |
| `warning` | `#B87A1E` | `#B87A1E` | `#B87A1E` |
| `warningContainer` | `#F8E6C2` | `#F8E6C2` | `#F8E6C2` |
| `error` | `#A8392E` | `#A8392E` | `#A8392E` |
| `errorContainer` | `#F5D7D3` | `#F5D7D3` | `#F5D7D3` |

**Default palette**: Caramel Latte (matches the screens shipped in `home-loaded.jsx`, `order-detail.jsx`, etc.).

### `AppPalette` ThemeExtension shape

```dart
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color primary, primaryDark, onPrimary, primaryContainer, onPrimaryContainer;
  final Color secondary;
  final Color surface, surfaceVariant, surfaceDim;
  final Color outline, outlineSoft;
  final Color onSurface, onSurfaceVar;
  final Color success, successContainer;
  final Color warning, warningContainer;
  final Color error, errorContainer;

  const AppPalette.caramel() : /* hardcoded values */;
  const AppPalette.espresso() : ...;
  const AppPalette.matcha() : ...;

  @override
  AppPalette copyWith({...}) => ...;
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) => ...;
}
```

Access in widgets:

```dart
final p = Theme.of(context).extension<AppPalette>()!;
return Container(color: p.surface, ...);
```

### Persisting the chosen palette

- Store `palette: 'caramel' | 'espresso' | 'matcha'` in `SharedPreferences`.
- Wire it via a `ThemeBloc` (new bloc, register in `MultiBlocProvider`) that emits the active palette name; `MaterialApp` rebuilds with the matching `ThemeData`.

### Material 3 ColorScheme bridging

The `ThemeData.colorScheme` is still set via `ColorScheme.fromSeed(seedColor: p.primary)` so that built-in Material widgets (TextField, Switch, etc.) look correct. The `AppPalette` extension adds the extra semantic tokens (success, warning, surfaceVariant variations, etc.) that Material 3 doesn't standardize.

---

## 3. Spacing (4pt grid)

```dart
class AppSpacing {
  static const double xs   = 4;   // SP.1
  static const double sm   = 8;   // SP.2
  static const double md   = 12;  // SP.3
  static const double lg   = 16;  // SP.4
  static const double xl   = 20;  // SP.5
  static const double xxl  = 24;  // SP.6
  static const double xxxl = 32;  // SP.8
  static const double huge = 40;  // SP.10
  static const double mega = 48;  // SP.12
}
```

Use everywhere instead of magic numbers. The legacy `SpaceHeight(h)` / `SpaceWidth(w)` widgets keep working — pass `AppSpacing.lg` instead of `16`.

---

## 4. Radius

```dart
class AppRadius {
  static const double xs   = 6;
  static const double sm   = 10;
  static const double md   = 14;
  static const double lg   = 20;
  static const double xl   = 28;
  static const double pill = 999;
}

// Convenience BorderRadius accessors
extension AppRadiusExt on double {
  BorderRadius get all => BorderRadius.circular(this);
}
```

---

## 5. Typography (Quicksand)

| Token | Size | Weight | Line height | Letter spacing |
|---|---|---|---|---|
| `displayL` | 32 | 700 | 40 | -0.5 |
| `displayM` | 26 | 700 | 32 | -0.3 |
| `titleL` | 22 | 700 | 28 | -0.2 |
| `titleM` | 18 | 600 | 24 | 0 |
| `titleS` | 15 | 600 | 20 | 0 |
| `bodyL` | 16 | 500 | 24 | 0 |
| `bodyM` | 14 | 500 | 20 | 0 |
| `bodyS` | 12 | 500 | 16 | 0 |
| `labelL` | 14 | 600 | 18 | 0.1 |
| `labelM` | 12 | 600 | 16 | 0.3 |
| `priceL` | 22 | 700 | 26 | -0.2 |
| `priceM` | 17 | 700 | 22 | 0 |

```dart
class AppTypography {
  static final TextStyle displayL = GoogleFonts.quicksand(fontSize: 32, fontWeight: FontWeight.w700, height: 40/32, letterSpacing: -0.5);
  // ... etc
}

// Use:
Text('Detail Order', style: AppTypography.titleL.copyWith(color: p.onSurface));
```

Quicksand is loaded via `google_fonts: ^7.0.0` at runtime — keep that, or bundle the .ttf in `assets/fonts/` for offline-first guarantee (recommended, since the app is offline-first).

---

## 6. Icons

The design uses a monoline stroke icon set (24×24, strokeWidth 2). Map them to Flutter as follows:

| JSX name | Source in Flutter | Notes |
|---|---|---|
| `eye` / `eye-off` | `Icons.visibility_outlined` / `Icons.visibility_off_outlined` | |
| `mail` | `Icons.mail_outline` | |
| `lock` | `Icons.lock_outline` | |
| `search` | `Icons.search` | |
| `qr` | `Icons.qr_code_2` | (also keep `assets/icons/qr_code.svg` for the scan button overlay) |
| `cart` | `Icons.shopping_cart_outlined` | |
| `home` | `Icons.home_outlined` (active: `Icons.home`) | |
| `receipt` | `Icons.receipt_long_outlined` | |
| `clock` | `Icons.access_time` | |
| `settings` | `Icons.settings_outlined` | |
| `plus` / `minus` | `Icons.add` / `Icons.remove` | |
| `arrow-right` | `Icons.arrow_forward_rounded` | |
| `chev-right` / `chev-down` | `Icons.chevron_right` / `Icons.expand_more` | |
| `star` | `Icons.star_rounded` | |
| `filter` | `Icons.tune` | |
| `sparkle` | `Icons.auto_awesome` | |
| `check` | `Icons.check_rounded` | |
| `leaf` / `coffee` | Use custom SVG if needed | |
| `tag` | `Icons.local_offer_outlined` | |
| `fire` | `Icons.local_fire_department_outlined` | |
| `bell` | `Icons.notifications_outlined` | |

Stroke width is achieved via `Icon(..., weight: 500)` (Material Symbols) or by picking the `_outlined` variant. For brand-only marks (coffee cup logo in `login.jsx:14-34`), keep them as custom SVG and store under `assets/icons/brand_mark.svg`.

---

## 7. Atoms — build these FIRST (Phase 2 of redesign)

Each atom below lives in `lib/core/components/`. The "Maps to" column points at the JSX reference.

### 7.1 `AppButton`

Maps to: `PrimaryButton` (login.jsx:57), CTA buttons throughout.

```dart
enum AppButtonVariant { primary, primaryWithArrow, outline, ghost, danger }
enum AppButtonSize { sm, md, lg }      // 40 / 48 / 56 pixel heights

class AppButton extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool fullWidth;
  final VoidCallback? onPressed;
  // ...
}
```

Variants:
- **primary**: filled `primary`, `onPrimary` text, shadow `primary40` (use `BoxShadow(color: p.primary.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))`).
- **primaryWithArrow**: same body + trailing 40×40 chip with `${onPrimary}22` bg containing an arrow. Used on `order-detail.jsx:407` and `home-loaded.jsx:113`.
- **outline**: transparent bg, `1.5px outline` border, `onSurface` text.
- **ghost**: text-only, no border.
- **danger**: `error55` border + `error` text (outlined danger). Or filled-error variant for refund actions.

Loading state replaces label with `SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: ...))`.

### 7.2 `AppTextField`

Maps to: `TextField` (login.jsx:36), `FormField` (draft-order.jsx:148).

```dart
class AppTextField extends StatelessWidget {
  final String? label;            // shown above the field
  final String hint;
  final IconData? leadingIcon;
  final Widget? trailing;
  final TextEditingController? controller;
  final bool obscure;
  final bool autofocus;
  final TextInputType keyboardType;
  final String? prefixText;       // e.g. 'Rp'
  final String? errorText;
  final bool subtle;              // for non-focused secondary fields
  final TextStyle? valueStyle;    // for monospace amount inputs
  final void Function(String)? onChanged;
}
```

Style: 56px tall, 16px horizontal padding, `R.md` radius. Idle border `1.5px outline`. Focused border `1.5px primary` + outer box-shadow `0 0 0 4px primary @ 10% opacity` (use a Stack with a glow Container, or a `decoration: BoxDecoration(boxShadow: ...)`).

### 7.3 `AppChip`

Maps to: filter chips (history-empty.jsx, home.jsx), quick-amount chips (order-detail.jsx).

```dart
enum AppChipVariant { filter, suggestion, money, status }
class AppChip extends StatelessWidget {
  final String label;
  final bool active;
  final IconData? leadingIcon;
  final Color? activeBg;          // override for status chips
  final Color? activeFg;
  // ...
}
```

Default active: `onSurface` bg + `surface` text (inverse chip — see `history-empty.jsx:62-72`).
Alternative active: `primaryContainer` bg + `onPrimaryContainer` text (used in quick-amount chips).

### 7.4 `AppStatusPill`

Maps to: success/warn/error pills throughout (`buka-kasir.jsx:120` BALANCED, `payment-qris.jsx` MENUNGGU, `transaction-detail.jsx` LUNAS).

```dart
enum AppStatusKind { success, warning, error, info, neutral }
class AppStatusPill extends StatelessWidget {
  final String label;             // usually UPPERCASE
  final AppStatusKind kind;
  final bool showDot;             // leading colored dot
}
```

### 7.5 `AppBadge`

Maps to: stock badges (home.jsx:59-68), qty badges (home-loaded.jsx:178-187), nav badges.

### 7.6 `AppStepper`

Maps to: order-item stepper (order-detail.jsx + home-loaded.jsx:285).

```dart
enum AppStepperSize { sm, md }    // 32 / 40 height
class AppStepper extends StatelessWidget {
  final int qty;
  final int min;                  // default 0; cart line is 1
  final int? max;                 // optional stock cap
  final ValueChanged<int> onChanged;
  final AppStepperSize size;
}
```

Style: `primaryContainer` track, `R.sm` radius, +/− glyphs in `primary`, qty in `onPrimaryContainer` `700`.

### 7.7 `AppSwitchTile`

Maps to: close-kasir (cetak struk closing), draft sheet (cetak bukti pesanan), add-product (Bestseller), promo manage rows. 44×24 track for full tiles, 36×22 for compact rows.

### 7.8 `AppSegmentedToggle`

Maps to: server-key Environment (server-key.jsx), promo DiscountSheet `TypeToggle`. Container with `surfaceVariant` bg; active segment is a `Card`-like white with soft shadow.

### 7.9 `AppIconButton`

44×44 square. Variants: `transparent` (back arrows), `surfaceVariant` (calendar, share, filter).

### 7.10 `AppCard` / `AppListGroup`

Maps to: every grouped section (settings, recon, info rows, items list).

```dart
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? background;        // default: surface
  final BorderRadius? radius;
  final Border? border;           // default: 1px outlineSoft
}

// For grouped rows with internal separators
class AppListGroup extends StatelessWidget {
  final List<Widget> children;    // separated by 1px outlineSoft
}
```

### 7.11 `AppEmptyState`

Maps to: home-empty, order-detail-empty, draft-order-empty, history-empty, printer (no devices). Slots: `visual` (a custom widget), `title`, `body`, optional `helperCard` (small explainer with numbered steps), `primaryAction`, `secondaryAction`.

### 7.12 `AppNumberedStep`

```dart
enum AppStepStyle { filled, outlined }
class AppNumberedStep extends StatelessWidget {
  final int n;
  final String text;
  final AppStepStyle style;
}
```

Filled = `primary` circle, `onPrimary` text. Outlined = `1.5px primary` border, `primary` text.

### 7.13 `AppBanner`

Inline notice card. Maps to: home-empty warning, printer warning, sync-data success, txn-detail success hero.

```dart
enum AppBannerKind { success, warning, error, info, primary }
class AppBanner extends StatelessWidget {
  final AppBannerKind kind;
  final IconData? leadingIcon;
  final String title;
  final String? body;
  final Widget? trailing;         // e.g. action button
  final bool pulse;               // for live status (promo "berlangsung")
}
```

### 7.14 `AppAppBar`

Replaces `Scaffold.appBar` everywhere. Slots: leading back-arrow (auto-hidden on root tabs), title (`titleL`), subtitle (`bodyS`, `onSurfaceVar`), trailing actions. Height ~64. Color: `surface` (NOT primary — the new design has a clean header, unlike the legacy white-on-primary).

### 7.15 `AppBottomNav`

Maps to: `BottomNav` (home.jsx:510). 4 tabs (Home / Order / Riwayat / Setting). Active pill: `primaryContainer` background with `onPrimaryContainer` icon. Inactive: transparent.

Items receive `badge: int?` so the cart count can appear on Order, and pending-sync count on Setting.

### 7.16 `AppBottomSheet`

Wrapper for `showModalBottomSheet`. Provides:
- 24px top corners
- 40×4 drag handle (8px below top)
- 20px horizontal padding
- Optional sticky bottom action row
- `maxHeightFactor: 0.92` default

```dart
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  Widget? bottomActions,
  double maxHeightFactor = 0.92,
});
```

### 7.17 Pricing & detail rows

`AppKeyValueRow` — label left / value right. Variants:
- `regular` — onSurfaceVar label, onSurface value
- `big` — used for "Total" (bodyL + priceL)
- `accent` — value in `success` (kembalian)
- `muted` — value in `onSurfaceVar` (discount line)
- `highlight` — top border + bold (Estimasi kas akhir in close-kasir)

### 7.18 Helper widgets needed for specific screens

| Widget | Used by | Notes |
|---|---|---|
| `ProductImg` | home, order, history, drafts, txn-detail, report | Initial-letter placeholder with hue-tinted bg. Use `cached_network_image` when product has a real `image` field, else fall back to colored tile. |
| `Avatar` | settings, buka/close kasir, payment-success | round, initials, primary bg or primaryContainer bg |
| `MethodBadge` | history list | 40×40, color-coded by payment method (`cash`=success, `qris`=primary, `transfer`=warning) |
| `BrandMark` | login | Coffee-cup SVG; store as `assets/icons/brand_mark.svg` |
| `FauxQR` → real `QrImageView` | payment-qris | Use `qr_flutter` package (add to pubspec). Wrap with logo overlay via `embeddedImage`. |
| `TrendChart` | report | Mini chart, ~300×88. Use `fl_chart` (add to pubspec) or hand-roll a `CustomPainter` for the 7-day polyline. |
| `ScannerOverlay` | scanner | 4 corner brackets + animated scan line; overlay on top of `MobileScanner` widget. |

### 7.19 Feedback helpers

```dart
// lib/core/components/feedback.dart
class AppSnackbar {
  static void success(BuildContext context, String message);
  static void error(BuildContext context, String message);
  static void info(BuildContext context, String message);
}

class AppConfirm {
  static Future<bool> show(BuildContext context, {
    required String title,
    required String body,
    String confirmLabel = 'Lanjut',
    String cancelLabel = 'Batal',
    bool destructive = false,
  });
}

class AppLoadingDialog {
  static void show(BuildContext context);
  static void hide(BuildContext context);
}
```

---

## 8. Layout patterns

### 8.1 Standard page shell

```dart
Scaffold(
  backgroundColor: p.surface,
  appBar: AppAppBar(title: 'Detail Order', subtitle: '#ORD-1248 · Meja 4', trailing: [...]),
  body: SafeArea(
    bottom: false,
    child: Column(children: [
      Expanded(child: ListView(...)),
      AppStickyFooter(child: AppButton.primary(label: 'Bayar', ...)),  // optional
    ]),
  ),
  bottomNavigationBar: hasBottomNav ? AppBottomNav(active: 1, cartCount: 3) : null,
);
```

### 8.2 Sticky bottom CTA

Add 1px top border `outlineSoft`, 16px padding (12 vertical), `surface` background. Use a `Container` placed in `Scaffold.body` rather than `bottomNavigationBar` when there's also a tab bar.

### 8.3 Floating cart bar (above bottom nav)

Maps to: home-loaded.jsx:84-122, home.jsx:151-181.

Implement as a `Stack` overlay positioned `bottom: kBottomNavigationBarHeight + 12, left: 16, right: 16`. Background = `primary`. Padding 10/10/10/18 (T/R/B/L). Trailing inverted `AppButton.outline` (white bg, primary text).

### 8.4 Section headers

```dart
Padding(
  padding: const EdgeInsets.only(top: 18, bottom: 8),
  child: Text('PRODUK & PENJUALAN',
    style: AppTypography.labelM.copyWith(
      color: p.onSurfaceVar,
      letterSpacing: 1.2,
    )),
)
```

### 8.5 Empty/loading/error states

Every list-rendering page must handle all three:

```dart
BlocBuilder<XxxBloc, XxxState>(
  builder: (context, state) => state.maybeWhen(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (msg) => AppEmptyState.error(message: msg, onRetry: () => bloc.add(...)),
    success: (data) => data.isEmpty
      ? AppEmptyState.noData(title: '...', body: '...', primaryAction: ...)
      : _buildList(data),
    orElse: () => const SizedBox.shrink(),
  ),
);
```

---

## 9. Asset / color audit map

When migrating an existing legacy widget, replace these:

| Legacy (`AppColors`) | New |
|---|---|
| `AppColors.primary` (`#3949AB`) | `p.primary` (caramel `#B8743D`) |
| `AppColors.white` | `p.surface` or `p.onPrimary` (context-dependent) |
| `AppColors.light` | `p.surfaceVariant` |
| `AppColors.black` | `p.onSurface` |
| `AppColors.grey` | `p.onSurfaceVar` |
| `AppColors.card` (`#E5E5E5`) | `p.outlineSoft` |
| `AppColors.green` | `p.success` |
| `AppColors.red` | `p.error` |
| `AppColors.disabled` | `p.outline` |
| `AppColors.blueLight` | (was decoration — replace contextually with `p.primaryContainer`) |

If a legacy widget cannot be reskinned without breaking another page, copy-edit-replace it under `core/components/` with the new name (e.g. `Button` → `AppButton`), and migrate callers page-by-page.

---

## 10. Specific design system rules

- **Border radius**: never use `BorderRadius.circular(16)` — use `AppRadius.md.all`.
- **Shadow on primary**: always tint with the primary color (`p.primary.withOpacity(0.25)`, offset `(0, 6)`, blur 16) for primary CTAs. Other shadows: avoid; the design uses borders + soft inner surfaces instead.
- **No drop shadows on cards** — use `1px outlineSoft` border. Only modals and floating cart bars get shadows.
- **Animations**: use Flutter's default `Duration(milliseconds: 200)` for state changes (chev rotate, expand cards), `300` for sheet transitions. Use `Curves.easeOutCubic` by default.
- **Icons inside buttons**: 18px for `sm`, 20px for `md`, 22px for `lg`.
- **Dividers between rows in a list group**: 1px `outlineSoft`, full width inside the card.
- **Disabled states**: opacity 0.5–0.6, no color change (matches `home.jsx:191` and `home-empty.jsx` disabled search).
- **Required field marker**: `*` in `p.error`, before or after the label.

---

## 11. Tablet / large screen note

The new-design JSX targets 380×760 (phone portrait). The redesign is **phone-first**; tablet layouts are out of scope for this round. If a particular screen breaks at >600dp width, gracefully cap content width to 480dp and center.
