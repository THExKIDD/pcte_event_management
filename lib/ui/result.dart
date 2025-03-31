import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pcte_event_management/widgets/drawer_builder.dart';

import '../Api_Calls/result_api_calls.dart';


class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<Map<String, dynamic>> tableData = [];
  bool isLoading = true;
  final ResultApiCalls apiCalls = ResultApiCalls();
  String selectedCategory = "Junior";
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    setState(() => isLoading = true);
    try {
      tableData = await apiCalls.getFinalResults(year: selectedYear, type: selectedCategory);
    } catch (e) {
      log('Error fetching leaderboard: $e');
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9E2A2F),
        title: const Text(
          "Leaderboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            color: Colors.white,
          ),
        ),
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Leaderboard",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    DropdownButton<int>(
                      value: selectedYear,
                      items: List.generate(5, (index) => DateTime.now().year - index)
                          .map((int year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedYear = newValue;
                            fetchLeaderboard();
                          });
                        }
                      },
                    ),
                    SizedBox(width: 5),
                    DropdownButton<String>(
                      value: selectedCategory,
                      items: ["Junior", "Senior"].map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCategory = newValue;
                            fetchLeaderboard();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : tableData.isEmpty
                  ? const Center(
                  child: Text("No data available", style: TextStyle(fontSize: 16)))
                  : SingleChildScrollView(
                scrollDirection: Axis.vertical, // Enables vertical scrolling
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                  child: DataTable(
                    columnSpacing: 10,
                    headingRowColor: WidgetStateColor.resolveWith((states) => Color(0xFF9E2A2F)),
                    columns: const [
                      DataColumn(
                        label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text("Class",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text("Pts", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                      ),
                    ],
                    rows: tableData.asMap().entries.map((entry) => DataRow(cells: [
                      DataCell(Text((entry.key + 1).toString(), style: TextStyle(fontSize: 12))),
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 100, maxWidth: 150),
                          child: Text(
                            entry.value["name"],
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      ),
                      DataCell(Text(entry.value["totalPoints"].toString(), style: TextStyle(fontSize: 12))),
                    ])).toList(),
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}