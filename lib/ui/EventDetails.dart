import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/Registration_api_calls.dart';
import 'package:pcte_event_management/Api_Calls/event_api_calls.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/ui/student_reg.dart';
import 'package:pcte_event_management/ui/update_event.dart';

import 'event_registrations_screen.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventName;
  final String description;
  final List<dynamic> rules;
  final int maxStudents;
  final int minStudents;
  final String location;
  final String convener;
  final List<dynamic> points;
  final String eventId;

  const EventDetailsPage({
    super.key,
    required this.eventName,
    required this.description,
    required this.maxStudents,
    required this.minStudents,
    required this.location,
    required this.convener,
    required this.eventId,
    required this.rules,
    required this.points,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool isRegistrationsLoading = true;
  List<dynamic> eventRegistrations = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEventRegistrations();
  }

  Future<void> getEventRegistrations() async {
    try {
      final registrationApiCalls = RegistrationApiCalls();
      eventRegistrations =
          await registrationApiCalls.getEventRegistrations(widget.eventId);
      log("Event Registrations: ${eventRegistrations.toString()}");
      setState(() {
        isRegistrationsLoading = false;
      }); // Update UI after data is loaded
    } catch (e) {
      setState(() {
        isRegistrationsLoading = false;
      });
      log("Error fetching event registrations: $e");
      eventRegistrations = []; // Initialize to empty list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    // log('event id is :  ${widget.eventId}');
    final SecureStorage secureStorage = SecureStorage();
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Event Details", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF9E2A2F),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      body: FutureBuilder(
        future: secureStorage.getData('user_type'),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          String? userType = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildEventHeader(),
                const SizedBox(height: 16),
                _buildExpandableInfoCard(
                  icon: Icons.info_outline,
                  title: "Description",
                  content: widget.description,
                ),
                _buildExpandableInfoCard(
                  icon: Icons.rule,
                  title: "Rules",
                  contentWidget: _buildRulesList(),
                ),
                _buildExpandableInfoCard(
                  icon: Icons.people_outline,
                  title: "Participants",
                  content:
                      "Minimum: ${widget.minStudents}\nMaximum: ${widget.maxStudents}",
                ),
                _buildExpandableInfoCard(
                  icon: Icons.location_on_outlined,
                  title: "Location",
                  content: widget.location,
                ),
                _buildExpandableInfoCard(
                  icon: Icons.person_outline,
                  title: "Convener",
                  content: widget.convener,
                ),
                _buildExpandableInfoCard(
                  icon: Icons.star_outline,
                  title: "Points Distribution",
                  contentWidget: _buildPointsList(),
                ),
                const SizedBox(height: 16),
                if (userType == 'Admin' || userType == 'Convenor')
                  _buildAdminControls(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FutureBuilder(
      future: SecureStorage().getData('user_type'),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == 'Teacher') {
          return FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentRegistrationScreen(
                  eventId: widget.eventId,
                  maxStudents: widget.maxStudents,
                  minStudents: widget.minStudents,
                ),
              ),
            ),
            backgroundColor: const Color(0xFF9E2A2F),
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEventHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF9E2A2F).withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.event, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.eventName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableInfoCard({
    required IconData icon,
    required String title,
    String? content,
    Widget? contentWidget,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF9E2A2F)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: contentWidget ??
                Text(
                  content ?? '',
                  style: const TextStyle(fontSize: 15),
                ),
          ),
        ],
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildRulesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.rules.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E2A2F).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.rules[index].toString(),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPointsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.points.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E2A2F).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_getOrdinalSuffix(index + 1)} Place:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Chip(
                label: Text(
                  '${widget.points[index]} Points',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF9E2A2F),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ),
        );
      }),
    );
  }

// Add this button in the _buildAdminControls method in EventDetailsPage
  Widget _buildAdminControls(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              UpdateEventScreen(eventId: widget.eventId)));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: const Color(0xFF9E2A2F)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'UPDATE',
                  style: TextStyle(
                    color: Color(0xFF9E2A2F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text("Confirm Delete"),
                          content: Text("Do you want to delete this event?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop(); // Close the dialog
                              },
                              child: Text("No"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(ctx).pop(); // Close the dialog
                                await _deleteEvent(
                                    context); // Call your delete function here
                                Navigator.pop(
                                    context); // Close the current screen
                              },
                              child: Text("Yes"),
                            ),
                          ],
                        );
                      });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E2A2F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'DELETE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventRegistrationsScreen(
                    eventId: widget.eventId,
                    eventName: widget.eventName,
                    registrations: eventRegistrations,
                  ),
                ));
          },
          icon: const Icon(Icons.people, color: Colors.white),
          label: isRegistrationsLoading
              ? const CircularProgressIndicator()
              : Text(
                  'VIEW REGISTRATIONS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9E2A2F),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteEvent(BuildContext context) async {
    final secureStorage = SecureStorage();
    final eventApiCalls = EventApiCalls();
    final token = await secureStorage.getData('jwtToken');

    await eventApiCalls.deleteEvent(token!, widget.eventId).then((success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Deleted Successfully" : "Delete Failed"),
          duration: const Duration(seconds: 1),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    });
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return 'th';
    }
  }
}
