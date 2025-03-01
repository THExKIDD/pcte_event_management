import 'package:flutter/material.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/ui/student_reg.dart';

class EventDetailsPage extends StatelessWidget {
  final String eventName;
  final String description;
  final String rules =
      "1. Teams must register before the deadline.\n2. Each team should have 2-5 members.\n3. Follow the event code of conduct. \n4.Teams must register before the deadline.\n2. Each team should have 2-5 members.\n3. Follow the event code of conduct.";
  final int maxStudents;
  final int minStudents;
  final String location;
  final String convener;
  final int points = 50;
  final String eventId;

  const EventDetailsPage({super.key,required this.eventName, required this.description, required this.maxStudents, required this.minStudents, required this.location, required this.convener, required this.eventId});
  @override
  Widget build(BuildContext context) {
    SecureStorage secureStorage = SecureStorage();
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Details", style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF9E2A2F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FutureBuilder(
        future: secureStorage.getData('user_type'),
        builder: (context, snapshot) {

        if(snapshot.hasData && snapshot.data == 'Teacher')
          {
            return SizedBox(
              height: 70,
              width: 70,
              child: FloatingActionButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StudentRegistrationScreen(eventId: eventId,)));
                },
                backgroundColor: Color(0xFF9E2A2F),
                child: Icon(Icons.add,color: Colors.white,),
              ),
            );
          }
        else{
          return SizedBox();
        }

        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventNameCard(),
            SizedBox(height: 10),
            _buildInfoCard(Icons.info, "Description", description),
            _buildInfoCard(Icons.rule, "Rules", rules),
            _buildInfoCard(Icons.group, "Min-Max Students",
                "$minStudents - $maxStudents"),
            _buildInfoCard(Icons.location_on, "Location", location),
            _buildInfoCard(Icons.person, "Convener", convener),
            _buildInfoCard(Icons.star, "Points", "$points Points"),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: (){

                }, child: Text('Update ')),
                ElevatedButton(onPressed: (){
                  
                }, child: Text('Delete ')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEventNameCard() {
    return Card(
      color: Color(0xFF9E2A2F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.event, color: Colors.white, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                eventName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF9E2A2F)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}



