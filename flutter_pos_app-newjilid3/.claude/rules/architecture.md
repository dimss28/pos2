# Architecture Rules — Flutter POS App

Authoritative conventions for `flutter_pos_app`. When a rule below conflicts with code you find in the repo, the rule wins — the code is the legacy that the redesign is correcting.

---

## 1. Layer-first + feature-first hybrid

```
lib/
├── main.dart                     # MultiBlocProvider + MaterialApp + auth gate
├── core/                         # cross-cutting: tokens, components, extensions
│   ├── assets/                   # flutter_gen output (do not hand-edit)
│   ├── components/               # shared widgets (atoms + molecules)
│   ├── constants/                # AppColors (legacy), Variables (env config)
│   ├── extensions/               # int/string/date/context extensions
│   ├── theme/                    # NEW (redesign): AppTheme, palette, type, spacing, radius
│   └── router/                   # OPTIONAL future: central route table
├── data/
│   ├── datasources/              # remote + local sources
│   ├── models/
│   │   ├── request/              # XxxRequestModel (toMap → JSON body)
│   │   └── response/             # XxxResponseModel (fromMap ← JSON)
│   └── dataoutputs/              # printer (ESC/POS) and other side effects
└── presentation/<feature>/
    ├── pages/                    # full-page widgets (one Scaffold each)
    ├── widgets/                  # feature-scoped widgets
    ├── models/                   # UI-only data classes (Freezed if non-trivial)
    └── bloc/<topic>/
        ├── <topic>_bloc.dart
        ├── <topic>_event.dart   (part of)
        ├── <topic>_state.dart   (part of)
        └── <topic>_bloc.freezed.dart  (generated)
```

**Existing features**: `auth`, `home`, `order`, `draft_order`, `history`, `setting`.
**New features to add (redesign)**: `cash_session` (buka/tutup kasir), `promo`.

### Rule

- Cross-feature code goes in `core/`. Feature-specific code stays in `presentation/<feature>/`.
- Never import from one `presentation/<featureA>/` into `presentation/<featureB>/` without going through a `core/` shared widget. If two features need the same widget, promote it to `core/components/`.
- A `bloc/` folder may have multiple `<topic>/` subfolders (e.g. `setting/bloc/report/{close_cashier,product_sales,summary}/`).
- Fix the existing typo: `presentation/draft_order/wedgets/` → `widgets/` when you next touch it.

---

## 2. State management — `flutter_bloc` + Freezed unions

### 2.1 Bloc, not Cubit

Use **`Bloc`** with Freezed event/state unions. **No `Cubit`** in this codebase.

### 2.2 File layout per bloc

```dart
// login_bloc.dart
part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource _authRemoteDatasource;
  LoginBloc(this._authRemoteDatasource) : super(const _Initial()) {
    on<_Login>(_onLogin);
  }
  Future<void> _onLogin(_Login event, Emitter<LoginState> emit) async { /* ... */ }
}

// login_event.dart
part of 'login_bloc.dart';
@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.login({required String email, required String password}) = _Login;
}

// login_state.dart
part of 'login_bloc.dart';
@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loading() = _Loading;
  const factory LoginState.success(AuthResponseModel data) = _Success;
  const factory LoginState.error(String message) = _Error;
}
```

### 2.3 State design

- **No positional tuples in success states.** The legacy `OrderState.success(...)` with 8 positional args is brittle — wrap them in a small Freezed data class.
  ```dart
  // Good
  const factory OrderState.success(OrderSummary summary) = _Success;
  @freezed
  class OrderSummary with _$OrderSummary {
    const factory OrderSummary({
      required List<OrderItem> items,
      required int totalQty,
      required int totalPrice,
      required String paymentMethod,
      required int nominal,
      required int kasirId,
      required String kasirName,
      String? customerName,
    }) = _OrderSummary;
  }
  ```
- Use `.maybeWhen(...)` / `.maybeMap(...)` in widgets, with `orElse: () => ...`.
- Always handle 4 states minimum: `initial`, `loading`, `success`, `error`.

### 2.4 Provider scope

- **Default**: register the bloc once in `main.dart`'s `MultiBlocProvider`. This is the project convention because most blocs hold persistent app state (cart, history, products).
- **Exception**: a bloc that owns transient screen state (e.g. a form bloc for `AddProductPage`) should be scoped via a route-local `BlocProvider` inside that page's `build()`.

### 2.5 Side effects

