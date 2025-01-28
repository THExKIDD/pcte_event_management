import 'package:flutter/material.dart';

class PassProvider with ChangeNotifier
{

  bool _obscurePass = true;

  bool get obscurePass => _obscurePass;

  void passHider ()
  {

    _obscurePass = !_obscurePass;
    notifyListeners();

  }
}