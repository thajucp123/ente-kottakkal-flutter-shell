# 2. JavaScript Bridge for Native Features

Date: 2026-05-22

## Status

Accepted

## Context

Using a WebView-based architecture means the web application cannot natively access mobile features like haptics, native share sheets, or secure local storage. To provide a seamless experience, the web app needs a way to "request" these native actions from the Flutter shell.

## Decision

We will implement a custom JavaScript channel named `EnteKottakkal`. The Flutter shell will listen for messages on this channel and execute corresponding native code.

Messages will be sent from JavaScript as JSON strings:
```js
window.EnteKottakkal.postMessage(JSON.stringify({
  type: "haptic",
  style: "medium"
}));
```

The Flutter shell will parse these messages in `lib/features/webview/native_bridge.dart` and use native plugins (like `vibration`, `share_plus`, `shared_preferences`) to fulfill the requests. For requests requiring a response, the Flutter shell will inject a custom event (`EnteKottakkalResponse`) back into the WebView.

## Consequences

### Positive
- **Extensible:** New native features can be added by simply adding a new message type to the bridge.
- **Decoupled:** The web app doesn't need to know how the native feature is implemented, only the message format.
- **Bi-directional:** Supports both fire-and-forget actions and request-response patterns.

### Negative
- **Message Parsing Overhead:** Small overhead for JSON stringification and parsing.
- **Maintenance Sync:** The message format must be kept in sync between the Next.js app and the Flutter shell.
- **Global Namespace:** Adds a single object (`EnteKottakkal`) to the window's global namespace.
