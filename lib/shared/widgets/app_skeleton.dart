import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';
import 'package:stably_app/shared/widgets/base_card.dart';

class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.radius = 12,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tokens.border.withAlpha(180),
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(begin: 0.35, end: 0.75, duration: 900.ms);
  }
}

class AppHighlightPanelSkeleton extends StatelessWidget {
  const AppHighlightPanelSkeleton({super.key, this.showFooter = false});

  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: AppSkeletonBox(height: 12, width: 96, radius: 999)),
              SizedBox(width: 12),
              AppSkeletonBox(height: 28, width: 72, radius: 999),
            ],
          ),
          const SizedBox(height: 18),
          const AppSkeletonBox(height: 28, width: double.infinity, radius: 14),
          const SizedBox(height: 10),
          const AppSkeletonBox(height: 14, width: double.infinity),
          const SizedBox(height: 8),
          const AppSkeletonBox(height: 14, width: 260),
          const SizedBox(height: 22),
          const Row(
            children: [
              Expanded(child: AppSkeletonBox(height: 52, radius: 16)),
              SizedBox(width: 16),
              Expanded(child: AppSkeletonBox(height: 52, radius: 16)),
            ],
          ),
          if (showFooter) ...[
            const SizedBox(height: 20),
            const AppSkeletonBox(height: 42, width: double.infinity, radius: 999),
          ],
        ],
      ),
    );
  }
}

class AppInsightTileSkeleton extends StatelessWidget {
  const AppInsightTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBox(height: 42, width: 42, radius: 14),
          SizedBox(height: AppSpacing.item),
          AppSkeletonBox(height: 12, width: 88, radius: 999),
          SizedBox(height: 8),
          AppSkeletonBox(height: 26, width: 96, radius: 12),
          SizedBox(height: 6),
          AppSkeletonBox(height: 12, width: double.infinity),
          SizedBox(height: 8),
          AppSkeletonBox(height: 12, width: 140),
        ],
      ),
    );
  }
}

class AppInfoListSkeleton extends StatelessWidget {
  const AppInfoListSkeleton({
    super.key,
    this.rows = 3,
  });

  final int rows;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeletonBox(height: 18, width: 140, radius: 999),
          const SizedBox(height: AppSpacing.block),
          for (var index = 0; index < rows; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeletonBox(height: 12, width: 90, radius: 999),
                      SizedBox(height: 6),
                      AppSkeletonBox(height: 12, width: double.infinity),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                AppSkeletonBox(height: 22, width: 80, radius: 12),
              ],
            ),
            if (index != rows - 1) ...[
              const SizedBox(height: 14),
              Divider(height: 1),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }
}

class AppOpportunityCardSkeleton extends StatelessWidget {
  const AppOpportunityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSkeletonBox(height: 42, width: 42, radius: 14),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonBox(height: 16, width: 120, radius: 999),
                    SizedBox(height: 6),
                    AppSkeletonBox(height: 12, width: 140),
                  ],
                ),
              ),
              SizedBox(width: 12),
              AppSkeletonBox(height: 24, width: 72, radius: 12),
            ],
          ),
          SizedBox(height: 14),
          AppSkeletonBox(height: 12, width: double.infinity),
          SizedBox(height: 8),
          AppSkeletonBox(height: 12, width: 220),
          SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppSkeletonBox(height: 28, width: 72, radius: 999),
              AppSkeletonBox(height: 28, width: 64, radius: 999),
              AppSkeletonBox(height: 28, width: 96, radius: 999),
            ],
          ),
        ],
      ),
    );
  }
}

class AppMetricCardSkeleton extends StatelessWidget {
  const AppMetricCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: AppSkeletonBox(height: 12, width: 110, radius: 999)),
              SizedBox(width: 12),
              AppSkeletonBox(height: 28, width: 60, radius: 999),
            ],
          ),
          SizedBox(height: AppSpacing.item),
          AppSkeletonBox(height: 30, width: 160, radius: 12),
          SizedBox(height: 8),
          AppSkeletonBox(height: 12, width: double.infinity),
          SizedBox(height: 8),
          AppSkeletonBox(height: 12, width: 180),
        ],
      ),
    );
  }
}

class AppListSkeleton extends StatelessWidget {
  const AppListSkeleton({
    super.key,
    this.items = 3,
  });

  final int items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items; index++) ...[
          const AppOpportunityCardSkeleton(),
          if (index != items - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}
