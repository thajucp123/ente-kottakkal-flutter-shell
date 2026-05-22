# 4. External URL Handling

Date: 2026-05-22

## Status

Accepted

## Context

Certain types of links (e.g., phone numbers, email addresses, or links to external websites) should not be handled within the application's WebView. Instead, they should be handed off to the appropriate native application (dialer, email client, or external browser) to ensure the best possible user experience.

## Decision

We will implement a multi-layered approach to external URL handling:
1. **JavaScript Injection:** We will inject a script (`lib/features/webview/webview_link_handler.dart`) into every page loaded in the WebView. This script intercepts clicks on `<a>` tags with `target="_blank"` or specific URI schemes (`tel:`, `mailto:`, `sms:`, `geo:`, etc.).
2. **Native Redirection:** When an intercepted link is clicked, the script sends an `openExternal` message to the Flutter shell via the JavaScript bridge.
3. **`url_launcher` Service:** The Flutter shell uses `ExternalLinkService` (built on `url_launcher`) to launch these URIs with `LaunchMode.externalApplication`.
4. **Manifest Queries:** To comply with Android 11+ package visibility requirements, we will include `<queries>` entries in `AndroidManifest.xml` for all supported schemes.

## Consequences

### Positive
- **Better User Experience:** Users can use their preferred native apps for specialized tasks (calling, emailing).
- **Security:** External websites are opened in the system browser rather than a potentially less secure WebView.
- **Consistency:** Provides expected behavior for standard web links on mobile platforms.

### Negative
- **Injection Complexity:** Requires careful JavaScript injection to ensure all links are captured without breaking web app functionality.
- **Maintenance:** The list of supported schemes must be maintained in both the JavaScript injector and the Android manifest.
