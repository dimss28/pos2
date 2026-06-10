import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_banner.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/components/app_icon_button.dart';
import '../../../core/components/app_key_value_row.dart';
import '../../../core/components/app_numbered_step.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_stepper.dart';
import '../../../core/components/app_sticky_footer.dart';
import '../../../core/components/feedback.dart';
import '../../../core/components/product_img.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/datasources/payment_settings_remote_datasource.dart';
import '../../../data/models/response/product_response_model.dart';
import '../../cash_session/bloc/cash_session/cash_session_bloc.dart';
import '../../home/bloc/checkout/checkout_bloc.dart';
import '../../home/models/checkout_summary.dart';
import '../../home/models/order_item.dart';
import '../../home/dashboard_scope.dart';
import '../../draft_order/pages/draft_order_page.dart';
import '../../promo/widgets/discount_sheet.dart';
import '../bloc/order/order_bloc.dart';
import '../models/order_summary.dart';
import '../widgets/open_bill_sheet.dart';
import '../widgets/payment_confirm_sheet.dart';
import '../widgets/payment_qris_sheet.dart';

enum _PaymentChoice { cash, qris, transfer }

/// Bring the user back to the Home tab from OrderPage regardless of whether
/// OrderPage is the Order tab itself (inside DashboardPage's IndexedStack) or
/// was pushed on top of it (e.g., entered via "Bayar" from an Open Bill).
void _goToHomeTab(BuildContext context) {
  final scope = DashboardScope.of(context);
  if (scope != null) {
    // Switch the bottom-nav target before popping so the tab is already
    // correct by the time pushed-on-top routes unwind.
    scope.switchTo(0);
    Navigator.of(context).popUntil((r) => r.isFirst);
  } else {
    Navigator.of(context).maybePop();
  }
}

