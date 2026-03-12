import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/metric_text.dart';

class AllocationSplitCard extends StatefulWidget {
  const AllocationSplitCard({super.key, required this.rows});

  final List<({String label, String value, Color color, int flex})> rows;

  @override
  State<AllocationSplitCard> createState() => _AllocationSplitCardState();
}

class _AllocationSplitCardState extends State<AllocationSplitCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Allocation pie split', style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: widget.rows.isEmpty
                ? const SizedBox.shrink()
                : PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            final newTouch = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                            if (newTouch != _touchedIndex && newTouch >= 0) {
                              HapticFeedback.selectionClick();
                            }
                            _touchedIndex = newTouch;
                          });
                        },
                      ),
                      startDegreeOffset: 180,
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 4,
                      centerSpaceRadius: 50,
                      sections: _showingSections(),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
          for (var index = 0; index < widget.rows.length; index++) ...[
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.rows[index].color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.rows[index].label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: _touchedIndex == index
                          ? FontWeight.w700
                          : null,
                    ),
                  ),
                ),
                MetricText(
                  widget.rows[index].value,
                  size: _touchedIndex == index ? 18 : 16,
                  color: _touchedIndex == index
                      ? widget.rows[index].color
                      : null,
                ),
              ],
            ),
            if (index != widget.rows.length - 1) ...[
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    return List.generate(widget.rows.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 45.0 : 35.0;

      final row = widget.rows[i];
      return PieChartSectionData(
        color: row.color,
        value: row.flex.toDouble(),
        title: '${row.flex}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}
