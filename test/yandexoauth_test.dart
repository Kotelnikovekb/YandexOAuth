import 'package:flutter_test/flutter_test.dart';
import 'package:yandexoauth/yandexoauth.dart';
import 'package:yandexoauth/yandexoauth_platform_interface.dart';
import 'package:yandexoauth/yandexoauth_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockYandexoauthPlatform
    extends YandexoauthPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<FingerprintModel> getCertificateFingerprint({FingerprintType type = FingerprintType.sha1}) {
    throw UnimplementedError('getCertificateFingerprint() has not been implemented.');
  }

  @override
  Future<bool> logoutYandex() {
    throw UnimplementedError('logoutYandex() has not been implemented.');
  }

  @override
  Future<YandexAuthResult> signInWithYandex() {
    throw UnimplementedError('signInWithYandex() has not been implemented.');
  }

  @override
  Future<bool> startYandexSdk() {
    throw UnimplementedError('startYandexSdk() has not been implemented.');
  }
}

void main() {
  final YandexoauthPlatform initialPlatform = YandexoauthPlatform.instance;

  test('$MethodChannelYandexoauth is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelYandexoauth>());
  });

  test('getPlatformVersion', () async {
    Yandexoauth yandexoauthPlugin = Yandexoauth();
    MockYandexoauthPlatform fakePlatform = MockYandexoauthPlatform();
    YandexoauthPlatform.instance = fakePlatform;

    expect(await yandexoauthPlugin.getPlatformVersion(), '42');
  });
}
