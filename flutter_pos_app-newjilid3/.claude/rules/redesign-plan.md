# Redesign Development Plan

Phased plan to migrate `flutter_pos_app` from the legacy UI (`AppColors.primary = #3949AB`, Material-default chrome) to the new POS Batch 11 design (3-palette, Caramel-default, Quicksand, soft surfaces).

Goal: ship visual + UX redesign **without rewriting the data layer**. Reskin first, refactor only what blocks the redesign, add the two missing features (`buka_kasir`, `promo`) last.

---

## 0. Phases at a glance

| Phase | Theme | Output | Branch suggestion |
|---|---|---|---|
| 1 | Foundation | Design tokens + theme module + main.dart cleanup | `redesign/phase-1-foundation` |
| 2 | Atoms | Build all 18 shared widgets in `core/components/` | `redesign/phase-2-atoms` |
| 3 | Auth & shift | Login + (new) BukaKasir + (reskin) CloseKasir | `redesign/phase-3-shift` |
| 4 | Catalog & order | Home (loaded + empty) + Scanner + OrderDetail (+empty) | `redesign/phase-4-catalog` |
| 5 | Payment | PaymentConfirm + PaymentSuccess + PaymentQRIS (page, not dialog) | `redesign/phase-5-payment` |
| 6 | Drafts | DraftOrder list + OpenBill sheet | `redesign/phase-6-drafts` |
| 7 | History | History (loaded + empty) + TransactionDetail (new page) | `redesign/phase-7-history` |
| 8 | Settings & management | Settings + Sync + Printer + Product + ServerKey + Report | `redesign/phase-8-settings` |
| 9 | Promo | New `promo` feature (entity + page + DiscountSheet) | `redesign/phase-9-promo` |
| 10 | Polish | Lint bump, dead-code cleanup, BlocObserver, env config, splash | `redesign/phase-10-polish` |

Each phase is reviewable independently and can be merged before the next starts.

---

## 1. Phase 1 — Foundation

### Tasks

1. **Bump `flutter_lints`** in `pubspec.yaml` from `^2.0.0` → `^4.0.0`. Fix newly-flagged warnings (mostly `use_super_parameters`, `prefer_const_constructors`, `unused_local_variable`).
2. **Add packages**:
   - `qr_flutter: ^4.1.0` (real QR rendering for QRIS)
   - `fl_chart: ^0.69.0` (Report trend chart) — *optional, can hand-roll instead*.
   - Remove `badges` (unused).
3. **Create `lib/core/theme/`** per `design-system.md` §1:
   - `app_palette.dart` — `AppPalette` ThemeExtension with 3 named constructors.
   - `app_spacing.dart`, `app_radius.dart`, `app_typography.dart` — constants.
   - `app_theme.dart` — `ThemeData buildTheme(AppPalette p)` that registers `AppPalette` as a `ThemeExtension` and bridges to `ColorScheme.fromSeed`.
4. **Create `ThemeBloc`** at `lib/presentation/setting/bloc/theme/theme_bloc.dart`:
   - State: `ThemeState({required String paletteName})`.
   - Events: `changed(name)`, `loaded()`.
   - On `loaded`, read from SharedPreferences. On `changed`, persist and emit.
   - Register in `MultiBlocProvider` and fire `..add(const ThemeEvent.loaded())`.
5. **Update `main.dart`**:
   - Add `WidgetsFlutterBinding.ensureInitialized()` at the top of `main()`.
   - Wrap `MaterialApp` in `BlocBuilder<ThemeBloc, ThemeState>` so swapping palette rebuilds the theme.
   - Replace the `FutureBuilder` auth-gate with a dedicated `SplashPage` widget (described below).
   - In dev (kDebugMode), set `Bloc.observer = AppBlocObserver()` (new helper at `lib/core/bloc/app_bloc_observer.dart` — logs every event/state via `dev.log`).
6. **Create `SplashPage`** at `lib/presentation/auth/pages/splash_page.dart`:
   - On `initState`, await `AuthLocalDatasource().isAuth()` then `pushReplacement` to either `DashboardPage` or `LoginPage`.
   - Render a centered `BrandMark` + tagline while waiting.
