# yandexoauth

[English](README.md)

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

### Виджет кнопки Яндекса

В пакете есть готовые кнопки входа через Яндекс. Тема кнопки автоматически берется из `Theme.of(context).brightness`, поэтому кнопка следует светлой или темной теме приложения.

Основная кнопка:

```dart
YandexButton.main(
  size: YandexButtonSize.xxl,
  onPressed: _isYandexReady ? _login : null,
)
```

Дополнительная персонализированная кнопка:

```dart
YandexButton.additional(
  text: 'Войти как Юрий',
  avatar: NetworkImage('https://example.com/avatar.png'),
  size: YandexButtonSize.m,
  onPressed: _login,
)
```

Иконка с фоном:

```dart
YandexButton.iconBg(
  size: YandexButtonSize.m,
  iconType: YandexButtonIconType.ya,
  iconStyle: YandexButtonIconStyle.circle,
  onPressed: _login,
)
```

Иконка без фона:

```dart
YandexButton.iconOnly(
  size: YandexButtonSize.m,
  iconType: YandexButtonIconType.yaEng,
  onPressed: _login,
)
```

Принудительная тема кнопки:

```dart
YandexButton.main(
  theme: YandexButtonTheme.dark,
  onPressed: _login,
)
```

Кастомная ширина и скругление:

```dart
YandexButton.main(
  width: 320,
  borderRadius: 12,
  text: 'Продолжить с Яндексом',
  onPressed: _login,
)
```

Доступные типы кнопки: `main`, `additional`, `icon`, `iconBg`.

Доступные размеры: `xs` - 36px, `s` - 40px, `m` - 44px, `l` - 48px, `xl` - 52px, `xxl` - 56px.

Доступные типы иконки: `ya`, `yaEng`.

Доступные формы иконки: `square`, `rounded`, `circle`.

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

Префикс `yx` в `yxваш_client_id` обязателен. Итоговая URL scheme должна быть `yxAAAAAA`, где `AAAAAA` — ваш Yandex ClientID.

2. Убедитесь, что минимальная версия iOS — 13.0 или выше.

3. Плагин поддерживает как CocoaPods, так и Swift Package Manager (SPM). В новых версиях Flutter (3.22+) SPM используется по умолчанию для новых проектов.

## Типовые ошибки

### `YANDEX_AUTHORIZE_ERROR` с `loginSDKIsNotActivated` на iOS

Yandex iOS SDK получил команду авторизации до успешной активации.

Что сделать:

* Всегда вызывайте и дожидайтесь `startYandexSdk()` перед `signInWithYandex()`.
* Не разрешайте пользователю нажимать кнопку входа, пока инициализация не завершилась.
* Проверьте, что `YAClientId` есть в `ios/Runner/Info.plist` и не пустой.
* Проверьте, что `CFBundleURLSchemes` содержит `yx<ваш_client_id>`.

Пример:

```dart
bool _isYandexReady = false;

Future<void> _initYandexSdk() async {
  try {
    final success = await _yandexoauthPlugin.startYandexSdk();
    setState(() => _isYandexReady = success);
  } on YandexOAuthException catch (e) {
    setState(() {
      _isYandexReady = false;
      _authStatus = 'Ошибка инициализации Yandex SDK: ${e.message}';
    });
  }
}

Future<void> _login() async {
  if (!_isYandexReady) {
    setState(() {
      _authStatus = 'Дождитесь завершения инициализации Yandex SDK';
    });
    return;
  }

  final result = await _yandexoauthPlugin.signInWithYandex();
}
```

### Справочник ошибок

| Код | Платформа | Что означает | Что проверить |
| --- | --- | --- | --- |
| `YANDEX_CLIENT_ID_MISSING` | iOS | `YAClientId` отсутствует или пустой. | Добавьте `YAClientId` в `ios/Runner/Info.plist`. |
| `YANDEX_INIT_ERROR` | Android/iOS | Ошибка инициализации native SDK. | Проверьте `details`, client id, настройку платформы и зависимости native SDK. |
| `YANDEX_NOT_INITIALIZED` | Android | Авторизация запущена до `startYandexSdk()`. | Дождитесь `startYandexSdk()` перед входом. |
| `YANDEX_AUTHORIZE_ERROR` | Android/iOS | Не удалось открыть native-экран авторизации. | Проверьте `details`; на iOS `loginSDKIsNotActivated` означает, что инициализация не завершилась. |
| `YANDEX_VIEW_CONTROLLER_MISSING` | iOS | Плагин не смог найти root view controller. | Вызывайте вход после отображения Flutter UI. |
| `ACTIVITY_NOT_FOUND` | Android | Плагин не привязан к Android `Activity`. | Вызывайте вход только с активного Flutter-экрана. |
| `YANDEX_PENDING_REQUEST` | Android | Предыдущий запрос авторизации ещё не завершился. | Блокируйте кнопку входа на время авторизации. |
| `YANDEX_CANCELLED` | Android | Пользователь отменил авторизацию. | Обрабатывайте как обычную отмену пользователем. |
| `YANDEX_AUTH_ERROR` | Android | Yandex SDK вернул ошибку авторизации. | Проверьте `details`, package name, client id и настройки в Яндекс Консоли. |
| `YANDEX_INVALID_RESPONSE` | Dart | Native layer вернул успех без токена. | Проверьте результат native SDK и значение `details`. |
| `INVALID_NATIVE_RESPONSE` | Dart | Native layer вернул ответ неподдерживаемого формата. | Проверьте совместимость Dart и native-реализации плагина. |
| `CONTEXT_NOT_FOUND` | Android | Android application context недоступен. | Убедитесь, что плагин зарегистрирован в обычном lifecycle Flutter-приложения. |
| `FINGERPRINT_NOT_FOUND` | Android | Не удалось прочитать fingerprint сертификата подписи. | Запустите signed build или проверьте Android signing configuration. |

