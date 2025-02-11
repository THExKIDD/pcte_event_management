import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
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



  Future<bool> getUserCall(String token) async {
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await dio.get(
        dotenv.env['GETUSER_API']!,

      );


      if(response.statusCode == 200)
      {
        final SecureStorage secureStorage = SecureStorage();
        log("Got THE USER");
        log(response.statusMessage.toString());
        Map<String , dynamic> userDetails = response.data['user'];
        String userTypeGet = response.data['user']['user_type'];
        final data2 = userTypeGet.toString();
        log(data2);
        secureStorage.saveData('user_type', data2);
        final data = userDetails.toString();
        secureStorage.saveData('userDetails', data);
        final msg = await secureStorage.getData('userDetails');
        log(msg!);


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

      if(response.statusCode == 201)
      {
        log("Signed up Successfully");
        log(response.statusMessage.toString());
        return true;
      }
      else if (response.statusCode == 400)
        {
          log("Bad Request ");
          log(response.statusMessage.toString());
          return false;
        }
      else{
        return false;
      }
    } on DioException catch (e) {
      log("DioException: ${e.toString()}");
      return false;
    }
  }

  Future<bool> sendOtp(String email) async {

    try{

      final emailObj = UserModel(email: email);


      final response = await dio.post(dotenv.env['FORGOT_PASS_API']!,
          data: emailObj.toJson() );


      if(response.statusCode == 200)
        {
          log('OTP SENT');
          log(response.statusMessage.toString());
          return true;
        }
      else if(response.statusCode == 500)
        {
          log("Internal Server Error");
          log(response.statusMessage.toString());
          return true;
        }
      return true;


    }

    on DioException catch(e){
      log("DioException: ${e.toString()}");
      return false;
    }

  }

   Future<bool> forgotPass({String? Email, String? Otp, String? NewPass}) async {

    final String? email = Email;
    final String? otp = Otp;
    final String? newPass = NewPass;

    

      
      try {
        final request = UserModel(email: email, otp: otp, password: newPass);

        final response = await dio.post(
            dotenv.env['PASS_RESET_API']!,
            data: request.toJson()
        );



        log(response.statusCode.toString());
        log(response.statusMessage.toString());

        if(response.statusCode == 200){
          return true;
        }
        else{
          return false;
        }

      } on Exception catch (e) {
        log(e.toString());
        return false;
      }

      
  }
  
  Future<void> getFacultyCall(String tkn) async {


    try {
      dio.options.headers ['Authorization'] = 'Bearer $tkn';
       final response =  await dio.get(dotenv.env['GET_FACULTY_API']!);

      log(response.statusCode.toString());
      String responseData = response.data.toString();

      List<dynamic> jsonData = response.data['data'];

      log(jsonData[1]);






    } on Exception catch (e) {
      log(e.toString());
    }




    
    
  }
  
  


}