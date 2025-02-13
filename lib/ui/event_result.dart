import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcte_event_management/widgets/drawer_builder.dart';
import 'login.dart';
import 'package:animate_do/animate_do.dart';

class EventResultScreen extends StatefulWidget {
  const EventResultScreen({super.key});

  @override
  State<EventResultScreen> createState() => _EventResultScreenState();
}

class _EventResultScreenState extends State<EventResultScreen> {
  List<Map<String, dynamic>> tableData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventResults();
  }

  Future<void> fetchEventResults() async {
    try {
      final response = await http.get(Uri.parse('YOUR_BACKEND_URL/event_results'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          tableData = data.isNotEmpty
              ? data.map((e) => {
            "position": e["position"].toString(),
            "class": e["class"],
            "points": e["points"].toString(),
          }).toList()
              : [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load event results');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        tableData = [
          {"position": "1", "class": "A", "points": "100"},
          {"position": "2", "class": "B", "points": "90"},
          {"position": "3", "class": "C", "points": "80"},
        ];
      });
      print('Error fetching event results: $e');
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodium(Colors.grey, 2, tableData[1]["class"]!),
        _buildPodium(Colors.yellow, 1, tableData[0]["class"]!),
        _buildPodium(Colors.brown, 3, tableData[2]["class"]!),
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
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Points", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          ...tableData.map((data) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(data["position"]!),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(data["class"]!),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(data["points"]!),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
