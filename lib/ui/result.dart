import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pcte_event_management/widgets/drawer_builder.dart';
import 'package:fl_chart/fl_chart.dart';
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
      tableData = await apiCalls.getFinalResults(
          year: selectedYear, type: selectedCategory);
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<int>(
                      value: selectedYear,
                      items: List.generate(
                              5, (index) => DateTime.now().year - index)
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
                    SizedBox(width: 20),
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
                          child: Text("No data available",
                              style: TextStyle(fontSize: 16)))
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Flexible(
                              flex: 1,
                              // fit: FlexFit.loose,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: 3000,
                                  height: 350,
                                  child: BarChart(
                                    BarChartData(
                                        barTouchData: BarTouchData(
                                            enabled: true,
                                            touchTooltipData:
                                                BarTouchTooltipData(
                                                    direction:
                                                        TooltipDirection.top)),
                                        alignment: BarChartAlignment.start,
                                        // backgroundColor: Colors.yellow,
                                        groupsSpace: 30,
                                        barGroups: tableData
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int index = entry.key;
                                          var value = entry.value;
                                          return BarChartGroupData(
                                            x: index,
                                            barRods: [
                                              BarChartRodData(
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                                toY: value['totalPoints']
                                                            .toDouble() ==
                                                        0
                                                    ? 1
                                                    : value['totalPoints']
                                                        .toDouble(),
                                                color: Colors.blue,
                                                width: 30,
                                              ),
                                            ],
                                            showingTooltipIndicators: [0],
                                            barsSpace: 20,
                                          );
                                        }).toList(),
                                        titlesData: FlTitlesData(
                                          bottomTitles: AxisTitles(
                                            drawBelowEverything: true,
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                if (value.toInt() >= 0 &&
                                                    value.toInt() <
                                                        tableData.length) {
                                                  String name =
                                                      tableData[value.toInt()]
                                                          ['name'];

                                                  return SideTitleWidget(
                                                    meta: meta,
                                                    child: Text(
                                                      name.length > 20
                                                          ? '${name.substring(0, 10)}...'
                                                          : name,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 8),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            drawBelowEverything: true,
                                            sideTitles: SideTitles(
                                              showTitles:
                                                  true, // Disable y-axis labels in the chart
                                              interval: _calculateInterval(),
                                              getTitlesWidget: (value, meta) {
                                                // Only show integer values
                                                if (value ==
                                                    value.roundToDouble()) {
                                                  return SideTitleWidget(
                                                    meta: meta,
                                                    child: Text(
                                                      value.toInt().toString(),
                                                      style: const TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox
                                                    .shrink(); // Hide non-integer labels
                                              },

                                              reservedSize:
                                                  40, // No space needed since labels are outside
                                            ),
                                          ),
                                          topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false,
                                                  reservedSize: 10)),
                                          rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        gridData: FlGridData(show: false),
                                        // barTouchData: BarTouchData(enabled: true),
                                        maxY:
                                            _calculateMaxY() // Keep the maxY setting
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: tableData.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        // surfaceTintColor: Colors.brown,
                        shadowColor: Colors.black54,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromARGB(180, 248, 247, 247)
                                      .withValues(alpha: 0.5),
                                  const Color.fromARGB(255, 194, 161, 161)
                                      .withValues(alpha: 0.5),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )),
                          child: ListTile(
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 8),
                                  if (index < 3)
                                    Icon(Icons.emoji_events, size: 16),
                                  SizedBox(height: 2),
                                  Text('${index + 1}')
                                ],
                              ),
                              title: Text(tableData[index]['name']),
                              subtitle:
                                  Text(tableData[index]['type'].toString()),
                              trailing: Column(
                                children: [
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text('Points'),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(tableData[index]['totalPoints']
                                      .toString()),
                                ],
                              )),
                        ),
                      );
                    }))
          ],
        ),
      ),
    );
  }

  double _calculateMaxY() {
    if (tableData.isEmpty) return 10.0; // Default maxY when no data
    double maxPoints = tableData[0]['totalPoints'].toDouble();

    return maxPoints <= 0 ? 8 : maxPoints + 4; // Add padding, ensure non-zero
  }

  double _calculateInterval() {
    double maxY = _calculateMaxY();
    if (maxY <= 5) return 1.0; // Small range, small interval
    return (maxY / 5).ceilToDouble(); // Divide into 5 steps
  }
}
