import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/components/app_badge.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_chip.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/components/app_icon_button.dart';
import '../../../core/components/app_stepper.dart';
import '../../../core/components/feedback.dart';
import '../../../core/components/product_img.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/store_branding.dart';
import '../../../data/models/response/category_response_model.dart';
import '../../../data/models/response/product_response_model.dart';
import '../../order/pages/order_page.dart';
import '../../setting/bloc/sync/sync_bloc.dart';
import '../../setting/pages/sync_data_page.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../bloc/product/product_bloc.dart';
import '../models/checkout_summary.dart';
import 'scanner_page.dart';

enum _ViewMode { grid, list }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();
  int _activeCategoryId = 0; // 0 = "Semua"
  _ViewMode _view = _ViewMode.grid;
  String _storeTitle = StoreBranding.name;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductEvent.fetchLocal());
    context
        .read<CategoryBloc>()
        .add(const CategoryEvent.getCategoriesLocal());
    AuthLocalDatasource().getReceiptBranding().then((b) {
      if (b.storeName.isNotEmpty && mounted) {
        setState(() => _storeTitle = b.storeName);
      }
    });
    // Auto-reconnect to last paired printer in background.
    AuthLocalDatasource().getPrinter().then((mac) async {
      if (mac.isNotEmpty) {
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    if (value.length >= 3) {
      context.read<ProductBloc>().add(ProductEvent.searchProduct(value));
    } else if (value.isEmpty) {
      context
          .read<ProductBloc>()
          .add(const ProductEvent.fetchAllFromState());
    }
  }

  void _onCategoryTap(Category? c) {
    setState(() => _activeCategoryId = c?.id ?? 0);
    if (c == null) {
      context.read<ProductBloc>().add(const ProductEvent.fetchLocal());
    } else {
      context.read<ProductBloc>().add(ProductEvent.fetchByCategory(c.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final today = _today();

    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, cartState) {
            final cart = cartState.maybeWhen(
              success: (s) => s,
              orElse: () => const CheckoutSummary(),
            );
            return Stack(
              children: [
                Column(
                  children: [
                    _Header(
                      storeTitle: _storeTitle,
                      today: today,
                      cartCount: cart.totalQuantity,
                    ),
                    _SearchAndScan(controller: _searchCtrl, onChanged: _onSearch),
                    _CategoryChipsRow(
                      activeId: _activeCategoryId,
                      onPick: _onCategoryTap,
                      view: _view,
                      onViewChanged: (v) => setState(() => _view = v),
                    ),
                    Expanded(child: _ProductsBody(view: _view, cart: cart)),
                  ],
                ),
                if (cart.totalQuantity > 0)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _FloatingCartBar(cart: cart),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _today() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

// ─── header ──────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String storeTitle;
  final String today;
  final int cartCount;
  const _Header({
    required this.storeTitle,
    required this.today,
    required this.cartCount,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                storeTitle,
                maxLines: 1,
                style: AppTypography.titleL.copyWith(color: p.onSurface),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            cartCount > 0 ? '$cartCount di keranjang' : today,
            style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
          ),
        ],
      ),
    );
  }
}

// ─── search bar with scan button ─────────────────────────────────────────
class _SearchAndScan extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchAndScan({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 48,
        padding: const EdgeInsets.fromLTRB(14, 0, 6, 0),
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
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: 'Cari produk atau scan...',
                  hintStyle: AppTypography.bodyM
                      .copyWith(color: p.onSurfaceVar, fontSize: 13),
                ),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScannerPage()),
              ),
              borderRadius: AppRadius.smAll,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.primary,
                  borderRadius: AppRadius.smAll,
                ),
                child: Icon(Icons.qr_code_2, size: 18, color: p.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── category chips + view toggle ────────────────────────────────────────
class _CategoryChipsRow extends StatelessWidget {
  final int activeId;
  final void Function(Category?) onPick;
  final _ViewMode view;
  final ValueChanged<_ViewMode> onViewChanged;

  const _CategoryChipsRow({
    required this.activeId,
    required this.onPick,
    required this.view,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  final categories = state.maybeWhen(
                    loaded: (list) => list,
                    loadedLocal: (list) => list,
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
                      for (final c in categories)
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
          ),
          const SizedBox(width: 10),
          _ViewToggleWidget(view: view, onChanged: onViewChanged),
        ],
      ),
    );
  }
}

class _ViewToggleWidget extends StatelessWidget {
  final _ViewMode view;
  final ValueChanged<_ViewMode> onChanged;
  const _ViewToggleWidget({required this.view, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget cell(_ViewMode mode, IconData icon) {
      final active = view == mode;
      return InkWell(
        onTap: () => onChanged(mode),
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: p.onSurface.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: active ? p.onSurface : p.onSurfaceVar,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.surfaceVariant,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        children: [
          cell(_ViewMode.grid, Icons.grid_view_rounded),
          cell(_ViewMode.list, Icons.view_list_rounded),
        ],
      ),
    );
  }
}

// ─── products grid/list ──────────────────────────────────────────────────
class _ProductsBody extends StatelessWidget {
  final _ViewMode view;
  final CheckoutSummary cart;

  const _ProductsBody({required this.view, required this.cart});

  int _qtyOf(Product product) {
    for (final item in cart.products) {
      if (item.product == product) return item.quantity;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => _LoadingArea(),
          loading: () => _LoadingArea(),
          error: (message) => Center(
            child: AppEmptyState.error(
              message: message,
              onRetry: () => context
                  .read<ProductBloc>()
                  .add(const ProductEvent.fetchLocal()),
            ),
          ),
          success: (products) {
            if (products.isEmpty) return const _HomeEmpty();
            final pad = cart.totalQuantity > 0 ? 180.0 : 100.0;
            if (view == _ViewMode.grid) {
              return GridView.builder(
                padding: EdgeInsets.fromLTRB(16, 12, 16, pad),
                itemCount: products.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (_, i) => _ProductGridCard(
                  product: products[i],
                  qty: _qtyOf(products[i]),
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16, 12, 16, pad),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ProductListRow(
                product: products[i],
                qty: _qtyOf(products[i]),
              ),
            );
          },
        );
      },
    );
  }
}

class _LoadingArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: CircularProgressIndicator(color: context.palette.primary));
}

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty();

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      visual: _EmptyVisual(),
      title: 'Belum ada produk',
      body:
          'Sinkronkan menu dari server untuk mulai jualan, atau tambahkan produk manual lewat Setting.',
      primaryAction: AppButton(
        label: 'Sinkronkan sekarang',
        leadingIcon: Icons.sync,
        fullWidth: false,
        onPressed: () {
          context.read<SyncBloc>().add(const SyncEvent.syncAll());
          AppSnackbar.info(context, 'Mengambil data dari server...');
          context.push(const SyncDataPage());
        },
      ),
    );
  }
}

