# 06 — Atoms: Layout (AppAppBar, AppBottomNav, AppCard, AppListGroup, AppStickyFooter, AppSectionLabel, Spaces)

## Goal

Atom-atom layout yang membentuk kerangka tiap halaman: app bar, bottom navigation, card, group list, sticky footer, section label, dan spacing helper.

## Prerequisite

- Step 05 selesai.

## Konsep yang diajarkan

- **`PreferredSizeWidget`** — interface yang dibutuhkan `Scaffold.appBar` untuk tahu tinggi widget tanpa render dulu.
- **`SafeArea`** — auto-padding untuk notch / system gesture bar.
- **`Material` + `InkWell` di luar `Container`** — supaya ripple keluar di atas background.
- **`ModalRoute.of(context)?.canPop`** — cek otomatis apakah halaman ini bisa di-pop (untuk auto-show back arrow).
- **`AnimatedContainer`** untuk transisi tab aktif yang smooth.
- **`Border` 1px** untuk visual separator (vs shadow) — design system kita "soft + flat".

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Sudah ada `AppPalette`, `AppTypography`, `AppRadius`, `AppSpacing` di `lib/core/theme/`, dan atom `AppButton`, `AppIconButton` (akan saya buat di file terpisah — sementara pakai tag TODO kalau perlu reference).

Tugas: generate 7 file widget di `lib/core/components/`.

═══════════════════════════════════════════════
FILE 1: lib/core/components/spaces.dart
═══════════════════════════════════════════════
2 StatelessWidget tipis:
- `class SpaceHeight extends StatelessWidget` dengan `final double height` → return `SizedBox(height: height)`.
- `class SpaceWidth extends StatelessWidget` dengan `final double width` → return `SizedBox(width: width)`.

═══════════════════════════════════════════════
FILE 2: lib/core/components/app_section_label.dart
═══════════════════════════════════════════════
`class AppSectionLabel extends StatelessWidget`:
- Field: `final String label`, `final EdgeInsetsGeometry margin = EdgeInsets.only(top: 18, bottom: 8)`.
- Render: Padding(margin) > Text(label.toUpperCase(), style: `AppTypography.labelM.copyWith(color: p.onSurfaceVar, fontSize: 11, letterSpacing: 1.2)`).
- Constructor positional `AppSectionLabel(this.label, {super.key, this.margin = ...})`.

═══════════════════════════════════════════════
FILE 3: lib/core/components/app_card.dart
═══════════════════════════════════════════════
`class AppCard extends StatelessWidget`:
- Field: `child, padding = EdgeInsets.all(14), background?, radius = AppRadius.mdAll, border?, onTap?`.
- Container: `decoration: BoxDecoration(color: background ?? Colors.white, borderRadius: radius, border: border ?? Border.all(color: p.outlineSoft))`.
- Kalau ada `onTap`, wrap dengan `Material(transparent) > InkWell(onTap, borderRadius: radius)`.

═══════════════════════════════════════════════
FILE 4: lib/core/components/app_list_group.dart
═══════════════════════════════════════════════
`class AppListGroup extends StatelessWidget`:
- Field: `children: List<Widget>, padding?, background?, radius = AppRadius.mdAll`.
- Container white dengan border `p.outlineSoft`, radius, `clipBehavior: Clip.antiAlias`.
- Isi: `Column(crossAxisAlignment.stretch)` dengan children, dipisahkan oleh divider `Container(height: 1, color: p.outlineSoft)` antar baris.

═══════════════════════════════════════════════
FILE 5: lib/core/components/app_sticky_footer.dart
═══════════════════════════════════════════════
`class AppStickyFooter extends StatelessWidget`:
- Field: `child, padding = EdgeInsets.symmetric(horizontal:16, vertical:12)`.
- Render: Container(bg: `p.surface`, border-top 1px `p.outlineSoft`) > SafeArea(top:false) > Padding(padding) > child.

═══════════════════════════════════════════════
FILE 6: lib/core/components/app_app_bar.dart
═══════════════════════════════════════════════
`class AppAppBar extends StatelessWidget implements PreferredSizeWidget`:
- Field: `title: String, subtitle?, leading?, trailing: List<Widget> = const [], automaticallyImplyLeading=true`.
- `@override Size get preferredSize => Size.fromHeight(subtitle == null ? 64 : 72)`.
- Build:
  - `final canPop = ModalRoute.of(context)?.canPop ?? false`.
  - Kalau `leading == null && automaticallyImplyLeading && canPop` → buat `AppIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.maybePop(context))`. (Asumsikan AppIconButton akan dibuat di step 08; sementara fallback ke `IconButton(icon: Icon(Icons.arrow_back_rounded), onPressed: ...)` saja kalau belum ada.)
  - Material(`p.surface`) > SafeArea(bottom:false) > SizedBox(height: preferredSize.height) > Padding(h:8) > Row:
    - leading kalau ada, else SizedBox(width:8). Spacer kecil 4.
    - Expanded > Column.start.center:
      - Text title (`AppTypography.titleL.copyWith(color: p.onSurface)`, ellipsis)
      - Kalau subtitle: SizedBox(2), Text subtitle (`AppTypography.bodyS.copyWith(color: p.onSurfaceVar)`, ellipsis).
    - ...trailing.