/// Cart / checkout page.
///
/// Branches on [CheckoutBloc]:
///   - cart empty → [_EmptyCart] with "Pilih menu" CTA
///   - cart non-empty → item list + payment selector + sticky pay bar
///
/// Maps to `.claude/new-design/screens/order-detail.jsx` and
/// `.claude/new-design/screens/order-detail-empty.jsx`.
class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> with WidgetsBindingObserver {
  _PaymentChoice _method = _PaymentChoice.cash;
  final String _customerName = '';
  bool _qrisAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refreshQrisAvailability();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshQrisAvailability();
    }
  }

  Future<void> refreshQrisAvailability() async {
    final payment = await PaymentSettingsRemoteDatasource().fetch();
    dev.log(
      'QRIS check: server enabled=${payment.qrisEnabled} configured=${payment.midtransConfigured}',
      name: 'OrderPage',
    );
    if (!mounted) return;
    final available = payment.qrisAvailable;
    dev.log('QRIS available=$available', name: 'OrderPage');
    setState(() {
      _qrisAvailable = available;
      if (!available && _method == _PaymentChoice.qris) {
        _method = _PaymentChoice.cash;
      }
    });
  }

  int? _activeCashSessionId() {
    return context.read<CashSessionBloc>().state.maybeWhen(
          open: (s) => s.id,
          orElse: () => null,
        );
  }

  Future<void> _pay(CheckoutSummary cart) async {
    final sessionId = _activeCashSessionId();
    if (sessionId == null) {
      AppSnackbar.error(
        context,
        'Tidak ada shift aktif — buka kasir dulu.',
      );
      return;
    }
    final methodLabel = switch (_method) {
      _PaymentChoice.cash => 'Tunai',
      _PaymentChoice.qris => 'QRIS',
      _PaymentChoice.transfer => 'Transfer',
    };

    final bloc = context.read<OrderBloc>();
    bloc.add(
      OrderEvent.addPaymentMethod(
        paymentMethod: methodLabel,
        orders: cart.products,
        customerName: _customerName,
        cashSessionId: sessionId,
      ),
    );

    // The handler is async (awaits getAuthData), so we can't read state
    // synchronously after add(). Wait for the next terminal state.
    final next = await bloc.stream.firstWhere(
      (s) => s.maybeWhen(
        success: (_) => true,
        error: (_) => true,
        orElse: () => false,
      ),
    );
    if (!mounted) return;

    final summary = next.maybeWhen(success: (s) => s, orElse: () => null);
    if (summary == null) {
      final msg = next.maybeWhen(error: (m) => m, orElse: () => 'Gagal memproses pembayaran');
      AppSnackbar.error(context, msg);
      return;
    }

    switch (_method) {
      case _PaymentChoice.cash:
        showPaymentConfirmSheet(context, summary: summary);
      case _PaymentChoice.qris:
        showPaymentQrisSheet(context, summary: summary);
      case _PaymentChoice.transfer:
        AppSnackbar.info(context,
            'Pembayaran Transfer segera hadir — pakai Tunai/QRIS untuk sekarang.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppAppBar(
        title: 'Detail Order',
        subtitle: 'Pesanan saat ini',
        automaticallyImplyLeading: ModalRoute.of(context)?.canPop ?? false,
        trailing: [
          AppIconButton(
            icon: Icons.list_alt,
            variant: AppIconButtonVariant.surfaceVariant,
            tooltip: 'Lihat semua Open Bill',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DraftOrderPage()),
            ),
          ),
          const SizedBox(width: 6),
          AppIconButton(
            icon: Icons.bookmark_add_outlined,
            variant: AppIconButtonVariant.surfaceVariant,
            tooltip: 'Simpan ke Open Bill',
            onPressed: _openSaveDraft,
          ),
        ],
      ),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, cartState) {
          final cart = cartState.maybeWhen(
            success: (s) => s,
            orElse: () => const CheckoutSummary(),
          );
          if (cart.isEmpty) return const _EmptyCart();
          return BlocBuilder<OrderBloc, OrderState>(
            builder: (context, orderState) {
              final orderSummary = orderState.maybeWhen(
                success: (s) => s,
                orElse: () => const OrderSummary(),
              );
              return _LoadedCart(cart: cart, order: orderSummary);
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, cartState) {
          final cart = cartState.maybeWhen(
            success: (s) => s,
            orElse: () => const CheckoutSummary(),
          );
          if (cart.isEmpty) return const SizedBox.shrink();
          return BlocBuilder<OrderBloc, OrderState>(
            builder: (context, orderState) {
              final orderSummary = orderState.maybeWhen(
                success: (s) => s,
                orElse: () => const OrderSummary(),
              );
              final discount = orderSummary.discountAmount;
              final taxPct =
                  AuthLocalDatasource().getTaxPercentSync() / 100.0;
              final tax = (cart.totalPrice * taxPct).round();
              final totalBayar =
                  (cart.totalPrice + tax - discount).clamp(0, 1 << 31);
              return _PaymentFooter(
                cart: cart,
                totalBayar: totalBayar,
                method: _method,
                qrisAvailable: _qrisAvailable,
                onMethodChanged: (v) => setState(() => _method = v),
                onPay: () => _pay(cart),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openSaveDraft() async {
    final saved = await showOpenBillSheet(context);
    if (!mounted || !saved) return;
    context.read<CheckoutBloc>().add(const CheckoutEvent.started());
    Navigator.of(context).maybePop();
  }
}

// ─── empty cart ──────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppEmptyState(
      visual: Container(
        width: 110,
        height: 80,
        decoration: BoxDecoration(
          color: p.primaryContainer,
          borderRadius: AppRadius.lgAll,
        ),
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.all(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: p.primary,
            borderRadius: AppRadius.smAll,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.local_offer_outlined,
              size: 16, color: p.onPrimary),
        ),
      ),
      title: 'Keranjang kosong',
      body:
          'Pilih menu dari halaman utama untuk mulai membuat order pelanggan.',
      helperCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELANJUTNYA',
            style: AppTypography.labelM.copyWith(
              color: p.onSurfaceVar,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const AppNumberedStep(
            n: 1,
            text: 'Tambah menu dari katalog',
            style: AppStepStyle.outlined,
          ),
          const AppNumberedStep(
            n: 2,
            text: 'Pilih metode bayar (Cash / QRIS / Transfer)',
            style: AppStepStyle.outlined,
          ),
          const AppNumberedStep(
            n: 3,
            text: 'Cetak struk & selesai',
            style: AppStepStyle.outlined,
          ),
        ],
      ),
      primaryAction: AppButton(
        label: 'Pilih menu',
        onPressed: () => _goToHomeTab(context),
      ),
    );
  }
}

