
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/result_api_calls.dart';
import 'package:pcte_event_management/widgets/drawer_builder.dart';
import 'package:animate_do/animate_do.dart';

class EventResultScreen extends StatefulWidget {
  final String eventId;
  const EventResultScreen({super.key, required this.eventId});

  @override
  State<EventResultScreen> createState() => _EventResultScreenState();
}

class _EventResultScreenState extends State<EventResultScreen> {
  List<Map<String, dynamic>> tableData = [];
  bool isLoading = true;
  bool noResultsAvailable = false;


  Future<List<Map<String, dynamic>>> getResult() async
  {

    ResultApiCalls resultApiCalls = ResultApiCalls();

    List<Map<String, dynamic>> resultList = await resultApiCalls.getResultById(eventId: widget.eventId);
    return resultList;


  }

  Future<void> _fetchResult () async
  {

    tableData = await getResult();
    setState(() {
      isLoading =false;
      noResultsAvailable = tableData.isEmpty;
    });

  }


  @override
  void initState() {
    super.initState();
    _fetchResult();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9E2A2F),
        title: const Text("Event Results", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            color: Colors.white,
          ),
        ),
      ),
      drawer: CustomDrawer(),
      body:  isLoading ?
      Center(child: CircularProgressIndicator(),)
          :
          noResultsAvailable
              ?
          Center(child: Text('Results not Available'),)
              :
          Column(
        children: [
          const SizedBox(height: 20),
          const Text("Event Winners ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildWinnerStand(),
          const SizedBox(height: 30),
          const Text("Leaderboard", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildLeaderboardTable(),
        ],
      ),
    );
  }

  Widget _buildWinnerStand() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(child: _buildPodium(Colors.grey, 2, tableData.length > 1 ?   tableData[1]['studentName'] : "N/A")),
        Flexible(child: _buildPodium(Colors.yellow, 1, tableData.isNotEmpty ? tableData[0]['studentName'] : "N/A")),
        Flexible(child: _buildPodium(Colors.brown, 3, tableData.length > 2 ? tableData[2]['studentName'] : "N/A")),
      ],
    );
  }

  Widget _buildPodium(Color color, int position, String className) {
    return BounceInUp(
      child: Column(
        children: [
          Container(
            width: 80,
            height: position == 1 ? 120 : (position == 2 ? 100 : 80),
            color: color,
            alignment: Alignment.center,
            child: Text(
              "$position",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            className,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget _buildLeaderboardTable() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        border: TableBorder.all(),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1),
        },
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFF9E2A2F)),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Position", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Class", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              /*Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Points", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),*/
            ],
          ),
          ...tableData.map((data) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(tableData.isNotEmpty ? data["position"]!.toString() : "N/A"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(tableData.isNotEmpty ? data["classId"]["name"]! : "N/A"),
              ),
              /*Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('20'),
              ),*/
            ],
          )),
        ],
      ),
    );
  }
}
