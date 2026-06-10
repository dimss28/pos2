import 'package:flutter/material.dart';

import '../../../core/components/app_badge.dart';
import '../../../core/components/app_bottom_sheet.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/product_img.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/response/product_response_model.dart';
import '../pages/add_product_page.dart';

Future<void> showProductDetailSheet(
  BuildContext context, {
  required Product product,
}) {
  return showAppBottomSheet<void>(
    context: context,
    headerBuilder: (ctx) => _Header(product: product),
    bottomActions: _Actions(product: product),
    child: _Body(product: product),
  );
}

class _Header extends StatelessWidget {
  final Product product;
  const _Header({required this.product});

  int _hueFor(Product p) => ((p.productId ?? p.id ?? 0) * 47) % 360;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
              Text(
                product.name,
                style: AppTypography.titleM.copyWith(color: p.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    product.category,
                    style:
                        AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
                  ),
                  if (product.isBestSeller) ...[
                    const SizedBox(width: 8),
                    const AppBadge(label: 'BESTSELLER'),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final Product product;
  const _Body({required this.product});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: p.surfaceVariant,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              label: 'Harga',
              value: product.price.currencyFormatRp.trim(),
            ),
          ),
          Container(width: 1, height: 36, color: p.outlineSoft),
          Expanded(
            child: _Stat(
              label: 'Stok',
              value: product.stock == 0 ? 'Habis' : '${product.stock}',
              valueColor:
                  product.stock == 0 ? p.error : null,
            ),
          ),
          Container(width: 1, height: 36, color: p.outlineSoft),
          Expanded(
            child: _Stat(
              label: 'Status',
              value: product.isBestSeller ? 'Bestseller' : 'Reguler',
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Stat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelM.copyWith(
            color: p.onSurfaceVar,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleS.copyWith(
            color: valueColor ?? p.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final Product product;
  const _Actions({required this.product});

  @override
  Widget build(BuildContext context) {
    return AppButton.primaryWithArrow(
      label: 'Edit Produk',
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddProductPage(existing: product),
          ),
        );
      },
    );
  }
}
