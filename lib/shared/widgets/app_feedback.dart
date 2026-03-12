import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';

class AppFeedback {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, _FeedbackTone.success);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, _FeedbackTone.info);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, _FeedbackTone.error);
  }

  static void _show(BuildContext context, String message, _FeedbackTone tone) {
    final tokens = context.tokens;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: switch (tone) {
          _FeedbackTone.success => tokens.success,
          _FeedbackTone.info => tokens.info,
          _FeedbackTone.error => tokens.warning,
        },
      ),
    );
  }
}

enum _FeedbackTone { success, info, error }
