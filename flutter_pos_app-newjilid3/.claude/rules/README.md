# Project Rules — Flutter POS App

Rules and plans for **POS Batch 11** (`flutter_pos_app`) — a Flutter mobile POS app with offline-first SQLite, BLoC state management, Midtrans QRIS, and Bluetooth thermal printing.

## Files in this folder

| File | Read when |
|---|---|
| [`architecture.md`](./architecture.md) | Before touching any code. Defines layers, naming, BLoC patterns, data access, navigation, error handling. **Canonical project conventions.** |
| [`design-system.md`](./design-system.md) | Before writing any widget. Defines the design tokens (palette, spacing, radius, typography), the shared widget catalog, and one-shot examples. Sources of truth: `.claude/new-design/theme.jsx`, `.claude/new-design/icons.jsx`. |
| [`redesign-plan.md`](./redesign-plan.md) | When planning or sequencing the redesign work. Phased plan (foundation → atoms → molecules → screens → new features) with per-screen mapping (old file → new file). |

## How to use these rules

1. **Reading order for a new contributor / fresh agent**: README → architecture → design-system → redesign-plan.
2. **When implementing a screen**: open `redesign-plan.md` for the per-screen spec, then `design-system.md` for the widgets to use, then `architecture.md` for the BLoC/data wiring.
3. **When adding a new feature** (e.g. `buka_kasir`, `promo`): start with `architecture.md` §"How to add a new feature".
4. The JSX in `.claude/new-design/` is the **visual specification** — translate, do not literally copy. Flutter widgets must be idiomatic.

## Source-of-truth pointers

- **Design tokens**: `.claude/new-design/theme.jsx` (palettes, spacing, radius, type scale)
- **Icon set**: `.claude/new-design/icons.jsx` (SVG monoline icons — map to existing assets under `assets/icons/*.svg` or Material icons)
- **Screen designs**: `.claude/new-design/screens/*.jsx` (24 screens, all 3 palette options)
- **Reference screenshots**: `.claude/new-design/uploads/*.png`
- **Backend**: `/Users/bahri/development/FIC11Jilid2/laravel-pos-backend-prejilid2`

## Non-negotiables (quick reference)

- **State management**: `flutter_bloc` only. No Provider/Riverpod/GetX.
- **Models**: handwritten `fromMap`/`toMap` for response/request DTOs; **Freezed** for BLoC event/state unions and for new UI/value models.
- **Routing**: today is Navigator 1.0 via `context.push(Widget)`. **Keep this for the redesign** unless explicitly approved to migrate (deep-link or web support would be the trigger).
- **Theme**: Material 3, single light theme. **No hardcoded hex codes in widgets** — only through the new `AppTheme` extension (see `design-system.md`).
- **Folder layout**: layer-first (`core/`, `data/`, `presentation/`), feature-first within `presentation/`.
- **Language of strings**: Bahasa Indonesia in UI. English is allowed in code identifiers/comments only.
- **Currency**: always `int.currencyFormatRp` extension (`lib/core/extensions/int_ext.dart`). Never inline.
- **Naming**: `snake_case` files, `PascalCase` classes, suffixes `Page`, `Bloc`, `Datasource`, `ResponseModel`, `RequestModel`.
