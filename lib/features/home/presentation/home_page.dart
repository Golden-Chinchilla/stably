import 'package:flutter/cupertino.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/mock_trend_card.dart';
import 'package:stably_app/shared/widgets/opportunity_card.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      title: 'Stably',
      subtitle: 'Institutional-grade stablecoin yield intelligence.',
      children: [
        SectionBlock(
          title: 'Command Center',
          subtitle:
              'A launch-ready dashboard should feel calm, premium, and immediately actionable.',
          child: HighlightPanel(
            eyebrow: 'Today',
            title: 'Optimize stablecoin yield without wallet complexity.',
            description:
                'Monitor blended returns, compare safe overflow routes, and keep your opportunity stack visible in one refined command center.',
            value: '+18.42 USDC',
            secondaryValue: '8.73% APY',
            tag: 'Live',
            footer: Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: 'Review discovery',
                    icon: CupertinoIcons.arrow_up_right,
                  ),
                ),
              ],
            ),
          ),
        ),
        SectionBlock(
          title: 'Portfolio at a glance',
          subtitle:
              'Daily use depends on high signal, readable density, and clear hierarchy.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.shield_fill,
                      label: 'Risk posture',
                      value: 'Balanced',
                      caption: 'Conservative mix across transparent lanes.',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.bolt_fill,
                      label: 'Promo room',
                      value: '500 USDC',
                      caption: 'Unused high-yield campaign capacity.',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.money_dollar_circle,
                      label: 'Tracked capital',
                      value: '10.0k',
                      caption: 'Static shell for future local position data.',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.bell,
                      label: 'Active alerts',
                      value: '03',
                      caption: 'Threshold rules and promo monitoring.',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              MockTrendCard(
                title: 'Projected growth curve',
                subtitle:
                    'A soft trend surface that previews long-term compounding behavior.',
              ),
            ],
          ),
        ),
        SectionBlock(
          title: 'Best lanes today',
          subtitle:
              'The homepage should surface curated actions, not an overwhelming feed.',
          child: Column(
            children: [
              OpportunityCard(
                icon: CupertinoIcons.sparkles,
                platform: 'Binance Earn',
                asset: 'USDC · CeFi promo',
                apy: '11.00%',
                summary:
                    'Short-capacity onboarding lane with strong upside for the first allocation bucket.',
                tags: ['Capped', 'CeFi', 'Promo'],
              ),
              SizedBox(height: 16),
              OpportunityCard(
                icon: CupertinoIcons.shield,
                platform: 'Aave V3',
                asset: 'USDC · Ethereum',
                apy: '6.12%',
                summary:
                    'Transparent overflow route with familiar DeFi risk and stable liquidity depth.',
                tags: ['Flexible', 'DeFi', 'Baseline'],
                tone: StatusTagTone.info,
              ),
            ],
          ),
        ),
        SectionBlock(
          title: 'Risk framing',
          subtitle:
              'Compliance and clarity should be visible in the experience, not hidden.',
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'This app simulates and compares only',
                description:
                    'No trades, deposits, or custody actions are performed inside the product.',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Rates may move faster than the UI refreshes',
                description:
                    'Final pricing and campaign availability should always be re-checked on the target platform.',
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
