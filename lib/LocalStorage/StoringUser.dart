import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreUser {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Save userType
  static Future<void> saveUserType(String userType) async {
    await _storage.write(key: "user_type", value: userType);
  }

  // Retrieve userType
  static Future<String?> getUserType() async {
    return await _storage.read(key: "user_type");
  }
}
