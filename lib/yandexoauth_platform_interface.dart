import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/models/fingerprint_model.dart';
import 'src/models/yandex_auth_result.dart';
import 'yandexoauth_method_channel.dart';

abstract class YandexoauthPlatform extends PlatformInterface {
  /// Constructs a YandexoauthPlatform.
  YandexoauthPlatform() : super(token: _token);

  static final Object _token = Object();

  static YandexoauthPlatform _instance = MethodChannelYandexoauth();

  /// The default instance of [YandexoauthPlatform] to use.
  ///
  /// Defaults to [MethodChannelYandexoauth].
  static YandexoauthPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [YandexoauthPlatform] when
  /// they register themselves.
  static set instance(YandexoauthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> startYandexSdk() {
    throw UnimplementedError('startYandexSdk() has not been implemented.');
  }

  Future<YandexAuthResult> signInWithYandex() {
    throw UnimplementedError('signInWithYandex() has not been implemented.');
  }

  Future<bool> logoutYandex() {
    throw UnimplementedError('logoutYandex() has not been implemented.');
  }

  Future<FingerprintModel> getCertificateFingerprint({
    FingerprintType type = FingerprintType.sha1,
  }) {
    throw UnimplementedError('getCertificateFingerprint() has not been implemented.');
  }
}