// ─── loaded cart ─────────────────────────────────────────────────────────
class _LoadedCart extends StatelessWidget {
  final CheckoutSummary cart;
  final OrderSummary order;
  const _LoadedCart({required this.cart, required this.order});

  /// Tax dari Receipt Settings (cached saat app start oleh main.dart).
  /// Mis. 10 = 10% PB1. Default 0 (tax tidak diaplikasikan).
  double get _taxPct => AuthLocalDatasource().getTaxPercentSync() / 100.0;
  int get _subtotal => cart.totalPrice;
  int get _tax => (_subtotal * _taxPct).round();
  int get _discount => order.discountAmount;
  int get _total => (_subtotal + _tax - _discount).clamp(0, 1 << 31);

  Future<void> _openDiscount(BuildContext context) async {
    final picked = await showDiscountSheet(
      context,
      subtotal: _subtotal,
      current: order.appliedDiscount,
    );
    if (picked == null || !context.mounted) return;
    if (picked.amount == 0) {
      context.read<OrderBloc>().add(const OrderEvent.clearDiscount());
    } else {
      context.read<OrderBloc>().add(OrderEvent.applyDiscount(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return BlocBuilder<CashSessionBloc, CashSessionState>(
      builder: (context, shiftState) {
        final shiftClosed = shiftState.maybeWhen(
          open: (_) => false,
          orElse: () => true,
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            if (shiftClosed) ...[
              const AppBanner(
                kind: AppBannerKind.warning,
                leadingIcon: Icons.lock_outline,
                title: 'Belum ada shift aktif',
                body: 'Buka kasir dulu untuk bisa menyimpan order.',
              ),
              const SizedBox(height: 12),
            ],
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  for (var i = 0; i < cart.products.length; i++) ...[
                    _OrderItemRow(item: cart.products[i]),
                    Container(height: 1, color: p.outlineSoft),
                  ],
                  _AddMoreTile(
                    onTap: () => _goToHomeTab(context),
                  ),
                ],
              ),
            ),
            const _SectionLabel('Diskon'),
            _DiscountRow(
              discount: _discount,
              applied: order.appliedDiscount,
              onTap: () => _openDiscount(context),
            ),
            const _SectionLabel('Ringkasan'),
            AppCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  AppKeyValueRow(
                    label: 'Subtotal',
                    value: _subtotal.currencyFormatRp.trim(),
                  ),
                  if (_taxPct > 0)
                    AppKeyValueRow(
                      label: 'Pajak (${(_taxPct * 100).toInt()}%)',
                      value: _tax.currencyFormatRp.trim(),
                    ),
                  if (_discount > 0)
                    AppKeyValueRow(
                      label: order.appliedDiscount?.displayLabel() ??
                          'Diskon',
                      value:
                          '−${_discount.currencyFormatRp.trim()}',
                      variant: AppKVVariant.muted,
                    ),
                  AppKeyValueRow(
                    label: 'Total',
                    value: _total.currencyFormatRp.trim(),
                    variant: AppKVVariant.big,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DiscountRow extends StatelessWidget {
  final int discount;
  final dynamic applied;
  final VoidCallback onTap;
  const _DiscountRow({
    required this.discount,
    required this.applied,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final has = discount > 0;
    return Material(
      color: Colors.white,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: has
                  ? p.primary.withValues(alpha: 0.55)
                  : p.outlineSoft,
              width: has ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.primaryContainer,
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.local_offer_outlined,
                    color: p.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      has ? 'Diskon dipakai' : 'Pakai promo / voucher',
                      style: AppTypography.bodyL.copyWith(
                        color: p.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (has)
                      Text(
                        'Hemat ${discount.currencyFormatRp.trim()}',
                        style: AppTypography.bodyS.copyWith(
                          color: p.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Text(
                        'Voucher code, promo otomatis, atau diskon manual',
                        style: AppTypography.bodyS.copyWith(
                          color: p.onSurfaceVar,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: p.onSurfaceVar),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMoreTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMoreTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: p.primaryContainer,
                borderRadius: AppRadius.smAll,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.add, size: 18, color: p.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tambah produk',
                style: AppTypography.bodyL.copyWith(
                  color: p.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: p.onSurfaceVar, size: 20),
          ],
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;
  const _OrderItemRow({required this.item});

  int _hueFor(Product p) => ((p.productId ?? p.id ?? 0) * 47) % 360;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          ProductImg(
            name: item.product.name,
            hue: _hueFor(item.product),
            imageUrl: item.product.displayImageUrl,
            size: 52,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.product.name ?? '-',
                  style: AppTypography.bodyM.copyWith(
                    color: p.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${(item.product.price ?? 0).currencyFormatRp.trim()} / pcs',
                  style: AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
                ),
              ],
            ),
          ),
          AppStepper(
            qty: item.quantity,
            max: item.product.stock,
            onChanged: (v) {
              if (v > item.quantity) {
                context
                    .read<CheckoutBloc>()
                    .add(CheckoutEvent.addCheckout(item.product));
              } else {
                context
                    .read<CheckoutBloc>()
                    .add(CheckoutEvent.removeCheckout(item.product));
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─── payment selector + pay button (sticky footer) ──────────────────────
class _PaymentFooter extends StatelessWidget {
  final CheckoutSummary cart;
  final int totalBayar;
  final _PaymentChoice method;
  final bool qrisAvailable;
  final ValueChanged<_PaymentChoice> onMethodChanged;
  final VoidCallback onPay;

  const _PaymentFooter({
    required this.cart,
    required this.totalBayar,
    required this.method,
    required this.qrisAvailable,
    required this.onMethodChanged,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppStickyFooter(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _MethodCard(
                  label: 'Tunai',
                  icon: Icons.payments_outlined,
                  active: method == _PaymentChoice.cash,
                  onTap: () => onMethodChanged(_PaymentChoice.cash),
                ),
              ),
              if (qrisAvailable) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _MethodCard(
                    label: 'QRIS',
                    icon: Icons.qr_code_2,
                    active: method == _PaymentChoice.qris,
                    onTap: () => onMethodChanged(_PaymentChoice.qris),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: _MethodCard(
                  label: 'Transfer',
                  icon: Icons.account_balance_outlined,
                  active: method == _PaymentChoice.transfer,
                  onTap: () => onMethodChanged(_PaymentChoice.transfer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.primary,
              borderRadius: AppRadius.mdAll,
              boxShadow: [
                BoxShadow(
                  color: p.primary.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total bayar',
                        style: AppTypography.bodyS.copyWith(
                          color: p.onPrimary.withValues(alpha: 0.85),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        totalBayar.currencyFormatRp.trim(),
                        style: AppTypography.titleM.copyWith(
                          color: p.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: p.onPrimary,
                  borderRadius: AppRadius.mdAll,
                  child: InkWell(
                    onTap: onPay,
                    borderRadius: AppRadius.mdAll,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 14, 12),
                      child: Row(
                        children: [
                          Text(
                            'Bayar',
                            style: AppTypography.labelL.copyWith(
                              color: p.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.arrow_forward,
                              size: 18, color: p.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _MethodCard({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = active ? p.primaryContainer : Colors.white;
    final border = active ? p.primary : p.outlineSoft;
    final fg = active ? p.primary : p.onSurfaceVar;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: border, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelM.copyWith(
                color: fg,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) =>
      AppSectionLabel(label, margin: const EdgeInsets.only(top: 18, bottom: 8));
}
