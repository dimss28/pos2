# 41 — Promo Management (Model, Datasource, Bloc, Manage Page, Add/Edit)

## Goal

CRUD promo: `PromoModel` (percent/rupiah/b1g1), datasource remote/local, `PromoBloc` (remote-first untuk write, local-first untuk read), `ManagePromoPage` (list + toggle active), `AddEditPromoPage` (form).

## Prerequisite

- Step 40 selesai. Tabel `promos` SQLite (step 12) ada.

## Konsep yang diajarkan

- **Optimistic toggle dengan rollback** pada error.
- **`computeDiscount(subtotal)`** client-side preview, BE recompute saat order (anti-tamper).
- **`isLive(now)`** time-window check.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. Tabel `promos` siap. Generate 6 file.

═══════════════════════════════════════════════
FILE 1: lib/data/models/response/promo_model.dart
═══════════════════════════════════════════════
```dart
enum PromoType { percent, rupiah, b1g1 }
PromoType _parseType(String? raw) => switch (raw) {
  'rupiah' => PromoType.rupiah,
  'b1g1' => PromoType.b1g1,
  _ => PromoType.percent,
};
String typeKey(PromoType t) => switch (t) {
  PromoType.percent => 'percent',
  PromoType.rupiah => 'rupiah',
  PromoType.b1g1 => 'b1g1',
};

class PromoModel {
  final int? id;
  final String name;
  final PromoType type;
  final int value;  // 0-100 for percent, rupiah for fixed
  final String? code;  // voucher code; null = auto-apply
  final String? appliesToJson;  // {"category":"kopi"} atau {"product_ids":[1,2]}
  final int minSubtotal;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool active;
  final int isSync;

  PromoModel({this.id, required this.name, required this.type, required this.value,
    this.code, this.appliesToJson, this.minSubtotal = 0, this.startsAt, this.endsAt,
    this.active = true, this.isSync = 0});

  bool get hasCode => (code ?? '').isNotEmpty;

  bool isLive([DateTime? now]) {
    final n = now ?? DateTime.now();
    if (!active) return false;
    if (startsAt != null && n.isBefore(startsAt!)) return false;
    if (endsAt != null && n.isAfter(endsAt!)) return false;
    return true;
  }

  /// Client-side preview. BE recompute on order create.
  int computeDiscount(int subtotal) {
    if (!isLive()) return 0;
    if (subtotal < minSubtotal) return 0;
    switch (type) {
      case PromoType.percent: return (subtotal * value ~/ 100);
      case PromoType.rupiah: return value > subtotal ? subtotal : value;
      case PromoType.b1g1: return 0; // computed per-line by UI
    }
  }

  factory PromoModel.fromMap(Map<String, dynamic> map) => PromoModel(
    id: (map['id'] as num?)?.toInt(),
    name: map['name'] as String,
    type: _parseType(map['type'] as String?),
    value: (map['value'] as num?)?.toInt() ?? 0,
    code: map['code'] as String?,
    appliesToJson: map['applies_to'] is String
      ? map['applies_to'] as String
      : map['applies_to'] == null ? null : json.encode(map['applies_to']),
    minSubtotal: (map['min_subtotal'] as num?)?.toInt() ?? 0,
    startsAt: _parseDt(map['starts_at']), endsAt: _parseDt(map['ends_at']),
    active: _parseBool(map['active']),
    isSync: (map['is_sync'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name, 'type': typeKey(type), 'value': value,
    'code': code, 'applies_to': appliesToJson, 'min_subtotal': minSubtotal,
    'starts_at': startsAt?.toIso8601String(), 'ends_at': endsAt?.toIso8601String(),
    'active': active ? 1 : 0, 'is_sync': isSync,
  };

  PromoModel copyWith({...}) => /* all optional */;
}
```

═══════════════════════════════════════════════
FILE 2: lib/data/datasources/promo_remote_datasource.dart
═══════════════════════════════════════════════
Methods (semua return `Future<Either<String, T>>`):
- `Future<Either<String, List<PromoModel>>> list()` — GET /api/promos.
- `Future<Either<String, PromoModel>> create(PromoModel p)` — POST /api/promos.
- `Future<Either<String, PromoModel>> update(PromoModel p)` — PUT /api/promos/{id}.
- `Future<Either<String, PromoModel>> toggle(int id)` — PATCH /api/promos/{id}/toggle.
- `Future<Either<String, void>> delete(int id)` — DELETE /api/promos/{id}.

Semua pakai Bearer token dari AuthLocalDatasource.

═══════════════════════════════════════════════
FILE 3: lib/data/datasources/promo_local_datasource.dart
═══════════════════════════════════════════════
Singleton (share DB dengan ProductLocalDatasource). Methods:
- `getAll() → List<PromoModel>`.
- `replaceAll(List<PromoModel>)`: delete all + insert all.
- `upsert(PromoModel)`: INSERT OR REPLACE by id.
- `delete(int id)`.

═══════════════════════════════════════════════
FILE 4-6: PromoBloc + event + state
═══════════════════════════════════════════════
**promo_event.dart**:
```dart
@freezed
class PromoEvent with _$PromoEvent {
  const factory PromoEvent.loadFromCache() = _LoadFromCache;
  const factory PromoEvent.refreshFromRemote() = _RefreshFromRemote;
  const factory PromoEvent.toggle(int id) = _Toggle;
  const factory PromoEvent.save(PromoModel promo) = _Save;
  const factory PromoEvent.delete(int id) = _Delete;
}
```

**promo_state.dart**:
```dart
@freezed
class PromoState with _$PromoState {
  const factory PromoState.initial() = _Initial;
  const factory PromoState.loading() = _Loading;
  const factory PromoState.success(List<PromoModel> promos) = _Success;
  const factory PromoState.error(String message) = _Error;
}
```

