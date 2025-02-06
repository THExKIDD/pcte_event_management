import 'package:flutter/material.dart';

class PassProvider with ChangeNotifier
{

  bool _obscurePass = true;
  bool _signObscurePass = true;

  bool get obscurePass => _obscurePass;
  bool get signObscurePass => _signObscurePass;

  void passHider ()
  {

    _obscurePass = !_obscurePass;
    notifyListeners();

  }

  void signPassHider()
  {

    _signObscurePass = !_signObscurePass;
    notifyListeners();

  }



}