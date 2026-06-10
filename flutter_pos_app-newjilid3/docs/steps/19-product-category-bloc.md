# 19 — ProductBloc + CategoryBloc

## Goal

2 bloc untuk katalog: `ProductBloc` (fetch, search, filter by category, add, update) dan `CategoryBloc` (fetch list dari BE / lokal). **Source of truth = local DB**; remote dipakai untuk sync.

## Prerequisite

- Step 18 selesai.
- `ProductRemoteDatasource`, `ProductLocalDatasource.instance`, model `Product`/`Category` siap.

## Konsep yang diajarkan

- **Internal state caching dalam Bloc** (`List<Product> products`) untuk operasi filter/search yang ringan tanpa hit DB lagi.
- **Multiple states variant** (`loaded` dari remote, `loadedLocal` dari local) — bisa di-merge atau dipertahankan terpisah; kita pertahankan untuk eksplisit.
- **Pure local read** vs auto-fallback ke remote — kita pilih pure local (sync owned by SyncBloc step 40) supaya tidak ada race condition.

---

## Prompt siap kirim ke AI

````
Project Flutter `flutter_pos_app`. `ProductRemoteDatasource`, `ProductLocalDatasource.instance`, model `Product`, `Category` sudah ada. Package `image_picker` sudah di pubspec.

Generate 6 file di `lib/presentation/home/bloc/`.

═══════════════════════════════════════════════
FILE 1-3: product_bloc/event/state
═══════════════════════════════════════════════
**product_bloc.dart**:
```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_pos_app/data/datasources/product_remote_datasource.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/request/product_request_model.dart';
import '../../../../data/models/response/product_response_model.dart';

part 'product_bloc.freezed.dart';
part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDatasource _productRemoteDatasource;
  /// Cache internal hasil fetchLocal terakhir — dipakai untuk filter/search
  /// in-memory supaya tidak hit DB tiap perubahan.
  List<Product> products = [];

  ProductBloc(this._productRemoteDatasource) : super(const _Initial()) {
    on<_Fetch>((event, emit) async {
      emit(const ProductState.loading());
      final response = await _productRemoteDatasource.getProducts();
      response.fold(
        (l) => emit(ProductState.error(l)),
        (r) { products = r.data; emit(ProductState.success(r.data)); },
      );
    });

    on<_FetchLocal>((event, emit) async {
      emit(const ProductState.loading());
      final local = await ProductLocalDatasource.instance.getAllProduct();
      products = local;
      emit(ProductState.success(products));
    });

    on<_FetchByCategory>((event, emit) async {
      emit(const ProductState.loading());
      final filtered = event.category == 'all'
        ? products
        : products.where((e) => e.category == event.category).toList();
      emit(ProductState.success(filtered));
    });

    on<_AddProduct>((event, emit) async {
      emit(const ProductState.loading());
      final req = ProductRequestModel(
        name: event.product.name, price: event.product.price,
        stock: event.product.stock, category: event.product.category,
        categoryId: event.product.categoryId,
        isBestSeller: event.product.isBestSeller ? 1 : 0,
        image: event.image,
      );
      final res = await _productRemoteDatasource.addProduct(req);
      res.fold(
        (l) => emit(ProductState.error(l)),
        (r) { products.add(r.data); emit(ProductState.success(products)); },
      );
    });

    on<_UpdateProduct>((event, emit) async {
      emit(const ProductState.loading());
      final res = await _productRemoteDatasource.updateProduct(
        productId: event.productId, name: event.product.name,
        price: event.product.price, stock: event.product.stock,
        category: event.product.category, categoryId: event.product.categoryId,
        isBestSeller: event.product.isBestSeller, image: event.image,
      );
      await res.fold(
        (msg) async => emit(ProductState.error(msg)),
        (r) async {
          await ProductLocalDatasource.instance.upsertProduct(r.data);
          products = await ProductLocalDatasource.instance.getAllProduct();
          emit(ProductState.success(products));
        },
      );
    });

    on<_SearchProduct>((event, emit) async {
      emit(const ProductState.loading());
      final filtered = products
        .where((e) => e.name.toLowerCase().contains(event.query.toLowerCase()))
        .toList();
      emit(ProductState.success(filtered));
    });

    on<_FetchAllFromState>((event, emit) async {
      emit(const ProductState.loading());
      emit(ProductState.success(products));
    });
  }
}
```

**product_event.dart** (`part of`):
```dart
@freezed
class ProductEvent with _$ProductEvent {
  const factory ProductEvent.started() = _Started;
  const factory ProductEvent.fetch() = _Fetch;
  const factory ProductEvent.fetchByCategory(String category) = _FetchByCategory;
  const factory ProductEvent.fetchLocal() = _FetchLocal;
  const factory ProductEvent.addProduct(Product product, XFile image) = _AddProduct;
  const factory ProductEvent.updateProduct({
    required int productId,
    required Product product,
    XFile? image,
  }) = _UpdateProduct;
  const factory ProductEvent.searchProduct(String query) = _SearchProduct;
  const factory ProductEvent.fetchAllFromState() = _FetchAllFromState;
}
```