7. **Move base URL to dart-define**: change `Variables.baseUrl` to `String.fromEnvironment('BASE_URL', defaultValue: 'http://192.168.18.192:8000')`. Document the new run command in README.
8. **Mark `AppColors` as deprecated** with `@Deprecated('Use Theme.of(context).extension<AppPalette>()')`. Do NOT delete — legacy pages will still import it until they migrate.

### Acceptance

- App still runs. Login still works.
- `Theme.of(context).extension<AppPalette>()` returns the Caramel palette.
- Changing palette in (placeholder) Settings updates colors live.
- No `print(...)` in modified files.

---

## 2. Phase 2 — Atoms

Build every widget listed in `design-system.md` §7 in `lib/core/components/`. **Do not skip this phase** — without these atoms, screen work in Phases 3–9 will spawn one-off duplicates.

### Build order (each in its own file)

1. `app_button.dart`
2. `app_text_field.dart` (+ `app_money_text_field.dart` variant)
3. `app_chip.dart`
4. `app_status_pill.dart` + `app_badge.dart`
5. `app_stepper.dart` (+ `app_stepper_field.dart` for the +/− tile)
6. `app_switch_tile.dart`
7. `app_segmented_toggle.dart`
8. `app_icon_button.dart`
9. `app_card.dart` + `app_list_group.dart`
10. `app_app_bar.dart`
11. `app_bottom_nav.dart`
12. `app_bottom_sheet.dart` (`showAppBottomSheet` helper + `_AppBottomSheetShell`)
13. `app_key_value_row.dart`
14. `app_banner.dart`
15. `app_empty_state.dart` + `app_numbered_step.dart`
16. `app_section_label.dart` + `app_sticky_footer.dart`
17. `feedback.dart` (`AppSnackbar`, `AppConfirm`, `AppLoadingDialog`)
18. Domain helpers: `product_img.dart`, `avatar.dart`, `method_badge.dart`, `brand_mark.dart`, `qr_view.dart` (wraps `qr_flutter`), `trend_chart.dart`, `scanner_overlay.dart`.

### Acceptance

- A storybook page (`lib/presentation/dev/component_gallery_page.dart`, only accessible from a debug menu) renders every component in all variants.
- All atoms use `AppPalette` extension; no `AppColors.*` references.

---

## 3. Phase 3 — Auth & Shift

### Screens
- `login_page.dart` (reskin)
- `buka_kasir_page.dart` (**NEW**)
- close kasir (reskin — currently a dialog in `setting_page.dart:146-186`, promote to its own page)

### Design references
- `.claude/new-design/screens/login.jsx` (`LoginA` is the chosen variation — classic centered)
- `.claude/new-design/screens/buka-kasir.jsx`
- `.claude/new-design/screens/close-kasir.jsx`

### Backend / data changes
- Add `cash_sessions` table to `pos13.db`:
  ```sql
  CREATE TABLE cash_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    shift_label TEXT NOT NULL,             -- 'Pagi' | 'Siang' | 'Malam'
    opening_float INTEGER NOT NULL,
    opening_note TEXT,
    opened_at TEXT NOT NULL,               -- ISO
    cash_in INTEGER DEFAULT 0,
    cash_out INTEGER DEFAULT 0,
    physical_count INTEGER,
    variance INTEGER,
    closing_note TEXT,
    closed_at TEXT,
    is_sync INTEGER DEFAULT 0
  );
  ```
- Add `cash_session_id INTEGER` column to `orders`.
- Bump DB version `1 → 2`, write `_onUpgrade` for both changes.
- Add `cash_session_local_datasource.dart` (open/close/getCurrent/getById).
- Backend (Laravel): add `/api/cash-sessions` POST for sync if not present — coordinate before implementing.

### New bloc
- `cash_session_bloc.dart` (events: `open(shift, float, note)`, `close(physicalCount, note, printOnClose)`, `currentLoaded()`).

### Page flow
1. Login succeeds → `pushReplacement` to `BukaKasirPage` (NOT `DashboardPage`).
2. `BukaKasirPage` "Mulai Shift" → opens session → `pushReplacement` to `DashboardPage`.
3. Settings → "Tutup Kasir" → `ClosingKasirPage` → on success → `pushAndRemoveUntil` to `LoginPage`.
4. If on app open a `cash_session` is still open → skip BukaKasir, go straight to DashboardPage.