- For navigation / dialogs / snackbars in response to a state change, use `BlocListener` (not inline `addListener`). Keep `BlocBuilder` pure (return widgets only).

---

## 3. Data layer

### 3.1 Datasources, not repositories

Today the project has no repositories — UI blocs talk to datasources directly. **Keep this convention for the redesign**, but stop calling datasources from widgets — go through the bloc.

```
data/datasources/
  auth_local_datasource.dart       (SharedPreferences wrapper)
  auth_remote_datasource.dart      (HTTP)
  product_local_datasource.dart    (sqflite — SINGLETON, holds DB schema)
  product_remote_datasource.dart   (HTTP, multipart for images)
  order_remote_datasource.dart     (HTTP)
  midtrans_remote_datasource.dart  (HTTP to api.midtrans.com)
  report_remote_datasource.dart    (HTTP)
```

### 3.2 Method signatures

- Remote: `Future<Either<String, T>>` from `dartz`. Left = error message (raw response body or message); Right = parsed model.
- Local: returns the model directly (`Future<List<Product>>`, `Future<void>`, etc.) and throws on DB error.
- Auth header is **always** read at the call site: `await AuthLocalDatasource().getAuthData()` → `Bearer ${token}`. (A future cleanup is to centralize this, but don't do it as part of the redesign.)

### 3.3 Models

Two model conventions coexist:

| Layer | Style | Why |
|---|---|---|
| `data/models/request/` and `data/models/response/` (DTOs) | **Handwritten** `factory fromMap(Map<String, dynamic>)`, `Map<String, dynamic> toMap()`, plus `fromJson(String)` / `toJson()` convenience | Already used everywhere; rewriting them adds noise without value. |
| New UI value models (under `presentation/<feature>/models/`) | **Freezed** with `@freezed` + `with _$X` | Type-safe `copyWith`, `==`, `hashCode`, and union support. |
| Bloc events & states | **Freezed** | Project standard. |

**Rule for the redesign**: if you need to add fields to an existing response model, keep it handwritten (don't introduce a parallel Freezed version). If you create a brand-new model used only in UI/bloc, prefer Freezed.

### 3.4 SQLite (`pos13.db`)

- All schema lives in `product_local_datasource.dart` (`_createDB`). Today there are 6 tables: `products`, `categories`, `orders`, `order_items`, `draft_orders`, `draft_order_items`.
- **DB version is `1` with no `onUpgrade` handler.** Adding tables/columns requires bumping the version and writing migration logic, OR deleting the file (acceptable in dev, NOT in prod).
- **Redesign new tables** (see `redesign-plan.md`):
  - `cash_sessions` — opening float, closing reconciliation, shift label, opened_at, closed_at, opened_by_user_id, status.
  - `promos` — id, name, type (`percent`|`rupiah`|`b1g1`), value, code, applies_to (JSON), starts_at, ends_at, active.
  - Add column `orders.cash_session_id` and `orders.promo_id` / `orders.discount_amount`.
- Migration path: write `_onUpgrade(db, oldV, newV)` with `switch (oldV)` cascading `ALTER TABLE` / `CREATE TABLE` blocks. Wrap risky changes in a try/catch that falls back to drop-and-recreate in debug only.
- Singleton access only: `ProductLocalDatasource.instance` (never `new ProductLocalDatasource()`).

### 3.5 Offline-first sync

- New orders are written locally with `is_sync = 0`, then uploaded via `SyncOrderBloc` when online.
- Use the same pattern for new entities (`cash_sessions.is_sync`, etc.) if backend supports remote storage. If a feature is local-only (e.g. printer config), no `is_sync` column.

### 3.6 HTTP

- Plain `package:http`. No Dio.
- For the redesign do **not** introduce Dio just for interceptors — instead create a small `core/http/api_client.dart` helper that:
  - Reads base URL from `--dart-define=BASE_URL=...` (with fallback to `Variables.baseUrl` for dev).
  - Attaches `Authorization: Bearer <token>` automatically.
  - Normalizes errors to `Left<String, T>`.
- Wire datasources to use this helper *incrementally*; don't rewrite everything at once.

### 3.7 Environment / config

- **Today**: `lib/core/constants/variables.dart` hardcodes `baseUrl = 'http://192.168.18.192:8000'`.
- **Redesign rule**: replace with `String.fromEnvironment('BASE_URL', defaultValue: 'http://192.168.18.192:8000')`. Build with `flutter run --dart-define=BASE_URL=https://staging.example.com`.
- Document the dev/staging/prod URLs in `README.md`.

---

## 3.5 Data flow & sync

The app is **offline-first for orders**, **online-required for shifts**, and **periodically-cached for reference data**. Every feature must follow the table below — never invent a fourth pattern.

### 3.5.1 Source of truth per domain

| Domain | Source of truth | Local cache | Sync pattern | Offline allowed? |
|---|---|---|---|---|
| **Products** | Backend (`/api/products`) | `products` table | Pull-replace on `SyncBloc.pullProducts` | ✅ Read offline after first pull |
| **Categories** | Backend (`/api/list-categories`) | `categories` table | Pull-replace on `SyncBloc.pullCategories` | ✅ Read offline after first pull |
| **Promos** (Phase 9) | Backend (`/api/promos`) | `promos` table | Pull-replace on `SyncBloc.pullPromos` | ✅ Read offline after first pull |
| **Orders** | Local first | `orders` table with `is_sync` column | Push-on-success via `SyncBloc.pushOrders` | ✅ Saved locally with `is_sync = 0`, uploaded when online |
| **Cash sessions** | **Backend** | `cash_sessions` table (mirror cache only) | Remote-first via `CashSessionBloc` | ❌ Open/close requires network |
| **Reports** | Backend only | None | On-demand fetch in `ReportPage` | ❌ Fetched live each open |
| **Auth token** | Backend (login) | `SharedPreferences['auth_data']` | One-shot at login | N/A |
| **Server key QRIS** | Local only (user input) | `SharedPreferences['server_key']` | None — never uploaded | ✅ |
| **Printer MAC** | Local only (user pairing) | `SharedPreferences['printer']` | None | ✅ |

### 3.5.2 Where to read/write

**Reading reference data** (Products, Categories, Promos): always read from `ProductLocalDatasource.getAllProduct()` / `.getAllCategories()` — **never** call the remote datasource directly from a feature bloc. Stale data > network error.

**Writing orders**: every cart checkout writes via `ProductLocalDatasource.saveOrder(order)` with `is_sync = 0`. The order is only `POST`ed to `/api/orders` later, via `SyncBloc.pushOrders` (manual or auto-trigger). **Never** call `OrderRemoteDatasource.sendOrder()` synchronously from a checkout flow — payment success is decoupled from upload success.

**Cash sessions**: always go through `CashSessionBloc`. The bloc owns the remote datasource and mirrors successful responses to the local `cash_sessions` table (for offline read of current shift info). New features must NOT call the local datasource directly for shift state — read it via `context.read<CashSessionBloc>().state`.

### 3.5.3 Sync triggers (when sync runs)

| Trigger | What | Where |
|---|---|---|
| **Bootstrap after auth** | `SyncBloc.bootstrap()` — pulls products + categories + best-effort pushes pending orders | `SplashPage._start()` |
| **Manual all** | `SyncBloc.syncAll()` | "Sinkronkan semua" CTA on Sinkronisasi Data settings page |
| **Manual per-domain** | `SyncBloc.pullProducts()` / `.pullCategories()` / `.pushOrders()` | Per-row "Sync" button on Sinkronisasi Data page |
| **Snapshot refresh** | `SyncBloc.refreshSnapshot()` — recompute counts from local DB only | After saving a new local order |
| **Pre-close shift** *(Phase 5)* | `SyncBloc.pushOrders()` then block close if `pendingOrderCount > 0` | `TutupKasirPage` before POST `/cash-sessions/{id}/close` |
| **Auto on connectivity regain** *(Phase 8, deferred)* | `SyncBloc.pushOrders()` | App-level listener on `Connectivity().onConnectivityChanged` |

### 3.5.4 SyncSnapshot — the one state UI reads

`SyncBloc` exposes a single `SyncSnapshot` (Freezed) carrying:
- per-domain counts (`productCount`, `categoryCount`, `pendingOrderCount`)
- per-domain `lastSyncXxxAt` (DateTime?)
- `inProgress: String?` — the domain currently being synced (`'products'`/`'categories'`/`'orders'`), or null
- `errors: Map<String, String>` — last failure per domain (empty = clean)

The Sinkronisasi Data settings page renders directly from this snapshot. The bottom nav badge ("Setting" pending count) reads `pendingOrderCount`.

### 3.5.5 What sync NEVER does

- It never wipes local orders. Failed pushes stay `is_sync = 0` for next retry.
- It never blocks the UI. Bootstrap failure → splash still routes to BukaKasir/Dashboard using cached data.
- It never auto-overwrites server data. Pull is server→local only.
- It never silently drops errors. Every failed pull/push lands in `SyncSnapshot.errors` so the Sinkronisasi Data page can surface a banner.

### 3.5.6 Offline-mode rules

- **First-run guard**: if `productCount == 0` after bootstrap, BukaKasir is still navigable (you can open a shift offline) but Home will show the `home-empty.jsx` "Belum pernah sinkron" state with a CTA to retry. Do not crash, do not block.
- **Saving orders offline**: always allowed if there's an open shift. Local DB write succeeds, `SyncBloc.refreshSnapshot()` fires, badge updates.
- **Closing shift**: requires pending = 0 (enforced by `TutupKasirPage`'s pre-close guard). If pending > 0, the page shows a warning banner with a "Kirim sekarang" action and disables the close button until `SyncBloc.pushOrders()` succeeds.

### 3.5.7 Connectivity & auto-sync

`ConnectivityBloc` (in `lib/presentation/connectivity/bloc/connectivity/`) wraps `connectivity_plus`'s `onConnectivityChanged` stream and emits one of four states:

| State | Meaning |
|---|---|
| `unknown()` | Pre-`started` (cold boot). Treat as "assume online" in UI. |
| `online()` | Device has a working interface (wifi/mobile/vpn/ethernet). |
| `offline()` | `none` connectivity. |
| `restored()` | **Transition** state — emitted exactly once when going offline → online. |

The app root in `main.dart` wires a `BlocListener<ConnectivityBloc>` that fires `SyncBloc.pushOrders()` + `SyncBloc.pullPromos()` on every `restored` event. The bloc itself stays pure (no `SyncBloc` coupling) so it's testable in isolation.

UI banners (e.g. "Mode offline — order disimpan lokal") should subscribe to `online()` / `offline()` states, not `restored()` (which is a one-shot signal).

---

## 4. Presentation layer

### 4.1 Page structure

Every page is one class extending `StatefulWidget` or `StatelessWidget` and returning **one `Scaffold`**. Pages live in `presentation/<feature>/pages/` and end with the suffix `Page`.

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
```

### 4.2 Widget granularity

- Anything reused across **2+ features** → `lib/core/components/`.
- Anything reused across **2+ pages within one feature** → `presentation/<feature>/widgets/`.
- One-off subwidget used in one page → keep as `_PrivateWidget` inside the page file (preferred over giant `build` methods).

### 4.3 Navigation

- **Convention**: Navigator 1.0 via the `BuildContextExt` in `lib/core/extensions/build_context_ext.dart`:
  - `context.push(SomePage())` → `Navigator.push`
  - `context.pushReplacement(SomePage())` → `Navigator.pushReplacement`
  - `context.pushAndRemoveUntil(SomePage(), (_) => false)` → reset stack (e.g. after login)
  - `context.pop()` → `Navigator.pop`
- **Tab navigation** lives in `DashboardPage` via an `int _selectedIndex` swapping page bodies; do not introduce nested navigators for the redesign — the existing pattern is fine and matches the design (one bottom nav across Home/Order/Riwayat/Setting).
- **Bottom sheets** use `showModalBottomSheet(context: ..., isScrollControlled: true, useSafeArea: true)`. See `design-system.md` for the standard `AppBottomSheet` shell.
- **Dialogs**: prefer bottom sheets over `AlertDialog` for the redesign (matches new design language). Reserve `AlertDialog` for tiny confirm prompts only.

### 4.4 Theme access

- **Never** read `AppColors.X` directly in a redesigned widget. Always go through `Theme.of(context).extension<AppPalette>()` (see `design-system.md`).
- Old `AppColors` constants will remain in `core/constants/colors.dart` for legacy pages only. Mark them `@Deprecated('Use AppPalette extension')` to discourage new uses.

### 4.5 Currency, dates, numbers

| Need | Use |
|---|---|
| Rupiah display | `myInt.currencyFormatRp` (extension on `int`) → `Rp. 22.000` |
| Rupiah display without symbol | `currencyFormatRpV2` |
| Parse `"Rp. 22.000"` back to int | `String.toIntegerFromText` |
| Date in Bahasa Indonesia | `DateTime.toFormattedTime()` → `'24 Mei 2026, 14:30'` |
| Parse ISO timestamp | `String.toFormattedTime` |

Avoid inlining `DateFormat('yyyy-MM-ddTHH:mm:ss')`; if you must serialize a timestamp, add a helper to `date_time_ext.dart`.

### 4.6 Indonesian copy

- All user-facing strings must be Bahasa Indonesia and must match the new-design copy (see `redesign-plan.md` for per-screen copy tables).
- Do not introduce ARB/`AppLocalizations` as part of the redesign — it would explode scope. Keep strings inline for now; centralize later.

---

## 5. Cross-cutting rules

### 5.1 No print, no debug noise

- Replace bare `print(...)` with `developer.log(message, name: 'FeatureName')` (`import 'dart:developer' as dev;`).
- Wrap dev-only logs behind `kDebugMode` checks if they are noisy.

### 5.2 Error handling

- HTTP/DB errors flow as `Left<String, T>` or thrown exceptions → bloc converts to `XxxState.error(message)` → widget surfaces via `AppSnackbar.error(context, message)` (a new helper in `core/components/feedback.dart` to be added in Phase 2 of the redesign).
- Never swallow a caught exception silently. At minimum `dev.log` it.

### 5.3 Linting

- Bump `flutter_lints` from `^2.0.0` to `^4.0.0` as part of the redesign and fix any newly-flagged warnings.

### 5.4 Comments and dead code

- Default: no comments. Add one short line only when the *why* is non-obvious.
- Delete commented-out blocks (`// final status = ...`) when you touch a file.

### 5.5 Assets

- Add new icons under `assets/icons/<name>.svg`, regenerate via `flutter pub run build_runner build --delete-conflicting-outputs`, and reference via `Assets.icons.X.path`.
- For the redesign, prefer the **existing SVG icon set** + Material Symbols (via `Icons.X_outlined`) over adding bespoke icons. Reserve new SVGs for brand-specific marks (e.g. the coffee-cup `BrandMark` from `login.jsx`).

---

## 6. `main.dart` setup rules

- Always call `WidgetsFlutterBinding.ensureInitialized()` before any async work (e.g. preloading shared_preferences). Currently the file does not — add this in Phase 1.
- Add a **`SplashPage`** as `home:` of `MaterialApp` that does the auth gate (`AuthLocalDatasource().isAuth()`), then `pushReplacement`s to `DashboardPage` or `LoginPage`. Drop the `FutureBuilder` — it currently shows a blank screen.
- Register a `BlocObserver` in dev for tracing (e.g. `Bloc.observer = AppBlocObserver()` in `main()`).

---

## 7. How to add a new feature

Step-by-step recipe (use for `cash_session`, `promo`, and any future feature):

1. **Create the folder**: `lib/presentation/<feature>/{pages,widgets,models,bloc/<topic>}/`.
2. **Define the bloc** (events, states, bloc class) — Freezed unions. Run `build_runner` to generate `.freezed.dart`.
3. **Define the response/request model** under `data/models/`.
4. **Add the datasource method(s)** in `data/datasources/<feature>_remote_datasource.dart` (and `_local_datasource.dart` if storing offline). For SQLite changes, bump `pos13.db` version and write `_onUpgrade`.
5. **Register the bloc** in `main.dart`'s `MultiBlocProvider`. Fire an initial event in `..add(const XxxEvent.started())` if the feature must hydrate on app boot.
6. **Build the page** with `Scaffold` + `AppAppBar` + `BlocConsumer` + bottom sheet helpers from `design-system.md`.
7. **Wire navigation** via `context.push(NewPage())`.
8. **Add copy** in Bahasa Indonesia from the new-design JSX.
9. **Test on a real device** (especially: scanner, printer, QRIS). Type-checking does not catch UI bugs.

---

## 8. Backend reference

Laravel backend lives at `/Users/bahri/development/FIC11Jilid2/laravel-pos-backend-prejilid2`. Check its routes/controllers before adding any HTTP call. If a feature requires a new endpoint, coordinate with the backend (open an issue / PR there first) — do not invent endpoint paths in the Flutter app.

---

## 9. Things to NOT do

- **Do not** introduce a new state-management package (Riverpod, Provider, GetX).
- **Do not** introduce Dio just to get interceptors.
- **Do not** introduce `go_router` unless deep-links or web/desktop become a hard requirement.
- **Do not** introduce code-generated models (`json_serializable`) for the existing handwritten DTOs.
- **Do not** rewrite a working bloc or datasource as part of a UI redesign. Reskin first; refactor only if the existing API blocks the redesign.
- **Do not** call a datasource directly from a widget. Go through the bloc.
- **Do not** use `print(...)` or leave `// TODO` without an owner/date.
- **Do not** add `AlertDialog` for anything richer than a yes/no prompt — use bottom sheets.
