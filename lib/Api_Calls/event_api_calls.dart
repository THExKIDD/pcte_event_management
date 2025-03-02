import 'dart:core';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EventApiCalls {
  final Dio dio = Dio();

  Future<bool> createEventCall() async {
    try {
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

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      Response response =
          await dio.get('https://koshish-backend.vercel.app/api/event/');

      log(response.statusMessage.toString());
      log(response.data.toString());

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
}
