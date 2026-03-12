import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppSwitchRow extends StatelessWidget {
  const AppSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
        CupertinoSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}
