import 'src/models/fingerprint_model.dart';
import 'src/models/yandex_auth_result.dart';
import 'yandexoauth_platform_interface.dart';

export 'src/exceptions/yandex_oauth_exception.dart';
export 'src/models/fingerprint_model.dart';
export 'src/models/yandex_auth_result.dart';
export 'src/widgets/yandex_button.dart';

class Yandexoauth {
  Future<String?> getPlatformVersion() {
    return YandexoauthPlatform.instance.getPlatformVersion();
  }

  Future<bool> startYandexSdk() {
    return YandexoauthPlatform.instance.startYandexSdk();
  }

  Future<YandexAuthResult> signInWithYandex() {
    return YandexoauthPlatform.instance.signInWithYandex();
  }

  Future<bool> logoutYandex() {
    return YandexoauthPlatform.instance.logoutYandex();
  }

  Future<FingerprintModel> getCertificateFingerprint({
    FingerprintType type = FingerprintType.sha1,
  }) {
    return YandexoauthPlatform.instance.getCertificateFingerprint(type: type);
  }
}
