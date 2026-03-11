import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';
import 'package:stably_app/shared/widgets/ambient_backdrop.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _items = [
    CupertinoIcons.home,
    CupertinoIcons.compass_fill,
    CupertinoIcons.chart_bar_alt_fill,
    CupertinoIcons.money_dollar_circle_fill,
    CupertinoIcons.bell_fill,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final isWide = MediaQuery.sizeOf(context).width >= AppSpacing.webBreakpoint;
    final tokens = context.tokens;
    final bodyChild = AmbientBackdrop(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: AppSpacing.maxContentWidth,
                height: constraints.maxHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? AppSpacing.page + 8 : AppSpacing.page,
                  ),
                  child: navigationShell,
                ),
              ),
            );
          },
        ),
      ),
    );

    return Scaffold(
      body: SizedBox.expand(
        child: bodyChild.animate().fade(duration: 220.ms).slideY(begin: 0.04, end: 0),
      ),
      bottomNavigationBar: SizedBox(
        height: 84,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.surface.withAlpha(244),
              border: Border.all(color: tokens.border),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  for (var index = 0; index < _items.length; index++)
                    Expanded(
                      child: _AnimatedNavItem(
                        icon: _items[index],
                        selected: currentIndex == index,
                        onTap: () {
                          navigationShell.goBranch(
                            index,
                            initialLocation: index == navigationShell.currentIndex,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavItem extends StatelessWidget {
  const _AnimatedNavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 420),
            curve: Curves.elasticOut,
            offset: selected ? const Offset(0, -0.06) : Offset.zero,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.elasticOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? tokens.primarySubtle : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 420),
                curve: Curves.elasticOut,
                scale: selected ? 1.24 : 0.96,
                child: Icon(
                  icon,
                  color: selected ? tokens.primary : tokens.textSecondary,
                  size: selected ? 25 : 21,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
