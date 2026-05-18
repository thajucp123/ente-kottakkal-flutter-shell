import 'dart:async';
import 'dart:convert';

import 'package:webview_flutter/webview_flutter.dart';

typedef ExternalUrlOpener = Future<void> Function(Uri uri);
typedef ToastPresenter = void Function(String message);
typedef DialogPresenter = Future<void> Function({
  required String title,
  required String message,
});

class NativeBridge {
  const NativeBridge({
    required this.openExternalUrl,
    required this.showToast,
    required this.showDialog,
  });

  final ExternalUrlOpener openExternalUrl;
  final ToastPresenter showToast;
  final DialogPresenter showDialog;

  void handleMessage(JavaScriptMessage message) {
    try {
      final payload = jsonDecode(message.message);
      if (payload is! Map<String, dynamic>) return;

      switch (payload['type']) {
        case 'openExternal':
          _handleOpenExternal(payload);
          break;
        case 'toast':
          _handleToast(payload);
          break;
        case 'dialog':
          unawaited(_handleDialog(payload));
          break;
      }
    } catch (_) {
      showToast(message.message);
    }
  }

  void _handleOpenExternal(Map<String, dynamic> payload) {
    final url = payload['url'];
    final uri = url is String ? Uri.tryParse(url) : null;
    if (uri != null) unawaited(openExternalUrl(uri));
  }

  void _handleToast(Map<String, dynamic> payload) {
    final text = payload['message'];
    if (text is String && text.trim().isNotEmpty) {
      showToast(text.trim());
    }
  }

  Future<void> _handleDialog(Map<String, dynamic> payload) {
    final title = payload['title'];
    final message = payload['message'];
    return showDialog(
      title: title is String ? title : 'Message',
      message: message is String ? message : '',
    );
  }
}
