# yandexoauth

[Русский](README_RU.md)

Flutter plugin for native authorization via Yandex SDK.

## Features

* Native authorization via Yandex ID.
* Obtaining access token.
* Logout.
* Obtaining certificate fingerprint (for Android) to configure the application in the Yandex console.

## Usage

### SDK Initialization

Before using authorization functions, you must initialize the SDK:

```dart
final _yandexoauthPlugin = Yandexoauth();

await _yandexoauthPlugin.startYandexSdk();
```

### Sign in with Yandex

```dart
try {
  final YandexAuthResult result = await _yandexoauthPlugin.signInWithYandex();
  if (result.success) {
    print('Token: ${result.token}');
  }
} on YandexOAuthException catch (e) {
  print('Error: ${e.message}');
}
```

### Yandex Button Widget

The package includes ready-to-use Yandex sign-in buttons. The button theme is resolved automatically from `Theme.of(context).brightness`, so it follows your app's light or dark theme.

Main button:

```dart
YandexButton.main(
  size: YandexButtonSize.xxl,
  onPressed: _isYandexReady ? _login : null,
)
```

Additional personalized button:

```dart
YandexButton.additional(
  text: 'Sign in as Yuri',
  avatar: NetworkImage('https://example.com/avatar.png'),
  size: YandexButtonSize.m,
  onPressed: _login,
)
```

Icon with background:

```dart
YandexButton.iconBg(
  size: YandexButtonSize.m,
  iconType: YandexButtonIconType.ya,
  iconStyle: YandexButtonIconStyle.circle,
  onPressed: _login,
)
```

Icon without background:

```dart
YandexButton.iconOnly(
  size: YandexButtonSize.m,
  iconType: YandexButtonIconType.yaEng,
  onPressed: _login,
)
```

Force a specific button theme:

```dart
YandexButton.main(
  theme: YandexButtonTheme.dark,
  onPressed: _login,
)
```

Customize shape and width:

```dart
YandexButton.main(
  width: 320,
  borderRadius: 12,
  text: 'Continue with Yandex',
  onPressed: _login,
)
```

Available button types: `main`, `additional`, `icon`, `iconBg`.

Available sizes: `xs` - 36px, `s` - 40px, `m` - 44px, `l` - 48px, `xl` - 52px, `xxl` - 56px.

Available icon types: `ya`, `yaEng`.

Available icon styles: `square`, `rounded`, `circle`.

### Logout

```dart
await _yandexoauthPlugin.logoutYandex();
```

### Get Fingerprint (Android only)

