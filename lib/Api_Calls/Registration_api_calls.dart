import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';

class RegistrationApiCalls{

  final Dio dio = Dio();
  final secureStorage = SecureStorage();

  
  Future<void> registerStudentApi(List<String> studentNames, String eventId)async {

    try {
      String? tkn = await secureStorage.getData('jwtToken');

      dio.options.headers['Authorization'] = 'Bearer $tkn';

      Map<String,dynamic> rawJson = {
        'students' : studentNames,
        'eventId' : eventId
      };

      log(rawJson.toString());

      final response = await dio.post(
        'https://koshish-backend.vercel.app/api/registrations',
        data: jsonEncode(rawJson),
      );
    } on DioException catch (e) {
      log(e.response!.statusCode.toString());
      log(e.response!.statusMessage.toString());
      log(e.response!.data.toString());
    }

    
  }

}