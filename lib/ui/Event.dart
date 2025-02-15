import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/Controllers/signup_controller.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/widgets/dropdown.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final _formKey = GlobalKey<FormState>();

  String eventName = '';
  String description = '';
  List<String> rules = [];
  int maxStudents = 1;
  int minStudents = 1;
  String location = '';
  String convener = '';
  List<int> points = [];

  final FocusNode _eventTypeFocus = FocusNode();
  final FocusNode _participationTypeFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  final Color primaryColor = const Color(0xFF9E2A2F); // Custom color

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Event Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.height * 0.02,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: "Event Name",
                onChanged: (value) => eventName = value,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_eventTypeFocus),
              ),

              SizedBox(height: screenSize.height * 0.02),

              // Event Type Dropdown with Event Icon
              DropDown.showDropDown(
                "Event Type",
                const Icon(Icons.event, color: Colors.black),
                ["Junior", "Senior"],
                _participationTypeFocus,
              ),

              SizedBox(height: screenSize.height * 0.02),

              // Participation Type Dropdown with Group Icon
              DropDown.showDropDown(
                "Participation Type",
                const Icon(Icons.group, color: Colors.black),
                ["Solo", "Group"],
                _descriptionFocus,
              ),

              SizedBox(height: screenSize.height * 0.02),

              _buildTextField(
                label: "Description",
                maxLines: 3,
                onChanged: (value) => description = value,
                focusNode: _descriptionFocus,
              ),

              SizedBox(height: screenSize.height * 0.02),

              _buildTextField(
                label: "Rules",
                maxLines: 3,
                onChanged: (value) => rules = [value],
              ),

              SizedBox(height: screenSize.height * 0.02),

              _buildTextField(
                label: "Minimum Students",
                keyboardType: TextInputType.number,
                onChanged: (value) => minStudents = int.tryParse(value) ?? 1,
              ),

              SizedBox(height: screenSize.height * 0.02),

              _buildTextField(
                label: "Maximum Students",
                keyboardType: TextInputType.number,
                onChanged: (value) => maxStudents = int.tryParse(value) ?? 1,
              ),

              SizedBox(height: screenSize.height * 0.02),

              _buildTextField(
                label: "Location",
                onChanged: (value) => location = value,
              ),

              SizedBox(height: screenSize.height * 0.02),

              _buildTextField(
                label: "Convener",
                onChanged: (value) => convener = value,
              ),

              SizedBox(height: screenSize.height * 0.02),

              _buildTextField(
                label: "Points",
                keyboardType: TextInputType.number,
                onChanged: (value) => points = [int.tryParse(value) ?? 0],
              ),

              SizedBox(height: screenSize.height * 0.04),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final secureStorage = SecureStorage();
                    final apiCall = ApiCalls();
                    final signupController = SignupController(apiCall);
                    String? tkn = await secureStorage.getData('jwtToken');
                    if (_formKey.currentState!.validate()) {
                      signupController.createEventInfo(
                          name: eventName,
                          type: "Junior",
                          part_type: "Solo",
                          description: description,
                          rules: rules,
                          maxStudents: maxStudents,
                          minStudents: minStudents,
                          location: location,
                          points: [1, 2, 3]);
                      apiCall
                          .createEventCall(
                              signupController.createEventCred, tkn.toString())
                          .then((value) => {
                                if (value)
                                  {
                                    log("Event Saved: $eventName"),
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Event Saved!")),
                                    )
                                  }
                                else
                                  {
                                    log("Unable to Save : "),
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Failed!")),
                                    ),
                                  }
                              });
                    }
                  },
                  child: const Text(
                    "Save Event",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for text fields with consistent styling and borders
  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    FocusNode? focusNode,
    required Function(String) onChanged,
    Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black45),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black45),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF9E2A2F)),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
