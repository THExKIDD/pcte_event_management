import 'package:flutter/material.dart';
import 'package:pcte_event_management/Providers/pass_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _bubbleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);

    _bubbleAnimation = Tween<double>(begin: -20, end: 20)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
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
                  _buildBubble(size, 60, Colors.redAccent.withOpacity(0.3), -40, _bubbleAnimation.value),
                  _buildBubble(size, 90, Colors.red.withOpacity(0.2), size.width - 80, -_bubbleAnimation.value),
                  _buildBubble(size, 70, Colors.redAccent.withOpacity(0.2), 30, size.height * 0.4 + _bubbleAnimation.value),
                  _buildBubble(size, 100, Colors.red.withOpacity(0.3), size.width - 100, size.height * 0.7 - _bubbleAnimation.value),
                ],
              );
            },
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(size),
                SizedBox(height: size.height * 0.05),
                _buildSignupCard(size),
              ],
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
          colors: [Color(0xFFFA8072), Color(0xFFFFDAB9)],// Maroon gradient
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
            BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 5),
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

  Widget _buildSignupCard(Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 3),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              "Register",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              "Create your account",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            SizedBox(height: size.height * 0.03),
            _buildTextField("Username", Icons.person_outline, _controllerUsername, TextInputType.name),
            SizedBox(height: size.height * 0.02),
            _buildTextField("Email", Icons.email_outlined, _controllerEmail, TextInputType.emailAddress),
            SizedBox(height: size.height * 0.02),
            Consumer<PassProvider>(
              builder: (context, passCheck, child) {
                return _buildTextField(
                  "Password",
                  Icons.lock_outline,
                  _controllerPassword,
                  TextInputType.visiblePassword,
                  obscureText: passCheck.obscurePass,
                  suffixIcon: IconButton(
                    icon: Icon(passCheck.obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => passCheck.passHider(),
                  ),
                );
              },
            ),
            SizedBox(height: size.height * 0.02),
            Consumer<PassProvider>(
              builder: (context, passCheck, child) {
                return _buildTextField(
                  "Confirm Password",
                  Icons.lock_outline,
                  _controllerConfirmPassword,
                  TextInputType.visiblePassword,
                  obscureText: passCheck.obscurePass,
                  suffixIcon: IconButton(
                    icon: Icon(passCheck.obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => passCheck.passHider(),
                  ),
                );
              },
            ),
            SizedBox(height: size.height * 0.03),
            _buildSignupButton(size),
            SizedBox(height: size.height * 0.02),
            _buildLoginOption(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, TextInputType type,
      {bool obscureText = false, Widget? suffixIcon}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black45),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? "Please enter $label." : null,
    );
  }

  Widget _buildSignupButton(Size size) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF9E2A2F),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
      ),
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
        }
      },
      child: const Text("Register", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildLoginOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800000))), // Maroon color
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
