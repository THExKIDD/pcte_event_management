import 'package:flutter/material.dart';

class StudentRegistrationScreen extends StatefulWidget {
  @override
  _StudentRegistrationScreenState createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  List<TextEditingController> controllers = [TextEditingController()];

  void addField() {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void removeField(int index) {
    if (controllers.length > 1) {
      setState(() {
        controllers.removeAt(index); // Remove the specific field
      });
    }
  }

  void register() {
    for (var controller in controllers) {
      print("Student Name: ${controller.text}");
    }
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
          icon: Icon(Icons.delete, color: Colors.red), // Change to dustbin icon
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
                child: Text("Add More Student", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Custom background color
                  padding: EdgeInsets.symmetric(vertical: 12), // Adjusted padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 50,
              width: double.infinity, // Make the button take full width
              margin: EdgeInsets.symmetric(horizontal: 16), // Add horizontal margin
              child: ElevatedButton(
                onPressed: register,
                child: Text("Register", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9E2A2F), // Custom background color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}