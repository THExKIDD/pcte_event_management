import 'package:flutter/material.dart';

import 'dart:developer';

import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/Controllers/login_controller.dart';
import 'package:pcte_event_management/Models/user_model.dart';
import 'package:pcte_event_management/Providers/login_provider.dart';
import 'package:pcte_event_management/Providers/pass_provider.dart';
import 'package:pcte_event_management/widgets/dropdown.dart';
import 'package:provider/provider.dart';


import 'home.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeUserName = FocusNode();
  final FocusNode _focusNodeUserType = FocusNode();
  final FocusNode _focusNodeEmail = FocusNode();
  final TextEditingController _controllerUserName = TextEditingController();
  final FocusNode _focusNodePhone = FocusNode();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerPhone = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _bubbleAnimation;

  final dropDownList = ['Teacher','Convenor'];

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bul, obj){

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
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
                    _buildBubble(size, 60, Colors.redAccent.withOpacity(0.3), -40, _bubbleAnimation.value),
                    _buildBubble(size, 90, Colors.red.withOpacity(0.2), size.width - 80, -_bubbleAnimation.value),
                    _buildBubble(size, 70, Colors.redAccent.withOpacity(0.2), 30, size.height * 0.4 + _bubbleAnimation.value),
                    _buildBubble(size, 100, Colors.red.withOpacity(0.3), size.width - 100, size.height * 0.7 - _bubbleAnimation.value),
                  ],
                );
              },
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40),
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
              "PCTE",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              "Sign Up a User",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),

            ),

            SizedBox(height: size.height * 0.03),
            DropDown.showDropDown('Select User Type',dropDownList,_focusNodeUserType), // Ensure this is a valid widget
            SizedBox(height: size.height * 0.02),
            _buildTextField(
                (_){},
                _focusNodeUserName,
                'Name',
                Icons.person_outline,
                _controllerUserName,
                TextInputType.name
            ),
            SizedBox(height: size.height * 0.02),
            _buildTextField((_){

            },
                _focusNodeEmail,
                "Email",
                Icons.email_outlined,
                _controllerEmail,
                TextInputType.emailAddress
            ),
            SizedBox(height: size.height * 0.02),
            _buildTextField(
                    (_)
                {


                },
                _focusNodePhone,
                'Phone Number',
                Icons.phone,
                _controllerPhone,
                TextInputType.phone
            ),
            SizedBox(height: size.height * 0.02),
            Consumer<PassProvider>(
              builder: (context, passCheck, child) {
                return _buildTextField(
                      (value){
                    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                  },
                  _focusNodePassword,
                  "Password",
                  Icons.lock_outline,
                  _controllerPassword,
                  TextInputType.visiblePassword,
                  obscureText: passCheck.signObscurePass,
                  suffixIcon: IconButton(
                    icon: Icon(passCheck.obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => passCheck.signObscurePass,
                  ),
                );
              },
            ),

            SizedBox(height: size.height * 0.03),

            _buildLoginButton(size),

            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(Function(String)? onFinalSubmission, FocusNode focusNode, String label, IconData icon, TextEditingController controller, TextInputType type,
      {bool obscureText = false, Widget? suffixIcon}) {
    return TextFormField(
      onFieldSubmitted: onFinalSubmission,
      focusNode: focusNode,
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
      onPressed: () async {
        final apiCalls = ApiCalls();
        final loginController = LoginController(apiCalls);
        if (_formKey.currentState?.validate() ?? false) {

          loginController.logInfo(
              ctx: context,
              email: _controllerEmail.text,
              password: _controllerPassword.text
          );
          await apiCalls.loginCall(loginController.loginCred).then((value){
            if(value)
            {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen() ));
            }
          });

        }
      },
      child: const Text("Sign Up User", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }



  @override
  void dispose() {
    _animationController.dispose();
    _focusNodePassword.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _focusNodePhone.dispose();
    _controllerPhone.dispose();
    super.dispose();
  }
}
