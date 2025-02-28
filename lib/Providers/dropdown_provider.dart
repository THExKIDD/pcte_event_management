import 'package:flutter/material.dart';

class DropDownProvider extends ChangeNotifier {
  final Map<String, String?> _selectedValues = {};

  String? getSelectedValue(String key) => _selectedValues[key];

  void setSelectedValue(String key, String? value) {
    _selectedValues[key] = value;
    notifyListeners(); // Notify UI to rebuild
  }
}