═══════════════════════════════════════════════
FILE 7: lib/core/components/app_bottom_nav.dart
═══════════════════════════════════════════════
- `class AppBottomNavItem` (model): `icon: IconData, activeIcon?: IconData, label: String, badge: int = 0`.
- `class AppBottomNav extends StatelessWidget`:
  - Field: `activeIndex: int, onTap: ValueChanged<int>, items: List<AppBottomNavItem>`.
  - **Factory `AppBottomNav.standard({key, activeIndex, onTap, cartCount=0, pendingSync=0})`** yang return AppBottomNav dengan 4 item standar:
    1. Home (`Icons.home_outlined` / `Icons.home_rounded`)
    2. Order (`Icons.shopping_cart_outlined` / `Icons.shopping_cart_rounded`, badge=cartCount)
    3. Riwayat (`Icons.receipt_long_outlined` / `Icons.receipt_long_rounded`)
    4. Setting (`Icons.settings_outlined` / `Icons.settings_rounded`, badge=pendingSync)
  - Render: Material(`p.surface`) > Container(border-top 1px `p.outlineSoft`) > SafeArea(top:false) > Padding(h:8, v:10) > Row(Expanded per item) > `_NavCell`.

- `class _NavCell extends StatelessWidget` (private):
  - InkWell(onTap) > Padding(v:4) > Column.min:
    - Stack(clip:none):
      - `AnimatedContainer(duration:150ms)` padding (h:16, v:4), decoration bg `active ? p.primaryContainer : transparent`, radius pill. Isi: Icon(active ? activeIcon ?? icon : icon, 22px, color `active ? p.onPrimaryContainer : p.onSurface`).
      - Kalau `item.badge > 0`: `Positioned(top: -2, right: -2, child: AppCountBadge(count: badge, background: p.error, foreground: white, border: p.surface))`. (AppCountBadge ada di file `app_badge.dart` yang dibuat di step 07. Sementara skip badge kalau belum ada.)
    - SizedBox(4), Text(item.label, `labelM.copyWith(color: active ? p.onSurface : p.onSurfaceVar, fontSize:11, fontWeight: active ? w700 : w500)`).

Pastikan semua file pakai `context.palette` (extension dari `app_palette.dart`).
````

---

## Verifikasi

Ubah `main.dart` placeholder jadi:

```dart
home: Scaffold(
  appBar: const AppAppBar(title: 'Atom Layout', subtitle: 'Demo step 06'),
  body: ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const AppSectionLabel('Section header'),
      const AppCard(child: Text('Sebuah kartu putih dengan border halus.')),
      const SizedBox(height: 16),
      AppListGroup(children: [
        const ListTile(title: Text('Row 1'), trailing: Icon(Icons.chevron_right)),
        const ListTile(title: Text('Row 2 (dipisah divider)')),
        const ListTile(title: Text('Row 3')),
      ]),
    ],
  ),
  bottomNavigationBar: AppBottomNav.standard(
    activeIndex: 0,
    onTap: (i) {},
    cartCount: 3,
    pendingSync: 1,
  ),
),
```

Run → cek: app bar ada title+subtitle, list group 3 baris dengan separator hairline, bottom nav 4 tab dengan badge.

## Talking points

1. **Kenapa AppAppBar bukan `AppBar` bawaan?**
   `AppBar` punya banyak default Material 3 (elevation scrolledUnder, surface tint) yang kontradiksi dengan design "flat". Kita bikin sendiri agar full control.

2. **`PreferredSizeWidget` interface**:
   `Scaffold.appBar` tipe-nya `PreferredSizeWidget`, bukan `Widget`. Karena Scaffold harus tahu tinggi appbar sebelum render body. Implement dengan `Size get preferredSize`.

3. **`automaticallyImplyLeading`**:
   Mirror behavior `AppBar` bawaan — kalau ada route di belakang, auto-show back arrow. `ModalRoute.of(context).canPop` adalah cara cek-nya.

4. **`Border.all(color: ..., width: 1.5)` vs `BoxShadow`**:
   Design "soft + flat" — border 1px untuk pemisahan visual cukup, shadow disisakan hanya untuk floating element (cart bar, modal). Hindari shadow tumpuk-tumpuk supaya visual gak berisik.

5. **`AnimatedContainer` di bottom nav**:
   Tap → AnimatedContainer interpolate background dari transparent ke primaryContainer dalam 150ms. Bandingkan vs Container biasa (instant) — UX terasa lebih "alive".

6. **`SafeArea(top: false)` di footer**:
   Hanya bottom inset yang perlu (untuk gesture bar). `top: true` (default) bisa bikin double padding kalau ditaruh di bawah app bar.

## Commit suggestion

```bash
git add lib/core/components/spaces.dart lib/core/components/app_section_label.dart lib/core/components/app_card.dart lib/core/components/app_list_group.dart lib/core/components/app_sticky_footer.dart lib/core/components/app_app_bar.dart lib/core/components/app_bottom_nav.dart
git commit -m "Step 06: atoms — app bar, bottom nav, card, list group, sticky footer, section label, spaces"
```

---

➡️ Lanjut ke [Step 07 — Atoms: Feedback](./07-atoms-feedback.md)
