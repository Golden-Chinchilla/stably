import 'package:flutter/material.dart';
class AppInteractiveCard extends StatelessWidget {
  const AppInteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 24,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        splashFactory: InkSparkle.splashFactory,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
