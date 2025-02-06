import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<Map<String, dynamic>> tableData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('YOUR_BACKEND_URL/leaderboard'));

      print("API Status Code: ${response.statusCode}"); // Debugging
      print("API Response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          tableData = data.isNotEmpty
              ? data.map((e) => {
            "position": e["position"].toString(),
            "class": e["class"],
            "points": e["points"].toString(),
          }).toList()
              : [
          ];
          isLoading = false;
        });

        print("Updated Table Data: $tableData");
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        tableData = [

          {"position": "1", "class": "A", "points": "100"},
          {"position": "2", "class": "B", "points": "90"},
          {"position": "3", "class": "C", "points": "100"},
        ];
      });
      print('Error fetching leaderboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF9E2A2F)),
              child: Text(
                "Navigation Menu",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Leaderboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ✅ Wrapped in Builder to force UI rebuild
            Builder(
              builder: (context) {
                return Table(
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
                          child: Text("Position",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Class",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Points",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.white)),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
