import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_bottom_sheet.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_money_text_field.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_segmented_toggle.dart';
import '../../../core/components/app_status_pill.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/promo_remote_datasource.dart';
import '../../../data/models/response/promo_model.dart';
import '../bloc/promo/promo_bloc.dart';
import '../models/applied_discount.dart';

/// Discount & voucher sheet opened from OrderPage. Three sources:
///   - Voucher code → call BE /promos/apply for server validation
///   - Auto promo  → tap a live promo from the cached list
///   - Manual disc → percent or rupiah field (caps at subtotal)
///
/// Returns the chosen [AppliedDiscount] or null on cancel.
Future<AppliedDiscount?> showDiscountSheet(
  BuildContext context, {
  required int subtotal,
  AppliedDiscount? current,
}) {
  return showAppBottomSheet<AppliedDiscount?>(
    context: context,
    headerBuilder: (ctx) => _Header(),
    child: _DiscountBody(subtotal: subtotal, current: current),
  );
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
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
              Text('Diskon & Voucher',
                  style: AppTypography.titleM.copyWith(color: p.onSurface)),
              Text('Pilih promo untuk order ini',
                  style:
                      AppTypography.bodyS.copyWith(color: p.onSurfaceVar)),
            ],
          ),
        ),
        BlocBuilder<PromoBloc, PromoState>(
          builder: (context, state) {
            final n = state.maybeWhen(
              success: (list) => list.where((p) => p.isLive()).length,
              orElse: () => 0,
            );
            return AppStatusPill(
              label: '$n tersedia',
              kind: n > 0 ? AppStatusKind.success : AppStatusKind.neutral,
            );
          },
        ),
      ],
    );
  }
}

class _DiscountBody extends StatefulWidget {
  final int subtotal;
  final AppliedDiscount? current;
  const _DiscountBody({required this.subtotal, this.current});

  @override
  State<_DiscountBody> createState() => _DiscountBodyState();
}

class _DiscountBodyState extends State<_DiscountBody> {
  final _codeCtrl = TextEditingController();
  String _manualType = 'percent'; // 'percent' | 'rupiah'
  int _manualValue = 0;
  bool _applyingCode = false;
  String? _codeError;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  int _manualDiscountAmount() {
    if (_manualValue <= 0) return 0;
    if (_manualType == 'percent') {
      final v = _manualValue.clamp(0, 100);
      return (widget.subtotal * v ~/ 100).clamp(0, widget.subtotal);
    }
    return _manualValue.clamp(0, widget.subtotal);
  }

