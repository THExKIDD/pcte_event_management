import 'package:flutter/cupertino.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/Models/event_model.dart';
import 'package:pcte_event_management/Models/user_model.dart';

class SignupController {
  final ApiCalls apiCall;
  final secureStorage = SecureStorage();
  late UserModel signupCred;
  late EventModel createEventCred;



  // Constructor that accepts an ApiCalls instance
  SignupController(this.apiCall);

  Future<void> signInfo({
    required BuildContext ctx,
    required String name,
    required String email,
    required String phn_no,
    required String password,
    required String userType
  }) async {
    signupCred = UserModel(
      userName: name,
      email: email,
      phoneNumber: phn_no,
      password: password,
      userType: userType,
    );
  }

  Future<void> createEventInfo({
    required String name,
    required String type,
    required String part_type,
    required String description,
    required List<String> rules,
    required int maxStudents,
    required int minStudents,
    required String location,
    required List<int> points,
    // required String? convenor
  })async {
    createEventCred = EventModel(
      name: name,
      type: type,
      partType: part_type,
      description: description,
      rules: rules,
      maxStudents: maxStudents,
      minStudents: minStudents,
      location: location,
      points: points,
      // convenor: convenor,
    );
  }
}
