import 'package:flutter/cupertino.dart';
import 'package:stably_app/shared/widgets/alert_rule_card.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/placeholder_metric_card.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      title: 'Alerts',
      subtitle: 'Premium notification surfaces for rates, promos, and rules.',
      children: [
        SectionBlock(
          title: 'Premium alerting',
          subtitle:
              'This page should already hint at retention and subscription value.',
          child: HighlightPanel(
            eyebrow: 'Signals',
            title: 'Keep rates, promos, and portfolio drift under one elegant watchlist.',
            description:
                'Alerts are framed as quiet, useful signals rather than noisy trading notifications, aligned with the product’s premium tone.',
            value: '03 active',
            secondaryValue: '2 premium',
            tag: 'Premium',
            tone: StatusTagTone.warning,
          ),
        ),
        SectionBlock(
          title: 'Alert status',
          subtitle:
              'A launch-like page should make notification value obvious at first glance.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.bell,
                      label: 'Threshold rules',
                      value: '2',
                      caption: 'Yield drops and baseline compression.',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.star_fill,
                      label: 'Premium tier',
                      value: 'On',
                      caption: 'Reserved space for subscription gating.',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              PlaceholderMetricCard(
                label: 'Active alert rules',
                value: '03',
                caption:
                    'Thresholds, promo watches, and rule-based reminders will live here.',
                tag: 'Premium',
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
        SectionBlock(
          title: 'Configured rules',
          subtitle:
              'Static cards should feel like a real notification center, not placeholders.',
          child: Column(
            children: [
              AlertRuleCard(
                title: 'USDC flexible yield falls below 4%',
                description:
                    'Notify when low-risk baseline yields compress enough to justify a manual review.',
                frequency: 'Enabled',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 16),
              AlertRuleCard(
                title: 'New exchange promo appears',
                description:
                    'Surface short-lived onboarding campaigns quickly so capped buckets can be reallocated.',
                frequency: 'Instant',
                tone: StatusTagTone.success,
              ),
              SizedBox(height: 16),
              AlertRuleCard(
                title: 'Portfolio drifts from suggested split',
                description:
                    'Remind when tracked positions materially diverge from the allocation plan.',
                frequency: 'Daily',
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
        SectionBlock(
          title: 'Messaging principles',
          subtitle:
              'The notification layer should stay informative, selective, and compliant.',
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'Alerts suggest reviews, not actions',
                description:
                    'The product surfaces information but does not execute transfers or recommendations.',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Short-lived promos may expire before the user acts',
                description:
                    'Final availability should always be verified on the destination platform.',
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
