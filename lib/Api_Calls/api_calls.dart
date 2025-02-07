import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pcte_event_management/Models/user_model.dart';

class ApiCalls {
  final Dio dio = Dio();
  final storage = FlutterSecureStorage();
  late String tkn ;

  Future<bool> loginCall(UserModel loginCred) async {
    try {
      final response = await dio.post(
        dotenv.env['LOGIN_API']!,
        data: loginCred.toJson(),

      );

      String res = response.data.toString();
      log(response.data.toString());

      tkn = response.data['token'].toString();
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

  Future<bool> signupCall(UserModel signupCred,String tkn) async {
    try {

       dio.options.headers['Authorization'] = 'Bearer $tkn';
      final response = await dio.post(
        dotenv.env['SIGNUP_API']!,
        data: signupCred.toJson(),

      );

      String res = response.data.toString();
      log("Res :::: $res");
      log(response.data.toString());

      if(response.statusCode == 200)
      {
        log("Signup Successfully");
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