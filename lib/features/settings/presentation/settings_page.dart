import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/app/providers/app_state_providers.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/async_section_state.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final healthAsync = ref.watch(healthProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: 'Settings',
      showSettingsButton: false,
      children: [
        const SectionBlock(
          title: 'Product tone',
          child: HighlightPanel(
            title:
                'The current product scope is intentionally narrow and data-led.',
            value: 'Top 20',
            secondaryValue: 'Binance + OKX',
            tag: 'Current scope',
            tone: StatusTagTone.info,
          ),
        ),
        SectionBlock(
          title: 'Appearance',
          trailing: StatusTag(
            label: isDark ? 'Dark' : 'Light',
            tone: StatusTagTone.info,
          ),
          child: BaseCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme mode', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Switch between warm daylight and quiet luxury dark mode.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch.adaptive(
                  value: isDark,
                  onChanged: (_) =>
                      ref.read(themeModeProvider.notifier).toggle(),
                ),
              ],
            ),
          ),
        ),
        SectionBlock(
          title: 'Data scope',
          child: BaseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tracked coverage', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'DefiLlama coverage is limited to the current top 20 stablecoins by circulating USD. Related DeFi pools are filtered to that same market set.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'CeFi rates currently come from Binance and OKX only, and the app shows six core fields for each offer.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        SectionBlock(
          title: 'Data status',
          child: healthAsync.when(
            data: (health) => BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current sources', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'DefiLlama for top-20 stablecoins and related DeFi pools. Binance and OKX for CeFi rates.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Last successful updates',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _SettingsStatusRow(
                    label: 'Stablecoins',
                    value: _formatSyncTime(health.stablecoinsSyncedAt),
                  ),
                  const SizedBox(height: 10),
                  _SettingsStatusRow(
                    label: 'DeFi pools',
                    value: _formatSyncTime(health.poolsSyncedAt),
                  ),
                  const SizedBox(height: 10),
                  _SettingsStatusRow(
                    label: 'CeFi board',
                    value: _formatSyncTime(health.cefiSyncedAt),
                  ),
                ],
              ),
            ),
            loading: () => const AsyncSectionState.loading(),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => ref.refresh(healthProvider.future),
            ),
          ),
        ),
        SectionBlock(
          title: 'Compliance',
          child: BaseCard(
            child: Text(
              'Stably aggregates public data and local simulations only. It does not execute trades, custody assets, or provide investment advice.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsStatusRow extends StatelessWidget {
  const _SettingsStatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

String _formatSyncTime(String? value) {
  if (value == null || value.isEmpty) {
    return 'Not synced yet';
  }

  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) {
    return value;
  }

  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  final hour = parsed.hour.toString().padLeft(2, '0');
  final minute = parsed.minute.toString().padLeft(2, '0');

  return '$month-$day $hour:$minute';
}
