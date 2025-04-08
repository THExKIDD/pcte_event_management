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

      print("token ${tkn}");

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

// In api_calls.dart or event_api_calls.dart

  Future<bool> updateEventCallWithData(
      String eventId, Map<String, dynamic> eventData) async {
    //         if (eventData["convenor"] == null) {
    //   eventData["convenor"] = {
    //     "name": eventData['name'],
    //     "email": "default@example.com",
    //     "phone": "+91 9876543210"
    //   };
    // }
    try {
      final token = await tokenFetcher();
      // log('toke is there $token');

      log('event data  ${eventData.toString()}');

      final response = await dio.put(
        'https://koshish-backend.vercel.app/api/event/update/$eventId',
        data: eventData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', 
          },
        ), // Send the event data in the request body
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        log('Update event failed with status: ${response.statusCode}');
        log('Update event error data: ${response.data}');
        throw Exception('status code wrong');
      }
    } on DioException catch (e) {
      log('Dio error updating event: ${e.toString()}');
      if (e.response != null) {
        log('Dio error response data: ${e.response!.data}');
        log('Dio error response headers: ${e.response!.headers}');
        log('Dio error response status code: ${e.response!.statusCode}');
      } else {
        log('Dio error request options: ${e.requestOptions}');
        log('Dio error message: ${e.message}');
      }
      return false;
    } catch (e) {
      log('General error updating event: ${e.toString()}');
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

  Future<bool> deleteEvent(String tkn, String id) async {
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
        throw Exception(
            'Failed to fetch events for class: ${response.statusMessage}');
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
