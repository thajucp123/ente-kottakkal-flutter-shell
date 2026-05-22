# 1. WebView-based Architecture

Date: 2026-05-22

## Status

Accepted

## Context

The Ente Kottakkal project has a mature Next.js web application. The goal is to provide a native Android mobile experience without duplicating the entire business logic and UI in Flutter. We need a solution that allows for rapid deployment of web updates while providing enough native integration (splash screens, back button handling, native permissions) to feel like a "real" app.

## Decision

We will use Flutter as a thin native shell that hosts the Next.js web application inside a WebView using the `webview_flutter` package. 

The native shell will be responsible for:
- App startup and splash screen.
- Hosting the WebView.
- Providing a bridge for native features.
- Handling platform-specific behaviors like the Android back button.

## Consequences

### Positive
- **Single Codebase for UI/Logic:** Business logic and most UI remain in the Next.js app, reducing maintenance effort.
- **Instant Updates:** Web updates are immediately available to app users without needing a new store release (for web-side changes).
- **Native Polish:** We can still provide native splash screens, icons, and platform-specific interactions where it matters most.

### Negative
- **Dependency on Connectivity:** The app requires an internet connection to function (partially mitigated by a custom offline page).
- **Performance:** WebView performance may be slightly lower than a fully native Flutter UI, though usually negligible for content-heavy apps.
- **Limited Offline Capability:** Native features are limited to what is exposed through the bridge.
