# 3. Back Button and Exit Strategy

Date: 2026-05-22

## Status

Accepted

## Context

On Android, users expect the physical back button to navigate through the app's history. In a WebView-hosted app, this history resides within the WebView itself. Simply closing the app on a back press would provide a poor user experience. Additionally, accidental app exits should be prevented.

## Decision

We will implement a hierarchical back button handling strategy:
1. **WebView History First:** If the WebView has internal navigation history (`canGoBack`), the back button will navigate to the previous page within the WebView.
2. **Double-Back to Exit:** If the WebView cannot go back, the first back press will show a native toast message ("Press back again to exit").
3. **Timed Confirmation:** If the user presses the back button again within a short time window (2 seconds), the app will exit.

This is implemented using Flutter's `PopScope` (or `WillPopScope` in older versions) in `lib/features/webview/fullscreen_webview_screen.dart`.

## Consequences

### Positive
- **Intuitive Navigation:** Matches Android user expectations for both web and native navigation.
- **Prevention of Accidental Exits:** The double-back mechanism provides a safety net for users.
- **Standard UX:** Consistent with many high-quality Android applications.

### Negative
- **Platform Specificity:** This behavior is specific to Android; iOS handles back navigation differently (gestures).
- **History Management:** The Flutter shell must actively query the WebView controller for its state on every back press.
