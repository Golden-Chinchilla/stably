import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';

class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -120,
          left: -60,
          child: _Orb(
            color: tokens.primary.withAlpha(68),
            size: 260,
          ),
        ),
        Positioned(
          top: 90,
          right: -90,
          child: _Orb(
            color: tokens.info.withAlpha(40),
            size: 220,
          ),
        ),
        Positioned(
          bottom: 120,
          left: 20,
          child: _Orb(
            color: tokens.success.withAlpha(26),
            size: 180,
          ),
        ),
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
