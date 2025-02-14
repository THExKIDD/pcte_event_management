import 'dart:developer';

import 'package:dio/dio.dart';

class ResultApiCalls
{
  
  final dio = Dio();

  Future<void> getResultById( {required String eventId}) async
  {
    
   try {
     final response = await dio.get('https://koshish-backend.vercel.app/api/result/get/$eventId');

     log(response.statusMessage.toString());
     log(response.data.toString());

     if(response.statusCode != 200)
       {
         throw Exception;
       }
   } on Exception catch (e) {
     log("result exception : ${e.toString()}");
   }
    
  }

}