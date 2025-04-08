import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pcte_event_management/Api_Calls/event_api_calls.dart';
import 'package:pcte_event_management/ui/EventDetails.dart';
import 'package:pcte_event_management/ui/student_reg.dart';
import 'package:pcte_event_management/widgets/drawer_builder.dart';
import '../LocalStorage/Secure_Store.dart';

class ClassEventsScreen extends StatefulWidget {
  const ClassEventsScreen({super.key});

  @override
  State<ClassEventsScreen> createState() => _ClassEventsScreenState();
}

class _ClassEventsScreenState extends State<ClassEventsScreen> {
  List<dynamic> events = [];
  bool isLoading = true;
  bool isEmpty = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    getClassEvents();
  }

  Future<void> getClassEvents() async {
    try {
      EventApiCalls eventApiCalls = EventApiCalls();
      final result = await eventApiCalls.getAllEventsForClass();

      log('class events : $result');

      setState(() {
        events = result;
        isLoading = false;
        isEmpty = result.isEmpty;
      });

    } catch (e) {
      setState(() {
        error = e.toString();
        events = [];
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
          'No Events\nTry Again Later',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )
          : ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20, bottom: 10),
            child: Text(
              "Class Events",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          // Events List
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsPage(
                      eventName: event['name'] ?? 'Unnamed Event',
                      description: event['description'],
                      maxStudents: event['maxStudents'],
                      minStudents: event['minStudents'],
                      location: event['location'],
                      convener: event['convenor'],
                      eventId: event['_id'],
                      rules: event['rules'],
                      points: event['points']
                  ),
                  )
                  );
                },
                child: EventCard(
                  eventName: event['name'] ?? 'Unnamed Event',
                  eventType: event['type'] ?? 'N/A',
                  eventId: event['_id'] ?? '',
                  minStudents: event['minStudents'] ?? 0,
                  maxStudents: event['maxStudents'] ?? 0,
                  onRegisterPressed: ()  async {
                    final bool result = await Navigator.push(context, MaterialPageRoute(builder: (_)=> StudentRegistrationScreen(eventId: event['_id'], minStudents:event['minStudents'], maxStudents: event['maxStudents'],)));


                    if(result)
                    {
                      setState(() {
                        isLoading = true;
                      });
                      getClassEvents();
                    }
                  },
                  isRegistered: event['register'] != null ? true : false,
                ),
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
  final String eventId;
  final int minStudents;
  final int maxStudents;
  final VoidCallback onRegisterPressed;
  final bool isRegistered;

  const EventCard({
    required this.eventName,
    required this.eventType,
    required this.eventId,
    required this.minStudents,
    required this.maxStudents,
    super.key,
    required this.onRegisterPressed,
    required this.isRegistered,

  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.8;
    double cardHeight = 140;

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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    eventName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(eventType),
                  Text('Students: $minStudents-$maxStudents'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: ElevatedButton(
              onPressed: onRegisterPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9E2A2F),
                minimumSize: const Size(100, 40),
              ),
              child: Text(
                isRegistered ?
                'Update'
                    :
                'Register',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}