import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/Api_Calls/event_api_calls.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/widgets/drop_box.dart';
import 'package:pcte_event_management/widgets/dropdown.dart';
import 'package:provider/provider.dart';

import '../Controllers/signup_controller.dart';
import '../Providers/dropdown_provider.dart';
import '../Providers/login_provider.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final _formKey = GlobalKey<FormState>();
  final secureStorage = SecureStorage();
  String eventName = '';
  String description = '';
  int maxStudents = 1;
  int minStudents = 1;
  String location = '';
  int points = 0;

  final List<TextEditingController> _rulesControllers =
  List.generate(3, (index) => TextEditingController());
  final List<TextEditingController> _pointsControllers =
  List.generate(3, (index) => TextEditingController());

  final FocusNode _descriptionFocus = FocusNode();
  final _participationTypeFocus = FocusNode();

  final Color primaryColor = const Color(0xFF9E2A2F);

  @override
  void dispose() {
    for (var controller in _rulesControllers) {
      controller.dispose();
    }
    for (var controller in _pointsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addRuleField() {
    setState(() {
      _rulesControllers.add(TextEditingController());
    });
  }

  void _removeRuleField() {
    if (_rulesControllers.isNotEmpty) {
      setState(() {
        _rulesControllers.removeLast();
      });
    }
  }

  void _addPointField() {
    setState(() {
      _pointsControllers.add(TextEditingController());
    });
  }

  void _removePointField() {
    if (_pointsControllers.isNotEmpty) {
      setState(() {
        _pointsControllers.removeLast();
      });
    }
  }

  // Future<String?> getUser()async{
  //   final apiCall = ApiCalls();
  //   await apiCall.getEventUser();
  //   return await secureStorage.getData('event_user_id');
  // }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Event",
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
              ),

              SizedBox(height: screenSize.height * 0.02),

              // DropDown.showDropDown("Event Type", const Icon(Icons.event, color: Colors.black), ["Junior", "Senior"], _participationTypeFocus,),
              // SizedBox(height: screenSize.height * 0.02),
              //
              // DropDown.showDropDown("Participation Type", const Icon(Icons.group, color: Colors.black), ["Solo", "Group"], _descriptionFocus),
              // SizedBox(height: screenSize.height * 0.02),

              DropDownBox(
                items: ["Junior", "Senior"],
                labelText: "Event Type",
                icon: const Icon(Icons.event, color: Colors.black),
                dropdownKey: "eventType", // Unique key
              ),
              SizedBox(height: screenSize.height * 0.02),

              DropDownBox(
                items: ["Solo", "Group"],
                labelText: "Participation Type",
                icon: const Icon(Icons.group, color: Colors.black),
                dropdownKey: "participationType", // Unique key
              ),

              SizedBox(height: screenSize.height * 0.02),
              _buildTextField(
                label: "Description",
                maxLines: 3,
                onChanged: (value) => description = value,
                focusNode: _descriptionFocus,
              ),

              SizedBox(height: screenSize.height * 0.02),

              _buildDynamicFields("Rules", _rulesControllers, _addRuleField, _removeRuleField),
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

              _buildDynamicFields("Points", _pointsControllers, _addPointField, _removePointField),
              SizedBox(height: screenSize.height * 0.04),

              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: screenSize.width * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),onPressed: () async{
                    if (_formKey.currentState!.validate()) {
                      final apiCall = ApiCalls();
                      SignupController signupController = SignupController(apiCall);
                      String? token = await secureStorage.getData('jwtToken');
                      await apiCall.getUserCall(token!);
                      // String? usr = await secureStorage.getData('user_id');
                      // log('user  $usr');

                      final dropDownProvider = Provider.of<DropDownProvider>(context, listen: false);

                      String type = dropDownProvider.getSelectedValue("eventType") ?? "Junior";
                      String partType = dropDownProvider.getSelectedValue("participationType") ?? "Solo";

                      print('Event Created with Type: $type and Participation: $partType');

                      // Extracting dynamic fields (Rules & Points)
                      List<String> rules = _rulesControllers.map((controller) => controller.text).toList();
                      List<int> points = _pointsControllers
                          .where((controller) => controller.text.isNotEmpty) // Ensure non-empty values
                          .map((controller) => int.tryParse(controller.text) ?? 0) // Convert to int safely
                          .toList();
                      log("Extracted Points: $points");

                      signupController.createEventInfo(
                        name: eventName,
                        type: type,  // Using extracted eventType
                        part_type: partType, // Using extracted participationType
                        description: description,
                        rules: rules,
                        maxStudents: maxStudents,
                        minStudents: minStudents,
                        location: location,
                        points: points,
                        // convenor: usr!,
                      );

                      await apiCall.createEventCall(signupController.createEventCred,token).then((value){
                          if(value){
                             ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Event is created successfully '
                                  )
                              ),
                            );
                          }else{
                             ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Unexpected Error Occured \n Please Try Again Later...'
                                  )
                              ),
                            );
                          }
                      });
                      print('Event Created with Type: $type and Participation: $partType');
                    }
                  },

                    child: const Text("Save Event", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFields(String label, List<TextEditingController> controllers, VoidCallback addField, VoidCallback removeField) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ...controllers.map((controller) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black45),
              ),
            ),
          ),
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: addField,
              icon: const Icon(Icons.add, color: Colors.blue),
              label: Text("Add $label", style: const TextStyle(color: Colors.blue)),
            ),
            TextButton.icon(
              onPressed: removeField,
              icon: const Icon(Icons.remove, color: Colors.red),
              label: Text("Remove $label", style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }
}
Widget _buildTextField({
  required String label,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  TextInputAction textInputAction = TextInputAction.done,
  FocusNode? focusNode,
  required Function(String) onChanged,
}) {
  return TextFormField(
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black45),
      ),
    ),
    maxLines: maxLines,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    focusNode: focusNode,
    onChanged: onChanged,
  );

}