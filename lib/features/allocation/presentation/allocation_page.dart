import 'package:flutter/cupertino.dart';
import 'package:stably_app/shared/widgets/allocation_split_card.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/info_list_card.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';
import 'package:stably_app/shared/widgets/placeholder_metric_card.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class AllocationPage extends StatelessWidget {
  const AllocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      title: 'Smart Allocation',
      subtitle: 'Visual structure for the core optimizer experience.',
      children: [
        SectionBlock(
          title: 'Optimizer preview',
          subtitle:
              'This hero block sells the product’s most differentiated experience.',
          child: HighlightPanel(
            eyebrow: 'Allocator',
            title: 'Turn capped promo bands into a clean multi-lane plan.',
            description:
                'Transform fragmented rates into one trustable recommendation that prioritizes capped campaigns first and pushes overflow into stable baselines.',
            value: '3 buckets',
            secondaryValue: '10,000 USDC',
            tag: 'Core',
            tone: StatusTagTone.info,
          ),
        ),
        SectionBlock(
          title: 'Scenario inputs',
          subtitle:
              'Even the static page should preview how a user will think through the optimizer.',
          trailing:
              PillButton(label: 'Optimize', icon: CupertinoIcons.bolt_fill),
          child: Column(
            children: [
              PlaceholderMetricCard(
                label: 'Available capital',
                value: '10,000.00 USDC',
                caption:
                    'Monospaced capital inputs help the calculator feel precise and quant-friendly.',
                tag: 'Scenario',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.flag_fill,
                      label: 'Target style',
                      value: 'Balanced',
                      caption: 'Moderate yield with sensible overflow logic.',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.chart_bar_alt_fill,
                      label: 'Output focus',
                      value: 'Daily',
                      caption: 'Surface passive income and annualized carry.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SectionBlock(
          title: 'Suggested split',
          subtitle:
              'A launch-like static output should already feel understandable and convincing.',
          child: Column(
            children: [
              AllocationSplitCard(
                rows: [
                  (
                    label: 'Promo bucket',
                    value: '500.00',
                    color: Color(0xFFD9A05B),
                    flex: 5,
                  ),
                  (
                    label: 'Secondary exchange',
                    value: '1,000.00',
                    color: Color(0xFF5E93A5),
                    flex: 10,
                  ),
                  (
                    label: 'On-chain baseline',
                    value: '8,500.00',
                    color: Color(0xFF4A5D23),
                    flex: 85,
                  ),
                ],
              ),
              SizedBox(height: 16),
              InfoListCard(
                title: 'Allocation lanes',
                rows: [
                  (
                    label: 'Promo exchange bucket',
                    value: '500.00',
                    hint: 'Reserve small-cap high-yield bands first.'
                  ),
                  (
                    label: 'Secondary exchange overflow',
                    value: '1,000.00',
                    hint: 'Capture remaining centralized incentives.'
                  ),
                  (
                    label: 'On-chain baseline',
                    value: '8,500.00',
                    hint: 'Anchor the remainder in transparent lending routes.'
                  ),
                ],
              ),
            ],
          ),
        ),
        SectionBlock(
          title: 'Why this mix',
          subtitle:
              'The product should explain recommendation logic, not just output numbers.',
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'Use capped campaigns first',
                description:
                    'Small high-yield windows create disproportionate value when placed at the front of the allocation stack.',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Overflow must remain understandable',
                description:
                    'The default recommendation prefers transparent and liquid routes once promotional capacity is exhausted.',
                tone: StatusTagTone.success,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
