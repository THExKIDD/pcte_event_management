import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import '../Models/class_model.dart';

class ApiService {

  static const String baseUrl = "https://koshish-backend.vercel.app/api/";

  static Future<List<ClassModel>> getAllClasses() async {
    try {
      SecureStorage secureStorage = SecureStorage();
      final String? tkn = await secureStorage.getData('jwtToken');

      if (tkn == null || tkn.isEmpty) {
        throw Exception("Token is null or empty");
      }
      print(tkn);

     // Debugging

      final response = await http.get(
        Uri.parse("$baseUrl/class/"),
        headers: {
          "Authorization": "Bearer $tkn"
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == true) {
          return (data["classes"] as List)
              .map((classJson) => ClassModel.fromJson(classJson))
              .toList();
        } else {
          throw Exception(data["message"] ?? "Unexpected API Error");
        }
      } else {
        throw Exception("Failed to load classes: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error: $e");
      return []; // Return an empty list on error
    }
  }

}
