import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';
import 'app_text_field.dart';

/// Monetary input with "Rp" prefix and thousand-separator formatting.
///
/// Use in: buka-kasir (modal awal), close-kasir (kas fisik), order-detail
/// (uang diterima), payment-confirm. Maps to: `AmountInput`
/// in `.claude/new-design/screens/buka-kasir.jsx` and
/// `.claude/new-design/screens/order-detail.jsx`.
///
/// Emits parsed [int] (rupiah, no formatting) via [onChanged].
class AppMoneyTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final int? initialValue;
  final void Function(int rupiah)? onChanged;
  final bool autofocus;
  final String? errorText;

  const AppMoneyTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.autofocus = false,
    this.errorText,
  });

  @override
  State<AppMoneyTextField> createState() => _AppMoneyTextFieldState();
}

class _AppMoneyTextFieldState extends State<AppMoneyTextField> {
  late final TextEditingController _controller;
  static final NumberFormat _fmt = NumberFormat.decimalPattern('id');

  String _format(int? v) =>
      (v != null && v > 0) ? _fmt.format(v) : '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.initialValue));
  }

  @override
  void didUpdateWidget(covariant AppMoneyTextField old) {
    super.didUpdateWidget(old);
    if (widget.initialValue != old.initialValue) {
      final formatted = _format(widget.initialValue);
      if (formatted != _controller.text) {
        _controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = digits.isEmpty ? 0 : int.parse(digits);
    final formatted = parsed == 0 ? '' : _fmt.format(parsed);
    if (formatted != _controller.text) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    widget.onChanged?.call(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppTextField(
      label: widget.label,
      hint: widget.hint ?? '0',
      prefixText: 'Rp',
      controller: _controller,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      errorText: widget.errorText,
      valueStyle: AppTypography.displayM.copyWith(
        color: p.onSurface,
        fontSize: 24,
      ),
      onChanged: _onChanged,
    );
  }
}
