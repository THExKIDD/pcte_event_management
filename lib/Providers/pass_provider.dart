import 'package:flutter/material.dart';

class PassProvider with ChangeNotifier
{

  bool _obscurePass = true;
  bool _signObscurePass = true;
  bool _isSearching = false;


  bool get obscurePass => _obscurePass;
  bool get signObscurePass => _signObscurePass;
  bool get isSearching => _isSearching;



  bool defaultPassHider(bool obscurePass){

    bool visibility = !obscurePass;
    notifyListeners();
    return visibility;


  }

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


  void searchState(){

    _isSearching = !_isSearching;
    notifyListeners();

  }






}