### Acceptance
- Open + close a shift, verify variance math (`expected = opening + cashIn − cashOut + cashRevenue`; `variance = physical − expected`).
- Closing prints a slip when toggle is on.

---

## 4. Phase 4 — Catalog & Order

### Screens
- `home_page.dart` (reskin both `home-empty.jsx` and `home-loaded.jsx`; toggle inside the page based on `ProductBloc` state)
- `scanner_page.dart` (reskin — add overlay)
- `order_page.dart` (reskin both `order-detail-empty.jsx` and `order-detail.jsx`)

### Design references
- `.claude/new-design/screens/home-empty.jsx`
- `.claude/new-design/screens/home-loaded.jsx` (use **grid view** as default; toggle to list)
- `.claude/new-design/screens/scanner.jsx`
- `.claude/new-design/screens/order-detail-empty.jsx`
- `.claude/new-design/screens/order-detail.jsx`

### Refactor required (before reskinning)
- **`CheckoutBloc.state.success`**: today is a 4-arg positional Freezed factory `success(List<Product> data, int totalQty, int totalPrice, List<int> qtys)`. Wrap in a `CheckoutSummary` Freezed data class so adding promo fields later doesn't break callsites.
- **`OrderBloc.state.success`**: 8-arg positional — same treatment, wrap in `OrderSummary` data class (see `architecture.md` §2.3).
- **Decouple payment dialogs from datasource**: today `payment_cash_dialog.dart` and `payment_qris_dialog.dart` call `ProductLocalDatasource.instance.saveOrder(...)` directly. Move this into `OrderBloc.add(OrderEvent.persistLocal(summary))` and have the dialog/bloc listen for `OrderState.persisted` before navigating. Necessary because the redesigned payment flow needs a clear point to attach receipt-printing, sync queue, etc.

### Local-storage additions
- Add `note TEXT` column to `order_items` so per-item notes work (see `order-detail.jsx:170` "Tambah catatan"). Bump DB version.

### Acceptance
- Grid/list toggle persists per session (not necessarily across launches).
- Adding items shows qty badge on product card + updates floating cart bar.
- "Pas/+5rb/+10rb/+20rb/+50rb" chips work on the cash field in OrderDetail (compute change live).
- Scanner detects a barcode → adds matching product to cart, returns to caller.

---

## 5. Phase 5 — Payment

### Screens
- Convert `payment_cash_dialog.dart` → **`PaymentConfirmSheet`** bottom sheet (called from `OrderPage`).
- Convert `payment_success_dialog.dart` → **`PaymentSuccessSheet`** bottom sheet.
- Promote `payment_qris_dialog.dart` → **full `PaymentQRISPage`** (the design has it as a sheet too, but full page is friendlier for status-polling and not blocked by accidental swipe-dismiss; alternatively keep as sheet — pick one, document the choice).

### Design references
- `.claude/new-design/screens/payment-flow.jsx`
- `.claude/new-design/screens/payment-qris.jsx`

### Data changes
- None — `OrderBloc` already covers the data flow.

### Implementation notes
- **QR generation**: replace `FauxQR` with `QrImageView(data: qrPayload, version: QrVersions.auto, size: 200)` from `qr_flutter`. Embed brand logo via `embeddedImage`.
- **Countdown timer**: simple `Timer.periodic(Duration(seconds: 1), ...)` in `StatefulWidget` — display "QR berlaku N menit Mdetik lagi".
- **Cek Status**: `QrisBloc.add(QrisEvent.checkStatus(orderId))` → on success → `PaymentSuccessSheet`.
- **Receipt print**: after `PaymentSuccessSheet` is shown, kick off `print_bluetooth_thermal` flow via the existing `CwbPrint` formatter (`lib/data/dataoutputs/cwb_print.dart`). Wrap in a try/catch — if no printer paired, show snackbar "Struk disimpan sebagai PDF" and use the `pdf` package to save instead.

### Acceptance
- Cash flow: enter received amount → see change live → confirm → success sheet → close returns to Home with cleared cart.
- QRIS flow: see real QR → poll status → success → close returns to Home.
- "Cetak ulang" actually re-prints from the printer.

---

## 6. Phase 6 — Drafts

### Screens
- `draft_order_page.dart` (reskin both empty + loaded; fold expand/collapse into the existing UI)
- New: `open_bill_sheet.dart` (bottom sheet, opened from OrderPage "Save → Draft" action)

