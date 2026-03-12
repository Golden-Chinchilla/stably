import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stably_app/app/providers/app_state_providers.dart';
import 'package:stably_app/app/router/app_router.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';

class AppPageScaffold extends ConsumerWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showSettingsButton = true,
    this.onRefresh,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showSettingsButton;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    final scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 18, right: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stackHeader = constraints.maxWidth < 430;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: tokens.primarySubtle.withAlpha(220),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusPill,
                                  ),
                                ),
                                child: Text(
                                  'Stable Yield Intelligence',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: tokens.primary,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(title),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (showSettingsButton && !stackHeader) ...[
                          const SizedBox(width: 12),
                          PillButton(
                            label: theme.brightness == Brightness.dark ? 'Light' : 'Dark',
                            icon: theme.brightness == Brightness.dark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                            isPrimary: false,
                            compact: true,
                            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
                          ),
                          const SizedBox(width: 12),
                          PillButton(
                            label: 'Settings',
                            icon: CupertinoIcons.slider_horizontal_3,
                            isPrimary: false,
                            compact: true,
                            onPressed: () =>
                                context.pushNamed(AppRoute.settings.name),
                          ),
                        ],
                      ],
                    ),
                    if (showSettingsButton && stackHeader) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          PillButton(
                            label: theme.brightness == Brightness.dark ? 'Light' : 'Dark',
                            icon: theme.brightness == Brightness.dark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                            isPrimary: false,
                            compact: true,
                            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
                          ),
                          const SizedBox(width: 12),
                          PillButton(
                            label: 'Settings',
                            icon: CupertinoIcons.slider_horizontal_3,
                            isPrimary: false,
                            compact: true,
                            onPressed: () =>
                                context.pushNamed(AppRoute.settings.name),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(
            top: AppSpacing.section + 4,
            bottom: AppSpacing.page + 12,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final childIndex = index ~/ 2;
                if (index.isOdd) {
                  return const SizedBox(height: AppSpacing.section);
                }
                return children[childIndex];
              },
              childCount: children.isEmpty ? 0 : children.length * 2 - 1,
            ),
          ),
        ),
      ],
    );

    if (onRefresh == null) {
      return scrollView;
    }

    return RefreshIndicator.adaptive(
      onRefresh: onRefresh!,
      child: scrollView,
    );
  }
}
