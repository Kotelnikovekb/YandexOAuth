# yandexoauth

[English](#english) | [Русский](#russian)

---

<a name="english"></a>
# yandexoauth (English)

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

2. Ensure that the minimum iOS version is 13.0 or higher.

3. The plugin supports both CocoaPods and Swift Package Manager (SPM). In newer versions of Flutter (3.22+), SPM is used by default for new projects.

## Support the Project

If you find this plugin useful, you can support its development:

* [**Donate via DonationAlerts**](https://www.donationalerts.com/r/kotelnikoff)
* [**Donate via CloudTips**](https://pay.cloudtips.ru/p/c9462580)

---

<a name="russian"></a>
# yandexoauth (Русский)

Flutter плагин для нативной авторизации через Яндекс SDK.

## Возможности

* Нативная авторизация через Яндекс ID.
* Получение токена доступа.
* Выход из аккаунта (logout).
* Получение отпечатка сертификата (fingerprint) для настройки приложения в консоли Яндекса.

## Использование

### Инициализация SDK

Перед использованием функций авторизации необходимо инициализировать SDK:

```dart
final _yandexoauthPlugin = Yandexoauth();

await _yandexoauthPlugin.startYandexSdk();
```

### Вход через Яндекс

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

### Выход

```dart
await _yandexoauthPlugin.logoutYandex();
```

### Получение Fingerprint (только для Android)

Этот метод полезен для получения SHA-1 или SHA-256 отпечатка, который нужно указать в [Яндекс Консоли](https://oauth.yandex.ru/).

```dart
final FingerprintModel fingerprint = await _yandexoauthPlugin.getCertificateFingerprint(
  type: FingerprintType.sha1,
);
print('Fingerprint: ${fingerprint.fingerprint}');
```

## Настройка платформ

### Android

1. В `build.gradle` вашего приложения (обычно `android/app/build.gradle` или `android/app/build.gradle.kts`) добавьте `YANDEX_CLIENT_ID` в `defaultConfig`:

```gradle
android {
    defaultConfig {
        // ...
        manifestPlaceholders += [
            YANDEX_CLIENT_ID: "ваш_client_id"
        ]
    }
}
```

Или для Kotlin DSL:

```kotlin
android {
    defaultConfig {
        // ...
        manifestPlaceholders["YANDEX_CLIENT_ID"] = "ваш_client_id"
    }
}
```

2. Убедитесь, что `applicationId` в `build.gradle` соответствует зарегистрированному в Яндекс Консоли.

Плагин автоматически добавляет необходимые настройки в свой `AndroidManifest.xml`, используя переменную `${YANDEX_CLIENT_ID}`.

### iOS

1. В `ios/Runner/Info.plist` добавьте ваш `YAClientId` и необходимые схемы:

```xml
<key>YAClientId</key>
<string>ваш_client_id</string>
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
            <string>yxваш_client_id</string>
        </array>
    </dict>
</array>
```

2. Убедитесь, что минимальная версия iOS — 13.0 или выше.

3. Плагин поддерживает как CocoaPods, так и Swift Package Manager (SPM). В новых версиях Flutter (3.22+) SPM используется по умолчанию для новых проектов.


## Поддержка проекта

Если вам понравился этот плагин, вы можете поддержать его разработку:

* [**Донат через DonationAlerts**](https://dalink.to/kotelnikoff_dev)
