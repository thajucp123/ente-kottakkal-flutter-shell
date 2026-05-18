import 'package:flutter/material.dart';

import 'features/webview/fullscreen_webview_screen.dart';

class WebViewShellApp extends StatelessWidget {
  const WebViewShellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FullscreenWebViewScreen(),
    );
  }
}
