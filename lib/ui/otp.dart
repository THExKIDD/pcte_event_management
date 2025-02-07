import 'dart:developer';
import 'package:flutter/material.dart';
import '../widgets/button.dart';
import 'home.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final List<TextEditingController> _controllers = List.generate(
      6, (index) => TextEditingController());
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
          Text("Enter OTP", style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return Container(
                width: 40,
                child: TextFormField(
                  controller: _controllers[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _onChanged(value, index);
                  },
                ),
              );
            }),
          ),
          SizedBox(height: size.height * 0.03),
          _buildSubmitButton(size),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Size size) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Verify OTP',
        onPressed: () {
          _submitOtp();
        }, // Optional: Change the border radius
      ),
    );
  }

  void _submitOtp() {
    String otp = _controllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      log("Entered OTP: $otp");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit OTP")),
      );
    }
  }
}