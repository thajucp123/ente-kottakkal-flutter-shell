# Ente Kottakkal Flutter Shell

Flutter Android shell app for the Ente Kottakkal web application.

The app loads the hosted Next.js web app inside a native WebView and adds mobile-specific behavior such as splash screen, launcher icon, loading overlay, Android back-button handling, external link launching, and a JavaScript bridge for native actions.

## Documentation

See the full project documentation of this Flutter app here:

[documentation.md](documentation.md)

The documentation includes project history, architecture, module responsibilities, JavaScript bridge usage, URL launching behavior, Android configuration, and developer notes.

## Current Web App

The WebView currently loads:

```text
https://ente-kottakkal-web.vercel.app/
```

The production fallback URL is configured in:

```text
lib/config/app_config.dart
```

For local development, pass a temporary URL at run/build time:

```powershell
flutter run --dart-define=WEBVIEW_URL=https://your-ngrok-url.ngrok-free.app
```

## Features

- Flutter WebView shell for the hosted Next.js app.
- Native Android splash screen using `flutter_native_splash`.
- Launcher icon generation using `flutter_launcher_icons`.
- Loading overlay while WebView pages are loading.
- Normal safe-area viewport, respecting Android status and navigation bars.
- Android back button navigates WebView history.
- Rapid double-back confirmation to exit the app.
- External URL handling with `url_launcher`.
- Support for links such as `tel:`, `mailto:`, `sms:`, and `target="_blank"`.
- JavaScript bridge named `EnteKottakkal` for web-to-native actions.

## Project Structure

```text
lib/
  main.dart
  app.dart
  config/
    app_config.dart
  features/
    webview/
      fullscreen_webview_screen.dart
      native_bridge.dart
      webview_link_handler.dart
  services/
    external_link_service.dart
  widgets/
    app_toast.dart
    page_loader.dart
```

## Requirements

- Flutter SDK
- Android Studio / Android SDK
- Android device or emulator

This project currently targets Android. iOS configuration may be added or expanded later, but iOS builds require macOS and Xcode.

## Getting Started

Install dependencies:

```powershell
flutter pub get
```

Format and analyze:

```powershell
dart format lib test
flutter analyze
```

Run on a connected Android device or emulator:

```powershell
flutter run
```

Run with an ngrok development URL:

```powershell
flutter run --dart-define=WEBVIEW_URL=https://your-ngrok-url.ngrok-free.app
```

For ngrok URLs, the Flutter shell applies a custom WebView user agent and initial `ngrok-skip-browser-warning` header to avoid ngrok's browser warning page interfering with Next.js assets.

Build a release APK:

```powershell
flutter build apk --release
```

## Icon And Splash Assets

The root `logo.png` file is used for both the launcher icon and splash screen.

After changing `logo.png` or related config in `pubspec.yaml`, regenerate assets:

```powershell
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## JavaScript Bridge Quick Example

The web app can call Flutter through:

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "toast",
  message: "Saved successfully"
}));
```

More bridge examples are available in [documentation.md](documentation.md#10-javascript-bridge).

## Contributing Notes

- Keep the Flutter layer focused on native shell behavior.
- Keep web product features in the Next.js app unless they require native access.
- Update [documentation.md](documentation.md) whenever architecture, native behavior, setup steps, or bridge contracts change.
