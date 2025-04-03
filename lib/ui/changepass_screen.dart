import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/ui/login.dart';
import 'package:provider/provider.dart';
import '../widgets/button.dart';
import 'home.dart';

class ChangePassScreen extends StatefulWidget {
  final String email;
  final String otp;
  const ChangePassScreen({super.key, required this.email, required this.otp});

  @override
  State<ChangePassScreen> createState() => _ChangePassScreenState();
}

class _ChangePassScreenState extends State<ChangePassScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _newPassFocus = FocusNode();
  final _confirmPassFocus = FocusNode();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _bubbleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);
    _bubbleAnimation = Tween<double>(begin: -20, end: 20).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).nextFocus(); // Move to the next field
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus(); // Move to the previous field
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildBubble(size, 60, Color.fromRGBO(255, 0, 0, 0.3), -40,
                      _bubbleAnimation.value),
                  _buildBubble(
                      size, 90, Color.fromRGBO(255, 0, 0, 0.2), size.width - 80,
                      -_bubbleAnimation.value),
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
                _buildOtpCard(size),
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

  Widget _buildBubble(Size size, double diameter, Color color, double left,
      double top) {
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

  Widget _buildOtpCard(Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildTextField(
                  (_){},
              _newPassFocus,
              'New Password',
              Icons.lock,
              _newPassController,
              TextInputType.text,
            obscureText: true,
          ),
          SizedBox(height: size.height * 0.03),
          _buildTextField(
                (_){},
            _confirmPassFocus,
            'Confirm Password',
            Icons.lock,
            _confirmPassController,
            TextInputType.text,
            obscureText: true,
          ),
          SizedBox(height: size.height * 0.03),
          _buildSubmitButton(size),
          SizedBox(height: size.height * 0.03),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Size size) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Set Password',
        onPressed: () {

          ApiCalls apiCalls = ApiCalls();

          if(comparePass()){

            apiCalls.forgotPass(
                Email: widget.email,
                Otp: widget.otp,
                NewPass: _confirmPassController.text).then((value){
                  if(value){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password Changed')));
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
                  }
            });

          }

          }, // Optional: Change the border radius
      ),
    );
  }

  bool comparePass(){
    if(_newPassController.text != _confirmPassController.text){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("passwords doesn't match")));
      return false;
    }
    else{
      return true;
    }
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


}