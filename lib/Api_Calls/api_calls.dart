import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pcte_event_management/Models/user_model.dart';

class ApiCalls {
  final Dio dio = Dio();


  Future<bool> loginCall(UserModel loginCred) async {
    try {
      final response = await dio.post(
        dotenv.env['LOGIN_API']!,
        data: loginCred.toJson(),


      );

      log(response.data.toString());

      if(response.statusCode == 200)
        {
          log("Logged in Successfully");
          log(response.statusMessage.toString());
          return true;
        }
      else{
        return false;
      }
    } on DioException catch (e) {
      log("DioException: ${e.toString()}");
      return false;
    }
  }



}