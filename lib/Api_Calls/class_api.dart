import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/Models/user_model.dart';
import '../Models/class_model.dart';
import 'dart:io'; // For SocketException and HttpException
// For jsonEncode / jsonDecode
import 'dart:async'; // For TimeoutException

class ApiService {
  static const String baseUrl = "https://koshish-backend.vercel.app/api/";

  static Future<List<ClassModel>> getAllClasses() async {
    try {
      SecureStorage secureStorage = SecureStorage();
      final String? tkn = await secureStorage.getData('jwtToken');

      if (tkn == null || tkn.isEmpty) {
        throw Exception("Token is null or empty");
      }
      log(tkn);

      // Debugging

      final response = await http.get(
        Uri.parse("$baseUrl/class?page=1&limit=1000"),
        headers: {"Authorization": "Bearer $tkn"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('response class :  ${response.body}');

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
      log("❌ Error: $e");
      return []; // Return an empty list on error
    }
  }

  static Future<Map<String, dynamic>> classLogin(UserModel classDetails) async {
    try {
      Map<String, dynamic> data;
      log(classDetails.userName.toString() +
          " " +
          classDetails.password.toString());

      Map<String, dynamic> requestData = {
        'username': classDetails.userName,
        'password': classDetails.password
      };

      SecureStorage secureStorage = SecureStorage();

      // Debugging

      final response = await http.post(
          Uri.parse(
            "${baseUrl}class/login",
          ),
          body: requestData);
      data = jsonDecode(response.body);
      log(response.body.toString() ?? 'its null');

      if (response.statusCode == 200) {
        log(data.toString());
        await secureStorage.clearAllData();
        await secureStorage.saveData('jwtToken', data['token']);
        await secureStorage.saveData('user_type', data['data']['type']);
        await secureStorage.saveData('user_id', data['data']['_id']);
        await secureStorage.saveData('className', data['data']['name']);
        final String? usertype = await secureStorage.getData('user_type');
        final String? jwtToken = await secureStorage.getData('jwtToken');
        log(jwtToken!);
        log(usertype!);
        return data;
      } else {
        throw Exception(' ${data['message']}');
      }
    } catch (e, stackTrace) {
      log("❌ Error: $e");
      throw Exception(e.toString()); // Return an empty list on error
    }
  }

  static Future<String> createClass(ClassModel classData) async {
    try {
      SecureStorage secureStorage = SecureStorage();
      final String? token = await secureStorage.getData('jwtToken');

      if (token == null || token.isEmpty) {
        throw Exception("Token is null or empty");
      }
      log(token);

      final response = await http.post(
        Uri.parse("https://koshish-backend.vercel.app/api/class"),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer $token", // assuming you are using JWT token for req.user
        },
        body: jsonEncode(classData.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return 'Successfull';
      } else {
        return 'Failure';
      }
    } on SocketException catch (e) {
      log('🚫 No Internet: $e');
      return 'No Internet';
    } on HttpException catch (e) {
      log('🌐 HTTP error: $e');
      return 'HTTP Error';
    } on FormatException catch (e) {
      log('📄 Invalid format: $e');
      return 'Invalid Format';
    } on TimeoutException catch (e) {
      log('⏱ Timeout: $e');
      return 'Timeout';
    } catch (e) {
      log('🔥 Unexpected error: $e');
      return 'Unexpected Error';
    }
  }

  static Future<String> updateClass(
      ClassModel classData, String classId) async {
    try {
      SecureStorage secureStorage = SecureStorage();
      final String? token = await secureStorage.getData('jwtToken');

      if (token == null || token.isEmpty) {
        throw Exception("Token is null or empty");
      }
      log(token);
      log('id :  $classId  \n');

      log(' data is here --->  ${jsonEncode(classData)}');

      final response = await http.put(
        Uri.parse(
            "https://koshish-backend.vercel.app/api/class/$classId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(classData.toJson()),
      );

      log("📡 Status Code: ${response.statusCode}");
      log("📨 Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return 'Successfull';
      } else {
        return 'Failure';
      }
    } on SocketException catch (e) {
      log('🚫 No Internet: $e');
      return 'No Internet';
    } on HttpException catch (e) {
      log('🌐 HTTP error: $e');
      return 'HTTP Error';
    } on FormatException catch (e) {
      log('📄 Invalid format: $e');
      return 'Invalid Format';
    } on TimeoutException catch (e) {
      log('⏱ Timeout: $e');
      return 'Timeout';
    } catch (e) {
      log('🔥 Unexpected error: $e');
      return 'Unexpected Error';
    }
  }

  static Future<bool> deleteclass(String classId) async {
    try {
      SecureStorage secureStorage = SecureStorage();
      final String? token = await secureStorage.getData('jwtToken');

      if (token == null || token.isEmpty) {
        throw Exception("Token is null or empty");
      }
      log(token);
      final response = await http.delete(
        Uri.parse('https://koshish-backend.vercel.app/api/class/$classId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer $token", // assuming you are using JWT token for req.user
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
