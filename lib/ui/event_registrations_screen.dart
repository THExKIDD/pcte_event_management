import 'dart:developer';
import 'package:flutter/material.dart';

class EventRegistrationsScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final List<dynamic> registrations;

  const EventRegistrationsScreen({
    Key? key,
    required this.eventId,
    required this.eventName,
    required this.registrations,
  }) : super(key: key);

  @override
  State<EventRegistrationsScreen> createState() => _EventRegistrationsScreenState();
}

class _EventRegistrationsScreenState extends State<EventRegistrationsScreen> {
  // Map to track expanded state of each class card
  Map<String, bool> expandedMap = {};
  // Map to group registrations by class
  Map<String, List<dynamic>> classRegistrationsMap = {};

  @override
  void initState() {
    super.initState();
    _processRegistrations();
  }

  void _processRegistrations() {
    // Group registrations by class
    for (var registration in widget.registrations) {
      final className = registration['classId']['name'];
      if (!classRegistrationsMap.containsKey(className)) {
        classRegistrationsMap[className] = [];
        // Initialize expanded state as false
        expandedMap[className] = false;
      }
      classRegistrationsMap[className]!.add(registration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.eventName} Registrations",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF9E2A2F),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: classRegistrationsMap.isEmpty
          ? _buildEmptyState()
          : _buildRegistrationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No registrations found for this event",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Registrations will appear here once classes are registered",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationsList() {
    final classNames = classRegistrationsMap.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classNames.length,
      itemBuilder: (context, index) {
        final className = classNames[index];
        final registrations = classRegistrationsMap[className]!;

        return _buildClassCard(className, registrations);
      },
    );
  }

  Widget _buildClassCard(String className, List<dynamic> registrations) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Class Header (Tappable)
          InkWell(
            onTap: () {
              setState(() {
                expandedMap[className] = !(expandedMap[className] ?? false);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9E2A2F).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school,
                      color: const Color(0xFF9E2A2F),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          className,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "${registrations.length} student${registrations.length != 1 ? 's' : ''} registered",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expandedMap[className] ?? false
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF9E2A2F),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),

          // Students List (Expandable)
          if (expandedMap[className] ?? false)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  const Divider(height: 1),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: registrations.length,
                    itemBuilder: (context, index) {
                      final students = registrations[index]['students'] as List<dynamic>;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (index > 0) const Divider(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 4, top: 4),
                              child: Text(
                                "Registration #${index + 1}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Column(
                              children: students.map<Widget>((student) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF9E2A2F).withOpacity(0.2),
                                    child: Text(
                                      student[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF9E2A2F),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    student,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  dense: true,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}