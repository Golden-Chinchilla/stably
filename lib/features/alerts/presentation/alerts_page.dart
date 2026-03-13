import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/app/l10n/app_localizations.dart';
import 'package:stably_app/features/alerts/data/models/alert_rule.dart';
import 'package:stably_app/features/alerts/presentation/providers/alert_rule_providers.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';
import 'package:stably_app/shared/utils/formatters.dart';
import 'package:stably_app/shared/widgets/alert_rule_card.dart';
import 'package:stably_app/shared/widgets/app_amount_field.dart';
import 'package:stably_app/shared/widgets/app_bottom_sheet_picker_field.dart';
import 'package:stably_app/shared/widgets/app_empty_state.dart';
import 'package:stably_app/shared/widgets/app_feedback.dart';
import 'package:stably_app/shared/widgets/app_filter_chip.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/app_segmented_control.dart';
import 'package:stably_app/shared/widgets/app_skeleton.dart';
import 'package:stably_app/shared/widgets/app_switch_row.dart';
import 'package:stably_app/shared/widgets/app_text_field.dart';
import 'package:stably_app/shared/widgets/async_section_state.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';
import 'package:stably_app/shared/widgets/placeholder_metric_card.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(alertRulesControllerProvider.future),
      ref.refresh(yieldPoolsProvider.future),
    ]);
  }

  Future<void> _openRuleForm(
    BuildContext context,
    WidgetRef ref, {
    AlertRule? initialRule,
  }) async {
    final pools = ref
        .read(yieldPoolsProvider)
        .maybeWhen(data: (items) => items, orElse: () => const <YieldPool>[]);

    final result = await showModalBottomSheet<AlertRule>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AlertRuleFormSheet(
        initialRule: initialRule,
        livePools: pools,
      ),
    );

    if (result == null) {
      return;
    }

    final controller = ref.read(alertRulesControllerProvider.notifier);
    if (initialRule == null) {
      await controller.addRule(result);
      if (context.mounted) {
        AppFeedback.showSuccess(context, context.tr('Alert rule saved.'));
      }
    } else {
      await controller.updateRule(result);
      if (context.mounted) {
        AppFeedback.showSuccess(context, context.tr('Alert rule updated.'));
      }
    }
  }

  Future<void> _deleteRule(
    BuildContext context,
    WidgetRef ref,
    AlertRule rule,
  ) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(context.tr('Delete alert rule')),
        content: Text('Remove "${rule.title}" from local alert rules?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('Cancel')),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.tr('Delete')),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(alertRulesControllerProvider.notifier).deleteRule(rule.id);
      if (context.mounted) {
        AppFeedback.showInfo(context, context.tr('Alert rule deleted.'));
      }
    }
  }

  Future<void> _toggleRuleEnabled(
    BuildContext context,
    WidgetRef ref,
    AlertRule rule,
  ) async {
    final nextRule = rule.copyWith(enabled: !rule.enabled);
    await ref.read(alertRulesControllerProvider.notifier).updateRule(nextRule);
    if (context.mounted) {
      if (nextRule.enabled) {
        AppFeedback.showSuccess(context, context.tr('Alert rule enabled.'));
      } else {
        AppFeedback.showInfo(context, context.tr('Alert rule paused.'));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(alertRulesControllerProvider);
    final poolsAsync = ref.watch(yieldPoolsProvider);

    return AppPageScaffold(
      title: context.tr('Alerts'),
      onRefresh: () => _refresh(ref),
      children: [
        SectionBlock(
          title: context.tr('Alerts Overview'),
          child: rulesAsync.when(
            data: (rules) {
              final enabledRules = rules.where((rule) => rule.enabled).length;

              return HighlightPanel(
                title: rules.isEmpty
                    ? 'Add your first alert rule.'
                    : 'Track current yield thresholds and promo watches from one ruleset.',
                value: '$enabledRules enabled',
                secondaryValue: '${rules.length} total',
                tag: rules.isEmpty ? 'Empty' : 'Active',
                tone: StatusTagTone.warning,
                footer: Row(
                  children: [
                    Expanded(
                      child: PillButton(
                        label: context.tr('Add rule'),
                        icon: CupertinoIcons.add,
                        onPressed: () => _openRuleForm(context, ref),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const AppHighlightPanelSkeleton(showFooter: true),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: context.tr('Alerts Snapshot'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PillButton(
                label: context.tr('Add'),
                icon: CupertinoIcons.add,
                compact: true,
                onPressed: () => _openRuleForm(context, ref),
              ),
              const SizedBox(width: 8),
              PillButton(
                label: context.tr('Clear'),
                icon: CupertinoIcons.trash,
                compact: true,
                isPrimary: false,
                onPressed: () async {
                  await ref
                      .read(alertRulesControllerProvider.notifier)
                      .clearRules();
                  if (context.mounted) {
                    AppFeedback.showInfo(
                      context,
                      context.tr('Alert rules cleared.'),
                    );
                  }
                },
              ),
            ],
          ),
          child: rulesAsync.when(
            data: (rules) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InsightTile(
                        icon: CupertinoIcons.bell,
                        label: 'Alert rules',
                        value: '${rules.length}',
                        caption:
                            'Local monitoring rules currently stored on device.',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InsightTile(
                        icon: CupertinoIcons.checkmark_seal_fill,
                        label: 'Enabled',
                        value: '${rules.where((rule) => rule.enabled).length}',
                        caption: 'Rules currently active on this device.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                poolsAsync.when(
                  data: (pools) => PlaceholderMetricCard(
                    label: 'Tracked yield pools',
                    value: '${pools.length} pools',
                    caption: pools.isEmpty
                        ? 'No tracked yield pools loaded yet.'
                        : 'Current market lead: ${pools.first.project} at ${formatPercent(pools.first.apy)}',
                    tag: 'Current',
                    tone: StatusTagTone.warning,
                  ),
                  loading: () => const AppMetricCardSkeleton(),
                  error: (error, _) => AsyncSectionState.error(
                    message: AsyncSectionState.presentError(error),
                    onRetry: () => _refresh(ref),
                  ),
                ),
              ],
            ),
            loading: () => const Column(
              children: [
                Row(
                  children: [
                    Expanded(child: AppInsightTileSkeleton()),
                    SizedBox(width: 16),
                    Expanded(child: AppInsightTileSkeleton()),
                  ],
                ),
                SizedBox(height: 16),
                AppMetricCardSkeleton(),
              ],
            ),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: context.tr('Alert Rules'),
          child: rulesAsync.when(
            data: (rules) {
              if (rules.isEmpty) {
                return AppEmptyState(
                  title: context.tr('No alert rules yet'),
                  description:
                      'Add a rule manually to monitor current market thresholds on this device.',
                  icon: CupertinoIcons.bell,
                  actionLabel: context.tr('Add rule'),
                  onAction: () => _openRuleForm(context, ref),
                );
              }

              final pools = poolsAsync.maybeWhen(
                data: (items) => items,
                orElse: () => const <YieldPool>[],
              );

              final sortedRules = [...rules]..sort(_compareRules);

              return Column(
                children: [
                  for (var index = 0; index < sortedRules.length; index++) ...[
                    AlertRuleCard(
                      title: sortedRules[index].title,
                      description: _ruleDescription(sortedRules[index], pools),
                      frequency: sortedRules[index].frequency,
                      tone: _ruleTone(sortedRules[index]),
                      statusLabel: sortedRules[index].enabled
                          ? 'Enabled'
                          : 'Paused',
                      secondaryTags: [
                        if (sortedRules[index].symbol != null)
                          sortedRules[index].symbol!,
                        if (sortedRules[index].chain != null)
                          sortedRules[index].chain!,
                        if (sortedRules[index].threshold != null)
                          '< ${sortedRules[index].threshold!.toStringAsFixed(2)}%',
                      ],
                      footer: Row(
                        children: [
                          Expanded(
                            child: PillButton(
                              label: sortedRules[index].enabled
                                  ? context.tr('Pause')
                                  : context.tr('Enable'),
                              icon: sortedRules[index].enabled
                                  ? CupertinoIcons.pause
                                  : CupertinoIcons.play_fill,
                              compact: true,
                              isPrimary: false,
                              onPressed: () => _toggleRuleEnabled(
                                context,
                                ref,
                                sortedRules[index],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PillButton(
                              label: context.tr('Edit'),
                              icon: CupertinoIcons.pencil,
                              compact: true,
                              isPrimary: false,
                              onPressed: () => _openRuleForm(
                                context,
                                ref,
                                initialRule: sortedRules[index],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PillButton(
                              label: context.tr('Delete'),
                              icon: CupertinoIcons.delete,
                              compact: true,
                              onPressed: () => _deleteRule(
                                context,
                                ref,
                                sortedRules[index],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index != sortedRules.length - 1)
                      const SizedBox(height: 16),
                  ],
                ],
              );
            },
            loading: () => const AppListSkeleton(items: 3),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: context.tr('Alert Notes'),
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'Alerts suggest review, not action',
                description:
                    'The product surfaces information but does not execute transfers or recommendations.',
                tone: StatusTagTone.info,
              ),
              const SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Short-lived promos may expire before action',
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

class _AlertRuleFormSheet extends StatefulWidget {
  const _AlertRuleFormSheet({
    this.initialRule,
    required this.livePools,
  });

  final AlertRule? initialRule;
  final List<YieldPool> livePools;

  @override
  State<_AlertRuleFormSheet> createState() => _AlertRuleFormSheetState();
}

class _AlertRuleFormSheetState extends State<_AlertRuleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late AlertRuleType _type;
  late String _frequency;
  late bool _enabled;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _symbolController;
  late final TextEditingController _chainController;
  late final TextEditingController _thresholdController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRule;
    _type = initial?.type ?? AlertRuleType.yieldBelow;
    _frequency = initial?.frequency ?? 'Instant';
    _enabled = initial?.enabled ?? true;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _symbolController = TextEditingController(text: initial?.symbol ?? '');
    _chainController = TextEditingController(text: initial?.chain ?? '');
    _thresholdController = TextEditingController(
      text: initial?.threshold == null
          ? ''
          : initial!.threshold!.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _symbolController.dispose();
    _chainController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = widget.livePools.take(6).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: BaseCard(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.initialRule == null
                      ? context.tr('Add rule')
                      : context.tr('Edit'),
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Store a local rule for yield thresholds or promo watches. Current market matches can be used to prefill symbols and chains.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Text('Rule type', style: theme.textTheme.titleSmall),
                const SizedBox(height: 10),
                AppSegmentedControl<AlertRuleType>(
                  value: _type,
                  options: [
                    for (final type in AlertRuleType.values)
                      (value: type, label: _typeLabel(type)),
                  ],
                  onChanged: (value) => setState(() => _type = value),
                ),
                const SizedBox(height: 16),
                if (suggestions.isNotEmpty) ...[
                  Text('Market matches', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final pool in suggestions)
                        AppFilterChip(
                          label: '${pool.symbol} · ${pool.project}',
                          onTap: () {
                            _symbolController.text = pool.symbol;
                            _chainController.text = pool.chain;
                            if (_titleController.text.trim().isEmpty) {
                              _titleController.text =
                                  '${pool.symbol} rule on ${pool.project}';
                            }
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                AppTextField(
                  controller: _titleController,
                  label: 'Title',
                  placeholder: 'USDC yield falls below 4%',
                  validator: _requiredField,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  placeholder: 'Notify when the current threshold is breached.',
                  validator: _requiredField,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _symbolController,
                        label: 'Stablecoin',
                        placeholder: 'USDC',
                        validator: _requiresSymbol(_type)
                            ? _requiredField
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _chainController,
                        label: 'Chain',
                        placeholder: 'Ethereum',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppAmountField(
                        controller: _thresholdController,
                        label: 'Threshold (%)',
                        placeholder: '4.00',
                        validator: _requiresThreshold(_type)
                            ? _positiveNumberField
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppBottomSheetPickerField<String>(
                        label: 'Frequency',
                        value: _frequency,
                        displayText: _frequency,
                        options: const [
                          (value: 'Instant', label: 'Instant'),
                          (value: 'Daily', label: 'Daily'),
                          (value: 'Weekly', label: 'Weekly'),
                        ],
                        onChanged: (value) =>
                            setState(() => _frequency = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppSwitchRow(
                  label: 'Enabled',
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: PillButton(
                        label: context.tr('Cancel'),
                        isPrimary: false,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PillButton(
                        label: widget.initialRule == null
                            ? context.tr('Save')
                            : context.tr('Update'),
                        icon: CupertinoIcons.check_mark,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rule = AlertRule(
      id: widget.initialRule?.id ?? '${DateTime.now().microsecondsSinceEpoch}',
      type: _type,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      frequency: _frequency,
      enabled: _enabled,
      symbol: _symbolController.text.trim().isEmpty
          ? null
          : _symbolController.text.trim().toUpperCase(),
      chain: _chainController.text.trim().isEmpty
          ? null
          : _chainController.text.trim(),
      threshold: _thresholdController.text.trim().isEmpty
          ? null
          : double.parse(_thresholdController.text.trim()),
    );

    Navigator.of(context).pop(rule);
  }
}

String _typeLabel(AlertRuleType type) {
  return switch (type) {
    AlertRuleType.yieldBelow => 'Yield below',
    AlertRuleType.newPromoWatch => 'Promo watch',
  };
}

bool _requiresSymbol(AlertRuleType type) {
  return switch (type) {
    AlertRuleType.yieldBelow => true,
    AlertRuleType.newPromoWatch => true,
  };
}

bool _requiresThreshold(AlertRuleType type) {
  return switch (type) {
    AlertRuleType.yieldBelow => true,
    AlertRuleType.newPromoWatch => false,
  };
}

String _ruleDescription(AlertRule rule, List<YieldPool> pools) {
  switch (rule.type) {
    case AlertRuleType.yieldBelow:
      return '${rule.description} Current threshold: ${rule.threshold?.toStringAsFixed(2) ?? '--'}%.';
    case AlertRuleType.newPromoWatch:
      final matched = pools
          .where((pool) => pool.symbol == rule.symbol)
          .take(1)
          .toList();
      if (matched.isEmpty) {
        return rule.description;
      }
      return '${rule.description} Current live context: ${matched.first.project} on ${matched.first.chain} at ${formatPercent(matched.first.apy)}.';
  }
}

StatusTagTone _ruleTone(AlertRule rule) {
  return switch (rule.type) {
    AlertRuleType.yieldBelow => StatusTagTone.info,
    AlertRuleType.newPromoWatch => StatusTagTone.success,
  };
}

String? _requiredField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String? _positiveNumberField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed <= 0) {
    return 'Enter a value greater than 0';
  }
  return null;
}

int _compareRules(AlertRule left, AlertRule right) {
  final enabledComparison = (right.enabled ? 1 : 0).compareTo(
    left.enabled ? 1 : 0,
  );
  if (enabledComparison != 0) {
    return enabledComparison;
  }

  final typeComparison = left.type.index.compareTo(right.type.index);
  if (typeComparison != 0) {
    return typeComparison;
  }

  return left.title.toLowerCase().compareTo(right.title.toLowerCase());
}
