import 'package:webview_flutter/webview_flutter.dart';

class WebViewLinkHandler {
  const WebViewLinkHandler._();

  static Future<void> install(WebViewController controller) {
    return controller.runJavaScript('''
      (function () {
        if (window.__enteKottakkalLinkHandlerInstalled) return;
        window.__enteKottakkalLinkHandlerInstalled = true;

        document.addEventListener('click', function (event) {
          var element = event.target;
          while (element && element.tagName !== 'A') {
            element = element.parentElement;
          }

          if (!element || !element.href) return;

          var href = element.href;
          var target = (element.getAttribute('target') || '').toLowerCase();
          var scheme = href.split(':')[0].toLowerCase();
          var externalSchemes = [
            'tel',
            'mailto',
            'sms',
            'geo',
            'market',
            'intent',
            'whatsapp'
          ];

          if (target === '_blank' || externalSchemes.indexOf(scheme) !== -1) {
            event.preventDefault();
            window.EnteKottakkal.postMessage(JSON.stringify({
              type: 'openExternal',
              url: href
            }));
          }
        }, true);
      })();
    ''');
  }
}
