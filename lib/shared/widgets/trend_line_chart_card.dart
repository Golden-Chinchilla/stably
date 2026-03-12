import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';
import 'package:stably_app/shared/utils/formatters.dart';
import 'package:stably_app/shared/widgets/base_card.dart';

class TrendLineChartCard extends StatelessWidget {
  const TrendLineChartCard({
    super.key,
    required this.currentUsd,
    required this.prevDayUsd,
    required this.prevWeekUsd,
    required this.prevMonthUsd,
  });

  final double? currentUsd;
  final double? prevDayUsd;
  final double? prevWeekUsd;
  final double? prevMonthUsd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    // Ordered points: month ago, week ago, day ago, current
    final points = <double>[
      prevMonthUsd ?? 0,
      prevWeekUsd ?? 0,
      prevDayUsd ?? 0,
      currentUsd ?? 0,
    ];

    final hasData = points.every((val) => val > 0);

    if (!hasData) {
      return BaseCard(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Not enough historical data to generate trend.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      );
    }

    final double minVal = points.reduce((a, b) => a < b ? a : b);
    final double maxVal = points.reduce((a, b) => a > b ? a : b);
    final double padding = (maxVal - minVal) * 0.1;
    final double minY = (minVal - padding).clamp(0, double.infinity);
    final double maxY = maxVal + padding;

    final spots = [
      FlSpot(0, points[0]),
      FlSpot(1, points[1]),
      FlSpot(2, points[2]),
      FlSpot(3, points[3]),
    ];

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Supply trend', style: theme.textTheme.titleMedium),
              Text(
                _percentageChangeText(points.first, points.last),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: points.last >= points.first
                      ? tokens.success
                      : tokens.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 3 > 0
                      ? (maxY - minY) / 3
                      : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: tokens.border.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final style = theme.textTheme.labelMedium;
                        String text = '';
                        switch (value.toInt()) {
                          case 0:
                            text = '1M';
                            break;
                          case 1:
                            text = '1W';
                            break;
                          case 2:
                            text = '1D';
                            break;
                          case 3:
                            text = 'Now';
                            break;
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => tokens.surface,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          formatCurrency(spot.y),
                          theme.textTheme.labelLarge!.copyWith(
                            color: tokens.textPrimary,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: tokens.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: tokens.surface,
                          strokeWidth: 2,
                          strokeColor: tokens.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          tokens.primary.withValues(alpha: 0.3),
                          tokens.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _percentageChangeText(double oldVal, double newVal) {
    if (oldVal == 0) return '';
    final change = ((newVal - oldVal) / oldVal) * 100;
    final prefix = change >= 0 ? '+' : '';
    return '$prefix${change.toStringAsFixed(2)}% in 30d';
  }
}
