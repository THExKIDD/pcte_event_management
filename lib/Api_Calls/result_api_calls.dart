import 'dart:developer';
import 'package:dio/dio.dart';

class ResultApiCalls {
  final dio = Dio();

  Future<void> getResultById({required String eventId}) async {
    try {
      final response = await dio.get(
        'https://koshish-backend.vercel.app/api/result/get/$eventId',
      );

      log("Status Code: ${response.statusCode}");
      log("Status Message: ${response.statusMessage}");
      log("Response Data: ${response.data}");


      if (response.statusCode == 200) {
        log("Result: ${response.data['data']['result'][0]}");
      } else {
        log("Unexpected Status Code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      log("DioException: ${e.response?.statusCode ?? "No Status Code"}");
      log("Error Message: ${e.response?.statusMessage ?? e.message}");
      log("Response Data: ${e.response?.data ?? "No Response Data"}");
    } catch (e) {
      log("Unexpected Error: $e");
    }
  }
}
