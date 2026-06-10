import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/models/response/promo_model.dart';

part 'applied_discount.freezed.dart';

/// Discount applied to the current order. Carried on [OrderSummary] and
/// persisted on the local order row as (promoId, discountAmount).
///
/// `source`:
///   - voucher: user typed a code in DiscountSheet
///   - auto: a `code == null` promo whose time-window is live
///   - manual: cashier-entered ad-hoc discount (no [promo])
@freezed
abstract class AppliedDiscount with _$AppliedDiscount {
  const AppliedDiscount._();

  const factory AppliedDiscount({
    required int amount,
    PromoModel? promo,
    @Default(AppliedDiscountSource.manual) AppliedDiscountSource source,
    String? note,
  }) = _AppliedDiscount;

  /// Convenience: subtotal AFTER discount, clamped at zero.
  int totalAfterDiscount(int subtotal) =>
      subtotal - amount < 0 ? 0 : subtotal - amount;

  /// Display label for the breakdown row, e.g. "Diskon · MEMBER10".
  String displayLabel() {
    if (source == AppliedDiscountSource.manual) {
      return note?.isNotEmpty == true
          ? 'Diskon · $note'
          : 'Diskon manual';
    }
    final p = promo;
    if (p == null) return 'Diskon';
    final code = p.code?.isNotEmpty == true ? ' · ${p.code}' : '';
    return 'Diskon · ${p.name}$code';
  }
}

enum AppliedDiscountSource { voucher, auto, manual }
