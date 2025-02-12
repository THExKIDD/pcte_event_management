import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pcte_event_management/Providers/pass_provider.dart';
import 'package:pcte_event_management/ui/Event.dart';
import 'package:pcte_event_management/ui/EventDetails.dart';
import 'package:pcte_event_management/ui/result.dart';
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
  final List<Map<String, String>> sliderEvents = [
    {"image": "assets/img/image1.jpg", "name": "solo dance"},
    {"image": "assets/img/image2.jpg", "name": "indian singing"},
    {"image": "assets/img/image3.jpg", "name": "group dance"},
    {"image": "assets/img/image4.jpg", "name": "western dance"},
    {"image": "assets/img/image5.jpeg", "name": "videography"},
  ];

  final List<Map<String, String>> verticalEvents = [
    {"image": "assets/img/image1.jpg", "name": "solo dance"},
    {"image": "assets/img/image1.jpg", "name": "Event B"},
    {"image": "assets/img/image2.jpg", "name": "Event C"},
    {"image": "assets/img/image2.jpg", "name": "Event D"},
  ];

  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;
  final SecureStorage secureStorage = SecureStorage();

  final _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < sliderEvents.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

  }


  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<PassProvider>(
      builder: (context,searchProvider,child) {
        return PopScope(
          canPop: !searchProvider.isSearching,
          onPopInvokedWithResult: (didPop,obj){
            if(searchProvider.isSearching && !didPop)
              {
                searchProvider.searchState();
              }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF9E2A2F),
              centerTitle: false, // Ensures proper alignment
              title: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: searchProvider.isSearching ? MediaQuery.of(context).size.width * 0.6 : 180, // Adjusted width
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
                  icon: Icon(searchProvider.isSearching ? Icons.close : Icons.search, color: Colors.white),
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
                            return Icon(Icons.person, color: Colors.black, size: 24);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            drawer: CustomDrawer(),


            body: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    padEnds: false,
                    itemCount: sliderEvents.length,
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      return SliderCard(
                        imagePath: sliderEvents[index]['image']!,
                        eventName: sliderEvents[index]['name']!,
                        index: index,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: verticalEvents.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsPage()));
                        },
                        child: VerticalCard(
                          imagePath: verticalEvents[index]['image']!,
                          eventName: verticalEvents[index]['name']!,
                          index: index,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class SliderCard extends StatelessWidget {
  final String imagePath;
  final String eventName;
  final int index;
  const SliderCard({required this.imagePath, required this.eventName, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Color.fromRGBO(38, 81, 120, 0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.4),
            blurRadius: 8,
            spreadRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Image.asset(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  eventName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class VerticalCard extends StatelessWidget {
  final String imagePath;
  final String eventName;
  final int index;
  const VerticalCard({required this.imagePath, required this.eventName, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to make the card size responsive
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.8; // 80% of the screen width
    double cardHeight = 140; // Reduced height

    return Container(
      height: cardHeight, // Adjusted height
      width: cardWidth, // Adjusted width
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            child: Image.asset(
              imagePath,
              width: 120, // Slightly reduced width
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    eventName,  // Display event name
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Slightly smaller font
                  ),
                  const SizedBox(height: 5),
                  const Text("This card now includes an image."),
                 Row(
                   children: [
                     CustomTextButton(
                       text: "Show Result",
                       onPressed: () {
                         Navigator.push(context,MaterialPageRoute(builder:  (_)=> ResultScreen()));
                       },
                     ),
                   ],
                 ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }
}