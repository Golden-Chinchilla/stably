import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.icon,
    this.size = 38,
    this.iconSize = 18,
    this.filled = false,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? tokens.primary : tokens.primarySubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: filled ? tokens.primary.withAlpha(140) : tokens.border,
        ),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: filled ? tokens.primarySubtle : tokens.primary,
      ),
    );
  }
}
