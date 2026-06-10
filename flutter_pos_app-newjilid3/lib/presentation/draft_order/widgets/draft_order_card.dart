import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_button.dart';
import '../../../core/components/feedback.dart';
import '../../../core/components/product_img.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../home/bloc/checkout/checkout_bloc.dart';
import '../../order/models/draft_order_model.dart';
import '../../order/pages/order_page.dart';
import '../bloc/draft_order/draft_order_bloc.dart';

/// Expandable draft order card. Collapsed header shows table label,
/// item count, time-ago, total, and a "Bayar" pill. Expanded body lists
/// the items with images + qty×price, then 3 action buttons.
///
/// Maps to the `DraftCard` in `.claude/new-design/screens/draft-order.jsx`.
class DraftOrderCard extends StatelessWidget {
  final DraftOrderModel data;
  final bool expanded;
  final VoidCallback onToggle;

  const DraftOrderCard({
    super.key,
    required this.data,
    required this.expanded,
    required this.onToggle,
  });

  int _hueFor(int? id) => ((id ?? 0) * 47) % 360;

  /// "Meja 4 · Andi" or fallback.
  String get _title {
    final t = data.displayTableLabel;
    final c = data.displayCustomerName;
    if (t.isEmpty && c.isEmpty) return 'Bon #${data.id}';
    if (c.isEmpty) return t;
    if (t.isEmpty) return c;
    return '$t · $c';
  }

  void _payNow(BuildContext context) {
    // Load draft items into the cart, then push the order page.
    context.read<CheckoutBloc>().add(CheckoutEvent.loadDraftOrder(data));
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrderPage()),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await AppConfirm.show(
      context,
      title: 'Hapus Open Bill?',
      body: 'Open Bill "$_title" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || data.id == null || !context.mounted) return;
    context
        .read<DraftOrderBloc>()
        .add(DraftOrderEvent.removeDraft(data.id!));
    AppSnackbar.info(context, 'Open Bill dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: expanded ? p.primary.withValues(alpha: 0.55) : p.outlineSoft,
          width: expanded ? 1.5 : 1,
        ),
        boxShadow: expanded
            ? [
                BoxShadow(
                  color: p.primary.withValues(alpha: 0.20),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: AppRadius.mdAll,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: p.primaryContainer,
                      borderRadius: AppRadius.smAll,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      data.displayTableLabel.toLowerCase().contains('take')
                          ? Icons.shopping_bag_outlined
                          : Icons.table_restaurant_outlined,
                      color: p.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _title,
                          style: AppTypography.bodyL.copyWith(
                            color: p.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${data.totalQuantity} item · ${data.transactionTime}',
                          style: AppTypography.bodyS.copyWith(
                            color: p.onSurfaceVar,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.totalPrice.currencyFormatRp.trim(),
                    style: AppTypography.titleM.copyWith(
                      color: p.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more,
                        color: p.onSurfaceVar, size: 20),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Container(height: 1, color: p.outlineSoft),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in data.orders)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          ProductImg(
                            name: item.product.name,
                            hue: _hueFor(item.product.productId ?? item.product.id),
                            size: 36,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.product.name,
                              style: AppTypography.bodyM.copyWith(
                                color: p.onSurface,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item.quantity} × ${(item.product.price).currencyFormatRp.trim()}',
                            style: AppTypography.bodyS.copyWith(
                              color: p.onSurfaceVar,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (item.quantity * item.product.price)
                                .currencyFormatRp
                                .trim(),
                            style: AppTypography.bodyM.copyWith(
                              color: p.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Hapus',
                          variant: AppButtonVariant.danger,
                          size: AppButtonSize.sm,
                          onPressed: () => _confirmDelete(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          label: 'Bayar →',
                          size: AppButtonSize.sm,
                          onPressed: () => _payNow(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

