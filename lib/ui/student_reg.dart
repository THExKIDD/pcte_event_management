import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/Registration_api_calls.dart';

class StudentRegistrationScreen extends StatefulWidget {
  final String eventId;
  final int minStudents;
  final int maxStudents;
  final List<dynamic>? registeredStudentNames;
  final String? registrationId;
  final String? classId;
  const StudentRegistrationScreen({
    super.key,
    required this.eventId,
    required this.minStudents,
    required this.maxStudents,
    this.registeredStudentNames,
    this.registrationId,
    this.classId
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
    // Initialize controllers based on registeredStudentNames if available
    if (widget.registeredStudentNames != null && widget.registeredStudentNames!.isNotEmpty) {
      for (String name in widget.registeredStudentNames!) {
        controllers.add(TextEditingController(text: name));
      }
    } else {
      // Otherwise initialize with minStudents count
      for (int i = 0; i < widget.minStudents; i++) {
        controllers.add(TextEditingController());
      }
    }

    log(widget.registeredStudentNames.toString());
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
    if (controllers.length > widget.minStudents) {
      setState(() {
        controllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Minimum ${widget.minStudents} students required'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          )
      );
    }
  }


  Future<void> updateRegistration() async {
    for (var controller in controllers) {
      log("Student Name: ${controller.text}");
      studentNames.add(controller.text);

    }

    log(studentNames.toString());
    RegistrationApiCalls registrationApiCalls = RegistrationApiCalls();
    setState(() {
      isLoading = true;
    });
    final val =  await registrationApiCalls.updateRegistrationApi(studentNames: studentNames, eventId: widget.eventId, registrationId: widget.registrationId!, classId: widget.classId);

    if(val.isNotEmpty)
    {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Successful'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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
            behavior: SnackBarBehavior.floating,
          )
      );
    }



    for (var controller in controllers) {
      controller.text = '';

    }

    FocusScope.of(context).unfocus();
    if (mounted) {
      Navigator.pop(context,true);
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

    if(val.isNotEmpty)
      {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Successful'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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
            behavior: SnackBarBehavior.floating,
          )
      );
    }



    for (var controller in controllers) {
      controller.text = '';

    }

    FocusScope.of(context).unfocus();
    if (mounted) {
      Navigator.pop(context,true);
    }


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
    bool canDelete = controllers.length > widget.minStudents;  // Only show delete button if we have more than minStudents

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black45),
        ),
        suffixIcon: canDelete
            ? IconButton(
          icon: Icon(Icons.delete, color: Color(0xFF9E2A2F)),
          onPressed: () {
            removeField(controllers.indexOf(controller));
          },
        )
            : null,  // Hide delete button if we can't delete
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
    bool isRegistered = widget.registeredStudentNames != null && widget.registeredStudentNames!.isNotEmpty;
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
                onPressed: isRegistered ? updateRegistration : register,
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