### Design references
- `.claude/new-design/screens/draft-order-empty.jsx`
- `.claude/new-design/screens/draft-order.jsx`

### Refactor
- Rename `presentation/draft_order/wedgets/` → `widgets/`.
- `DraftOrderBloc` already exists — verify it supports: list, expand-one-at-a-time, delete, "Bayar" (which loads draft into `CheckoutBloc` and navigates to OrderPage).
- Add `customer_name TEXT` and `table_label TEXT` columns to `draft_orders` if missing — bump DB version.

### Acceptance
- From OrderPage, tap "Draft" → OpenBillSheet → enter meja + nama → save → returns to DraftOrderPage with new entry.
- Expand a draft to see items + 3 actions (Edit, Cetak ulang, Hapus).
- "Bayar" on a draft loads it back into the cart and navigates to OrderPage.

---

## 7. Phase 7 — History

### Screens
- `history_page.dart` (reskin both empty + loaded; sticky day headers, filter chips, expandable cards)
- New: `transaction_detail_page.dart` — promote from inline `ExpansionTile` in `history_transaction_card.dart` to a full page (matches the new design's "permanent record" treatment, enables refund + share + reprint).

### Design references
- `.claude/new-design/screens/history-empty.jsx`
- `.claude/new-design/screens/history-loaded.jsx`
- `.claude/new-design/screens/transaction-detail.jsx`

### Refactor
- `HistoryBloc` likely needs a new event `loadByDateRange(from, to)` for the date filter chips (Hari Ini / Minggu Ini / Bulan Ini / Pilih tanggal).
- Group transactions by date in the UI layer (`groupBy` from `collection` package — already pulled transitively; if not, add).

### Acceptance
- Filter chips actually filter.
- Expanding one card collapses the previously expanded one (animation: 200ms).
- Tapping "Detail" navigates to `TransactionDetailPage` with the full record.
- Refund button is **disabled placeholder** for now (real refund flow is out of scope this round) — add `AppSnackbar.info(context, 'Fitur refund segera hadir')`.

---

## 8. Phase 8 — Settings & Management

### Screens
- `setting_page.dart` — grouped tiles with live status (already exists; reskin extensively).
- `sync_data_page.dart` (reskin) — per-row sync, last-sync time, activity log.
- `manage_printer_page.dart` (reskin) — pairing UI + status banner + permission hint.
- `manage_product_page.dart` (reskin) + `product_detail_sheet.dart` (NEW bottom sheet) + `add_product_page.dart` (reskin).
- `save_server_key_page.dart` (reskin) — environment toggle + masked key + sensitivity hint.
- `report_page.dart` (reskin) — date-range chips + 4 metric cards + trend chart + product table + PDF export.

### Design references
- `.claude/new-design/screens/settings.jsx`
- `.claude/new-design/screens/sync-data.jsx`
- `.claude/new-design/screens/printer.jsx`
- `.claude/new-design/screens/product.jsx`
- `.claude/new-design/screens/server-key.jsx`
- `.claude/new-design/screens/report.jsx`

### Data changes
- Add `image_url TEXT`, `is_bestseller INTEGER DEFAULT 0` columns to `products` table (the "Best" pill in `home-loaded.jsx` and `product.jsx` requires this). Bump DB version.
- Wire `add_product` multipart upload to include `is_bestseller`.

### Acceptance
- Settings page reflects live device state (printer connected/disconnected, server key set/not, last sync time).
- Sync Data: per-row "Sync" works; "Sinkronkan semua" syncs in order with progress.
- Manage Printer: scan → pick → pair → status banner updates to success.
- Manage Product: list shows stock badges; detail sheet shows stats; add form validates all required fields.
- Server Key: env toggle persists; eye-icon toggles masked/plaintext.
- Report: date-range filter works; PDF export still works; share intent opens.

---

## 9. Phase 9 — Promo (new feature)

### Screens
- `manage_promo_page.dart` — list active + scheduled, FAB to create. (Add a tile in Settings under "Produk & Penjualan".)
- `discount_sheet.dart` — bottom sheet opened from OrderPage to apply voucher/auto promo/manual discount.
- `add_edit_promo_page.dart` — form to create/edit a promo (out of scope for the JSX, design as a standard form following `add_product_page.dart` patterns).

### Design references
- `.claude/new-design/screens/promo.jsx` (`DiscountSheet` + `ManagePromoPage`)

### Data changes
- New `promos` table:
  ```sql
  CREATE TABLE promos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL,                   -- 'percent' | 'rupiah' | 'b1g1'
    value INTEGER NOT NULL,               -- percent (0-100) or rupiah
    code TEXT UNIQUE,                     -- voucher code; NULL = auto-apply
    applies_to TEXT,                      -- JSON: {"category": "kopi"} or {"productIds": [1,2]}
    starts_at TEXT,
    ends_at TEXT,
    active INTEGER DEFAULT 1,
    is_sync INTEGER DEFAULT 0
  );
  ```
- Add `promo_id INTEGER`, `discount_amount INTEGER DEFAULT 0` columns to `orders`.
- Bump DB version, write `_onUpgrade`.

### Bloc
- `promo_bloc.dart` — list/filter/toggle/active/inactive.
- `discount_bloc.dart` (or fold into `CheckoutBloc`) — apply promo to cart; compute hemat = `subtotal × percent/100` or `rupiah` etc.

### Backend
- Add `/api/promos` CRUD on the Laravel side. Sync via the same `is_sync` pattern.

### Acceptance
- From OrderPage, tap "Diskon" entry → DiscountSheet → enter MEMBER10 → "Pakai" → returns to OrderPage with discount line in summary and updated total.
- Manage Promo: live banner shows the currently-running promo (compare `starts_at/ends_at` to `now`).
- Switch toggles active on/off.

---

## 10. Phase 10 — Polish

- Remove `// commented-out` blocks across all touched files.
- Replace remaining `print(...)` → `dev.log`.
- Remove `lib/core/constants/colors.dart` `AppColors` if all callers migrated; otherwise keep `@Deprecated`.
- Add a `BlocObserver` that logs to a rolling file in debug builds (helpful for QA).
- Walk through every page on a real device — verify dynamic font scaling (`MediaQuery.textScalerOf`), small phones (360dp), large phones (430dp), and the bottom nav `SafeArea` insets.
- Capture screenshots for the PR description.
- Smoke-test the full happy path: login → buka kasir → add items → checkout (cash) → see in history → tutup kasir → re-login.

---

## 11. Per-screen migration table

For each new design screen, the existing Flutter file to reskin (or "NEW" if the file doesn't exist):

| Design (.claude/new-design/screens/) | Existing Flutter file | Action |
|---|---|---|
| `login.jsx` | `lib/presentation/auth/pages/login_page.dart` | RESKIN |
| `buka-kasir.jsx` | — | **NEW** `lib/presentation/cash_session/pages/buka_kasir_page.dart` |
| `close-kasir.jsx` | inline dialog in `setting_page.dart:146-186` | **PROMOTE TO PAGE** `lib/presentation/cash_session/pages/tutup_kasir_page.dart` |
| `home.jsx` / `home-empty.jsx` / `home-loaded.jsx` | `lib/presentation/home/pages/home_page.dart` | RESKIN — branch on `ProductBloc` state for empty/loaded |
| `scanner.jsx` | `lib/presentation/home/pages/scanner_page.dart` | RESKIN — overlay |
| `order-detail.jsx` / `order-detail-empty.jsx` | `lib/presentation/order/pages/order_page.dart` | RESKIN — branch on cart empty/loaded |
| `payment-flow.jsx` (confirm) | `lib/presentation/order/widgets/payment_cash_dialog.dart` | CONVERT dialog → bottom sheet |
| `payment-flow.jsx` (success) | `lib/presentation/order/widgets/payment_success_dialog.dart` | CONVERT dialog → bottom sheet |
| `payment-qris.jsx` | `lib/presentation/order/widgets/payment_qris_dialog.dart` | PROMOTE to page OR keep as sheet (decide; document) |
| `draft-order.jsx` (OpenBillSheet) | inline in `order_page.dart:77-167` | **EXTRACT** to `lib/presentation/order/widgets/open_bill_sheet.dart` |
| `draft-order.jsx` (DraftOrdersPage) / `draft-order-empty.jsx` | `lib/presentation/draft_order/pages/draft_order_page.dart` | RESKIN |
| `history-loaded.jsx` / `history-empty.jsx` | `lib/presentation/history/pages/history_page.dart` | RESKIN |
| `transaction-detail.jsx` | inline `ExpansionTile` in `lib/presentation/history/widgets/history_transaction_card.dart` | **NEW PAGE** `lib/presentation/history/pages/transaction_detail_page.dart` |
| `settings.jsx` | `lib/presentation/setting/pages/setting_page.dart` | RESKIN extensively |
| `sync-data.jsx` | `lib/presentation/setting/pages/sync_data_page.dart` | RESKIN |
| `printer.jsx` | `lib/presentation/setting/pages/manage_printer_page.dart` | RESKIN |
| `product.jsx` (list) | `lib/presentation/setting/pages/manage_product_page.dart` | RESKIN |
| `product.jsx` (detail sheet) | — | **NEW** `lib/presentation/setting/widgets/product_detail_sheet.dart` |
| `product.jsx` (add) | `lib/presentation/setting/pages/add_product_page.dart` | RESKIN |
| `server-key.jsx` | `lib/presentation/setting/pages/save_server_key_page.dart` | RESKIN |
| `report.jsx` | `lib/presentation/setting/pages/report/report_page.dart` | RESKIN |
| `promo.jsx` (DiscountSheet) | — | **NEW** `lib/presentation/promo/widgets/discount_sheet.dart` |
| `promo.jsx` (ManagePromoPage) | — | **NEW** `lib/presentation/promo/pages/manage_promo_page.dart` |
| (no design) | — | **NEW** `lib/presentation/promo/pages/add_edit_promo_page.dart` (derive from `add_product_page.dart` patterns) |

---

## 12. Risk register

| Risk | Mitigation |
|---|---|
| SQLite migrations across multiple phases (Phase 3, 4, 6, 8, 9 all add columns/tables) | Use a single sequential version bump per phase + `switch` in `_onUpgrade`. Test the upgrade path from version 1 each phase by deleting `pos13.db` from a built APK and reinstalling. |
| Backend Laravel may not have endpoints for `cash_sessions` and `promos` | Coordinate via the backend repo (`/Users/bahri/development/FIC11Jilid2/laravel-pos-backend-prejilid2`). Until present, store local-only with `is_sync = 0` and document the pending sync. |
| Existing 8-arg positional state tuples (`OrderState.success`) will break callers when wrapped | Do the refactor in Phase 4, gated by passing tests if added. Search for `.maybeWhen(success: (data, qty, total,` across `lib/` and update each callsite. |
| Quicksand via `google_fonts` requires network on first run | Bundle the font files (`Quicksand-Regular.ttf`, `Medium`, `SemiBold`, `Bold`) under `assets/fonts/` and reference in `pubspec.yaml`'s `fonts:` section. Falls back gracefully. |
| Reskin causes regression on a flow you didn't touch (e.g. printing) | After each phase, run the full smoke-test path (Phase 10 checklist). Don't skip device testing — `flutter analyze` won't catch UX bugs. |
| 3 palettes × every screen multiplies QA surface | Default to Caramel; QA Espresso and Matcha only on the Settings palette picker + 2 random screens (Home + Order). |

---

## 13. Definition of "done" for a screen

A redesigned screen is done when ALL of these are true:

- [ ] Uses **only** `AppPalette` extension; zero `AppColors.*` references in this file.
- [ ] Uses `AppButton`, `AppTextField`, `AppChip`, etc. — no bespoke buttons/inputs.
- [ ] Bahasa Indonesia copy matches the design spec exactly (case, punctuation).
- [ ] Handles loading / empty / error / success states per `design-system.md` §8.5.
- [ ] No `print(...)` statements; no commented-out blocks.
- [ ] Reviewed on a real device at 360dp width and 430dp width.
- [ ] If it has a bottom nav, the `SafeArea` insets render correctly (no overlap with the system gesture pill).
- [ ] If it has a primary CTA, the shadow tint matches `primary @ 25%`.
- [ ] Screenshot attached to PR.

---

## 14. Out of scope (do NOT do)

- Tablet / landscape layouts.
- Dark mode.
- i18n (ARB / `AppLocalizations`) — strings stay inline.
- Migrating to `go_router`.
- Migrating data models to Freezed.
- Refund implementation (placeholder snackbar only this round).
- Web / desktop builds.
- Tests beyond manual smoke testing.
