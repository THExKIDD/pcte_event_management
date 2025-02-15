import 'package:flutter/cupertino.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/Models/user_model.dart';
import 'package:pcte_event_management/Providers/login_provider.dart';
import 'package:provider/provider.dart';

class LoginController {
  final ApiCalls apiCall;
  late UserModel loginCred;

  // Constructor that accepts an ApiCalls instance
  LoginController(this.apiCall);

  Future<void> logInfo({required BuildContext ctx, required String email, required String password}) async {
    loginCred = UserModel(
      userType: Provider.of<LoginProvider>(ctx, listen: false).selectedValue.toString(),
      email: email,
      password: password,
    );

  }
}