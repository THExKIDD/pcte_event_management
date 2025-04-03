import 'dart:developer';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/Api_Calls/event_api_calls.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/Models/event_model.dart';
import 'package:pcte_event_management/widgets/drop_box.dart';
import 'package:pcte_event_management/widgets/dropdown.dart';
import 'package:provider/provider.dart';

import '../Controllers/signup_controller.dart';
import '../Providers/dropdown_provider.dart';
import '../Providers/login_provider.dart';

class UpdateEventScreen extends StatefulWidget {
  final String eventId;
  const UpdateEventScreen({super.key, required this.eventId});

  @override
  State<UpdateEventScreen> createState() => _UpdateEventScreenState();
}

class _UpdateEventScreenState extends State<UpdateEventScreen> {
  final Dio _dio = Dio();
  final _formKey = GlobalKey<FormState>();
  final secureStorage = SecureStorage();
  bool _isLoading = true;

  // Controllers for text fields
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minStudentsController = TextEditingController();
  final TextEditingController _maxStudentsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<TextEditingController> _rulesControllers = [];
  final List<TextEditingController> _pointsControllers = [];

  // Variables for dropdown initial values
  String? _initialEventType;
  String? _initialParticipationType;

  final FocusNode _descriptionFocus = FocusNode();
  final _participationTypeFocus = FocusNode();

