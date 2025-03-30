import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/event_api_calls.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/ui/student_reg.dart';

class EventDetailsPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final SecureStorage secureStorage = SecureStorage();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF9E2A2F),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      body: FutureBuilder(
        future: secureStorage.getData('user_type'),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot)
        {

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
                  content: description,
                ),
                _buildExpandableInfoCard(
                  icon: Icons.rule,
                  title: "Rules",
                  contentWidget: _buildRulesList(),
                ),
                _buildExpandableInfoCard(
                  icon: Icons.people_outline,
                  title: "Participants",
                  content: "Minimum: $minStudents\nMaximum: $maxStudents",
                ),
                _buildExpandableInfoCard(
                  icon: Icons.location_on_outlined,
                  title: "Location",
                  content: location,
                ),
                _buildExpandableInfoCard(
                  icon: Icons.person_outline,
                  title: "Convener",
                  content: convener,
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
                  eventId: eventId,
                  maxStudents: maxStudents,
                  minStudents: minStudents,
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
                eventName,
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
            child: contentWidget ?? Text(
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
      children: List.generate(rules.length, (index) {
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
                  rules[index].toString(),
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
      children: List.generate(points.length, (index) {
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
                  '${points[index]} Points',
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

  Widget _buildAdminControls(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {}, // Update functionality
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
            onPressed: () => _deleteEvent(context),
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
    );
  }

  bool _shouldShowAdminControls() {

    return true; // Replace with actual condition
  }

  Future<void> _deleteEvent(BuildContext context) async {
    final secureStorage = SecureStorage();
    final eventApiCalls = EventApiCalls();
    final token = await secureStorage.getData('jwtToken');

    await eventApiCalls.deleteEvent(token!, eventId).then((success) {
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
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}