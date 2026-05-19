import 'package:flutter/material.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: Color(0xFF5F6368),
              ),
              const SizedBox(height: 24),
              const Text(
                'No internet connection',
                style: TextStyle(
                  color: Color(0xFF202124),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'ഇന്റർനെറ്റ് കണക്ഷൻ ലഭ്യമല്ല',
                style: TextStyle(
                  color: Color(0xFF202124),
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              const Text(
                'Please turn on Wi-Fi or mobile data and try again.',
                style: TextStyle(
                  color: Color(0xFF5F6368),
                  fontSize: 15,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'ദയവായി Wi-Fi അല്ലെങ്കിൽ മൊബൈൽ ഡാറ്റ ഓൺ ചെയ്ത് വീണ്ടും ശ്രമിക്കുക.',
                style: TextStyle(
                  color: Color(0xFF5F6368),
                  fontSize: 15,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry / വീണ്ടും ശ്രമിക്കുക'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
