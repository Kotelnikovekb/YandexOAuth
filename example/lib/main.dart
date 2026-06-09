import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:yandexoauth/yandexoauth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _yandexoauthPlugin = Yandexoauth();
  String _authStatus = 'Не авторизован';
  String? _token;
  bool _isYandexReady = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _initYandexSdk();
  }

  Future<void> _initYandexSdk() async {
    try {
      final success = await _yandexoauthPlugin.startYandexSdk();
      debugPrint('Yandex SDK initialized: $success');
      if (!mounted) return;
      setState(() {
        _isYandexReady = success;
        _authStatus = success
            ? 'Yandex SDK готов'
            : 'Ошибка: Yandex SDK не был инициализирован';
      });
    } catch (e) {
      debugPrint('Error initializing Yandex SDK: $e');
      if (!mounted) return;
      setState(() {
        _isYandexReady = false;
        _authStatus = 'Ошибка инициализации Yandex SDK: $e';
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

    try {
      final result = await _yandexoauthPlugin.signInWithYandex();
      if (result.success) {
        setState(() {
          _authStatus = 'Авторизован';
          _token = result.token;
        });
      }
    } on YandexOAuthException catch (e) {
      setState(() {
        _authStatus = 'Ошибка: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _authStatus = 'Непредвиденная ошибка: $e';
      });
    }
  }

  Future<void> _logout() async {
    try {
      final success = await _yandexoauthPlugin.logoutYandex();
      if (success) {
        setState(() {
          _authStatus = 'Не авторизован';
          _token = null;
        });
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _yandexoauthPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Yandex OAuth Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Running on: $_platformVersion'),
                const SizedBox(height: 20),
                Text(
                  'Статус: $_authStatus',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_token != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Token: ${_token!.substring(0, 10)}...',
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 30),
                YandexButton(
                  onPressed: _isYandexReady ? _login : null,
                  text: _isYandexReady
                      ? 'Войти с Яндекс ID'
                      : 'Инициализация...',
                ),
                const SizedBox(height: 10),
                TextButton(onPressed: _logout, child: const Text('Выйти')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
