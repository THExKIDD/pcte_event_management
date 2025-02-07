import 'package:flutter/cupertino.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/Models/user_model.dart';
import 'package:pcte_event_management/Providers/login_provider.dart';
import 'package:provider/provider.dart';

class SignupController {
  final ApiCalls apiCall;

  late UserModel signupCred;

  // Constructor that accepts an ApiCalls instance
  SignupController(this.apiCall);

    Future<void> signInfo({required BuildContext ctx, required ,required String name,required String email,required String phn_no, required String password,}) async {
      signupCred = UserModel(
        userType: Provider.of<LoginProvider>(ctx, listen: false).selectedValue.toString(),
        userName : name,
        email: email,
        phoneNumber: phn_no,
        password: password,
      );

  }}