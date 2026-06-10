import 'package:freezed_annotation/freezed_annotation.dart';

import '../../home/models/order_item.dart';
import '../../promo/models/applied_discount.dart';

part 'order_summary.freezed.dart';

/// Wraps [OrderBloc] success state — replaces the 8-positional tuple
/// (products, totalQuantity, totalPrice, paymentMethod, nominalBayar,
/// idKasir, namaKasir, customerName) with a named-field value object.
///
/// Carries `cashSessionId` so orders saved locally are correctly attributed
/// to the active shift (drives backend `cashRevenue()` at close), and
/// `appliedDiscount` so discount lines + promo_id flow through to persist.
@freezed
abstract class OrderSummary with _$OrderSummary {
  const OrderSummary._();

  const factory OrderSummary({
    @Default(<OrderItem>[]) List<OrderItem> products,
    @Default(0) int totalQuantity,
    @Default(0) int totalPrice,
    @Default('') String paymentMethod,
    @Default(0) int nominalBayar,
    @Default(0) int idKasir,
    @Default('') String namaKasir,
    @Default('') String customerName,

    /// Set by the page that triggers payment, from the current open shift.
    /// Required when persisting to local DB.
    int? cashSessionId,

    /// Discount applied via voucher / auto-promo / manual entry.
    /// Bloc rebuilds [totalPrice] using `subtotal − appliedDiscount.amount`,
    /// so [totalPrice] is always the final tagihan AFTER promo.
    AppliedDiscount? appliedDiscount,
  }) = _OrderSummary;

  /// Kembalian = uang diterima − total tagihan. Negative if underpaid.
  int get change => nominalBayar - totalPrice;

  /// Sum of line items BEFORE discount.
  int get subtotal => products.fold<int>(
        0,
        (s, item) => s + item.quantity * item.product.price,
      );

  int get discountAmount => appliedDiscount?.amount ?? 0;
  int? get promoId => appliedDiscount?.promo?.id;
}
