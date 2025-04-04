import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/Registration_api_calls.dart';

import '../widgets/drawer_builder.dart';

class GetAllRegistrationScreen extends StatefulWidget {
  const GetAllRegistrationScreen({super.key});

  @override
  State<GetAllRegistrationScreen> createState() => _GetAllRegistrationScreenState();
}

class _GetAllRegistrationScreenState extends State<GetAllRegistrationScreen> {
  List<dynamic> registrations = [];
  Map<String, List<dynamic>> eventRegistrations = {};
  bool isLoading = true;
  bool isEmpty = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchRegistrations();
  }

  Future<void> fetchRegistrations() async {
    try {
      final registrationApiCalls = RegistrationApiCalls();

      // Get all registrations from API
      final Map<String, dynamic> apiResponse = await registrationApiCalls.getAllRegistrations();
      final List<dynamic> allRegistrations = apiResponse['registrations'] as List<dynamic>;

      // Group registrations by eventId
      final Map<String, List<dynamic>> groupedRegistrations = {};

      for (var registration in allRegistrations) {
        final eventId = registration['eventId']['_id'];
        if (!groupedRegistrations.containsKey(eventId)) {
          groupedRegistrations[eventId] = [];
        }
        groupedRegistrations[eventId]!.add(registration);
      }

      setState(() {
        registrations = allRegistrations;
        eventRegistrations = groupedRegistrations;
        isLoading = false;
        isEmpty = registrations.isEmpty;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        isEmpty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9E2A2F),
        centerTitle: false,
        title: Text(
          "Koshish Events",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  "assets/img/logo1.png",
                  fit: BoxFit.cover,
                  width: 36,
                  height: 36,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.person, color: Colors.black, size: 24);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(color: Color(0xFF9E2A2F)),
      )
          : isEmpty
          ? Center(
        child: Text(
          'No Registrations\nTry Again Later',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )
          : ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20, bottom: 10),
            child: Text(
              "Event Registrations",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          // Unique Events List
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: eventRegistrations.length,
            itemBuilder: (context, index) {
              final eventId = eventRegistrations.keys.elementAt(index);
              final registrationsList = eventRegistrations[eventId]!;
              final eventData = registrationsList.first['eventId'];

              return EventCard(
                eventName: eventData['name'],
                eventType: eventData['type'],
                location: eventData['location'],
                registrationsCount: registrationsList.length,
                registrations: registrationsList,
              );
            },
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String eventName;
  final String eventType;
  final String location;
  final int registrationsCount;
  final List<dynamic> registrations;

  const EventCard({
    required this.eventName,
    required this.eventType,
    required this.location,
    required this.registrationsCount,
    required this.registrations,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventRegistrationsScreen(
                eventName: eventName,
                registrations: registrations,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 5),
                  Text(eventType),
                  Spacer(),
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 5),
                  Text(location),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.groups, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 5),
                      Text('$registrationsCount ${registrationsCount == 1 ? 'Class' : 'Classes'} Registered'),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventRegistrationsScreen(
                            eventName: eventName,
                            registrations: registrations,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9E2A2F),
                      minimumSize: const Size(80, 36),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventRegistrationsScreen extends StatelessWidget {
  final String eventName;
  final List<dynamic> registrations;

  const EventRegistrationsScreen({
    Key? key,
    required this.eventName,
    required this.registrations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Event Registrations",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF9E2A2F),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9E2A2F).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.event,
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
                                eventName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "${registrations.length} Registered Classes",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Registered Classes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: registrations.length,
                itemBuilder: (context, index) {
                  final registration = registrations[index];
                  final classData = registration['classId'];
                  final students = registration['students'] as List;

                  return ClassRegistrationCard(
                    className: classData['name'],
                    studentsCount: students.length,
                    students: students,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClassRegistrationCard extends StatefulWidget {
  final String className;
  final int studentsCount;
  final List<dynamic> students;

  const ClassRegistrationCard({
    required this.className,
    required this.studentsCount,
    required this.students,
    Key? key,
  }) : super(key: key);

  @override
  State<ClassRegistrationCard> createState() => _ClassRegistrationCardState();
}

class _ClassRegistrationCardState extends State<ClassRegistrationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              widget.className,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              "${widget.studentsCount} ${widget.studentsCount == 1 ? 'Student' : 'Students'}",
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: const Color(0xFF9E2A2F),
              ),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF9E2A2F).withOpacity(0.1),
              foregroundColor: const Color(0xFF9E2A2F),
              child: Icon(Icons.school),
            ),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Registered Students",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  widget.students.isEmpty
                      ? Center(
                    child: Text(
                      "No students registered",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.students.length,
                    itemBuilder: (context, index) {
                      final student = widget.students[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF9E2A2F).withOpacity(0.05),
                          child: Text(
                            student.toString()[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF9E2A2F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(student.toString()),
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