  Future<void> _applyCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _codeError = 'Masukkan kode voucher dulu');
      return;
    }
    setState(() {
      _applyingCode = true;
      _codeError = null;
    });
    final result =
        await PromoRemoteDatasource().applyCode(code, widget.subtotal);
    if (!mounted) return;
    result.fold(
      (msg) {
        setState(() {
          _applyingCode = false;
          _codeError = msg;
        });
      },
      (data) {
        final (promo, amount) = data;
        Navigator.of(context).pop(AppliedDiscount(
          amount: amount,
          promo: promo,
          source: AppliedDiscountSource.voucher,
        ));
      },
    );
  }

  void _applyAutoPromo(PromoModel promo) {
    final amount = promo.computeDiscount(widget.subtotal);
    if (amount <= 0) {
      AppSnackbar.error(
        context,
        'Promo "${promo.name}" tidak cocok untuk order ini',
      );
      return;
    }
    Navigator.of(context).pop(AppliedDiscount(
      amount: amount,
      promo: promo,
      source: AppliedDiscountSource.auto,
    ));
  }

  void _applyManual() {
    final amount = _manualDiscountAmount();
    if (amount <= 0) {
      AppSnackbar.error(context, 'Masukkan nilai diskon');
      return;
    }
    Navigator.of(context).pop(AppliedDiscount(
      amount: amount,
      source: AppliedDiscountSource.manual,
      note: _manualType == 'percent'
          ? '$_manualValue%'
          : 'manual',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final manualAmount = _manualDiscountAmount();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Label('Kode voucher'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: _codeError != null ? p.error : p.outline,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(Icons.confirmation_number_outlined,
                  color: p.onSurfaceVar, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9_-]')),
                  ],
                  style: AppTypography.bodyL
                      .copyWith(color: p.onSurface, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                    border: InputBorder.none,
                    hintText: 'MEMBER10',
                    hintStyle: AppTypography.bodyL
                        .copyWith(color: p.onSurfaceVar),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: AppButton(
                  label: 'Pakai',
                  size: AppButtonSize.sm,
                  fullWidth: false,
                  loading: _applyingCode,
                  onPressed: _applyingCode ? null : _applyCode,
                ),
              ),
            ],
          ),
        ),
        if (_codeError != null) ...[
          const SizedBox(height: 6),
          Text(
            _codeError!,
            style: AppTypography.bodyS.copyWith(color: p.error, fontSize: 11),
          ),
        ],
        const _SectionLabel('Promo otomatis'),
        BlocBuilder<PromoBloc, PromoState>(
          builder: (context, state) {
            return state.maybeWhen(
              success: (list) {
                final auto = list
                    .where((p) => p.isLive() && (p.code ?? '').isEmpty)
                    .toList();
                if (auto.isEmpty) {
                  return const _MutedCard(
                      text: 'Tidak ada promo otomatis yang aktif saat ini');
                }
                return Column(
                  children: [
                    for (final promo in auto) ...[
                      _PromoCard(
                        promo: promo,
                        subtotal: widget.subtotal,
                        applied:
                            widget.current?.promo?.id == promo.id,
                        onTap: () => _applyAutoPromo(promo),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
              orElse: () => const _MutedCard(text: 'Memuat promo...'),
            );
          },
        ),
        const _SectionLabel('Diskon manual'),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSegmentedToggle<String>(
                value: _manualType,
                onChanged: (v) => setState(() => _manualType = v),
                options: const [
                  AppSegmentOption(value: 'percent', label: 'Persen %'),
                  AppSegmentOption(value: 'rupiah', label: 'Rupiah Rp'),
                ],
              ),
              const SizedBox(height: 12),
              if (_manualType == 'percent')
                _PercentField(
                  value: _manualValue,
                  onChanged: (v) => setState(() => _manualValue = v),
                )
              else
                AppMoneyTextField(
                  initialValue: _manualValue,
                  onChanged: (v) => setState(() => _manualValue = v),
                ),
              if (manualAmount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Hemat ${manualAmount.currencyFormatRp.trim()}',
                  style:
                      AppTypography.labelL.copyWith(color: p.success),
                ),
              ],
              if (_manualType == 'percent' && _manualValue > 25) ...[
                const SizedBox(height: 6),
                Text(
                  'Butuh otorisasi owner untuk diskon > 25%',
                  style: AppTypography.bodyS.copyWith(
                    color: p.warning,
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (widget.current != null)
                    Expanded(
                      child: AppButton(
                        label: 'Hapus diskon',
                        variant: AppButtonVariant.danger,
                        size: AppButtonSize.sm,
                        onPressed: () => Navigator.of(context).pop(
                          const AppliedDiscount(
                              amount: 0,
                              source: AppliedDiscountSource.manual),
                        ),
                      ),
                    ),
                  if (widget.current != null) const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: 'Pakai diskon manual',
                      size: AppButtonSize.sm,
                      onPressed: manualAmount > 0 ? _applyManual : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  final PromoModel promo;
  final int subtotal;
  final bool applied;
  final VoidCallback onTap;

  const _PromoCard({
    required this.promo,
    required this.subtotal,
    required this.applied,
    required this.onTap,
  });

  String _valueLabel() {
    switch (promo.type) {
      case PromoType.percent:
        return '${promo.value}%';
      case PromoType.rupiah:
        if (promo.value >= 1000) return 'Rp${promo.value ~/ 1000}rb';
        return 'Rp${promo.value}';
      case PromoType.b1g1:
        return 'B1G1';
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final discount = promo.computeDiscount(subtotal);
    final color = applied ? p.primary : p.outlineSoft;
    return Material(
      color: applied ? p.primaryContainer : Colors.white,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: color, width: applied ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: applied
                      ? p.primary.withValues(alpha: 0.22)
                      : p.primaryContainer,
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: Text(
                  _valueLabel(),
                  style: AppTypography.titleM.copyWith(
                    color: p.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      promo.name,
                      style: AppTypography.bodyL.copyWith(
                        color: p.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      discount > 0
                          ? 'Hemat ${discount.currencyFormatRp.trim()}'
                          : 'Tidak cocok untuk order ini',
                      style: AppTypography.bodyS.copyWith(
                        color: discount > 0 ? p.success : p.onSurfaceVar,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (applied)
                Icon(Icons.check_circle, color: p.primary, size: 22)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: p.primary, width: 1.2),
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Text(
                    'Pakai',
                    style: AppTypography.labelL.copyWith(
                      color: p.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PercentField extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _PercentField({required this.value, required this.onChanged});

  @override
  State<_PercentField> createState() => _PercentFieldState();
}

class _PercentFieldState extends State<_PercentField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.value > 0 ? widget.value.toString() : '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: p.outline, width: 1.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              style: AppTypography.titleM
                  .copyWith(color: p.onSurface, fontSize: 20),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: InputBorder.none,
                hintText: '10',
                hintStyle:
                    AppTypography.bodyL.copyWith(color: p.onSurfaceVar),
              ),
              onChanged: (v) {
                final n = int.tryParse(v) ?? 0;
                widget.onChanged(n);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Text(
              '%',
              style: AppTypography.titleM
                  .copyWith(color: p.onSurfaceVar, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => AppSectionLabel(label,
      margin: const EdgeInsets.only(top: 18, bottom: 8));
}

class _Label extends StatelessWidget {
  final String label;
  const _Label(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(label,
          style: AppTypography.titleS
              .copyWith(color: context.palette.onSurface)),
    );
  }
}

class _MutedCard extends StatelessWidget {
  final String text;
  const _MutedCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surfaceVariant,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: p.onSurfaceVar, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: AppTypography.bodyM.copyWith(color: p.onSurface)),
          ),
        ],
      ),
    );
  }
}
