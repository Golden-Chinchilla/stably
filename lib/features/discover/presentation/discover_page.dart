import 'package:flutter/cupertino.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/opportunity_card.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      title: 'Yield Discovery',
      subtitle: 'Scan curated opportunities across CeFi and DeFi.',
      children: [
        SectionBlock(
          title: 'Featured signal',
          subtitle:
              'This top block sets the visual tone for discovery-oriented browsing.',
          child: HighlightPanel(
            eyebrow: 'Discovery',
            title: 'Compare curated lanes across transparent risk buckets.',
            description:
                'Blend protocol research, exchange promos, and stablecoin context into a browser that feels premium instead of noisy.',
            value: '11.00%',
            secondaryValue: '12 lanes',
            tag: 'Screened',
          ),
        ),
        SectionBlock(
          title: 'Current filters',
          subtitle:
              'A near-launch screen should already show how selection and slicing will feel.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusTag(label: 'USDC'),
              StatusTag(label: 'Flexible', tone: StatusTagTone.info),
              StatusTag(label: 'CeFi / DeFi', tone: StatusTagTone.success),
              StatusTag(label: 'Risk screened', tone: StatusTagTone.warning),
              StatusTag(label: 'Top APY', tone: StatusTagTone.info),
            ],
          ),
        ),
        SectionBlock(
          title: 'Market scan',
          subtitle:
              'The launch experience should feel like a refined board of opportunities.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.creditcard_fill,
                      label: 'CeFi best',
                      value: '11.00%',
                      caption: 'Top campaign lane with strict cap logic.',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.cube_box_fill,
                      label: 'DeFi best',
                      value: '6.12%',
                      caption: 'Transparent overflow baseline.',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              OpportunityCard(
                icon: CupertinoIcons.sparkles,
                platform: 'Binance Earn',
                asset: 'USDC · Promo band',
                apy: '11.00%',
                summary:
                    'Excellent first bucket for capped capital with short-lived campaign upside.',
                tags: ['CeFi', 'Promo', 'Low cap'],
              ),
              SizedBox(height: 16),
              OpportunityCard(
                icon: CupertinoIcons.cube_box,
                platform: 'Aave V3',
                asset: 'USDC · Ethereum mainnet',
                apy: '6.12%',
                summary:
                    'Clear baseline route for overflow allocation and long-term simplicity.',
                tags: ['DeFi', 'Flexible', 'Baseline'],
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 16),
              OpportunityCard(
                icon: CupertinoIcons.flame,
                platform: 'Ethena',
                asset: 'USDe · Staking lane',
                apy: '12.45%',
                summary:
                    'Higher-yield synthetic dollar strategy with elevated complexity and monitoring needs.',
                tags: ['Synthetic', 'Higher risk', 'Yield'],
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
        SectionBlock(
          title: 'Research notes',
          subtitle:
              'A launch-ready static screen should still guide users on how to interpret the board.',
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'CeFi campaigns are capacity constrained',
                description:
                    'High APY exchange windows often apply only to a small balance slice.',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Synthetic dollars require extra scrutiny',
                description:
                    'Newer structures can offer higher yield, but risk profiles are rarely comparable to simple fiat-backed stablecoins.',
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
