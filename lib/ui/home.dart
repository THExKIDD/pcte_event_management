import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/event_api_calls.dart';
import 'package:pcte_event_management/Api_Calls/result_api_calls.dart';
import 'package:pcte_event_management/Providers/login_provider.dart';
import 'package:pcte_event_management/Providers/pass_provider.dart';
import 'package:pcte_event_management/ui/Event.dart';
import 'package:pcte_event_management/ui/EventDetails.dart';
import 'package:pcte_event_management/ui/event_result.dart';
import 'package:pcte_event_management/ui/result.dart';
import 'package:pcte_event_management/ui/student_reg.dart';
import 'package:pcte_event_management/widgets/drawer_builder.dart';
import 'package:pcte_event_management/widgets/textButton.dart';
import 'package:provider/provider.dart';
import '../LocalStorage/Secure_Store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> filteredEvents = [];
  List<Map<String, dynamic>> verticalEvents = [];
  bool isEmpty = false;

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final eventApi = EventApiCalls();
    List<Map<String, dynamic>> allEvents = await eventApi.getAllEvents();
    return allEvents;
  }

  Future<void> _fetchEvents() async {
    verticalEvents = await getAllEvents();
    setState(() {
      filteredEvents = List.from(verticalEvents);
      isLoading = false;
      isEmpty = verticalEvents.isEmpty;
    });
  }

  late PageController _pageController;
  final SecureStorage secureStorage = SecureStorage();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    log(verticalEvents.toString());
    return Consumer<PassProvider>(
      builder: (context, searchProvider, child) {
        return PopScope(
          canPop: !searchProvider.isSearching,
          onPopInvokedWithResult: (didPop, obj) {
            if (searchProvider.isSearching && !didPop) {
              searchProvider.searchState();
            }
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xFF9E2A2F),
                centerTitle: false,
                title: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: searchProvider.isSearching
                            ? MediaQuery.of(context).size.width * 0.6
                            : 180,
                        height: 40,
                        alignment: Alignment.centerLeft,
                        child: searchProvider.isSearching
                            ? TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: "Search events...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white60),
                          ),
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                        )
                            : Text(
                          "Koshish Events",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                  IconButton(
                    icon: Icon(
                        searchProvider.isSearching ? Icons.close : Icons.search,
                        color: Colors.white),
                    onPressed: () {
                      searchProvider.searchState();
                      if (!searchProvider.isSearching) _searchController.clear();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to Profile
                      },
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
                              return Icon(Icons.person,
                                  color: Colors.black, size: 24);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              drawer: CustomDrawer(),
              body: isLoading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : isEmpty
                  ? Center(
                child: Text(
                  'No Events \nTry Again Later',
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : FutureBuilder(
                future: secureStorage.getData('user_type'),
                builder: (context, snapshot) {
                  final userType = snapshot.data;
                  return ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 15, top: 20, bottom: 10),
                        child: Text(
                          "Events",
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
                        itemCount: verticalEvents.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EventDetailsPage(
                                    points: verticalEvents[index]['points'],
                                    rules: verticalEvents[index]['rules'],
                                    eventId: verticalEvents[index]['_id'],
                                    eventName: verticalEvents[index]['name'],
                                    description: verticalEvents[index]['description'],
                                    maxStudents: verticalEvents[index]['maxStudents'],
                                    minStudents: verticalEvents[index]['minStudents'],
                                    location: verticalEvents[index]['location'],
                                    convener: verticalEvents[index]['convenor']['name'],
                                  ),
                                ),
                              );
                            },
                            child: ModifiedVerticalCard(
                              eventName: verticalEvents[index]['name']!,
                              eventType: verticalEvents[index]['type']!,
                              eventId: verticalEvents[index]['_id'],
                              minStudents: verticalEvents[index]['minStudents'],
                              maxStudents: verticalEvents[index]['maxStudents'],
                              userType: userType ?? '',
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceButton(String title, IconData icon) {
    return Container(
      width: 90,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: Color(0xFF0047AB),
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ModifiedVerticalCard extends StatelessWidget {
  final String eventName;
  final String eventType;
  final String eventId;
  final String userType;
  final int minStudents;
  final int maxStudents;

  const ModifiedVerticalCard({
    required this.eventName,
    required this.eventType,
    required this.eventId,
    required this.userType,
    super.key,
    required this.minStudents,
    required this.maxStudents,
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
                ],
              ),
            ),
          ),
          if(userType == "Class")
            ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=> StudentRegistrationScreen(eventId: eventId, minStudents: minStudents, maxStudents: maxStudents,)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9E2A2F)
                ),
                child: Text('Register',style: TextStyle(color: Colors.white),)
            ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (String value) {
                if (value == 'show_result') {
                  log(eventId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventResultScreen(eventId: eventId),
                    ),
                  );
                } else if (value == 'add_result' && (userType == 'Convenor' || userType == 'Admin')) {
                  log(eventId);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'show_result',
                  child: Text('Show Result'),
                ),
                if (userType == 'Convenor' || userType == 'Admin')
                  const PopupMenuItem<String>(
                    value: 'add_result',
                    child: Text('Add Result'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}