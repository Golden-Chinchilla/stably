import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = CupertinoIcons.tray,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodySmall,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            PillButton(
              label: actionLabel!,
              icon: CupertinoIcons.arrow_clockwise,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
