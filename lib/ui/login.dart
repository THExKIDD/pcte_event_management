import 'package:flutter/material.dart';
import 'package:pcte_event_management/Providers/pass_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'home.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FocusNode _focusNodePassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

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
                _buildLoginCard(size),
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
          colors: [Color(0xFFFA8072), Color(0xFFFFDAB9)], // Soft red-orange gradient
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

  Widget _buildLoginCard(Size size) {
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
              "Welcome Back",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              "Login to your account",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            SizedBox(height: size.height * 0.03),
            _buildTextField("Username", Icons.person_outline, _controllerUsername, TextInputType.name),
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
            SizedBox(height: size.height * 0.03),
            _buildLoginButton(size),
            SizedBox(height: size.height * 0.02),
            _buildSignupOption(),
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

  Widget _buildLoginButton(Size size) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF9E2A2F),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
      ),
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      },
      child: const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildSignupOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () {
            _formKey.currentState?.reset();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Signup()));
          },
          child: const Text("Signup", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9E2A2F))),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}
