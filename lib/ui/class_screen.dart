import 'package:flutter/material.dart';

class CreateClassScreen1 extends StatefulWidget {
  @override
  _CreateClassScreenState createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen1>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _className = '';
  String _inchargeName = '';
  String _classType = 'Junior';
  late AnimationController _animationController;
  late Animation<double> _bubbleAnimation;
  final List<String> dropDownList = ['Junior', 'Senior'];

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
                  _buildBubble(size, 60, Colors.red.withOpacity(0.3), -40, _bubbleAnimation.value),
                  _buildBubble(size, 90, Colors.red.withOpacity(0.2), size.width - 80, -_bubbleAnimation.value),
                  _buildBubble(size, 70, Colors.red.withOpacity(0.1), 30, size.height * 0.4 + _bubbleAnimation.value),
                  _buildBubble(size, 100, Colors.red.withOpacity(0.3), size.width - 100, size.height * 0.7 - _bubbleAnimation.value),
                ],
              );
            },
          ),
          Center(
            child: _buildClassCard(size),
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
            BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10, spreadRadius: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: size.width * 0.8,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "Create New Class",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            _buildTextField("Class Name", Icons.class_, (value) {
              if (value!.isEmpty) return "Enter class name";
              return null;
            }, (value) => _className = value!),
            SizedBox(height: size.height * 0.02),
            _buildTextField("Incharge Name", Icons.person, (value) {
              if (value!.isEmpty) return "Enter incharge name";
              return null;
            }, (value) => _inchargeName = value!),
            SizedBox(height: size.height * 0.02),
            _buildDropdownField(),
            SizedBox(height: size.height * 0.03),
            _buildCreateClassButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, FormFieldValidator<String>? validator, FormFieldSetter<String>? onSaved) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _classType,
      items: dropDownList
          .map((type) => DropdownMenuItem(
        value: type,
        child: Text(type),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _classType = value!;
        });
      },
      decoration: InputDecoration(
        labelText: "Class Type",
        prefixIcon: Icon(Icons.category, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildCreateClassButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Class Created: $_className")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:  Color(0xFF9E2A2F),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
        ),
        child: Text("Create Class", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
