import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/app/providers/app_state_providers.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: 'Settings',
      subtitle: 'Theme, trust surfaces, and outward links live here.',
      showSettingsButton: false,
      children: [
        const SectionBlock(
          title: 'Product tone',
          subtitle:
              'Settings should still feel designed, not like a utility page.',
          child: HighlightPanel(
            eyebrow: 'Preferences',
            title: 'Switch between warm daylight and quiet luxury dark mode.',
            description:
                'The settings surface holds appearance, compliance, and support content while keeping the same refined card language as the rest of the app.',
            value: '2 themes',
            secondaryValue: '0 clutter',
            tag: 'Refined',
            tone: StatusTagTone.info,
          ),
        ),
        SectionBlock(
          title: 'Appearance',
          subtitle: 'Keep the app calm in both light and dark environments.',
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
          title: 'Compliance',
          subtitle: 'Risk framing stays explicit and easy to revisit.',
          child: BaseCard(
            child: Text(
              'Stably only aggregates public data and simulations. It does not execute trades, custody assets, or provide investment advice.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        const SectionBlock(
          title: 'Resources',
          subtitle: 'Reserve space for docs, legal pages, and external links.',
          child: Row(
            children: [
              Expanded(
                child: PillButton(
                  label: 'Cloudflare Docs',
                  icon: CupertinoIcons.arrow_up_right,
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
