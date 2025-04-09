import 'package:flutter/material.dart';
import 'dart:developer';
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
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;
  bool isEmpty = false;
  final SecureStorage secureStorage = SecureStorage();
  final Map<String, IconData> eventTypeIcons = {'default': Icons.event};
  final Map<String, Color> eventColors = {'default': Colors.indigo};

  @override
  void initState() {
    super.initState();
    getClassEvents();
  }

  Future<void> getClassEvents() async {
    try {
      EventApiCalls eventApiCalls = EventApiCalls();
      final result = await eventApiCalls.getAllEventsForClass();

      setState(() {
        events = List<Map<String, dynamic>>.from(result);
        isLoading = false;
        isEmpty = events.isEmpty;
      });
    } catch (e) {
      setState(() {
        events = [];
        isLoading = false;
        isEmpty = true;
      });
    }
  }

  IconData getEventIcon(String eventType) {
    return eventTypeIcons[eventType.toLowerCase()] ?? eventTypeIcons['default']!;
  }

  Color getEventColor(String eventType) {
    return eventColors[eventType.toLowerCase()] ?? eventColors['default']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFF9E2A2F),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Koshish Events",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                // Navigate to Profile
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF9E2A2F), size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF9E2A2F),
        ),
      )
          : isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Events Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stay tuned for upcoming events',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: getClassEvents,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E2A2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        color: const Color(0xFF9E2A2F),
        onRefresh: () async {
          setState(() {
            isLoading = true;
          });
          await getClassEvents();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Events Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Class Events",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Events Grid List
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final event = events[index];
                    return EventCard(
                      eventName: event['name'],
                      eventType: event['type'],
                      eventId: event['_id'],
                      minStudents: event['minStudents'],
                      maxStudents: event['maxStudents'],
                      icon: getEventIcon(event['type']),
                      color: getEventColor(event['type']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailsPage(
                              points: event['points'],
                              rules: event['rules'],
                              eventId: event['_id'],
                              eventName: event['name'],
                              description: event['description'],
                              maxStudents: event['maxStudents'],
                              minStudents: event['minStudents'],
                              location: event['location'],
                              convener: event['convenor']['name'],
                            ),
                          ),
                        );
                      },
                      onRegisterPressed: () async {
                        final bool result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentRegistrationScreen(
                              eventId: event['_id'],
                              minStudents: event['minStudents'],
                              maxStudents: event['maxStudents'],
                            ),
                          ),
                        );

                        if (result) {
                          setState(() {
                            isLoading = true;
                          });
                          getClassEvents();
                        }
                      },
                      isRegistered: event['register'] != null,
                    );
                  },
                  childCount: events.length,
                ),
              ),
            ),
          ],
        ),
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
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onRegisterPressed;
  final bool isRegistered;

  const EventCard({
    super.key,
    required this.eventName,
    required this.eventType,
    required this.eventId,
    required this.minStudents,
    required this.maxStudents,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.onRegisterPressed,
    required this.isRegistered,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Icon Header - Reduced height from 120 to 100
                Container(
                  height: 100,
                  width: double.infinity,
                  color: color.withOpacity(0.2),  // Removed withOpacity
                  child: Stack(
                    children: [
                      // Patterned background
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CirclePatternPainter( color: color.withOpacity(0.1)),
                        ),
                      ),
                      // Icon
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),  // Reduced padding
                          decoration: BoxDecoration(
                            color: Colors.white,  // White background
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 32,  // Reduced size
                            color: color,  // Color to match the type
                          ),
                        ),
                      ),
                      // Event Type Badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            eventType,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Event Details - Using Expanded to ensure it fits in available space
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event name with reduced height
                        Text(
                          eventName,
                          style: const TextStyle(
                            fontSize: 14, // Reduced font size
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6), // Reduced spacing

                        // Members count
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 14, // Reduced size
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$minStudents-$maxStudents members',
                              style: TextStyle(
                                fontSize: 11, // Reduced font size
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        // Spacer to push button to bottom
                        const Spacer(),

                        // Register button
                        SizedBox(
                          width: double.infinity,
                          height: 30, // Fixed height for button
                          child: ElevatedButton(
                            onPressed: onRegisterPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 0), // Reduced padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isRegistered ? 'Update' : 'Register',
                              style: const TextStyle(fontSize: 12), // Reduced font size
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Circle Pattern Painter for Event Card Background
class CirclePatternPainter extends CustomPainter {
  final Color color;

  CirclePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.15,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      size.width * 0.12,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.9),
      size.width * 0.08,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}