This method is useful for obtaining SHA-1 or SHA-256 fingerprint, which needs to be specified in the [Yandex Console](https://oauth.yandex.ru/).

```dart
final FingerprintModel fingerprint = await _yandexoauthPlugin.getCertificateFingerprint(
  type: FingerprintType.sha1,
);
print('Fingerprint: ${fingerprint.fingerprint}');
```

## Platform Setup

### Android

1. In your app's `build.gradle` (usually `android/app/build.gradle` or `android/app/build.gradle.kts`), add `YANDEX_CLIENT_ID` to `defaultConfig`:

```gradle
android {
    defaultConfig {
        // ...
        manifestPlaceholders += [
            YANDEX_CLIENT_ID: "your_client_id"
        ]
    }
}
```

Or for Kotlin DSL:

```kotlin
android {
    defaultConfig {
        // ...
        manifestPlaceholders["YANDEX_CLIENT_ID"] = "your_client_id"
    }
}
```

2. Make sure that `applicationId` in `build.gradle` matches the one registered in the Yandex Console.

The plugin automatically adds the necessary settings to its `AndroidManifest.xml` using the `${YANDEX_CLIENT_ID}` variable.

### iOS

1. In `ios/Runner/Info.plist`, add your `YAClientId` and necessary schemes:

```xml
<key>YAClientId</key>
<string>your_client_id</string>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>yandexauth</string>
    <string>yandexauth2</string>
    <string>yandexauth4</string>
    <string>primaryyandexloginsdk</string>
    <string>secondaryyandexloginsdk</string>
</array>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>YandexLoginSDK</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yxyour_client_id</string>
        </array>
    </dict>
</array>
```

The `yx` prefix in `yxyour_client_id` is required. The final URL scheme must be `yxAAAAAA`, where `AAAAAA` is your Yandex ClientID.

2. Ensure that the minimum iOS version is 13.0 or higher.

3. The plugin supports both CocoaPods and Swift Package Manager (SPM). In newer versions of Flutter (3.22+), SPM is used by default for new projects.

## Common Errors

### `YANDEX_AUTHORIZE_ERROR` with `loginSDKIsNotActivated` on iOS

The Yandex iOS SDK was asked to authorize before it was successfully activated.

What to do:

* Always call and await `startYandexSdk()` before `signInWithYandex()`.
* Do not allow the user to press the login button until initialization is complete.
* Check that `YAClientId` exists in `ios/Runner/Info.plist` and is not empty.
* Check that `CFBundleURLSchemes` contains `yx<your_client_id>`.

Example:

```dart
bool _isYandexReady = false;

Future<void> _initYandexSdk() async {
  try {
    final success = await _yandexoauthPlugin.startYandexSdk();
    setState(() => _isYandexReady = success);
  } on YandexOAuthException catch (e) {
    setState(() {
      _isYandexReady = false;
      _authStatus = 'Yandex SDK initialization failed: ${e.message}';
    });
  }
}

Future<void> _login() async {
  if (!_isYandexReady) {
    setState(() {
      _authStatus = 'Wait until Yandex SDK initialization is complete';
    });
    return;
  }

  final result = await _yandexoauthPlugin.signInWithYandex();
}
```

### Error Reference

| Code | Platform | What it means | What to check |
| --- | --- | --- | --- |
| `YANDEX_CLIENT_ID_MISSING` | iOS | `YAClientId` is missing or empty. | Add `YAClientId` to `ios/Runner/Info.plist`. |
| `YANDEX_INIT_ERROR` | Android/iOS | Native SDK initialization failed. | Check `details`, client id, platform setup, and native SDK dependencies. |
| `YANDEX_NOT_INITIALIZED` | Android | Authorization was started before `startYandexSdk()`. | Await `startYandexSdk()` before login. |
| `YANDEX_AUTHORIZE_ERROR` | Android/iOS | Native authorization screen failed to start. | Check `details`; on iOS `loginSDKIsNotActivated` means initialization did not complete. |
| `YANDEX_VIEW_CONTROLLER_MISSING` | iOS | The plugin could not find a root view controller. | Call login after the Flutter UI is visible. |
| `ACTIVITY_NOT_FOUND` | Android | The plugin is not attached to an Android `Activity`. | Call login only from a foreground Flutter screen. |
| `YANDEX_PENDING_REQUEST` | Android | A previous authorization request is still active. | Disable the login button while authorization is in progress. |
| `YANDEX_CANCELLED` | Android | The user cancelled authorization. | Treat this as a normal user cancellation. |
| `YANDEX_AUTH_ERROR` | Android | Yandex SDK returned an authorization failure. | Check `details`, package name, client id, and Yandex Console settings. |
| `YANDEX_INVALID_RESPONSE` | Dart | Native layer returned success without a token. | Check native SDK result and report the `details` value. |
| `INVALID_NATIVE_RESPONSE` | Dart | Native layer returned an unsupported response format. | Check plugin/native implementation compatibility. |
| `CONTEXT_NOT_FOUND` | Android | Android application context is unavailable. | Ensure the plugin is registered in a normal Flutter app lifecycle. |
| `FINGERPRINT_NOT_FOUND` | Android | Signing certificate fingerprint could not be read. | Run on a signed build or check Android signing configuration. |

### Yandex iOS SDK Error Codes

These codes can appear in `details` for iOS errors returned by Yandex Login SDK.

| Code | What it means | What to do |
| --- | --- | --- |
| `YXLErrorCodeNotActivated` | LoginSDK was not activated. | Await `startYandexSdk()` before login and block the login button until initialization is complete. |
| `YXLErrorCodeCancelled` | The authorization controller was closed by the user. | Treat it as a normal cancellation. |
| `YXLErrorCodeDenied` | The user denied authorization. | Show a message and let the user retry if needed. |
| `YXLErrorCodeInvalidClient` | An invalid application identifier was provided. | Check `YAClientId`, `yx<client_id>` URL scheme, and the app settings in Yandex Console. |
| `YXLErrorCodeInvalidScope` | Invalid scopes were configured for the application. | Check the scopes configured for the app in Yandex Console. |
| `YXLErrorCodeOther` | Other SDK error. | Check `details` and native logs. |
| `YXLErrorCodeRequestError` | Internal HTTP request error. | Check `details`; retry can be reasonable if the issue is temporary. |
| `YXLErrorCodeRequestConnectionError` | Connection error. | Check internet connectivity and retry. |
| `YXLErrorCodeRequestSSLError` | SSL error. | Check device date/time, network interception, certificates, and retry on a trusted network. |
| `YXLErrorCodeRequestNetworkError` | Other HTTP/network error. | Check connectivity, proxy/VPN, and `details`. |
| `YXLErrorCodeRequestResponseError` | HTTP response status is outside `200..299`. | Check `details`; verify Yandex service availability and app settings. |
| `YXLErrorCodeRequestEmptyDataError` | Empty HTTP response was received. | Retry and check native logs if it repeats. |
| `YXLErrorCodeRequestJwtError` | Invalid JWT request response was returned. | Check Yandex Console settings and `details`. |
| `YXLErrorCodeRequestJwtInternalError` | Internal JWT error. | Retry; if repeated, collect `details` and native logs. |
| `YXLErrorCodeInvalidState` | Invalid state parameter. | Make sure the auth flow is not interrupted or started multiple times in parallel. |
| `YXLErrorCodeInvalidCode` | Error while obtaining a token from the authorization code. | Check app settings and retry authorization. |
| `YXLActivationErrorCodeNoAppId` | Application identifier is `nil`. | Add a non-empty `YAClientId` to `Info.plist`. |
| `YXLActivationErrorCodeNoQuerySchemeInInfoPList` | `Info.plist` does not contain the `yandexauth` query scheme. | Add `yandexauth` to `LSApplicationQueriesSchemes`. |
| `YXLActivationErrorCodeNoSchemeInInfoPList` | `Info.plist` does not contain the `yx<client_id>` URL scheme. | Add `yx<client_id>` to `CFBundleURLSchemes`; the `yx` prefix is required. |

## Support the Project

If you find this plugin useful, you can support its development:

* [**Donate via DonationAlerts**](https://www.donationalerts.com/r/kotelnikoff)
* [**Donate via CloudTips**](https://pay.cloudtips.ru/p/c9462580)