### Коды ошибок Yandex iOS SDK

Эти коды могут приходить в `details` для iOS-ошибок, которые возвращает Yandex Login SDK.

| Код | Что означает | Что сделать |
| --- | --- | --- |
| `YXLErrorCodeNotActivated` | LoginSDK не был активирован. | Дождитесь `startYandexSdk()` перед входом и блокируйте кнопку логина до завершения инициализации. |
| `YXLErrorCodeCancelled` | Авторизационный контроллер был закрыт пользователем. | Обрабатывайте как обычную отмену пользователем. |
| `YXLErrorCodeDenied` | Пользователь запретил авторизацию. | Покажите сообщение и дайте возможность повторить вход. |
| `YXLErrorCodeInvalidClient` | Передан неверный идентификатор приложения. | Проверьте `YAClientId`, URL scheme `yx<client_id>` и настройки приложения в Яндекс Консоли. |
| `YXLErrorCodeInvalidScope` | При регистрации приложения указаны неверные scopes. | Проверьте scopes приложения в Яндекс Консоли. |
| `YXLErrorCodeOther` | Прочие ошибки SDK. | Проверьте `details` и native-логи. |
| `YXLErrorCodeRequestError` | Внутренняя ошибка HTTP-запроса. | Проверьте `details`; если ошибка временная, можно повторить запрос. |
| `YXLErrorCodeRequestConnectionError` | Ошибка соединения. | Проверьте интернет-соединение и повторите попытку. |
| `YXLErrorCodeRequestSSLError` | Ошибка SSL. | Проверьте дату/время на устройстве, перехват сети, сертификаты и повторите в доверенной сети. |
| `YXLErrorCodeRequestNetworkError` | Прочие ошибки HTTP/сети. | Проверьте соединение, proxy/VPN и `details`. |
| `YXLErrorCodeRequestResponseError` | Получен HTTP-ответ с кодом не в диапазоне `200..299`. | Проверьте `details`, доступность сервисов Яндекса и настройки приложения. |
| `YXLErrorCodeRequestEmptyDataError` | Получен пустой HTTP-ответ. | Повторите запрос; если ошибка повторяется, проверьте native-логи. |
| `YXLErrorCodeRequestJwtError` | Возвращён некорректный ответ на JWT-запрос. | Проверьте настройки приложения в Яндекс Консоли и `details`. |
| `YXLErrorCodeRequestJwtInternalError` | Внутренняя JWT-ошибка. | Повторите запрос; если ошибка повторяется, соберите `details` и native-логи. |
| `YXLErrorCodeInvalidState` | Неверный параметр состояния. | Убедитесь, что auth flow не прерывается и не запускается несколько раз параллельно. |
| `YXLErrorCodeInvalidCode` | Ошибка при получении токена по авторизационному коду. | Проверьте настройки приложения и повторите авторизацию. |
| `YXLActivationErrorCodeNoAppId` | Идентификатор приложения равен `nil`. | Добавьте непустой `YAClientId` в `Info.plist`. |
| `YXLActivationErrorCodeNoQuerySchemeInInfoPList` | В `Info.plist` нет схемы `yandexauth`. | Добавьте `yandexauth` в `LSApplicationQueriesSchemes`. |
| `YXLActivationErrorCodeNoSchemeInInfoPList` | В `Info.plist` нет URL scheme `yx<client_id>`. | Добавьте `yx<client_id>` в `CFBundleURLSchemes`; префикс `yx` обязателен. |

## Поддержка проекта

Если вам понравился этот плагин, вы можете поддержать его разработку:

* [**Донат через DonationAlerts**](https://dalink.to/kotelnikoff_dev)
