import 'package:flutter/material.dart';

class AppToast {
  const AppToast._();

  static OverlayEntry show({
    required BuildContext context,
    required String message,
    required OverlayEntry? currentOverlay,
    required VoidCallback onDismissed,
  }) {
    currentOverlay?.remove();

    late final OverlayEntry overlay;
    overlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
          child: IgnorePointer(
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlay);
    Future.delayed(const Duration(seconds: 2), () {
      if (!overlay.mounted) return;
      overlay.remove();
      onDismissed();
    });

    return overlay;
  }
}
