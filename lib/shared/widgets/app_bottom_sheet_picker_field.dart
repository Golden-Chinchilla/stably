import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stably_app/shared/widgets/base_card.dart';

class AppBottomSheetPickerField<T> extends StatelessWidget {
  const AppBottomSheetPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.displayText,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final String displayText;
  final List<({T value, String label})> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showPicker(context),
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(displayText, style: theme.textTheme.bodyLarge),
                ),
                const Icon(CupertinoIcons.chevron_up_chevron_down, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: BaseCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 14),
              for (var index = 0; index < options.length; index++) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(options[index].label),
                  trailing: options[index].value == value
                      ? const Icon(CupertinoIcons.check_mark_circled_solid)
                      : null,
                  onTap: () => Navigator.of(context).pop(options[index].value),
                ),
                if (index != options.length - 1)
                  Divider(height: 1, color: Theme.of(context).dividerColor),
              ],
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      onChanged(selected);
    }
  }
}
