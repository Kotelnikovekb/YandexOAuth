import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'src/exceptions/yandex_oauth_exception.dart';
import 'src/models/fingerprint_model.dart';
import 'src/models/yandex_auth_result.dart';
import 'yandexoauth_platform_interface.dart';

/// An implementation of [YandexoauthPlatform] that uses method channels.
class MethodChannelYandexoauth extends YandexoauthPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('yandexoauth');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> startYandexSdk() async {
    try {
      final dynamic response = await methodChannel.invokeMethod('start');

      if (response is bool) {
        return response;
      }

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return map['success'] == true;
      }

      return false;
    } on PlatformException catch (e) {
      throw YandexOAuthException(
        code: e.code,
        message: e.message ?? 'Не удалось инициализировать Yandex SDK',
        details: e.details,
      );
    }
  }

  @override
  Future<YandexAuthResult> signInWithYandex() async {
    try {
      final dynamic response = await methodChannel.invokeMethod('yandexAuth');
      final map = _asMap(response);
      final result = YandexAuthResult.fromMap(map);

      if (!result.success || result.token.isEmpty) {
        throw YandexOAuthException(
          code: 'YANDEX_INVALID_RESPONSE',
          message: 'Нативная авторизация вернула пустой токен',
          details: map,
        );
      }

      return result;
    } on PlatformException catch (e) {
      throw YandexOAuthException(
        code: e.code,
        message: e.message ?? 'Ошибка входа через Yandex',
        details: e.details,
      );
    }
  }

  @override
  Future<bool> logoutYandex() async {
    try {
      final dynamic response = await methodChannel.invokeMethod('logoutYandex');

      if (response is bool) {
        return response;
      }

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return map['success'] == true;
      }

      return false;
    } on PlatformException catch (e) {
      throw YandexOAuthException(
        code: e.code,
        message: e.message ?? 'Не удалось выполнить logout через Yandex',
        details: e.details,
      );
    }
  }

  @override
  Future<FingerprintModel> getCertificateFingerprint({
    FingerprintType type = FingerprintType.sha1,
  }) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Метод доступен только на android');
    }

    try {
      final dynamic response = await methodChannel.invokeMethod(
        'getCertificateFingerprint',
        type.label,
      );

      if (response is String) {
        return fingerprintModelFromJson(response);
      }

      return FingerprintModel.fromMap(_asMap(response));
    } on PlatformException catch (e) {
      throw YandexOAuthException(
        code: e.code,
        message: e.message ?? 'Не удалось получить fingerprint сертификата',
        details: e.details,
      );
    }
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    if (response is String) {
      return Map<String, dynamic>.from(
        jsonDecode(response) as Map<String, dynamic>,
      );
    }

    throw YandexOAuthException(
      code: 'INVALID_NATIVE_RESPONSE',
      message: 'Неподдерживаемый тип ответа от native layer',
      details: response.runtimeType.toString(),
    );
  }
}
