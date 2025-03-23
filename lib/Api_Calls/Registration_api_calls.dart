import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';

class RegistrationApiCalls{

  final Dio dio = Dio();
  final secureStorage = SecureStorage();


  Future<String?> tokenFetcher () async {

    try
    {
      String? tkn = await secureStorage.getData('jwtToken');
      log(tkn ?? "null token");
      return tkn;
    }
        catch(e){
          log(e.toString());
          throw Exception('Failed to fetch token');
        }

  }

  
  Future<bool> registerStudentApi(List<String> studentNames, String eventId)async {

    try {

      String? tkn = await tokenFetcher();

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

      if(response.statusCode == 200 || response.statusCode == 201)
      {
        log("Registered Successfully");
        log(response.data.toString());
        return true;
      }
      else
      {
        log(response.statusMessage.toString());
        log(response.statusCode.toString());
        log("Registration Failed");
        throw Exception('Failed to register');
      }

    } on DioException catch (e) {
      log(e.response!.statusCode.toString());
      log(e.response!.statusMessage.toString());
      log(e.response!.data.toString());
      return false;
    }
    catch(error)
    {
      log("Registration Failed : ${error.toString()}");
      return false;
    }

    
  }

}