class _EmptyVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: p.primaryContainer,
        borderRadius: AppRadius.mdAll,
      ),
      child: Icon(Icons.coffee_outlined, color: p.primary, size: 40),
    );
  }
}

// ─── grid card ───────────────────────────────────────────────────────────
class _ProductGridCard extends StatelessWidget {
  final Product product;
  final int qty;
  const _ProductGridCard({required this.product, required this.qty});

  int _hueFor(Product p) => ((p.productId ?? p.id ?? 0) * 47) % 360;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final inCart = qty > 0;
    final stock = product.stock;
    final outOfStock = stock <= 0;
    final atCap = !outOfStock && qty >= stock;
    final lowStock = !outOfStock && stock < 5;
    final disabled = outOfStock || atCap;

    return Opacity(
      opacity: outOfStock ? 0.55 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: disabled
              ? null
              : () => context
                  .read<CheckoutBloc>()
                  .add(CheckoutEvent.addCheckout(product)),
          borderRadius: AppRadius.mdAll,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color:
                    inCart ? p.primary.withValues(alpha: 0.55) : p.outlineSoft,
                width: inCart ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ProductImg(
                        name: product.name,
                        hue: _hueFor(product),
                        imageUrl: product.displayImageUrl,
                        size: double.infinity,
                      ),
                    ),
                    if (inCart)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: AppCountBadge(
                          count: qty,
                          border: p.surface,
                        ),
                      ),
                    if (outOfStock)
                      Positioned(
                        left: 4,
                        top: 4,
                        child: _StockBadge.outOfStock(p),
                      )
                    else if (lowStock)
                      Positioned(
                        left: 4,
                        top: 4,
                        child: _StockBadge.low(p, stock),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: AppTypography.bodyM.copyWith(
                    color: p.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.category,
                  style: AppTypography.bodyS.copyWith(
                    color: p.onSurfaceVar,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.price.currencyFormatRp.trim(),
                        style: AppTypography.priceM.copyWith(
                          color: p.onSurface,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    inCart
                        ? AppStepper(
                            qty: qty,
                            max: stock,
                            size: AppStepperSize.sm,
                            onChanged: (v) {
                              if (v > qty) {
                                context.read<CheckoutBloc>().add(
                                    CheckoutEvent.addCheckout(product));
                              } else {
                                context.read<CheckoutBloc>().add(
                                    CheckoutEvent.removeCheckout(product));
                              }
                            },
                          )
                        : Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: disabled
                                  ? p.surfaceDim
                                  : p.primary,
                              borderRadius: AppRadius.smAll,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 18,
                              color: disabled ? p.onSurfaceVar : p.onPrimary,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact pill placed on the product image to flag stock state.
class _StockBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _StockBadge._(this.label, this.bg, this.fg);

  factory _StockBadge.outOfStock(AppPalette p) =>
      _StockBadge._('HABIS', p.errorContainer, p.error);

  factory _StockBadge.low(AppPalette p, int stock) =>
      _StockBadge._('Sisa $stock', p.warningContainer, p.warning);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.labelM.copyWith(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─── list row ────────────────────────────────────────────────────────────
class _ProductListRow extends StatelessWidget {
  final Product product;
  final int qty;
  const _ProductListRow({required this.product, required this.qty});

  int _hueFor(Product p) => ((p.productId ?? p.id ?? 0) * 47) % 360;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final inCart = qty > 0;
    final stock = product.stock;
    final outOfStock = stock <= 0;
    final atCap = !outOfStock && qty >= stock;
    final lowStock = !outOfStock && stock < 5;
    final disabled = outOfStock || atCap;

    return Opacity(
      opacity: outOfStock ? 0.55 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: disabled
              ? null
              : () => context
                  .read<CheckoutBloc>()
                  .add(CheckoutEvent.addCheckout(product)),
          borderRadius: AppRadius.mdAll,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: inCart
                    ? p.primary.withValues(alpha: 0.55)
                    : p.outlineSoft,
                width: inCart ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ProductImg(
                      name: product.name,
                      hue: _hueFor(product),
                      imageUrl: product.displayImageUrl,
                      size: 64,
                    ),
                    if (inCart)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: AppCountBadge(count: qty, border: p.surface),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              product.name,
                              style: AppTypography.bodyL.copyWith(
                                color: p.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (outOfStock) ...[
                            const SizedBox(width: 6),
                            _StockBadge.outOfStock(p),
                          ] else if (lowStock) ...[
                            const SizedBox(width: 6),
                            _StockBadge.low(p, stock),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.category,
                        style: AppTypography.bodyS.copyWith(
                          color: p.onSurfaceVar,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.price.currencyFormatRp.trim(),
                        style: AppTypography.priceM
                            .copyWith(color: p.onSurface, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                inCart
                    ? AppStepper(
                        qty: qty,
                        max: stock,
                        onChanged: (v) {
                          if (v > qty) {
                            context.read<CheckoutBloc>().add(
                                CheckoutEvent.addCheckout(product));
                          } else {
                            context.read<CheckoutBloc>().add(
                                CheckoutEvent.removeCheckout(product));
                          }
                        },
                      )
                    : AppIconButton(
                        icon: Icons.add,
                        onPressed: disabled
                            ? null
                            : () => context
                                .read<CheckoutBloc>()
                                .add(CheckoutEvent.addCheckout(product)),
                        variant: AppIconButtonVariant.surfaceVariant,
                        size: 40,
                        iconSize: 20,
                        iconColor: disabled ? p.onSurfaceVar : p.primary,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── floating cart bar ──────────────────────────────────────────────────
class _FloatingCartBar extends StatelessWidget {
  final CheckoutSummary cart;
  const _FloatingCartBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.primary,
      borderRadius: AppRadius.lgAll,
      elevation: 0,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrderPage()),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
          decoration: BoxDecoration(
            color: p.primary,
            borderRadius: AppRadius.lgAll,
            boxShadow: [
              BoxShadow(
                color: p.primary.withValues(alpha: 0.33),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: p.onPrimary.withValues(alpha: 0.18),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Icon(Icons.shopping_cart_outlined,
                        color: p.onPrimary, size: 18),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: AppCountBadge(
                      count: cart.totalQuantity,
                      background: p.onSurface,
                      foreground: p.surface,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${cart.totalQuantity} item dipilih',
                      style: AppTypography.bodyS.copyWith(
                        color: p.onPrimary.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      cart.totalPrice.currencyFormatRp.trim(),
                      style: AppTypography.titleM.copyWith(
                        color: p.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                padding: const EdgeInsets.fromLTRB(14, 0, 10, 0),
                decoration: BoxDecoration(
                  color: p.onPrimary,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Row(
                  children: [
                    Text(
                      'Bayar',
                      style: AppTypography.labelL.copyWith(
                        color: p.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 16, color: p.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