**promo_bloc.dart**: handler:
- `_onLoadFromCache`: emit loading → `_local.getAll()` → success.
- `_onRefreshFromRemote`: emit loading → `_remote.list()` → fold → kalau OK: `_local.replaceAll(remote); emit(success(remote))`.
- `_onToggle(id)`: optimistic flip local list → `_remote.toggle(id)` → kalau gagal: rollback + emit error + restore. Kalau OK: `_local.upsert(saved)` + sync local list.
- `_onSave(promo)`: kalau id null → create; else update. Fold → upsert local + merge ke list.
- `_onDelete(id)`: optimistic remove → remote delete → kalau OK `_local.delete(id)`. Kalau gagal: rollback.

═══════════════════════════════════════════════
FILE 7: lib/presentation/promo/pages/manage_promo_page.dart
═══════════════════════════════════════════════
StatefulWidget. initState: `PromoBloc.add(loadFromCache)`; lalu `refreshFromRemote()`.

Build:
- Scaffold AppAppBar('Kelola Promo', trailing: [refresh icon]).
- FAB extended('Promo Baru', onPressed: push AddEditPromoPage).
- body BlocBuilder<PromoBloc>:
  - success(list):
    - Section 'Aktif sekarang' (filter isLive): For each → AppCard:
      - Row: Icon local_offer_outlined bg primaryContainer 40, Column [name titleS, '{discount label} · {ends_at format}' bodyS], Spacer, Switch toggle active.
      - Long-press → AppActionSheet (Edit / Hapus).
    - Section 'Dijadwalkan / Nonaktif' (rest): same.
  - empty: AppEmptyState 'Belum ada promo'.

═══════════════════════════════════════════════
FILE 8: lib/presentation/promo/pages/add_edit_promo_page.dart
═══════════════════════════════════════════════
StatefulWidget(promo?: PromoModel). State: name, type (enum), value, code, appliesTo, startsAt, endsAt, minSubtotal, active.

Form:
- AppTextField 'Nama' (controller).
- AppSegmentedToggle<PromoType>([percent, rupiah, b1g1]).
- Kalau percent → AppTextField numeric 'Persen (1-100)'.
- Kalau rupiah → AppMoneyTextField 'Nominal'.
- AppTextField 'Kode voucher (opsional)'.
- AppMoneyTextField 'Minimum subtotal (opsional)'.
- 2 date picker: 'Mulai' & 'Berakhir' — pakai `showDatePicker` + `showTimePicker` combine.
- AppSwitchTile 'Aktif'.
- AppButton 'Simpan' → PromoBloc.save.

═══════════════════════════════════════════════
FILE 9: lib/presentation/promo/models/applied_discount.dart
═══════════════════════════════════════════════
```dart
@freezed
abstract class AppliedDiscount with _$AppliedDiscount {
  const AppliedDiscount._();
  const factory AppliedDiscount({
    required int amount,
    PromoModel? promo,
    @Default(AppliedDiscountSource.manual) AppliedDiscountSource source,
    String? note,
  }) = _AppliedDiscount;

  int totalAfterDiscount(int subtotal) => subtotal - amount < 0 ? 0 : subtotal - amount;

  String displayLabel() {
    if (source == AppliedDiscountSource.manual) {
      return note?.isNotEmpty == true ? 'Diskon · $note' : 'Diskon manual';
    }
    final p = promo;
    if (p == null) return 'Diskon';
    final code = p.code?.isNotEmpty == true ? ' · ${p.code}' : '';
    return 'Diskon · ${p.name}$code';
  }
}

enum AppliedDiscountSource { voucher, auto, manual }
```

═══════════════════════════════════════════════
WIRING
═══════════════════════════════════════════════
- main.dart: uncomment `BlocProvider(create: (_) => PromoBloc()..add(loadFromCache()))`.
- SettingPage tile 'Kelola Promo' → push ManagePromoPage.
- SyncBloc.pullPromos: implement (analog dengan pullProducts).
````

---

## Verifikasi

1. Setting → Kelola Promo. Empty.
2. FAB → AddEditPromo → fill (e.g. "MEMBER10", percent 10) → Save → muncul di list.
3. Toggle active → off → on. Cek isLive.
4. Sync data → pullPromos → kalau ada di BE, merge.

## Talking points

1. **Optimistic toggle**:
   Switch flick instant. Kalau BE gagal, rollback. UX feel responsive, safety net via rollback.

2. **`computeDiscount` di client vs BE**:
   Client preview untuk UX live update. BE = source of truth saat persist order (anti-tampering).

3. **`appliesToJson` JSON-encoded string**:
   Schema flexible: `{"category":"kopi"}` atau `{"product_ids":[1,2,3]}`. Trade-off: gak typed, butuh parse di UI.

4. **`b1g1` returns 0 di computeDiscount**:
   Buy-one-get-one perlu per-line logic (kita gak punya cara generic compute di model). UI yang handle.

5. **Time-window**: 
   `startsAt` null = no lower bound. `endsAt` null = no upper. Cocok untuk promo evergreen vs limited-time.

## Commit suggestion

```bash
git add lib/data/models/response/promo_model.dart lib/data/datasources/promo_remote_datasource.dart lib/data/datasources/promo_local_datasource.dart lib/presentation/promo/ lib/presentation/setting/pages/setting_page.dart lib/main.dart
git commit -m "Step 41: Promo CRUD (model, datasource, bloc, manage page, add/edit)"
```

---

➡️ Lanjut ke [Step 42 — DiscountSheet (Apply di Order)](./42-discount-sheet.md)
