import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stably_app/shared/widgets/app_icon_badge.dart';
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIconBadge(icon: icon, size: 64, iconSize: 32)
                  .animate(delay: 100.ms)
                  .scaleXY(
                    begin: 0.5,
                    end: 1.0,
                    duration: 450.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 450.ms),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms).fadeIn(),
              const SizedBox(height: 8),
              Text(
                    description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  )
                  .animate(delay: 50.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms)
                  .fadeIn(),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                      width: 200,
                      child: PillButton(
                        label: actionLabel!,
                        icon: CupertinoIcons.arrow_right,
                        onPressed: onAction,
                      ),
                    )
                    .animate(delay: 150.ms)
                    .scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOutBack)
                    .fadeIn(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
