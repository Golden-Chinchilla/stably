import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isPrimary = true,
    this.compact = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final backgroundColor = isPrimary ? tokens.primary : tokens.primarySubtle;
    final foregroundColor = isPrimary ? Colors.white : tokens.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 12 : 14,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: compact ? 16 : 18, color: foregroundColor),
                SizedBox(width: compact ? 6 : 8),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foregroundColor,
                      fontSize: compact ? 13 : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
