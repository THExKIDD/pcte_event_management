import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/Models/user_model.dart';
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
      log(tkn);

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
      log("❌ Error: $e");
      return []; // Return an empty list on error
    }
  }

  static Future<Map<String,dynamic>> classLogin(UserModel classDetails) async {
    try {
      Map<String,dynamic> data;
      log(classDetails.userName.toString() +" "+ classDetails.password.toString());

      Map<String , dynamic> requestData = {
        'username':classDetails.userName,
        'password':classDetails.password
      };

      SecureStorage secureStorage = SecureStorage();


      // Debugging

      final response = await http.post(
        Uri.parse(
          "${baseUrl}class/login",
        ),
        body: requestData
      );
      data = jsonDecode(response.body);
      log(response.body.toString() ?? 'its null' );

      if (response.statusCode == 200) {
        log(data.toString());
        await secureStorage.saveData('jwtToken', data['token']);
        await secureStorage.saveData('user_type', data['data']['type']);
        await secureStorage.saveData('user_id', data['data']['_id']);
        final String? usertype = await secureStorage.getData('user_type');
        final String? jwtToken = await secureStorage.getData('jwtToken');
        log(jwtToken!);
        log(usertype!);
        return data;


    }
      else{
        throw Exception(' ${data['message']}');
      }

    } catch (e,stackTrace) {
      log("❌ Error: $e");
      throw Exception(e.toString()); // Return an empty list on error
    }
  }


}
