import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';

class RegistrationApiCalls {
  final Dio dio = Dio();
  final secureStorage = SecureStorage();

  Future<String?> tokenFetcher() async {
    try {
      String? tkn = await secureStorage.getData('jwtToken');
      log(tkn ?? "null token");
      return tkn;
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to fetch token');
    }
  }

  Future<Map<String,dynamic>> getAllRegistrations() async {
    try {
      String? tkn = await tokenFetcher();

      log(tkn ?? "null token");

      dio.options.headers['Authorization'] = 'Bearer $tkn';

      final response = await dio.get(
        'https://koshish-backend.vercel.app/api/registrations/',
      );

      if (response.statusCode == 200) {
        log("Registrations fetched successfully");
        log(response.data.toString());

        // Assuming the response has a structure like:
        // {
        //   "status": true,
        //   "message": "Registrations Fetched",
        //   "registrations": [...]
        // }
        if (response.data is Map && response.data['registrations'] != null) {
          log(response.data.toString());
          return response.data;
        }
        return {};
      } else {
        log("Failed to fetch registrations: ${response.statusCode}");
        throw Exception('Failed to fetch registrations: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      log("DioError: ${e.response?.statusCode} - ${e.response?.statusMessage}");
      log(e.response?.data.toString() ?? 'No response data');
      throw Exception('Failed to fetch registrations: ${e.message}');
    } catch (error) {
      log("Error fetching registrations: ${error.toString()}");
      throw Exception('Failed to fetch registrations');
    }
  }

  Future<Map<String,dynamic>> registerStudentApi(List<String> studentNames, String eventId) async {
    try {
      String? tkn = await tokenFetcher();

      dio.options.headers['Authorization'] = 'Bearer $tkn';

      Map<String, dynamic> rawJson = {
        'students': studentNames,
        'eventId': eventId
      };

      log(rawJson.toString());

      final response = await dio.post(
        'https://koshish-backend.vercel.app/api/registrations',
        data: jsonEncode(rawJson),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Registered Successfully");
        log(response.data.toString());
        return response.data;
      } else {
        log(response.statusMessage.toString());
        log(response.statusCode.toString());
        log("Registration Failed");
        throw Exception('Failed to register');
      }
    } on DioException catch (e) {
      log(e.response!.statusCode.toString());
      log(e.response!.statusMessage.toString());
      log(e.response!.data.toString());
      throw Exception(e.toString());
    } catch (error) {
      log("Registration Failed : ${error.toString()}");
      rethrow;
    }
  }



  Future<Map<String,dynamic>> updateRegistrationApi({
    required List<String> studentNames,
    required  String eventId,
    required  String registrationId ,
    String? classId } ) async {
    try {
      String? tkn = await tokenFetcher();

      dio.options.headers['Authorization'] = 'Bearer $tkn';

      Map<String, dynamic> rawJson = {
        'students': studentNames,
        'eventId': eventId,
        'classId' : classId
      };

      log(rawJson.toString());

      final response = await dio.put(
        'https://koshish-backend.vercel.app/api/registrations/$registrationId',
        data: jsonEncode(rawJson),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Registered Successfully");
        log(response.data.toString());
        return response.data;
      } else {
        log(response.statusMessage.toString());
        log(response.statusCode.toString());
        log("Registration Failed");
        return {};
      }
    } on DioException catch (e) {
      log(e.response!.statusCode.toString());
      log(e.response!.statusMessage.toString());
      log(e.response!.data.toString());
      return {};
    } catch (error) {
      log("Registration Failed : ${error.toString()}");
      rethrow;
    }
  }


  Future<List<dynamic>> getEventRegistrations(String eventId) async
  {

    try {
      String? tkn = await tokenFetcher();

      log(tkn ?? "null token");

      dio.options.headers['Authorization'] = 'Bearer $tkn';

      final response = await dio.get(
        'https://koshish-backend.vercel.app/api/registrations/category/$eventId',
      );

      if (response.statusCode == 200) {
        log("Registrations fetched successfully");

          return response.data['registrations'];
        }
        return [];
      } on DioException catch (e) {
      log("DioError: ${e.response?.statusCode} - ${e.response?.statusMessage}");
      log(e.response?.data.toString() ?? 'No response data');
      throw Exception('Failed to fetch registrations: ${e.message}');
    } catch (error) {
      log("Error fetching registrations: ${error.toString()}");
      throw Exception('Failed to fetch registrations');
    }


  }

}