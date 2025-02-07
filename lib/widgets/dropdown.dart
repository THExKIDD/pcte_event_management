import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Providers/login_provider.dart';
import 'package:provider/provider.dart';

import '../LocalStorage/Secure_Store.dart';
import '../LocalStorage/StoringUser.dart';

class DropDown{
  static late String? userType;

  static Widget showDropDown(String labelText, Icon icon,List<String> listItems, FocusNode nextFocus){

    return Consumer<LoginProvider>(
      builder: (context,dropDownValue,child) {

        return DropdownButtonFormField(
          dropdownColor: Color.fromRGBO(247, 240, 238, 1),
          items: listItems.map((String item){
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue)async{
            if (newValue != null) {
              await StoreUser.saveUserType(newValue);// Save selected value
              print("Doneeeee");
            } else{
              print("Nullllll");
            }
            // userType = newValue;
            // await SecureStorage().saveData("user_type", newValue!);
            // String? s = await SecureStorage().getData("user_type");
            // print('object ::::: $s');
            dropDownValue.updateSelectedValue(newValue);
            FocusScope.of(context).requestFocus(nextFocus);
          },
          validator: (value) => value == null ? "Please Select an Option" : null,
          hint: Text(labelText),
          decoration: InputDecoration(
            prefixIcon: icon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black45),
            ),
            label: Text(labelText),
          ),
        );

      },

    );

  }


}