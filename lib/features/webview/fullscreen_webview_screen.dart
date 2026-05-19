import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/app_config.dart';
import '../../services/external_link_service.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/offline_page.dart';
import '../../widgets/page_loader.dart';
import 'native_bridge.dart';
import 'webview_link_handler.dart';

class FullscreenWebViewScreen extends StatefulWidget {
  const FullscreenWebViewScreen({super.key});

  @override
  State<FullscreenWebViewScreen> createState() =>
      _FullscreenWebViewScreenState();
}

class _FullscreenWebViewScreenState extends State<FullscreenWebViewScreen> {
  static const _rapidBackWindow = Duration(milliseconds: 700);
  static const _exitConfirmWindow = Duration(seconds: 2);

  late final WebViewController _controller;
  late final NativeBridge _nativeBridge;

  DateTime? _lastBackPressedAt;
  DateTime? _exitPromptShownAt;
  OverlayEntry? _toastOverlay;
  var _isLoading = true;
  var _loadingProgress = 0;
  var _hasPageLoadError = false;

  @override
  void initState() {
    super.initState();

    _nativeBridge = NativeBridge(
      openExternalUrl: _openExternalUrl,
      showToast: _showToast,
      showDialog: _showNativeDialog,
      showConfirmDialog: _showConfirmDialog,
      emitBridgeEvent: _emitBridgeEvent,
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        AppConfig.javaScriptChannelName,
        onMessageReceived: _nativeBridge.handleMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigationRequest,
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _loadingProgress = 0;
              _hasPageLoadError = false;
            });
          },
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
              _isLoading = progress < 100;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _loadingProgress = 100;
            });
            unawaited(WebViewLinkHandler.install(_controller));
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) return;
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _hasPageLoadError = true;
            });
          },
        ),
      );

    unawaited(_loadInitialRequest());
  }

  Future<void> _loadInitialRequest() async {
    final webViewUserAgent = AppConfig.webViewUserAgent;
    if (webViewUserAgent != null) {
      await _controller.setUserAgent(webViewUserAgent);
    }

    await _controller.loadRequest(
      AppConfig.initialUri,
      headers: AppConfig.initialHeaders,
    );
  }

  Future<void> _retryInitialRequest() async {
    setState(() {
      _isLoading = true;
      _loadingProgress = 0;
      _hasPageLoadError = false;
    });

    await _controller.loadRequest(
      AppConfig.initialUri,
      headers: AppConfig.initialHeaders,
    );
  }

  @override
  void dispose() {
    _toastOverlay?.remove();
    _toastOverlay = null;
    super.dispose();
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri != null && ExternalLinkService.shouldOpenExternally(uri)) {
      unawaited(_openExternalUrl(uri));
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Future<void> _openExternalUrl(Uri uri) async {
    final opened = await ExternalLinkService.open(uri);
    if (!opened && mounted) {
      _showToast('No app found to open this link');
    }
  }

  Future<void> _showNativeDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
  }) async {
    if (!mounted) return false;

    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelText),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmText),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _emitBridgeEvent(
    String event,
    Map<String, dynamic> detail,
  ) async {
    final encodedEvent = jsonEncode(event);
    final encodedDetail = jsonEncode(detail);
    await _controller.runJavaScript('''
      window.dispatchEvent(new CustomEvent($encodedEvent, {
        detail: $encodedDetail
      }));
    ''');
  }

  Future<void> _handleBackPressed() async {
    final now = DateTime.now();
    final exitPromptShownAt = _exitPromptShownAt;

    if (exitPromptShownAt != null &&
        now.difference(exitPromptShownAt) <= _exitConfirmWindow) {
      await SystemNavigator.pop();
      return;
    }

    final lastBackPressedAt = _lastBackPressedAt;
    final isRapidBackPress = lastBackPressedAt != null &&
        now.difference(lastBackPressedAt) <= _rapidBackWindow;
    _lastBackPressedAt = now;

    if (isRapidBackPress) {
      _showExitPrompt();
      return;
    }

    _exitPromptShownAt = null;
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }

    _showExitPrompt();
  }

  void _showExitPrompt() {
    HapticFeedback.mediumImpact();
    _showToast(AppConfig.exitPromptMessage);
    _exitPromptShownAt = DateTime.now();
  }

  void _showToast(String message) {
    _toastOverlay = AppToast.show(
      context: context,
      message: message,
      currentOverlay: _toastOverlay,
      onDismissed: () => _toastOverlay = null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBackPressed();
      },
      child: Scaffold(
        body: SafeArea(
          child: ColoredBox(
            color: Colors.white,
            child: Stack(
              children: [
                Positioned.fill(child: WebViewWidget(controller: _controller)),
                if (_hasPageLoadError)
                  OfflinePage(onRetry: () => unawaited(_retryInitialRequest())),
                if (_isLoading) PageLoader(progress: _loadingProgress),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
