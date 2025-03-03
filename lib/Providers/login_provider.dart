import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
class LoginProvider with ChangeNotifier{

  String? _selectedValue;
  String? _anotherValue;
  SecureStorage secureStorage = SecureStorage();

  String? get selectedValue => _selectedValue;
  String? get anotherValue => _anotherValue;


  bool isLoading = false;




  void checkLoading()
  {
    isLoading = !isLoading;
    notifyListeners();
  }


  void updateSelectedValue(String? newValue)
  {
    _selectedValue = newValue;
    notifyListeners();
  }

  void updateTwoValue(String? valueOne , valueTwo)
  {
    _selectedValue = valueOne;
    _anotherValue = valueTwo;
    notifyListeners();
  }

  Future<void> onLogOut()
  async {
    await secureStorage.saveData('user_type', null);
    notifyListeners();
    notifyListeners();
    log("token deleted");

  }}