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
  List<Product> products = [];
  ProductBloc(
    this._productRemoteDatasource,
  ) : super(const _Initial()) {
    on<_Fetch>((event, emit) async {
      emit(const ProductState.loading());
      final response = await _productRemoteDatasource.getProducts();
      response.fold(
        (l) => emit(ProductState.error(l)),
        (r) {
          products = r.data;
          emit(ProductState.success(r.data));
        },
      );
    });

    on<_FetchLocal>((event, emit) async {
      emit(const ProductState.loading());
      // Pure local read. SyncBloc.bootstrap (and the per-domain pulls on
      // the Sinkronisasi page) own remote→local replication. Doing a
      // recovery remote fetch from here introduced a race with bootstrap
      // because both write to the same `products` table concurrently.
      final local = await ProductLocalDatasource.instance.getAllProduct();
      // ignore: avoid_print
      print('[ProductBloc] fetchLocal: ${local.length} rows from local DB');
      products = local;
      emit(ProductState.success(products));
    });

    on<_FetchByCategory>((event, emit) async {
      emit(const ProductState.loading());

      final newProducts = event.category == 'all'
          ? products
          : products
              .where((element) => element.category == event.category)
              .toList();

      emit(ProductState.success(newProducts));
    });

    on<_AddProduct>((event, emit) async {
      emit(const ProductState.loading());
      final requestData = ProductRequestModel(
        name: event.product.name,
        price: event.product.price,
        stock: event.product.stock,
        category: event.product.category,
        categoryId: event.product.categoryId,
        isBestSeller: event.product.isBestSeller ? 1 : 0,
        image: event.image,
      );
      final response = await _productRemoteDatasource.addProduct(requestData);
      // products.add(newProduct);
      response.fold(
        (l) => emit(ProductState.error(l)),
        (r) {
          products.add(r.data);
          emit(ProductState.success(products));
        },
      );

      emit(ProductState.success(products));
    });

    on<_UpdateProduct>((event, emit) async {
      emit(const ProductState.loading());
      final response = await _productRemoteDatasource.updateProduct(
        productId: event.productId,
        name: event.product.name,
        price: event.product.price,
        stock: event.product.stock,
        category: event.product.category,
        categoryId: event.product.categoryId,
        isBestSeller: event.product.isBestSeller,
        image: event.image,
      );
      await response.fold(
        (msg) async => emit(ProductState.error(msg)),
        (r) async {
          // Persist the fresh row locally so the manage list / home grid
          // reflect the edit even without a full re-sync.
          await ProductLocalDatasource.instance.upsertProduct(r.data);
          final fresh = await ProductLocalDatasource.instance.getAllProduct();
          products = fresh;
          emit(ProductState.success(products));
        },
      );
    });

    on<_SearchProduct>((event, emit) async {
      emit(const ProductState.loading());
      final newProducts = products
          .where((element) =>
              element.name.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

      emit(ProductState.success(newProducts));
    });

    on<_FetchAllFromState>((event, emit) async {
      emit(const ProductState.loading());

      emit(ProductState.success(products));
    });
  }
}
