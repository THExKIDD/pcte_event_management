import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pcte_event_management/Api_Calls/class_api.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/Models/class_model.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _controllerClassName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final storage = FlutterSecureStorage();
  final SecureStorage secureStorage = SecureStorage();

  late AnimationController _animationController;
  late Animation<double> _bubbleAnimation;

  String? _selectedLevel; // Holds the selected dropdown value

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _bubbleAnimation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  String convertClassNameToUsername(String className) {
    return className.toLowerCase().replaceAll(' ', '');
  }

  void _createClass() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLevel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select Junior or Senior")),
        );
        return;
      }

      final sendData = ClassModel(
          name: _controllerClassName.text,
          email: _controllerEmail.text,
          username: convertClassNameToUsername(_controllerClassName.text),
          password: _controllerPassword.toString(),
          type: _selectedLevel,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());

     

      final response = await ApiService.createClass(sendData);

      log('response of class : $response');

      if (response == 'Successfull') {
        _scaffoldMessanger('class created Successfull ', Colors.green);
      } else if (response == 'Failure') {
        _scaffoldMessanger('class creation failed', Colors.red);
      } else if (response == 'No Internet') {
        _scaffoldMessanger('No Internet ', Colors.red);
      } else if (response == 'Timeout') {
        _scaffoldMessanger('Timeout Error', Colors.red);
      } else {
        _scaffoldMessanger(
            'class creation failed : Unexpected Error ', Colors.red);
      }
      Navigator.of(context).pop();
    }
  }

  void _scaffoldMessanger(String input, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(input),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildGradientBackground(),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Stack(
                  children: [
                    _buildBubble(size, 60, Colors.red.withOpacity(0.3), -40,
                        _bubbleAnimation.value),
                    _buildBubble(size, 90, Colors.red.withOpacity(0.2),
                        size.width - 80, -_bubbleAnimation.value),
                    _buildBubble(size, 70, Colors.red.withOpacity(0.1), 30,
                        size.height * 0.4 + _bubbleAnimation.value),
                    _buildBubble(
                        size,
                        100,
                        Colors.red.withOpacity(0.3),
                        size.width - 100,
                        size.height * 0.7 - _bubbleAnimation.value),
                  ],
                );
              },
            ),
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(size),
                  SizedBox(height: size.height * 0.05),
                  _buildCreateClassCard(size),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFA8072), Color(0xFFFFDAB9)],
        ),
      ),
    );
  }

  Widget _buildBubble(
      Size size, double diameter, Color color, double left, double top) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
                color: Colors.red.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: size.height * 0.15,
          child: Image.asset("assets/img/logo1.png"),
        ),
      ],
    );
  }

  Widget _buildCreateClassCard(Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 3)
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              "Create a New Class",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: size.height * 0.02),
            _buildTextField("Class Name", Icons.class_, _controllerClassName,
                TextInputType.text),
            SizedBox(height: size.height * 0.02),
            _buildTextField("Email", Icons.email_outlined, _controllerEmail,
                TextInputType.emailAddress),
            SizedBox(height: size.height * 0.02),
            _buildTextField("Password", Icons.lock_outline, _controllerPassword,
                TextInputType.visiblePassword,
                obscureText: true),
            SizedBox(height: size.height * 0.03),
            _buildDropdown(size),
            SizedBox(height: size.height * 0.03),
            _buildCreateButton(size),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller,
    TextInputType inputType, {
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black45),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "Please enter $label." : null,
    );
  }

  Widget _buildDropdown(Size size) {
    return DropdownButtonFormField<String>(
      value: _selectedLevel,
      decoration: InputDecoration(
        labelText: "Select Level",
        prefixIcon: Icon(Icons.school_outlined, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: ["Junior", "Senior"].map((level) {
        return DropdownMenuItem(value: level, child: Text(level));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLevel = value;
        });
      },
      validator: (value) => value == null ? "Please select a level" : null,
    );
  }

  Widget _buildCreateButton(Size size) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF9E2A2F),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
      ),
      onPressed: _createClass,
      child: Text(
        "Create Class",
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controllerClassName.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}
