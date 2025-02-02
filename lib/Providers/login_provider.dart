import 'package:flutter/material.dart';

class LoginProvider with ChangeNotifier{

  String? _selectedValue;

  String? get selectedValue => _selectedValue;

  void updateSelectedValue(String? newValue)
  {
    _selectedValue = newValue;
    notifyListeners();
  }

}