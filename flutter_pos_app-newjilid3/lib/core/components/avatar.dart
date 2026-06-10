import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

enum AppAvatarKind { primary, primaryContainer }

/// Round avatar with two-letter initials.
/// Used by: settings profile, buka/close kasir identity card,
/// payment-success header.
class AppAvatar extends StatelessWidget {
  final String name;
  final double size;
  final AppAvatarKind kind;

  const AppAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.kind = AppAvatarKind.primary,
  });

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg) = switch (kind) {
      AppAvatarKind.primary => (p.primary, p.onPrimary),
      AppAvatarKind.primaryContainer =>
        (p.primaryContainer, p.onPrimaryContainer),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initialsOf(name),
        style: AppTypography.titleM.copyWith(
          color: fg,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
