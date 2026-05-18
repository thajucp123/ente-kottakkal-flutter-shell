import 'package:flutter/material.dart';

class PageLoader extends StatelessWidget {
  const PageLoader({required this.progress, super.key});

  final int progress;

  @override
  Widget build(BuildContext context) {
    final value = progress <= 0 ? null : progress / 100;

    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(
          color: Colors.white.withValues(alpha: 0.72),
          child: Center(
            child: SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(value: value, strokeWidth: 3),
            ),
          ),
        ),
      ),
    );
  }
}
