import 'package:flutter/cupertino.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/mock_trend_card.dart';
import 'package:stably_app/shared/widgets/opportunity_card.dart';
import 'package:stably_app/shared/widgets/placeholder_metric_card.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      title: 'Portfolio Tracker',
      subtitle: 'A local-first shell for manual positions and passive growth.',
      children: [
        SectionBlock(
          title: 'Portfolio summary',
          subtitle:
              'The asset page should feel precise, warm, and easy to scan.',
          child: HighlightPanel(
            eyebrow: 'Tracker',
            title: 'See your manual positions grow with a calm, local-first view.',
            description:
                'Combine manual entries with refreshed APY assumptions to simulate balance growth while keeping wallet connections out of scope.',
            value: '10,248.91',
            secondaryValue: '+248.91',
            tag: 'Tracking',
          ),
        ),
        SectionBlock(
          title: 'Performance shell',
          subtitle:
              'A polished launch screen should make the local tracker feel genuinely useful.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.money_dollar_circle,
                      label: 'Blended yield',
                      value: '6.42%',
                      caption: 'Base portfolio carry after promo dilution.',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.clock,
                      label: 'Compounding',
                      value: 'Daily',
                      caption: 'Static cadence preview for future math.',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              MockTrendCard(
                title: 'Balance path',
                subtitle:
                    'A soft chart surface that already feels native to a premium wealth dashboard.',
              ),
              SizedBox(height: 16),
              PlaceholderMetricCard(
                label: 'Simulated total balance',
                value: '10,248.91 USDC',
                caption:
                    'Future builds will compound this from manual entries and refreshed APY snapshots.',
                tag: 'Tracking',
                tone: StatusTagTone.success,
              ),
            ],
          ),
        ),
        SectionBlock(
          title: 'Recorded positions',
          subtitle:
              'Static holdings cards should preview the future local ledger layout.',
          child: Column(
            children: [
              OpportunityCard(
                icon: CupertinoIcons.cube_box,
                platform: 'Aave V3',
                asset: 'USDC · Primary baseline',
                apy: '6.12%',
                summary:
                    'Core overflow allocation that anchors the portfolio with readable risk.',
                tags: ['5,000 USDC', 'Flexible', 'DeFi'],
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 16),
              OpportunityCard(
                icon: CupertinoIcons.sparkles,
                platform: 'Binance Earn',
                asset: 'USDC · Promo bucket',
                apy: '11.00%',
                summary:
                    'Small-cap incentive lane tracked separately to show boosted contribution.',
                tags: ['500 USDC', 'CeFi', 'Promo'],
              ),
              SizedBox(height: 16),
              OpportunityCard(
                icon: CupertinoIcons.money_dollar_circle,
                platform: 'Dry powder',
                asset: 'USDC · Unallocated reserve',
                apy: '0.00%',
                summary:
                    'Reserved capital for new ideas, rebalance actions, or campaign refreshes.',
                tags: ['4,500 USDC', 'Reserve'],
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
        SectionBlock(
          title: 'Tracker notes',
          subtitle:
              'The portfolio page should reinforce local-first and manual-accounting boundaries.',
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'Balances are manually recorded',
                description:
                    'The app does not read exchange accounts or on-chain wallets for this product version.',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Simulated growth is directional',
                description:
                    'Actual outcomes depend on changing rates, reward mechanics, and real user actions.',
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
