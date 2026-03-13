import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/app/l10n/app_localizations.dart';
import 'package:stably_app/app/providers/app_state_providers.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';
import 'package:stably_app/shared/widgets/app_segmented_control.dart';
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
    final locale = ref.watch(localeProvider);
    final healthAsync = ref.watch(healthProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: context.tr('Settings'),
      showSettingsButton: false,
      children: [
        SectionBlock(
          title: context.tr('Product tone'),
          child: HighlightPanel(
            title: context.tr(
              'The current product scope is intentionally narrow and data-led.',
            ),
            value: 'Top 20',
            secondaryValue: 'Binance + OKX',
            tag: context.tr('Current scope'),
            tone: StatusTagTone.info,
          ),
        ),
        SectionBlock(
          title: context.tr('Appearance'),
          trailing: StatusTag(
            label: isDark ? context.tr('Dark') : context.tr('Light'),
            tone: StatusTagTone.info,
          ),
          child: BaseCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('Theme mode'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr(
                          'Switch between warm daylight and quiet luxury dark mode.',
                        ),
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
          title: context.tr('Language'),
          child: BaseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Language'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                AppSegmentedControl<String>(
                  value: locale.languageCode,
                  options: const [
                    (value: 'en', label: 'English'),
                    (value: 'zh', label: '中文'),
                  ],
                  onChanged: (value) => ref
                      .read(localeProvider.notifier)
                      .setLocale(Locale(value)),
                ),
              ],
            ),
          ),
        ),
        SectionBlock(
          title: context.tr('Data scope'),
          child: BaseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Tracked coverage'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'DefiLlama coverage is limited to the current top 20 stablecoins by circulating USD. Related DeFi pools are filtered to that same market set.',
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr(
                    'CeFi rates currently come from Binance and OKX only, and the app shows six core fields for each offer.',
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        SectionBlock(
          title: context.tr('Data status'),
          child: healthAsync.when(
            data: (health) => BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('Current sources'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr(
                      'DefiLlama for top-20 stablecoins and related DeFi pools. Binance and OKX for CeFi rates.',
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('Last successful updates'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _SettingsStatusRow(
                    label: context.tr('Stablecoins'),
                    value: _formatSyncTime(context, health.stablecoinsSyncedAt),
                  ),
                  const SizedBox(height: 10),
                  _SettingsStatusRow(
                    label: context.tr('DeFi pools'),
                    value: _formatSyncTime(context, health.poolsSyncedAt),
                  ),
                  const SizedBox(height: 10),
                  _SettingsStatusRow(
                    label: context.tr('CeFi board'),
                    value: _formatSyncTime(context, health.cefiSyncedAt),
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
          title: context.tr('Compliance'),
          child: BaseCard(
            child: Text(
              context.tr(
                'Stably aggregates public data and local simulations only. It does not execute trades, custody assets, or provide investment advice.',
              ),
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

String _formatSyncTime(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return context.tr('Not synced yet');
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
