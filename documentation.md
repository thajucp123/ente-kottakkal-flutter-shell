# Ente Kottakkal Flutter Shell Documentation

This project is a production-oriented Flutter shell app for the Ente Kottakkal web application. The native app is intentionally thin: it loads the hosted Next.js web app inside a WebView, while adding native mobile behavior where the web platform alone is not enough.

Current web app URL:

```dart
https://ente-kottakkal-web.vercel.app/
```

The URL is configured in `lib/config/app_config.dart`.

## Table Of Contents

- [1. Project Purpose](#1-project-purpose)
- [2. Setup History](#2-setup-history)
- [3. Project Structure](#3-project-structure)
  - [3.1 Entry And App Root](#31-entry-and-app-root)
  - [3.2 Configuration](#32-configuration)
  - [3.3 WebView Feature Modules](#33-webview-feature-modules)
  - [3.4 Services](#34-services)
  - [3.5 Widgets](#35-widgets)
- [4. Dependencies](#4-dependencies)
- [5. Android Configuration](#5-android-configuration)
- [6. App Icon And Splash Screen](#6-app-icon-and-splash-screen)
- [7. WebView Behavior](#7-webview-behavior)
- [8. Back Button Behavior](#8-back-button-behavior)
- [9. External URL Handling](#9-external-url-handling)
- [10. JavaScript Bridge](#10-javascript-bridge)
  - [10.1 Show Native Toast](#101-show-native-toast)
  - [10.2 Show Native Dialog](#102-show-native-dialog)
  - [10.3 Open External URL](#103-open-external-url)
- [11. Web Links With Target Blank](#11-web-links-with-target-blank)
- [12. Developer Commands](#12-developer-commands)
- [13. Notes For Future Developers](#13-notes-for-future-developers)
- [14. Current Known Scope](#14-current-known-scope)

## 1. Project Purpose

The app exists to package the Ente Kottakkal web experience as an Android mobile app. The Flutter layer handles:

- Native Android app startup and splash screen.
- App icon generation from `logo.png`.
- WebView hosting for the Next.js site.
- Page loading overlay while the WebView navigates.
- Android back button behavior for WebView history.
- Double-back exit confirmation.
- External link handling for `tel:`, `mailto:`, `sms:`, browser links, and similar schemes.
- A JavaScript bridge so the web app can request native actions.

## 2. Setup History

The initial app was created as a simple Flutter WebView shell. The project evolved through these major steps:

1. Created a Flutter app shell.
2. Added `webview_flutter` for loading the hosted web app.
3. Added native splash screen configuration with `flutter_native_splash`.
4. Added launcher icon configuration with `flutter_launcher_icons`.
5. Added Android internet permission.
6. Changed the visible Android app name to `എന്റെ കോട്ടക്കൽ`.
7. Used `logo.png` for launcher icon and splash screen.
8. Changed the WebView to render inside the normal safe viewport instead of covering status/navigation bars.
9. Added Android back-button handling so back navigates WebView history.
10. Added rapid double-back exit behavior with a toast-style message.
11. Added `url_launcher` for external URL schemes.
12. Added a JavaScript bridge named `EnteKottakkal`.
13. Refactored the app into modular production-friendly files.

## 3. Project Structure

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

### 3.1 Entry And App Root

#### `lib/main.dart`

Application entry point. It initializes Flutter and starts `WebViewShellApp`.

#### `lib/app.dart`

Defines the root `MaterialApp`. It currently loads `FullscreenWebViewScreen` as the home screen.

### 3.2 Configuration

#### `lib/config/app_config.dart`

Central location for app constants:

- `initialUrl`: the hosted Next.js URL loaded by the WebView.
- `javaScriptChannelName`: currently `EnteKottakkal`.
- `exitPromptMessage`: text shown for double-back exit confirmation.

### 3.3 WebView Feature Modules

#### `lib/features/webview/fullscreen_webview_screen.dart`

Main WebView screen. It owns the screen-level behavior:

- Creates and configures `WebViewController`.
- Enables JavaScript.
- Registers the native JS bridge.
- Handles WebView loading progress.
- Displays `PageLoader`.
- Handles Android back button behavior.
- Shows native dialogs.
- Shows app toast overlays.
- Opens external URLs through `ExternalLinkService`.

#### `lib/features/webview/native_bridge.dart`

Parses messages sent from the Next.js app through:

```js
window.EnteKottakkal.postMessage(...)
```

Supported message types:

- `openExternal`
- `toast`
- `dialog`

#### `lib/features/webview/webview_link_handler.dart`

Injects JavaScript into the loaded web page after page load.

It intercepts anchor clicks for:

- `target="_blank"`
- `tel:`
- `mailto:`
- `sms:`
- `geo:`
- `market:`
- `intent:`
- `whatsapp:`

When such a link is clicked, the page sends an `openExternal` message to Flutter instead of trying to handle it inside the WebView.

### 3.4 Services

#### `lib/services/external_link_service.dart`

Small service around `url_launcher`.

It decides whether a URI should open externally and launches it using:

```dart
LaunchMode.externalApplication
```

This is what allows `tel:` links to open the Android phone/dialer app directly instead of opening inside the WebView.

### 3.5 Widgets

#### `lib/widgets/app_toast.dart`

Custom lightweight toast overlay used by the Flutter shell. It is used for:

- Double-back exit message.
- JS bridge toast messages.
- External-link failure messages.

#### `lib/widgets/page_loader.dart`

Displays a loading overlay while WebView pages are loading.

## 4. Dependencies

Configured in `pubspec.yaml`.

### Runtime Dependencies

```yaml
webview_flutter
url_launcher
```

### Development Dependencies

```yaml
flutter_lints
flutter_launcher_icons
flutter_native_splash
flutter_test
```

## 5. Android Configuration

Main Android manifest:

```text
android/app/src/main/AndroidManifest.xml
```

Important configuration:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

This is required for the WebView to load the hosted web app.

The app label is configured through:

```xml
android:label="@string/app_name"
```

The actual Malayalam app name is stored in:

```text
android/app/src/main/res/values/strings.xml
```

The manifest also contains `<queries>` entries so Android 11+ can discover apps that handle:

- Phone calls: `tel:`
- Email: `mailto:`
- SMS: `sms:`
- Browser links: `https:`

## 6. App Icon And Splash Screen

The root file `logo.png` is used for both launcher icon and splash screen.

Configured in `pubspec.yaml`:

```yaml
flutter_native_splash:
  color: "#ffffff"
  color_dark: "#101820"
  image: logo.png
  image_dark: logo.png
  android: true
  ios: true
  web: false
  fullscreen: false

flutter_launcher_icons:
  android: true
  ios: true
  image_path: logo.png
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: logo.png
```

After changing `logo.png` or splash/icon config, regenerate assets:

```powershell
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## 7. WebView Behavior

The WebView:

- Loads `AppConfig.initialUrl`.
- Allows JavaScript.
- Uses a white background.
- Renders inside `SafeArea`, so it does not cover the Android status bar or navigation bar.
- Shows a loading overlay while navigation is in progress.

## 8. Back Button Behavior

The Android back button behavior is custom:

1. If the WebView can go back, a normal back press navigates to the previous WebView page.
2. If the user presses back rapidly twice, the app shows:

```text
Press back again to exit
```

3. If the user presses back again within the confirmation window, the app exits.
4. If there is no WebView history, the first back press shows the exit prompt.

This behavior lives in `fullscreen_webview_screen.dart`.

## 9. External URL Handling

External URL schemes should not load inside the WebView. They should open in native Android apps.

Examples:

```text
tel:+919999999999
mailto:hello@example.com
sms:+919999999999
https://example.com opened from target="_blank"
```

The Flutter side uses `url_launcher`.

For `tel:`, Android should open the dialer/phone app directly. It should not open a browser first unless the device has unusual app-handler configuration.

## 10. JavaScript Bridge

The Flutter WebView exposes a JavaScript channel named:

```js
EnteKottakkal
```

The Next.js app can send JSON messages to Flutter:

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "toast",
  message: "Saved successfully"
}));
```

### 10.1 Show Native Toast

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "toast",
  message: "Saved successfully"
}));
```

### 10.2 Show Native Dialog

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "dialog",
  title: "Notice",
  message: "This is a native Flutter dialog"
}));
```

### 10.3 Open External URL

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "openExternal",
  url: "tel:+919999999999"
}));
```

Other examples:

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "openExternal",
  url: "mailto:hello@example.com"
}));
```

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "openExternal",
  url: "https://example.com"
}));
```

## 11. Web Links With Target Blank

The Flutter app injects a link handler into the WebView page.

If the Next.js app renders:

```html
<a href="https://example.com" target="_blank">Open external site</a>
```

the Flutter shell intercepts it and opens the link externally instead of loading it inside the WebView.

## 12. Developer Commands

Install/update dependencies:

```powershell
flutter pub get
```

Format code:

```powershell
dart format lib test
```

Analyze code:

```powershell
flutter analyze
```

Run on connected Android device/emulator:

```powershell
flutter run
```

Build release APK:

```powershell
flutter build apk --release
```

Regenerate launcher icons:

```powershell
dart run flutter_launcher_icons
```

Regenerate native splash screen:

```powershell
dart run flutter_native_splash:create
```

## 13. Notes For Future Developers

- Keep app-wide constants in `AppConfig`.
- Keep WebView-specific behavior under `lib/features/webview`.
- Keep generic native helpers under `lib/services`.
- Keep reusable UI under `lib/widgets`.
- Add new JS bridge message types in `native_bridge.dart`.
- Add new external scheme handling in `webview_link_handler.dart` and Android manifest `<queries>` if Android package visibility requires it.
- Prefer keeping Flutter as a focused native shell unless a feature truly belongs outside the Next.js app.

## 14. Current Known Scope

This app currently targets Android. iOS configuration exists in package settings, but iOS builds require macOS and Xcode.

Windows desktop support is not required for this mobile WebView shell.
