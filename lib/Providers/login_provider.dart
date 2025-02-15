import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';

class LoginProvider with ChangeNotifier{

  String? _selectedValue;

  SecureStorage secureStorage = SecureStorage();

  String? get selectedValue => _selectedValue;



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

  Future<void> onLogOut()
  async {
    await secureStorage.saveData('user_type', null);
    notifyListeners();
    notifyListeners();
    log("token deleted");

  }





}