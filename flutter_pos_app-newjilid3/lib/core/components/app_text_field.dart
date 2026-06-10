import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Standard text field with focus halo (primary border + 10% ring),
/// optional label above, leading icon, prefix text (e.g. "Rp"), and trailing slot.
///
/// Maps to: `TextField` in `.claude/new-design/screens/login.jsx:36`,
/// `FormField` in `.claude/new-design/screens/draft-order.jsx:148`.
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final IconData? leadingIcon;
  final Widget? trailing;
  final String? prefixText;
  final TextEditingController? controller;
  final bool obscure;
  final bool autofocus;
  final bool readOnly;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextStyle? valueStyle;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool subtle;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.leadingIcon,
    this.trailing,
    this.prefixText,
    this.controller,
    this.obscure = false,
    this.autofocus = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.errorText,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.valueStyle,
    this.onChanged,
    this.onTap,
    this.subtle = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focused != _focusNode.hasFocus) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? p.error
        : _focused
            ? p.primary
            : (widget.subtle ? p.outlineSoft : p.outline);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: AppSpacing.sm),
            child: Text(
              widget.label!,
              style: AppTypography.titleS.copyWith(color: p.onSurface),
            ),
          ),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: _focused && !hasError
                ? [
                    BoxShadow(
                      color: p.primary.withValues(alpha: 0.10),
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.leadingIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg),
                  child: Icon(
                    widget.leadingIcon,
                    size: 20,
                    color: _focused ? p.primary : p.onSurfaceVar,
                  ),
                ),
              ],
              if (widget.prefixText != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg),
                  child: Text(
                    widget.prefixText!,
                    style: AppTypography.titleM.copyWith(color: p.onSurfaceVar),
                  ),
                ),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  readOnly: widget.readOnly,
                  obscureText: widget.obscure,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  maxLines: widget.obscure ? 1 : widget.maxLines,
                  minLines: widget.minLines,
                  maxLength: widget.maxLength,
                  onChanged: widget.onChanged,
                  onTap: widget.onTap,
                  style: widget.valueStyle ??
                      AppTypography.bodyL.copyWith(color: p.onSurface),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.leadingIcon == null &&
                              widget.prefixText == null
                          ? AppSpacing.lg
                          : AppSpacing.md,
                      vertical: 18,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    counterText: '',
                    hintText: widget.hint,
                    hintStyle:
                        AppTypography.bodyL.copyWith(color: p.onSurfaceVar),
                  ),
                ),
              ),
              if (widget.trailing != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: widget.trailing!,
                ),
              ],
            ],
          ),
        ),
        if (hasError) ...[
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 6),
            child: Text(
              widget.errorText!,
              style: AppTypography.bodyS.copyWith(color: p.error),
            ),
          ),
        ],
      ],
    );
  }
}
