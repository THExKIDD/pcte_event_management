import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/Api_Calls/class_api.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/Models/user_model.dart';
import 'package:pcte_event_management/ui/bottomNavBar.dart';

class ClassLogin extends StatefulWidget {
  const ClassLogin({super.key});

  @override
  State<ClassLogin> createState() => _ClassLoginState();
}

class _ClassLoginState extends State<ClassLogin> with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _bubbleAnimation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _bubbleAnimation = Tween<double>(begin: -20, end: 20).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildBubble(size, 60, Color.fromRGBO(255, 0, 0, 0.3), -40, _bubbleAnimation.value),
                  _buildBubble(size, 90, Color.fromRGBO(255, 0, 0, 0.2), size.width - 80, -_bubbleAnimation.value),
                  _buildBubble(size, 70, Color.fromRGBO(255, 0, 0, 0.1), 30, size.height * 0.4 + _bubbleAnimation.value),
                  _buildBubble(size, 100, Color.fromRGBO(255, 0, 0, 0.3), size.width - 100, size.height * 0.7 - _bubbleAnimation.value),
                ],
              );
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLoginCard(size),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildBubble(Size size, double diameter, Color color, double left, double top) {
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
            BoxShadow(color: Color.fromRGBO(255, 0, 0, 0.5), blurRadius: 10, spreadRadius: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 3),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Welcome Back",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: size.height * 0.02),
          _buildTextField("Username", Icons.person, usernameController),
          SizedBox(height: size.height * 0.02),
          _buildTextField("Password", Icons.lock, passwordController, obscureText: true),
          SizedBox(height: size.height * 0.03),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9E2A2F),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 5,
            ),
            onPressed: () async {
              try {
                setState(() {
                  isLoading = true;
                });
                String username = usernameController.text;
                String password = passwordController.text;
                final classDetails = UserModel(userName: username,password: password);
                SecureStorage secureStorage = SecureStorage();
                ApiCalls apiCalls = ApiCalls();
                final data = await ApiService.classLogin(classDetails);

                String? s = await secureStorage.getData('jwtToken');

                await apiCalls.getUserCall(s!);
                ScaffoldMessenger
                    .of(context)
                    .showSnackBar(
                    SnackBar(
                      content: Text(data['message']),
                      backgroundColor: Colors.green,
                      duration: Duration(milliseconds: 800),
                    )
                );
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> BottomNavBar()));
              }catch (e) {
                 log(e.toString());
                 ScaffoldMessenger
                     .of(context)
                     .showSnackBar(
                     SnackBar(
                       content: Text(e.toString()),
                       backgroundColor: Colors.red,
                       duration: Duration(milliseconds: 700),
                     )
                 );

                 setState(() {
                   isLoading = false;
                 });
              }

            },
            child: isLoading
                ?
            Center(child: CircularProgressIndicator())
                :
            Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
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
    );
  }
}