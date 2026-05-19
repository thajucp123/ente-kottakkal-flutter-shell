# Ente Kottakkal Flutter Shell Documentation

This project is a production-oriented Flutter shell app for the Ente Kottakkal web application. The native app is intentionally thin: it loads the hosted Next.js web app inside a WebView, while adding native mobile behavior where the web platform alone is not enough.

Default production web app URL:

```dart
https://ente-kottakkal-web.vercel.app/
```

The production fallback URL is configured in `lib/config/app_config.dart`. During development, a temporary URL can be passed with `--dart-define=WEBVIEW_URL=...`.

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
  - [10.4 Confirm Dialog](#104-confirm-dialog)
  - [10.5 Local Notification](#105-local-notification)
  - [10.6 Haptic And Vibration](#106-haptic-and-vibration)
  - [10.7 Share Sheet](#107-share-sheet)
  - [10.8 SharedPreferences Storage](#108-sharedpreferences-storage)
  - [10.9 Push Notifications](#109-push-notifications)
- [11. Web Links With Target Blank](#11-web-links-with-target-blank)
- [12. Developer Commands](#12-developer-commands)
- [13. Local Development With Ngrok](#13-local-development-with-ngrok)
- [14. Notes For Future Developers](#14-notes-for-future-developers)
- [15. Current Known Scope](#15-current-known-scope)

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

- `productionUrl`: the hosted production Next.js URL.
- `initialUrl`: the URL loaded by the WebView. It uses `WEBVIEW_URL` from `--dart-define` when provided, otherwise it falls back to `productionUrl`.
- `initialHeaders`: request headers used for the initial WebView load. Ngrok URLs receive `ngrok-skip-browser-warning`.
- `webViewUserAgent`: custom WebView user agent used for ngrok URLs so page assets and Next.js chunks avoid ngrok's browser warning behavior.
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
- `confirm`
- `localNotification`
- `pushNotification`
- `haptic`
- `vibrate`
- `share`
- `storageSet`
- `storageGet`
- `storageRemove`

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
flutter_local_notifications
share_plus
shared_preferences
webview_flutter
url_launcher
vibration
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
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
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

### 10.4 Confirm Dialog

Confirm dialogs return their result through a browser event named `EnteKottakkalResponse`.

```js
window.addEventListener("EnteKottakkalResponse", (event) => {
  if (event.detail.type === "confirmResult") {
    console.log(event.detail.requestId, event.detail.confirmed);
  }
});

window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "confirm",
  requestId: "confirm-1",
  title: "Confirm",
  message: "Do you want to continue?",
  confirmText: "Continue",
  cancelText: "Cancel"
}));
```

### 10.5 Local Notification

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "localNotification",
  id: 101,
  title: "Ente Kottakkal",
  message: "Your booking was updated"
}));
```

### 10.6 Haptic And Vibration

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "haptic",
  style: "medium"
}));
```

Supported haptic styles:

- `light`
- `medium`
- `heavy`
- `selection`

For direct vibration:

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "vibrate",
  duration: 120
}));
```

### 10.7 Share Sheet

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "share",
  text: "https://ente-kottakkal-web.vercel.app/",
  subject: "Ente Kottakkal"
}));
```

### 10.8 SharedPreferences Storage

Set a value:

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "storageSet",
  requestId: "save-token",
  key: "token",
  value: "abc123"
}));
```

Read a value:

```js
window.addEventListener("EnteKottakkalResponse", (event) => {
  if (event.detail.type === "storageGetResult") {
    console.log(event.detail.key, event.detail.value);
  }
});

window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "storageGet",
  requestId: "read-token",
  key: "token"
}));
```

Remove a value:

```js
window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "storageRemove",
  requestId: "remove-token",
  key: "token"
}));
```

### 10.9 Push Notifications

The bridge currently includes a `pushNotification` message type, but remote push notifications require Firebase project configuration before the app can return a real device token.

```js
window.addEventListener("EnteKottakkalResponse", (event) => {
  if (event.detail.type === "pushNotificationResult") {
    console.log(event.detail.supported, event.detail.message);
  }
});

window.EnteKottakkal?.postMessage(JSON.stringify({
  type: "pushNotification",
  requestId: "push-token"
}));
```

To make remote push notifications fully functional later, configure Firebase for Android, add the generated Firebase files, and wire `firebase_messaging` into the native bridge.

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

Run with a temporary development URL:
<small>This is helpful in running the flutter app with the Next.js dev server address instead of the final production url. More details later.</small>

```powershell
flutter run --dart-define=WEBVIEW_URL=https://your-ngrok-url.ngrok-free.app
```

Build with a custom URL:

```powershell
flutter build apk --release --dart-define=WEBVIEW_URL=https://your-ngrok-url.ngrok-free.app
```

Regenerate launcher icons:

```powershell
dart run flutter_launcher_icons
```

Regenerate native splash screen:

```powershell
dart run flutter_native_splash:create
```

## 13. Local Development With Ngrok

When developing the Next.js web app locally, use an ngrok tunnel so the Android phone can reach the dev server without depending on the machine's changing LAN IP address.

Start the Next.js dev server:

```powershell
npm run dev
```

In another terminal, expose the local dev server:

```powershell
ngrok http 3000
```

Ngrok will show a public HTTPS forwarding URL, for example:

```text
https://your-ngrok-url.ngrok-free.app
```

Run the Flutter app with that URL:

```powershell
flutter run --dart-define=WEBVIEW_URL=https://your-ngrok-url.ngrok-free.app
```

This avoids editing Dart source files for each temporary dev URL. The production Vercel URL remains the fallback when `WEBVIEW_URL` is not provided.

Because ngrok provides an HTTPS URL, Android cleartext HTTP configuration is normally not needed for this workflow.

Some ngrok free URLs may show a browser warning page inside WebView. If the HTML document loads but the page is mostly white, with only static layout such as the root navbar visible, the usual cause is that Next.js JavaScript chunks or CSS assets are receiving the ngrok warning response instead of the real asset.

The Flutter shell has two ngrok-specific protections:

- `AppConfig.initialHeaders` sends `ngrok-skip-browser-warning: true` for the initial page load.
- `AppConfig.webViewUserAgent` sets a custom WebView user agent for ngrok URLs so follow-up requests, including Next.js assets, are less likely to receive ngrok's browser warning page.

If ngrok behavior changes later, verify the forwarded URL directly in a mobile browser and check the Next.js dev server terminal for failed asset requests.

## 14. Notes For Future Developers

- Keep app-wide constants in `AppConfig`.
- Keep WebView-specific behavior under `lib/features/webview`.
- Keep generic native helpers under `lib/services`.
- Keep reusable UI under `lib/widgets`.
- Add new JS bridge message types in `native_bridge.dart`.
- Add new external scheme handling in `webview_link_handler.dart` and Android manifest `<queries>` if Android package visibility requires it.
- Prefer keeping Flutter as a focused native shell unless a feature truly belongs outside the Next.js app.

## 15. Current Known Scope

This app currently targets Android. iOS configuration exists in package settings, but iOS builds require macOS and Xcode.

Windows desktop support is not required for this mobile WebView shell.
