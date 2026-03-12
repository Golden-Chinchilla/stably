import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';
import 'package:stably_app/features/portfolio/data/models/portfolio_position.dart';
import 'package:stably_app/features/portfolio/presentation/providers/portfolio_providers.dart';
import 'package:stably_app/shared/utils/formatters.dart';
import 'package:stably_app/shared/widgets/app_amount_field.dart';
import 'package:stably_app/shared/widgets/app_empty_state.dart';
import 'package:stably_app/shared/widgets/app_feedback.dart';
import 'package:stably_app/shared/widgets/app_filter_chip.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/app_skeleton.dart';
import 'package:stably_app/shared/widgets/app_text_field.dart';
import 'package:stably_app/shared/widgets/async_section_state.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/info_list_card.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/metric_text.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';
import 'package:stably_app/shared/widgets/placeholder_metric_card.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(portfolioControllerProvider.future),
      ref.refresh(yieldPoolsProvider.future),
    ]);
  }

  Future<void> _openPositionForm(
    BuildContext context,
    WidgetRef ref, {
    PortfolioPosition? initialPosition,
  }) async {
    final livePools = ref
        .read(yieldPoolsProvider)
        .maybeWhen(data: (pools) => pools, orElse: () => const <YieldPool>[]);

    final result = await showModalBottomSheet<PortfolioPosition>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PortfolioPositionFormSheet(
        initialPosition: initialPosition,
        livePools: livePools,
      ),
    );

    if (result == null) {
      return;
    }

    final controller = ref.read(portfolioControllerProvider.notifier);
    if (initialPosition == null) {
      await controller.addPosition(result);
      if (context.mounted) {
        AppFeedback.showSuccess(context, 'Position saved.');
      }
    } else {
      await controller.updatePosition(result);
      if (context.mounted) {
        AppFeedback.showSuccess(context, 'Position updated.');
      }
    }
  }

  Future<void> _deletePosition(
    BuildContext context,
    WidgetRef ref,
    PortfolioPosition position,
  ) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete position'),
        content: Text(
          'Remove ${position.symbol} on ${position.platform} from tracked positions?',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(portfolioControllerProvider.notifier)
          .deletePosition(position.id);
      if (context.mounted) {
        AppFeedback.showInfo(context, 'Position deleted.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioControllerProvider);
    final poolsAsync = ref.watch(yieldPoolsProvider);
    final livePools = poolsAsync.maybeWhen(
      data: (pools) => pools,
      orElse: () => const <YieldPool>[],
    );

    return AppPageScaffold(
      title: 'Portfolio',
      onRefresh: () => _refresh(ref),
      children: [
        SectionBlock(
          title: 'Portfolio Overview',
          child: portfolioAsync.when(
            data: (positions) {
              final summary = _buildSummary(positions, livePools);

              return HighlightPanel(
                title: positions.isEmpty
                    ? 'Add your first tracked position.'
                    : 'Track ${positions.length} positions with live APY context.',
                value: formatCurrency(summary.totalAmount),
                secondaryValue: formatCurrency(summary.estimatedAnnualCarry),
                tag: positions.isEmpty ? 'Empty' : 'Tracking',
                footer: Row(
                  children: [
                    Expanded(
                      child: PillButton(
                        label: 'Add position',
                        icon: CupertinoIcons.add,
                        onPressed: () => _openPositionForm(context, ref),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PillButton(
                        label: positions.isEmpty ? 'Load demo' : 'Reload demo',
                        icon: CupertinoIcons.arrow_down_doc,
                        isPrimary: false,
                        onPressed: () async {
                          await ref
                              .read(portfolioControllerProvider.notifier)
                              .seedDemoFromLivePools();
                          if (context.mounted) {
                            AppFeedback.showInfo(
                              context,
                              'Demo positions loaded.',
                            );
                          }
                        },
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
          title: 'Portfolio Snapshot',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PillButton(
                label: 'Add',
                icon: CupertinoIcons.add,
                compact: true,
                onPressed: () => _openPositionForm(context, ref),
              ),
              const SizedBox(width: 8),
              PillButton(
                label: 'Clear',
                icon: CupertinoIcons.trash,
                isPrimary: false,
                compact: true,
                onPressed: () async {
                  await ref
                      .read(portfolioControllerProvider.notifier)
                      .clearAll();
                  if (context.mounted) {
                    AppFeedback.showInfo(context, 'Tracked positions cleared.');
                  }
                },
              ),
            ],
          ),
          child: portfolioAsync.when(
            data: (positions) {
              final summary = _buildSummary(positions, livePools);
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InsightTile(
                          icon: CupertinoIcons.money_dollar_circle,
                          label: 'Blended APY',
                          value: formatPercent(summary.blendedApy),
                          caption: 'Weighted from the tracked position mix.',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InsightTile(
                          icon: CupertinoIcons.clock,
                          label: 'Tracked positions',
                          value: '${positions.length}',
                          caption: 'Locally saved entries.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PlaceholderMetricCard(
                    label: 'Estimated annual carry',
                    value:
                        '${summary.estimatedAnnualCarry.toStringAsFixed(2)} USDC',
                    caption:
                        'Directional estimate using the current APY tied to each tracked position.',
                    tag: 'Local',
                    tone: StatusTagTone.success,
                  ),
                  const SizedBox(height: 16),
                  InfoListCard(
                    title: 'Portfolio fields',
                    rows: [
                      (
                        label: 'Tracked capital',
                        value: formatCurrency(summary.totalAmount),
                        hint: null,
                      ),
                      (
                        label: 'Estimated annual carry',
                        value: formatCurrency(summary.estimatedAnnualCarry),
                        hint: null,
                      ),
                      (
                        label: 'Highest APY',
                        value: formatPercent(summary.highestApy),
                        hint: null,
                      ),
                    ],
                  ),
                ],
              );
            },
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
                SizedBox(height: 16),
                AppInfoListSkeleton(rows: 3),
              ],
            ),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: 'Tracked Positions',
          child: portfolioAsync.when(
            data: (positions) {
              if (positions.isEmpty) {
                return AppEmptyState(
                  title: 'No tracked positions yet',
                  description:
                      'Add a position manually or load a demo set from the current yield pool board.',
                  icon: CupertinoIcons.briefcase,
                  actionLabel: 'Add position',
                  onAction: () => _openPositionForm(context, ref),
                );
              }

              final cards = <Widget>[
                for (var index = 0; index < positions.length; index++) ...[
                  _PortfolioPositionCard(
                    position: positions[index],
                    livePool: _findMatchingPool(positions[index], livePools),
                    onEdit: () => _openPositionForm(
                      context,
                      ref,
                      initialPosition: positions[index],
                    ),
                    onDelete: () =>
                        _deletePosition(context, ref, positions[index]),
                  ),
                  if (index != positions.length - 1) const SizedBox(height: 16),
                ],
              ];

              return Column(
                children: cards
                    .animate(interval: 50.ms)
                    .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                    .slideY(
                      begin: 0.1,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),
              );
            },
            loading: () => const AppListSkeleton(items: 3),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        const SectionBlock(
          title: 'Portfolio Notes',
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'Balances are manually recorded',
                description:
                    'The app does not read exchange accounts or on-chain wallets in this version.',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Projected carry is directional',
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

class _PortfolioPositionCard extends StatelessWidget {
  const _PortfolioPositionCard({
    required this.position,
    required this.onEdit,
    required this.onDelete,
    this.livePool,
  });

  final PortfolioPosition position;
  final YieldPool? livePool;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apy = livePool?.apy ?? position.apy;

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(position.platform, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${position.symbol} · ${position.chain}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              MetricText(formatPercent(apy), size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            livePool == null
                ? 'Tracked locally. No live yield pool match was found for this position.'
                : 'Matched against the current yield pool board for updated APY context.',
            style: theme.textTheme.bodySmall,
          ),
          if ((position.note ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(position.note!.trim(), style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusTag(label: formatCurrency(position.amount)),
              StatusTag(label: position.symbol),
              StatusTag(label: position.chain),
              StatusTag(
                label: livePool == null ? 'Manual APY' : 'Live APY',
                tone: livePool == null
                    ? StatusTagTone.warning
                    : StatusTagTone.info,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: 'Edit',
                  icon: CupertinoIcons.pencil,
                  isPrimary: false,
                  compact: true,
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(
                  label: 'Delete',
                  icon: CupertinoIcons.delete,
                  compact: true,
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortfolioSummary {
  const _PortfolioSummary({
    required this.totalAmount,
    required this.estimatedAnnualCarry,
    required this.blendedApy,
    required this.highestApy,
  });

  final double totalAmount;
  final double estimatedAnnualCarry;
  final double blendedApy;
  final double highestApy;
}

class _PortfolioPositionFormSheet extends StatefulWidget {
  const _PortfolioPositionFormSheet({
    this.initialPosition,
    required this.livePools,
  });

  final PortfolioPosition? initialPosition;
  final List<YieldPool> livePools;

  @override
  State<_PortfolioPositionFormSheet> createState() =>
      _PortfolioPositionFormSheetState();
}

class _PortfolioPositionFormSheetState
    extends State<_PortfolioPositionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _platformController;
  late final TextEditingController _symbolController;
  late final TextEditingController _chainController;
  late final TextEditingController _amountController;
  late final TextEditingController _apyController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPosition;
    _platformController = TextEditingController(text: initial?.platform ?? '');
    _symbolController = TextEditingController(text: initial?.symbol ?? '');
    _chainController = TextEditingController(text: initial?.chain ?? '');
    _amountController = TextEditingController(
      text: initial == null ? '' : initial.amount.toStringAsFixed(2),
    );
    _apyController = TextEditingController(
      text: initial == null ? '' : initial.apy.toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: initial?.note ?? '');
  }

  @override
  void dispose() {
    _platformController.dispose();
    _symbolController.dispose();
    _chainController.dispose();
    _amountController.dispose();
    _apyController.dispose();
    _noteController.dispose();
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
                  widget.initialPosition == null
                      ? 'Add position'
                      : 'Edit position',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Store a local position for a stablecoin, platform, and chain.',
                  style: theme.textTheme.bodySmall,
                ),
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Quick suggestions', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final pool in suggestions)
                        AppFilterChip(
                          label: '${pool.symbol} · ${pool.project}',
                          onTap: () {
                            _platformController.text = pool.project;
                            _symbolController.text = pool.symbol;
                            _chainController.text = pool.chain;
                            _apyController.text = (pool.apy ?? 0)
                                .toStringAsFixed(2);
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                AppTextField(
                  controller: _platformController,
                  label: 'Platform',
                  placeholder: 'Aave',
                  validator: _requiredField,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _symbolController,
                  label: 'Stablecoin',
                  placeholder: 'USDC',
                  validator: _requiredField,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _chainController,
                  label: 'Chain',
                  placeholder: 'Ethereum',
                  validator: _requiredField,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppAmountField(
                        controller: _amountController,
                        label: 'Amount',
                        placeholder: '5000',
                        validator: _positiveNumberField,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppAmountField(
                        controller: _apyController,
                        label: 'Stored APY',
                        placeholder: '6.25',
                        validator: _nonNegativeNumberField,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _noteController,
                  label: 'Note',
                  placeholder: 'Optional memo',
                  maxLines: 3,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: PillButton(
                        label: 'Cancel',
                        isPrimary: false,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PillButton(
                        label: widget.initialPosition == null
                            ? 'Save'
                            : 'Update',
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

    final initial = widget.initialPosition;
    final position = PortfolioPosition(
      id: initial?.id ?? '${DateTime.now().microsecondsSinceEpoch}',
      platform: _platformController.text.trim(),
      symbol: _symbolController.text.trim().toUpperCase(),
      chain: _chainController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      apy: double.parse(_apyController.text.trim()),
      createdAt: initial?.createdAt ?? DateTime.now().toIso8601String(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    Navigator.of(context).pop(position);
  }
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

String? _nonNegativeNumberField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed < 0) {
    return 'Enter a valid APY';
  }
  return null;
}

_PortfolioSummary _buildSummary(
  List<PortfolioPosition> positions,
  List<YieldPool> pools,
) {
  if (positions.isEmpty) {
    return const _PortfolioSummary(
      totalAmount: 0,
      estimatedAnnualCarry: 0,
      blendedApy: 0,
      highestApy: 0,
    );
  }

  final totalAmount = positions.fold<double>(
    0,
    (sum, item) => sum + item.amount,
  );
  var estimatedAnnualCarry = 0.0;
  var highestApy = 0.0;

  for (final position in positions) {
    final livePool = _findMatchingPool(position, pools);
    final effectiveApy = livePool?.apy ?? position.apy;
    estimatedAnnualCarry += position.amount * (effectiveApy / 100);
    highestApy = effectiveApy > highestApy
        ? effectiveApy.toDouble()
        : highestApy;
  }

  final blendedApy = totalAmount == 0
      ? 0.0
      : (estimatedAnnualCarry / totalAmount) * 100;

  return _PortfolioSummary(
    totalAmount: totalAmount,
    estimatedAnnualCarry: estimatedAnnualCarry,
    blendedApy: blendedApy,
    highestApy: highestApy,
  );
}

YieldPool? _findMatchingPool(
  PortfolioPosition position,
  List<YieldPool> pools,
) {
  for (final pool in pools) {
    if (pool.symbol.toUpperCase() == position.symbol.toUpperCase() &&
        pool.chain == position.chain &&
        pool.project == position.platform) {
      return pool;
    }
  }

  for (final pool in pools) {
    if (pool.symbol.toUpperCase() == position.symbol.toUpperCase()) {
      return pool;
    }
  }

  return null;
}
