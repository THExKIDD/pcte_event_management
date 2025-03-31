import 'dart:core';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../LocalStorage/Secure_Store.dart';

class EventApiCalls {
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

  Future<bool> createEventCall() async {
    try {
      String? tkn = await tokenFetcher();

      dio.options.headers['Authorization'] = 'Bearer $tkn';

      final response = await dio.post(
        dotenv.env['CREATE_EVENT_API']!,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception;
      }
    } on Exception catch (e) {
      log('create event exception : ${e.toString()}');
      return false;
    }
  }



  Future<bool> updateEventCall(String eventId) async {
    try {

      final response = await dio.put(
        'https://koshish-backend.vercel.app/api/event/update/$eventId',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception;
      }
    } on Exception catch (e) {
      log('create event exception : ${e.toString()}');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      Response response =
          await dio.get('https://koshish-backend.vercel.app/api/event/');

      log(response.statusMessage.toString());

      if (response.statusCode != 200) {
        throw Exception;
      }

      Map<String, dynamic> jsonData = response.data;

      List<Map<String, dynamic>> allEvents =
          List<Map<String, dynamic>>.from(jsonData['events']);
      return allEvents;
    } on Exception catch (e) {
      log('getAllEventException : ${e.toString()}');
      return [];
    }
  }

  Future<bool> deleteEvent(String tkn,String id) async {
    log(":::: $tkn :: $id");
    try {
      final apiUrl = dotenv.env['DELETE_EVENT_API'];
      log('$apiUrl$id');
      dio.options.headers['Authorization'] = 'Bearer $tkn';
      final response = await dio.delete('$apiUrl$id');

      log(response.statusCode.toString());
      log(response.data.toString());

      if (response.statusCode == 200) {

        return true;
      }
    } on Exception catch (e) {
      log(e.toString());
      return false;
    }
    return false;
  }



  Future<List<dynamic>> getAllEventsForClass() async {
    try {
      String? tkn = await tokenFetcher();

      dio.options.headers['Authorization'] = 'Bearer $tkn';

      final response = await dio.get(
        'https://koshish-backend.vercel.app/api/event/class',
      );

      if (response.statusCode == 200) {
        log("Events for class fetched successfully");
        log(response.data.toString());

        // Assuming the response has a structure like:
        // {
        //   "status": true,
        //   "message": "Event fetched successfully",
        //   "result": [...]
        // }
        if (response.data is Map && response.data['result'] != null) {
          return response.data['result'];
        }
        return [];
      } else {
        log("Failed to fetch events for class: ${response.statusCode}");
        throw Exception('Failed to fetch events for class: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      log("DioError: ${e.response?.statusCode} - ${e.response?.statusMessage}");
      log(e.response?.data.toString() ?? 'No response data');
      throw Exception('Failed to fetch events for class: ${e.message}');
    } catch (error) {
      log("Error fetching events for class: ${error.toString()}");
      throw Exception('Failed to fetch events for class');
    }
  }
}
