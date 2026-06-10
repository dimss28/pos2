import 'package:freezed_annotation/freezed_annotation.dart';

import 'order_item.dart';

part 'checkout_summary.freezed.dart';

/// Wraps [CheckoutBloc] success state — replaces the 4-positional tuple
/// (products, totalQuantity, totalPrice, draftName) so adding fields like
/// `discountAmount` or `promoCode` in Phase 9 doesn't break every callsite.
@freezed
abstract class CheckoutSummary with _$CheckoutSummary {
  const CheckoutSummary._();

  const factory CheckoutSummary({
    @Default(<OrderItem>[]) List<OrderItem> products,
    @Default(0) int totalQuantity,
    @Default(0) int totalPrice,
    @Default('customer') String draftName,

    /// Source draft id when the cart was loaded from an existing Open Bill.
    /// Saving the cart updates this row instead of creating a duplicate;
    /// paying it out deletes this row.
    int? linkedDraftId,
    String? linkedTableLabel,
    String? linkedCustomerName,
  }) = _CheckoutSummary;

  bool get isEmpty => products.isEmpty;
  bool get isNotEmpty => products.isNotEmpty;

  /// Re-compute [totalQuantity] and [totalPrice] from the current
  /// [products] list. Use in [CheckoutBloc] event handlers after mutating
  /// the list so the totals stay in sync.
  static (int qty, int price) totalsOf(Iterable<OrderItem> items) {
    var qty = 0;
    var price = 0;
    for (final item in items) {
      qty += item.quantity;
      price += item.quantity * item.product.price;
    }
    return (qty, price);
  }
}
