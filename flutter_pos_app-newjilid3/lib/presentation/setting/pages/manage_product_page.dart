import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_badge.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_chip.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/components/app_icon_button.dart';
import '../../../core/components/product_img.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/response/category_response_model.dart';
import '../../../data/models/response/product_response_model.dart';
import '../../home/bloc/category/category_bloc.dart';
import '../../home/bloc/product/product_bloc.dart';
import '../widgets/product_detail_sheet.dart';
import 'add_product_page.dart';

class ManageProductPage extends StatefulWidget {
  const ManageProductPage({super.key});

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  int _activeCategoryId = 0;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductEvent.fetchLocal());
    context
        .read<CategoryBloc>()
        .add(const CategoryEvent.getCategoriesLocal());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onCategoryTap(Category? c) {
    setState(() => _activeCategoryId = c?.id ?? 0);
    if (c == null) {
      context.read<ProductBloc>().add(const ProductEvent.fetchLocal());
    } else {
      context.read<ProductBloc>().add(ProductEvent.fetchByCategory(c.name));
    }
  }

  List<Product> _filtered(List<Product> all) {
    if (_query.trim().isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  int _lowStockCount(List<Product> all) =>
      all.where((p) => p.stock > 0 && p.stock <= 6).length;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppAppBar(
        title: 'Kelola Produk',
        subtitle: 'Tambah, edit, hapus menu',
        trailing: [
          AppIconButton(
            icon: Icons.refresh,
            variant: AppIconButtonVariant.surfaceVariant,
            onPressed: () => context
                .read<ProductBloc>()
                .add(const ProductEvent.fetchLocal()),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () =>
                Center(child: CircularProgressIndicator(color: p.primary)),
            error: (msg) => Center(
              child: AppEmptyState.error(
                message: msg,
                onRetry: () => context
                    .read<ProductBloc>()
                    .add(const ProductEvent.fetchLocal()),
              ),
            ),
            success: (all) {
              if (all.isEmpty) {
                return AppEmptyState(
                  visual: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: p.primaryContainer,
                      borderRadius: AppRadius.lgAll,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.inventory_2_outlined,
                        color: p.primary, size: 44),
                  ),
                  title: 'Belum ada produk',
                  body:
                      'Tambah produk untuk mulai jualan. Atau sync dari server kalau sudah ada.',
                  primaryAction: AppButton(
                    label: 'Tambah produk pertama',
                    leadingIcon: Icons.add,
                    fullWidth: false,
                    onPressed: () => context.push(const AddProductPage()),
                  ),
                );
              }
              final low = _lowStockCount(all);
              final shown = _filtered(all);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(
                      '${all.length} produk · $low stok menipis',
                      style: AppTypography.bodyS
                          .copyWith(color: p.onSurfaceVar),
                    ),
                  ),
                  _SearchBar(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  _CategoryChips(
                    activeId: _activeCategoryId,
                    onPick: _onCategoryTap,
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: shown.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _ProductTile(product: shown[i]),
                    ),
                  ),
                ],
              );
            },
            orElse: () =>
                Center(child: CircularProgressIndicator(color: p.primary)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        onPressed: () => context.push(const AddProductPage()),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: p.surfaceVariant,
          borderRadius: AppRadius.mdAll,
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: p.onSurfaceVar),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppTypography.bodyM.copyWith(color: p.onSurface),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Cari produk...',
                  hintStyle:
                      AppTypography.bodyM.copyWith(color: p.onSurfaceVar),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final int activeId;
  final void Function(Category?) onPick;
  const _CategoryChips({required this.activeId, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        height: 36,
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            final cats = state.maybeWhen(
              loadedLocal: (list) => list,
              loaded: (list) => list,
              orElse: () => const <Category>[],
            );
            return ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppChip(
                    label: 'Semua',
                    active: activeId == 0,
                    onTap: () => onPick(null),
                  ),
                ),
                for (final c in cats)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: c.name,
                      active: activeId == c.id,
                      onTap: () => onPick(c),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  const _ProductTile({required this.product});

  int _hueFor(Product p) => ((p.productId ?? p.id ?? 0) * 47) % 360;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final out = product.stock == 0;
    final low = product.stock > 0 && product.stock <= 6;
    return Material(
      color: Colors.white,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: () => showProductDetailSheet(context, product: product),
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: p.outlineSoft),
          ),
          child: Opacity(
            opacity: out ? 0.7 : 1,
            child: Row(
              children: [
                ProductImg(
                  name: product.name,
                  hue: _hueFor(product),
                  imageUrl: product.displayImageUrl,
                  size: 64,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: AppTypography.bodyL.copyWith(
                                color: p.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.isBestSeller)
                            const AppBadge(label: 'BEST'),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.category,
                        style: AppTypography.bodyS
                            .copyWith(color: p.onSurfaceVar, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            product.price.currencyFormatRp.trim(),
                            style: AppTypography.priceM
                                .copyWith(color: p.onSurface, fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          if (out)
                            const AppBadge(
                                label: 'Habis', kind: AppBadgeKind.stockOut)
                          else if (low)
                            AppBadge(
                                label: 'Stok ${product.stock}',
                                kind: AppBadgeKind.stockLow)
                          else
                            Text(
                              'stok ${product.stock}',
                              style: AppTypography.bodyS
                                  .copyWith(color: p.success, fontSize: 11),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: p.onSurfaceVar),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
