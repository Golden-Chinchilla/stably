import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_text_styles.dart';

class MetricText extends StatelessWidget {
  const MetricText(
    this.value, {
    super.key,
    this.size = 16,
    this.weight = FontWeight.w700,
    this.color,
  });

  final String value;
  final double size;
  final FontWeight weight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: AppTextStyles.metricStyle(
        context,
        size: size,
        weight: weight,
        color: color,
      ),
    );
  }
}
