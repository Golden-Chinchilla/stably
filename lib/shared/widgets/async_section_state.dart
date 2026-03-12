import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stably_app/shared/network/api_exception.dart';
import 'package:stably_app/shared/widgets/base_card.dart';

class AsyncSectionState extends StatelessWidget {
  const AsyncSectionState.loading({
    super.key,
    this.message = 'Loading...',
  })  : isError = false,
        onRetry = null;

  const AsyncSectionState.error({
    super.key,
    required this.message,
    this.onRetry,
  }) : isError = true;

  final String message;
  final bool isError;
  final VoidCallback? onRetry;

  static String presentError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Unable to load this section right now.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!isError)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  CupertinoIcons.exclamationmark_circle,
                  color: theme.colorScheme.error,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isError ? theme.colorScheme.error : null,
                  ),
                ),
              ),
            ],
          ),
          if (isError && onRetry != null) ...[
            const SizedBox(height: 14),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
