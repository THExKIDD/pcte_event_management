import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/Api_Calls/class_api.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/Models/class_model.dart';

class UpdateClasscreen extends StatefulWidget {
  final ClassModel classData;
  const UpdateClasscreen({super.key, required this.classData});

  @override
  State<UpdateClasscreen> createState() => _UpdateClasscreenState();
}

class _UpdateClasscreenState extends State<UpdateClasscreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController controllerClassName = TextEditingController();
  TextEditingController controllerClassIncharge = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  final storage = FlutterSecureStorage();
  final SecureStorage secureStorage = SecureStorage();

  List<Map<String, dynamic>> inchargeList = [];

  late AnimationController _animationController;
  late Animation<double> _bubbleAnimation;
  bool isLoading = false;
  String? selectedValue;
  String? _selectedLevel; // Holds the selected dropdown value

  @override
  void initState() {
    super.initState();
    startupfunction();
    // _valueprovider();
    // inchargeList = itemsGetter();
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 5),
    // )..repeat(reverse: true);

    // _bubbleAnimation = Tween<double>(begin: -20, end: 20).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    // );
  }

  void startupfunction() async {
    _valueprovider();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _bubbleAnimation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    inchargeList = await itemsGetter();
  }

  String convertClassNameToUsername(String className) {
    return className.toLowerCase().replaceAll(' ', '');
  }

  void _valueprovider() async {
    setState(() {
      controllerClassName.text = widget.classData.name!;
      controllerEmail.text = widget.classData.email!;

      _selectedLevel = widget.classData.type!;
    });
  }

  Future<List<Map<String, dynamic>>> itemsGetter() async {
    try {
      SecureStorage secureStorage = SecureStorage();
      ApiCalls apiCalls = ApiCalls();

      String? token = await secureStorage.getData('jwtToken');
      log(token ?? 'no token');

      final items = await apiCalls.getFacultyCall(token!);

      List<Map<String, dynamic>> values = items
          .map((toElement) => {
                'id': toElement['_id'].toString(),
                'name': toElement['name'].toString(),
              })
          .toList();
      log('  string  $values');

      return values;
    } on Exception catch (e) {
      log(e.toString());
      return [];
    }
  }

  void _updateClass() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLevel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select Junior or Senior")),
        );
        return;
      }
      setState(() {
        isLoading = true;
      });

      final sendData = ClassModel(
          id: widget.classData.id,
          name: controllerClassName.text,
          email: controllerEmail.text,
          username: convertClassNameToUsername(controllerClassName.text),
          password: controllerPassword.toString(),
          incharge: selectedValue,
          type: _selectedLevel,
          updatedAt: DateTime.now());

      if (widget.classData.id == null ||
          widget.classData.id.toString().isEmpty) {
        _scaffoldMessanger('class id is not valid ', Colors.red[700]!);
        return;
      }

      log('sed    ${jsonEncode(sendData)}');

      final response =
          await ApiService.updateClass(sendData, widget.classData.id!);

      log('response of class : $response');
      setState(() {
        isLoading = false;
      });

      if (response == 'Successfull') {
        _scaffoldMessanger('class Updated Successfull ', Colors.green);
      } else if (response == 'Failure') {
        _scaffoldMessanger('class Updation failed', Colors.red);
      } else if (response == 'No Internet') {
        _scaffoldMessanger('No Internet ', Colors.red);
      } else if (response == 'Timeout') {
        _scaffoldMessanger('Timeout Error', Colors.red);
      } else {
        _scaffoldMessanger(
            'class creation failed : Unexpected Error ', Colors.red);
      }
      // Navigator.of(context).pop();
    }
  }

  void _scaffoldMessanger(String input, Color color) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(input),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, true);
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
                    _buildBubble(size, 60, Colors.red.withValues(alpha: 0.3),
                        -40, _bubbleAnimation.value),
                    _buildBubble(size, 90, Colors.red.withValues(alpha: 0.3),
                        size.width - 80, -_bubbleAnimation.value),
                    _buildBubble(size, 70, Colors.red.withValues(alpha: 0.3),
                        30, size.height * 0.4 + _bubbleAnimation.value),
                    _buildBubble(
                        size,
                        100,
                        Colors.red.withValues(alpha: 0.3),
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
            if (isLoading)
              Positioned(
                  child: Center(
                child: CircularProgressIndicator(
                  strokeAlign: 5,
                  strokeWidth: 5,
                  color: Colors.red[700],
                ),
              ))
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
              "Update a ${widget.classData.name}",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: size.height * 0.02),
            _buildTextField("Class Name", Icons.class_, controllerClassName,
                TextInputType.text),
            SizedBox(height: size.height * 0.02),
            _buildTextField("Email", Icons.email_outlined, controllerEmail,
                TextInputType.emailAddress),
            SizedBox(height: size.height * 0.02),
            _inchargeDropDownButton(inchargeList),
            SizedBox(height: size.height * 0.02),
            _buildTextField("Password", Icons.lock_outline, controllerPassword,
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
        backgroundColor: !isLoading ? Color(0xFF9E2A2F) : null,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // elevation: 5,
      ),
      onPressed: _updateClass,
      child: Text(
        "Update Class",
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _inchargeDropDownButton(List<Map<String, dynamic>> inchargelist) {
    final size = MediaQuery.of(context).size;
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: const Row(
          children: [
            Icon(
              Icons.list,
              size: 24,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Text(
                'Select Item',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        items: inchargelist
            .map<DropdownMenuItem<String>>((item) => DropdownMenuItem<String>(
                  value: item['id'].toString(),
                  child: Text(
                    item['name'].toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 11, 11, 11),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        value: selectedValue,
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
        },
        buttonStyleData: ButtonStyleData(
          height: size.height * 0.08,
          width: size.width * 0.8,
          padding: const EdgeInsets.only(left: 20, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black26,
            ),
            color: const Color.fromARGB(255, 255, 252, 252),
          ),
          elevation: 0,
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.arrow_forward_ios_outlined,
          ),
          iconSize: 18,
          iconEnabledColor: Color.fromARGB(255, 0, 0, 0),
          iconDisabledColor: Colors.grey,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color.fromARGB(255, 241, 240, 240),
          ),
          offset: const Offset(-10, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(3),
            thumbVisibility: MaterialStateProperty.all(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 40, right: 14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controllerClassName.dispose();
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }
}
