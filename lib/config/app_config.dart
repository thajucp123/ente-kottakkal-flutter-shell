class AppConfig {
  const AppConfig._();

  static const productionUrl = 'https://ente-kottakkal-web.vercel.app/';
  static const initialUrl = String.fromEnvironment(
    'WEBVIEW_URL',
    defaultValue: productionUrl,
  );
  static final initialUri = Uri.parse(initialUrl);
  static final initialHeaders = initialUri.host.contains('ngrok')
      ? const {'ngrok-skip-browser-warning': 'true'}
      : const <String, String>{};
  static final webViewUserAgent = initialUri.host.contains('ngrok')
      ? 'EnteKottakkalWebView/1.0'
      : null;
  static const javaScriptChannelName = 'EnteKottakkal';
  static const exitPromptMessage = 'Press back again to exit';
}
