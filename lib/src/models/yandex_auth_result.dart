import 'dart:convert';

YandexAuthResult yandexAuthResultFromJson(String source) {
  return YandexAuthResult.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

String yandexAuthResultToJson(YandexAuthResult data) {
  return jsonEncode(data.toMap());
}

class YandexAuthResult {
  const YandexAuthResult({
    required this.success,
    required this.token,
    this.jwt,
    this.expiresIn,
    this.displayName,
    this.login,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  final bool success;
  final String token;
  final String? jwt;
  final int? expiresIn;
  final String? displayName;
  final String? login;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;

  factory YandexAuthResult.fromMap(Map<String, dynamic> map) {
    return YandexAuthResult(
      success: map['success'] == true,
      token: map['token']?.toString() ?? '',
      jwt: map['jwt']?.toString(),
      expiresIn: map['expiresIn'] is int
          ? map['expiresIn'] as int
          : int.tryParse(map['expiresIn']?.toString() ?? ''),
      displayName: map['displayName']?.toString(),
      login: map['login']?.toString(),
      firstName: map['firstName']?.toString(),
      lastName: map['lastName']?.toString(),
      avatarUrl: map['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'token': token,
      'jwt': jwt,
      'expiresIn': expiresIn,
      'displayName': displayName,
      'login': login,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
    };
  }
}
