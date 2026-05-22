import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef ExternalUrlOpener = Future<void> Function(Uri uri);
typedef ToastPresenter = void Function(String message);
typedef DialogPresenter = Future<void> Function({
  required String title,
  required String message,
});
typedef ConfirmDialogPresenter = Future<bool> Function({
  required String title,
  required String message,
  required String confirmText,
  required String cancelText,
});
typedef BridgeEventEmitter = Future<void> Function(
  String event,
  Map<String, dynamic> detail,
);

class NativeBridge {
  NativeBridge({
    required this.openExternalUrl,
    required this.showToast,
    required this.showDialog,
    required this.showConfirmDialog,
    required this.emitBridgeEvent,
  });

  static const _responseEventName = 'EnteKottakkalResponse';
  static const _notificationChannelId = 'ente_kottakkal_default';
  static const _notificationChannelName = 'Ente Kottakkal';

  final ExternalUrlOpener openExternalUrl;
  final ToastPresenter showToast;
  final DialogPresenter showDialog;
  final ConfirmDialogPresenter showConfirmDialog;
  final BridgeEventEmitter emitBridgeEvent;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  var _localNotificationsInitialized = false;

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
        case 'confirm':
          unawaited(_handleConfirm(payload));
          break;
        case 'localNotification':
          unawaited(_handleLocalNotification(payload));
          break;
        case 'pushNotification':
          unawaited(_handlePushNotification(payload));
          break;
        case 'haptic':
          _handleHaptic(payload);
          break;
        case 'vibrate':
          unawaited(_handleVibrate(payload));
          break;
        case 'share':
          unawaited(_handleShare(payload));
          break;
        case 'exit':
          unawaited(_handleExit(payload));
          break;
        case 'storageSet':
          unawaited(_handleStorageSet(payload));
          break;
        case 'storageGet':
          unawaited(_handleStorageGet(payload));
          break;
        case 'storageRemove':
          unawaited(_handleStorageRemove(payload));
          break;
      }
    } catch (_) {
      showToast(message.message);
    }
  }

  // Opens phone, mail, browser, maps, and other external app links.
  void _handleOpenExternal(Map<String, dynamic> payload) {
    final url = payload['url'];
    final uri = url is String ? Uri.tryParse(url) : null;
    if (uri != null) unawaited(openExternalUrl(uri));
  }

  // Shows a lightweight native toast overlay in the Flutter shell.
  void _handleToast(Map<String, dynamic> payload) {
    final text = payload['message'];
    if (text is String && text.trim().isNotEmpty) {
      showToast(text.trim());
    }
  }

  // Shows a native alert dialog with one OK action.
  Future<void> _handleDialog(Map<String, dynamic> payload) {
    final title = payload['title'];
    final message = payload['message'];
    return showDialog(
      title: title is String ? title : 'Message',
      message: message is String ? message : '',
    );
  }

  // Shows a native confirm dialog and sends the result back to JavaScript.
  Future<void> _handleConfirm(Map<String, dynamic> payload) async {
    final requestId = _requestId(payload);
    final confirmed = await showConfirmDialog(
      title: _string(payload['title'], fallback: 'Confirm'),
      message: _string(payload['message']),
      confirmText: _string(payload['confirmText'], fallback: 'OK'),
      cancelText: _string(payload['cancelText'], fallback: 'Cancel'),
    );

    await _emitResult(
      'confirmResult',
      requestId: requestId,
      data: {'confirmed': confirmed},
    );
  }

  // Shows a local device notification from a JavaScript bridge request.
  Future<void> _handleLocalNotification(Map<String, dynamic> payload) async {
    await _ensureLocalNotificationsInitialized();

    final id = payload['id'] is int
        ? payload['id'] as int
        : DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final title = _string(payload['title'], fallback: 'Ente Kottakkal');
    final body = _string(payload['message']);

    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  // Placeholder for remote push notifications, which require Firebase setup.
  Future<void> _handlePushNotification(Map<String, dynamic> payload) async {
    await _emitResult(
      'pushNotificationResult',
      requestId: _requestId(payload),
      data: {
        'supported': false,
        'message':
            'Push notifications require Firebase project configuration before this bridge action can return a device token.',
      },
    );
    showToast('Push notifications require Firebase setup');
  }

  // Triggers Android/iOS haptic feedback using Flutter's built-in APIs.
  void _handleHaptic(Map<String, dynamic> payload) {
    switch (_string(payload['style'], fallback: 'medium')) {
      case 'light':
        HapticFeedback.lightImpact();
        break;
      case 'heavy':
        HapticFeedback.heavyImpact();
        break;
      case 'selection':
        HapticFeedback.selectionClick();
        break;
      case 'medium':
      default:
        HapticFeedback.mediumImpact();
        break;
    }
  }

  // Triggers device vibration when supported by the current device.
  Future<void> _handleVibrate(Map<String, dynamic> payload) async {
    if (await Vibration.hasVibrator() != true) return;

    final duration = payload['duration'];
    await Vibration.vibrate(
      duration: duration is int ? duration : 80,
    );
  }

  // Opens the native Android share sheet.
  Future<void> _handleShare(Map<String, dynamic> payload) async {
    final text = _string(payload['text']);
    if (text.trim().isEmpty) return;

    await Share.share(
      text,
      subject: _string(payload['subject']),
    );
  }

  // Exits the app when the user confirms the exit action from JavaScript.
   Future<void> _handleExit(Map<String, dynamic> payload) async {
    final requestId = _requestId(payload);
    final confirmed = await showConfirmDialog(
      title: 'Exit App',
      message: 'Are you sure you want to exit the app?',
      confirmText: 'Exit',
      cancelText: 'Cancel',
    );

    if (confirmed) {
      // exits app on Android; on iOS, this will just pop the current view which is the closest equivalent
      SystemNavigator.pop();
    } else {
      await _emitResult(
        'exitResult',
        requestId: requestId,
        data: {'exited': false},
      );
    }
  } 

  // Stores a string value in SharedPreferences.
  Future<void> _handleStorageSet(Map<String, dynamic> payload) async {
    final requestId = _requestId(payload);
    final key = payload['key'];
    if (key is! String || key.trim().isEmpty) {
      await _emitError('storageSetResult', requestId, 'Missing storage key');
      return;
    }

    final value = payload['value'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      value is String ? value : jsonEncode(value),
    );

    await _emitResult('storageSetResult', requestId: requestId);
  }

  // Reads a string value from SharedPreferences and sends it to JavaScript.
  Future<void> _handleStorageGet(Map<String, dynamic> payload) async {
    final requestId = _requestId(payload);
    final key = payload['key'];
    if (key is! String || key.trim().isEmpty) {
      await _emitError('storageGetResult', requestId, 'Missing storage key');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await _emitResult(
      'storageGetResult',
      requestId: requestId,
      data: {
        'key': key,
        'value': prefs.getString(key),
      },
    );
  }

  // Removes a value from SharedPreferences.
  Future<void> _handleStorageRemove(Map<String, dynamic> payload) async {
    final requestId = _requestId(payload);
    final key = payload['key'];
    if (key is! String || key.trim().isEmpty) {
      await _emitError('storageRemoveResult', requestId, 'Missing storage key');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await _emitResult('storageRemoveResult', requestId: requestId);
  }

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_localNotificationsInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );
    await _localNotifications.initialize(initializationSettings);

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _localNotificationsInitialized = true;
  }

  Future<void> _emitResult(
    String type, {
    String? requestId,
    Map<String, dynamic> data = const {},
  }) {
    return emitBridgeEvent(_responseEventName, {
      'type': type,
      if (requestId != null) 'requestId': requestId,
      ...data,
    });
  }

  Future<void> _emitError(
    String type,
    String? requestId,
    String message,
  ) {
    return _emitResult(
      type,
      requestId: requestId,
      data: {
        'error': message,
      },
    );
  }

  String? _requestId(Map<String, dynamic> payload) {
    final requestId = payload['requestId'];
    return requestId is String && requestId.trim().isNotEmpty
        ? requestId
        : null;
  }

  String _string(Object? value, {String fallback = ''}) {
    return value is String ? value : fallback;
  }
}
