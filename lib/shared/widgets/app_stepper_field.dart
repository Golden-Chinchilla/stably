import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppStepperField extends StatelessWidget {
  const AppStepperField({
    super.key,
    required this.label,
    required this.value,
    this.onDecrease,
    this.onIncrease,
  });

  final String label;
  final String value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(CupertinoIcons.minus),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(CupertinoIcons.plus),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
