import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/Registration_api_calls.dart';

class StudentRegistrationScreen extends StatefulWidget {
  final String eventId;
  final int minStudents;
  final int maxStudents;
  const StudentRegistrationScreen({
    super.key,
    required this.eventId,
    required this.minStudents,
    required this.maxStudents,
  });

  @override
  State<StudentRegistrationScreen> createState()  => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  List<TextEditingController> controllers = [];
  List<String> studentNames = [];
  bool isLoading = false;


  @override
  void initState() {
    for(int i = 0; i < widget.minStudents; i++)
    {
      controllers.add(TextEditingController());
    }
    super.initState();
  }

  @override
  void dispose() {
    for(var controller in controllers)
      {
        controller.dispose();
      }
    super.dispose();
  }

  void addField() {


    if(controllers.length < widget.maxStudents)
      {
        setState(() {
          controllers.add(TextEditingController());
        });
      }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Max limit reached'
              ),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          )
      );
    }
  }

  void removeField(int index) {
    if (controllers.length > 1) {
      setState(() {
        controllers.removeAt(index); // Remove the specific field
      });
    }
  }

  Future<void> register() async {
    for (var controller in controllers) {
      log("Student Name: ${controller.text}");
      studentNames.add(controller.text);

    }

    log(studentNames.toString());
    RegistrationApiCalls registrationApiCalls = RegistrationApiCalls();
    setState(() {
      isLoading = true;
    });
    final val =  await registrationApiCalls.registerStudentApi(studentNames,widget.eventId);

    if(val)
      {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Successful'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          )
        );
      }
    else{
      setState(() {
        isLoading =false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Failed\nTry Again Later'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          )
      );
    }



    for (var controller in controllers) {
      controller.text = '';

    }

    FocusScope.of(context).unfocus();
    Navigator.pop(context);


    // You can add backend API integration here
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    FocusNode? focusNode,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black45),
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.delete, color: Color(0xFF9E2A2F)), // Change to dustbin icon
          onPressed: () {
            removeField(controllers.indexOf(controller));
          },
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Registration', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF9E2A2F),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0), // Padding between text fields
                    child: _buildTextField(
                      label: 'Student Name ${index + 1}',
                      controller: controllers[index],
                      onChanged: (value) {
                        // You can handle the change if needed
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 50,
              width: double.infinity, // Make the button take full width
              margin: EdgeInsets.symmetric(horizontal: 16), // Add horizontal margin
              child: ElevatedButton(
                onPressed: addField,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Custom background color
                  padding: EdgeInsets.symmetric(vertical: 12), // Adjusted padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: Text("Add More Student", style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 50,
              width: double.infinity, // Make the button take full width
              margin: EdgeInsets.symmetric(horizontal: 16), // Add horizontal margin
              child: ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9E2A2F), // Custom background color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: isLoading ?  Center(child: CircularProgressIndicator(),) :Text("Register", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}