  final Color primaryColor = const Color(0xFF9E2A2F);

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _minStudentsController.dispose();
    _maxStudentsController.dispose();
    _locationController.dispose();
    for (var controller in _rulesControllers) {
      controller.dispose();
    }
    for (var controller in _pointsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addRuleField() {
    setState(() {
      _rulesControllers.add(TextEditingController());
    });
  }

  void _removeRuleField() {
    if (_rulesControllers.isNotEmpty) {
      setState(() {
        _rulesControllers.removeLast().dispose();
      });
    }
  }

  void _addPointField() {
    setState(() {
      _pointsControllers.add(TextEditingController());
    });
  }

  void _removePointField() {
    if (_pointsControllers.isNotEmpty) {
      setState(() {
        _pointsControllers.removeLast().dispose();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with default fields
    _rulesControllers.add(TextEditingController());
    for (int i = 0; i < 3; i++) {
      _pointsControllers.add(TextEditingController());
    }
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    try {
      final response = await _dio.get(
          'https://koshish-backend.vercel.app/api/event/${widget.eventId}');
      if (response.statusCode == 200) {
        final data = response.data['event'];

        // Clear existing controllers first but keep at least 1 rule and 3 points
        _rulesControllers.forEach((c) => c.dispose());
        _pointsControllers.forEach((c) => c.dispose());
        _rulesControllers.clear();
        _pointsControllers.clear();

        setState(() {
          // Set values for all controllers
          _eventNameController.text = data['name'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _minStudentsController.text = (data['minStudents'] ?? 1).toString();
          _maxStudentsController.text = (data['maxStudents'] ?? 1).toString();
          _locationController.text = data['location'] ?? '';

          // Set initial values for dropdowns
          _initialEventType = data['type']?.toString() ?? 'Junior';
          _initialParticipationType = data['part_type']?.toString() ?? 'Solo';

          // Initialize rules list - ensure at least 1 rule
          final rules = (data['rules'] as List<dynamic>? ?? []);
          if (rules.isNotEmpty) {
            for (var rule in rules) {
              _rulesControllers
                  .add(TextEditingController(text: rule.toString()));
            }
          } else {
            _rulesControllers.add(TextEditingController());
          }

          // Initialize points list - ensure at least 3 points
          final points = (data['points'] as List<dynamic>? ?? []);
          if (points.isNotEmpty) {
            for (var point in points) {
              _pointsControllers
                  .add(TextEditingController(text: point.toString()));
            }
          }
          // Add remaining points if needed to reach minimum 3
          while (_pointsControllers.length < 3) {
            _pointsControllers.add(TextEditingController());
          }

          _isLoading = false;
        });

        // Set dropdown values after the widget is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final dropDownProvider =
              Provider.of<DropDownProvider>(context, listen: false);
          dropDownProvider.setSelectedValue("eventType", _initialEventType);
          dropDownProvider.setSelectedValue(
              "participationType", _initialParticipationType);
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load event details')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Update Event", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.02,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    SizedBox(height: screenSize.height * 0.02),
                    TextFormField(
                      controller: _eventNameController,
                      decoration: InputDecoration(
                        labelText: "Event Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black45),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    DropDownBox(
                      items: ["Junior", "Senior"],
                      labelText: "Event Type",
                      icon: const Icon(Icons.event, color: Colors.black),
                      dropdownKey: "eventType",
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    DropDownBox(
                      items: ["Solo", "Group"],
                      labelText: "Participation Type",
                      icon: const Icon(Icons.group, color: Colors.black),
                      dropdownKey: "participationType",
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: null,
                      focusNode: _descriptionFocus,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black45),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    _buildDynamicFields("Rules", _rulesControllers,
                        _addRuleField, _removeRuleField,
                        minFields: 1),
                    SizedBox(height: screenSize.height * 0.02),
                    TextFormField(
                      controller: _minStudentsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Minimum Students",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black45),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    TextFormField(
                      controller: _maxStudentsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Maximum Students",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black45),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: "Location",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black45),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    _buildDynamicFields("Points", _pointsControllers,
                        _addPointField, _removePointField,
                        minFields: 3),
                    SizedBox(height: screenSize.height * 0.04),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: screenSize.width * 0.8,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              if (_formKey.currentState!.validate()) {
                                final apiCall = EventApiCalls();
                                // SignupController signupController = ... (You likely don't need this for updating)

                                final dropDownProvider =
                                    Provider.of<DropDownProvider>(context,
                                        listen: false);

                                String type = dropDownProvider
                                        .getSelectedValue("eventType") ??
                                    "Junior";
                                String partType =
                                    dropDownProvider.getSelectedValue(
                                            "participationType") ??
                                        "Solo";

                                // Extracting dynamic fields (Rules & Points)
                                List<String> rules = _rulesControllers
                                    .map((controller) => controller.text)
                                    .where((text) => text.isNotEmpty)
                                    .toList();
                                List<int> points = _pointsControllers
                                    .where((controller) =>
                                        controller.text.isNotEmpty)
                                    .map((controller) =>
                                        int.tryParse(controller.text) ?? 0)
                                    .toList();

                                // Prepare the updated event data

                                final updatedEvent = EventModel(
                                  id: widget
                                      .eventId, // If your model requires it for updates
                                  name: _eventNameController.text,
                                  type: type,
                                  partType: partType,
                                  description: _descriptionController.text,
                                  rules: rules,
                                  maxStudents: int.tryParse(
                                          _maxStudentsController.text) ??
                                      1,
                                  minStudents: int.tryParse(
                                          _minStudentsController.text) ??
                                      1,
                                  location: _locationController.text,
                                  convenor: '',
                                  points: points,
                                  // You might need to handle convenor and isActive if you want to update them
                                );

                                // Call the updateEventCall method
                                log('updated enceb t data /+\n');
                                log('${updatedEvent.toJson()}');
                                bool isUpdated =
                                    await apiCall.updateEventCallWithData(
                                  widget.eventId,
                                  (updatedEvent
                                      .toJson()), // Pass the data to be updated
                                );
                                if (isUpdated) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Event updated successfully')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Failed to update event. Please try again later.')),
                                  );
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error updating event: $e')),
                              );
                              log('Error updating event: $e');
                            }
                          },
                          child: const Text("Update Event",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDynamicFields(
      String label,
      List<TextEditingController> controllers,
      VoidCallback addField,
      VoidCallback removeField,
      {int minFields = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ...controllers.map((controller) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: TextFormField(
                controller: controller,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black45),
                  ),
                ),
              ),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: addField,
              icon: const Icon(Icons.add, color: Colors.blue),
              label: Text("Add $label",
                  style: const TextStyle(color: Colors.blue)),
            ),
            TextButton.icon(
              onPressed: controllers.length > minFields ? removeField : null,
              icon: const Icon(Icons.remove, color: Colors.red),
              label: Text("Remove $label",
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }
}
