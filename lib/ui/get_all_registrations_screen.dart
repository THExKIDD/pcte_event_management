import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/Registration_api_calls.dart';

class GetAllRegistrationScreen extends StatefulWidget {
  const GetAllRegistrationScreen({super.key});

  @override
  State<GetAllRegistrationScreen> createState() => _GetAllRegistrationScreenState();
}

class _GetAllRegistrationScreenState extends State<GetAllRegistrationScreen> {
  List<dynamic> registrations = [];
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

      setState(() {
        registrations = allRegistrations;
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
          // Registrations List
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              final registration = registrations[index];
              final event = registration['eventId'];
              final classData = registration['classId'];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailsScreen(
                        eventName: event['name'],
                        className: classData['name'],
                        students: registration['students'],
                      ),
                    ),
                  );
                },
                child: RegistrationCard(
                  eventName: event['name'],
                  eventType: event['type'],
                  className: classData['name'],
                  location: event['location'],
                  studentsCount: (registration['students'] as List).length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RegistrationCard extends StatelessWidget {
  final String eventName;
  final String eventType;
  final String className;
  final String location;
  final int studentsCount;

  const RegistrationCard({
    required this.eventName,
    required this.eventType,
    required this.className,
    required this.location,
    required this.studentsCount,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.8;
    double cardHeight = 160;

    return Container(
      height: cardHeight,
      width: cardWidth,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    eventName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.event, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 5),
                      Text(eventType),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.school, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 5),
                      Text(className),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 5),
                      Text(location),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 5),
                      Text('$studentsCount ${studentsCount == 1 ? 'Student' : 'Students'} Registered'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailsScreen(
                      eventName: eventName,
                      className: className,
                      students: [],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9E2A2F),
                minimumSize: const Size(100, 40),
              ),
              child: const Text(
                'View',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailsScreen extends StatelessWidget {
  final String eventName;
  final String className;
  final List<dynamic> students;

  const EventDetailsScreen({
    Key? key,
    required this.eventName,
    required this.className,
    required this.students,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Registration Details",
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
                                className,
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
              "Registered Students",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            students.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No students registered",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF9E2A2F).withOpacity(0.2),
                        child: Text(
                          student.toString()[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF9E2A2F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        student.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text("Student #${index + 1}"),
                    ),
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