**product_state.dart** (`part of`):
```dart
@freezed
class ProductState with _$ProductState {
  const factory ProductState.initial() = _Initial;
  const factory ProductState.loading() = _Loading;
  const factory ProductState.success(List<Product> products) = _Success;
  const factory ProductState.error(String message) = _Error;
}
```

═══════════════════════════════════════════════
FILE 4-6: category_bloc/event/state
═══════════════════════════════════════════════
**category_bloc.dart**:
```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_pos_app/data/datasources/product_remote_datasource.dart';

import '../../../../data/models/response/category_response_model.dart';

part 'category_bloc.freezed.dart';
part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final ProductRemoteDatasource productRemoteDatasource;
  List<Category> categories = [];

  CategoryBloc(this.productRemoteDatasource) : super(const _Initial()) {
    on<_GetCategories>((event, emit) async {
      emit(const _Loading());
      final res = await productRemoteDatasource.getCategories();
      res.fold((l) => emit(_Error(l)), (r) => emit(_Loaded(r.data)));
    });

    on<_GetCategoriesLocal>((event, emit) async {
      emit(const _Loading());
      categories = await ProductLocalDatasource.instance.getAllCategories();
      emit(_LoadedLocal(categories));
    });
  }
}
```

**category_event.dart**:
```dart
@freezed
class CategoryEvent with _$CategoryEvent {
  const factory CategoryEvent.started() = _Started;
  const factory CategoryEvent.getCategories() = _GetCategories;
  const factory CategoryEvent.getCategoriesLocal() = _GetCategoriesLocal;
}
```

**category_state.dart**:
```dart
@freezed
class CategoryState with _$CategoryState {
  const factory CategoryState.initial() = _Initial;
  const factory CategoryState.loading() = _Loading;
  const factory CategoryState.loaded(List<Category> categories) = _Loaded;
  const factory CategoryState.loadedLocal(List<Category> categories) = _LoadedLocal;
  const factory CategoryState.error(String message) = _Error;
}
```

═══════════════════════════════════════════════
STEP 7: Update `main.dart`
═══════════════════════════════════════════════
Uncomment di provider list:
```dart
BlocProvider(create: (_) => ProductBloc(ProductRemoteDatasource())),
BlocProvider(create: (_) => CategoryBloc(ProductRemoteDatasource())),
```

═══════════════════════════════════════════════
STEP 8: Generate
═══════════════════════════════════════════════
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
````

---

## Verifikasi

Belum bisa visual sebelum HomePage di-implement (step 20). Sementara, test via splash → cek tab Setting stub jangan crash karena bloc tersedia.

## Talking points

1. **Kenapa `products` cache di Bloc instance, bukan di state?**
   `products` adalah "source data" untuk operasi filter/search. State adalah "view-projection". Kalau `products` di state, tiap filter butuh copy List → boros memory + bloc state harus copy whole list di setiap emit.

2. **`fetchByCategory` filter di memory**:
   Daripada query SQL `WHERE category = ?`, kita filter list yang sudah di-cache. Lebih cepat untuk datasets <10k items. Untuk >10k, query SQL lebih scalable.

3. **`fetchLocal` pure (tidak fallback ke remote)**:
   Awalnya code ada auto-fallback (kalau local empty → fetch remote). Itu bug-prone: race condition saat `SyncBloc.bootstrap` jalan paralel. Sekarang SyncBloc satu-satunya yang write `products` table.

4. **`_LoadedLocal` vs `_Loaded`**:
   Kenapa dipisah? Untuk debugging: kalau state `loadedLocal`, kita tahu source = SQLite (offline). Kalau `loaded`, source = remote. UI bisa show indicator "🔌 offline mode".

5. **`updateProduct` flow**:
   - PUT ke BE.
   - Sukses → `upsertProduct` ke local DB (supaya edit terlihat tanpa full re-sync).
   - Re-fetch dari local + emit.

6. **Pemodelan event yang named param** (`updateProduct({...})`):
   Beberapa event punya banyak param — pakai named lebih readable: `ProductEvent.updateProduct(productId: 5, product: p, image: null)`.

## Commit suggestion

```bash
git add lib/presentation/home/bloc/product/ lib/presentation/home/bloc/category/ lib/main.dart
git commit -m "Step 19: ProductBloc + CategoryBloc with local-first reads"
```

---

➡️ Lanjut ke [Step 20 — HomePage](./20-home-page.md)
