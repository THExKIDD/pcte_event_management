import 'dart:developer';

import 'package:dio/dio.dart';

class EventApiCalls{
  
  final Dio dio = Dio();
  
  Future<bool> createEventCall() async {
    
    try {
     final response =await  dio.post(
        'https://koshish-backend.vercel.app/api/event/create',
      );

      if(response.statusCode == 200)
        {
          return true;
        }
      else{
        throw Exception;
      }
    } on Exception catch (e) {
      log('create event exception : ${e.toString()}');
      return false;
    }
    
    
  }

  
}