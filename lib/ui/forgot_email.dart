import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home.dart';

class ForgotEmail extends StatefulWidget {
  const ForgotEmail({super.key});

  @override
  State<ForgotEmail> createState() => _ForgotEmailState();
}

class _ForgotEmailState extends State<ForgotEmail> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodeUserName = FocusNode();
  final TextEditingController _controllerEmail = TextEditingController();


  late AnimationController _animationController;
  late Animation<double> _bubbleAnimation;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _bubbleAnimation = Tween<double>(begin: -20, end: 20).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
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
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text("Forgot Password ?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: size.height * 0.01),

            _buildTextField(_focusNodeUserName, "Email", Icons.person_outline, _controllerEmail, TextInputType.name),
            SizedBox(height: size.height * 0.02),
            SizedBox(height: size.height * 0.03),
            _buildLoginButton(size),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(FocusNode focusNode, String label, IconData icon, TextEditingController controller, TextInputType type,
      {bool obscureText = false, Widget? suffixIcon}) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      keyboardType: type,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLoginButton(Size size) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF9E2A2F),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () async {
        if (_formKey.currentState?.validate() ?? false) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }
      },
      child: const Text("Send OTP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controllerEmail.dispose();

    super.dispose();
  }
}
