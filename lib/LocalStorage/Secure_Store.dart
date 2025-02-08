import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Create storage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Save data
   Future<void> saveData(String key, String? value) async {
    await _storage.write(key: key, value: value);
  }



  // Retrieve data
  Future<String?> getData(String key) async {
    return await _storage.read(key: key);
  }

  // Delete data
  Future<void> deleteData(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _storage.deleteAll();
  }
}
