import 'dart:convert';

enum FingerprintType {
  sha1('SHA1'),
  sha256('SHA256');

  const FingerprintType(this.label);

  final String label;

  static FingerprintType fromValue(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'SHA256':
        return FingerprintType.sha256;
      case 'SHA1':
      default:
        return FingerprintType.sha1;
    }
  }
}

FingerprintModel fingerprintModelFromJson(String source) {
  return FingerprintModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

String fingerprintModelToJson(FingerprintModel data) {
  return jsonEncode(data.toMap());
}

class FingerprintModel {
  const FingerprintModel({
    required this.success,
    required this.type,
    this.fingerprint,
    this.packageName,
    this.errorMessage,
  });

  final bool success;
  final FingerprintType type;
  final String? fingerprint;
  final String? packageName;
  final String? errorMessage;

  factory FingerprintModel.fromMap(Map<String, dynamic> map) {
    return FingerprintModel(
      success: map['success'] == true,
      type: FingerprintType.fromValue(
        map['type']?.toString() ?? map['algorithm']?.toString(),
      ),
      fingerprint: map['fingerprint']?.toString(),
      packageName: map['packageName']?.toString(),
      errorMessage:
          map['errorMessage']?.toString() ?? map['message']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'type': type.label,
      'fingerprint': fingerprint,
      'packageName': packageName,
      'errorMessage': errorMessage,
    };
  }
}
