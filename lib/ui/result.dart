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
      body: SafeArea(
        child: Padding(
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
                      const SizedBox(width: 20),
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
              const SizedBox(height: 0),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : tableData.isEmpty
                        ? const Center(
                            child: Text("No data available",
                                style: TextStyle(fontSize: 16)))
                        : Card(
                            shadowColor: Colors.black,
                            elevation: 10,
                            child: SingleChildScrollView(
                              physics: ScrollPhysics(
                                  parent: BouncingScrollPhysics()),
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: tableData.length * 90.0, // Dynamic width
                                child: BarChart(
                                  BarChartData(
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        direction: TooltipDirection.top,
                                        tooltipPadding: const EdgeInsets.all(5),
                                        maxContentWidth: 50,
                                        tooltipMargin: 6,
                                        getTooltipItem:
                                            (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            rod.toY.toString(),
                                            const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12, // Smaller font size
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    alignment: BarChartAlignment.start,
                                    groupsSpace: 80,
                                    barGroups:
                                        tableData.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      var value = entry.value;
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(5),
                                                topRight: Radius.circular(5)),
                                            toY: value['totalPoints']
                                                        .toDouble() ==
                                                    0
                                                ? 0
                                                : (value['totalPoints'] as num)
                                                    .toDouble(),
                                            // color: Colors.blue,
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color.fromARGB(
                                                    255, 81, 168, 239),
                                                const Color.fromARGB(
                                                    214, 8, 30, 131),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            width: 35,
                                          ),
                                        ],
                                        showingTooltipIndicators: index < 3
                                            ? [0]
                                            : [], // Only for top 3
                                        barsSpace: 50,
                                      );
                                    }).toList(),
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        drawBelowEverything: true,
                                        sideTitles: SideTitles(
                                          interval: 2,
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            log('message: ${value.toString()}');
                                            if (value.toInt() >= 0 &&
                                                value.toInt() <
                                                    tableData.length) {
                                              String name =
                                                  tableData[value.toInt()]
                                                          ['name']
                                                      .toString();

                                              return SideTitleWidget(
                                                meta: meta,
                                                child: Text(
                                                  name.length > 16
                                                      ? '${name.substring(0, 16)}...'
                                                      : name,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 8),
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
                                            if (value ==
                                                value.roundToDouble()) {
                                              return SideTitleWidget(
                                                meta: meta,
                                                child: Text(
                                                  value.toInt().toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
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
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(show: false),
                                    maxY: _calculateMaxY(),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(180, 107, 203, 227)
                                  .withValues(alpha: 0.5),
                              const Color.fromARGB(255, 48, 94, 247)
                                  .withValues(alpha: 0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 8),
                              if (index < 3) Icon(Icons.emoji_events, size: 16),
                              const SizedBox(height: 2),
                              Text('${index + 1}'),
                            ],
                          ),
                          title: Text(tableData[index]['name']),
                          subtitle: Text(tableData[index]['type'].toString()),
                          trailing: Column(
                            children: [
                              const SizedBox(height: 4),
                              const Text('Points'),
                              const SizedBox(height: 8),
                              Text(tableData[index]['totalPoints'].toString()),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateMaxY() {
    if (tableData.isEmpty) return 10.0; // Default maxY when no data
    double maxPoints = tableData[0]['totalPoints'].toDouble();
    if (maxPoints <= 6) {
    } else if (maxPoints <= 10) {
      maxPoints = 10 + 2;
    } else if (maxPoints > 10 && maxPoints <= 15) {
      maxPoints = 15 + 4;
    } else if (maxPoints <= 20) {
      maxPoints = 20 + 5;
    } else if (maxPoints <= 30) {
      maxPoints = 30 + 5;
    } else if (maxPoints <= 40) {
      maxPoints = 40 + 6;
    } else if (maxPoints <= 50) {
      maxPoints = 50 + 6;
    } else if (maxPoints <= 60) {
      maxPoints = 60 + 7;
    } else if (maxPoints <= 70) {
      maxPoints = 70 + 8;
    } else if (maxPoints <= 80) {
      maxPoints = 80 + 9;
    } else if (maxPoints <= 90) {
      maxPoints = 90 + 10;
    } else if (maxPoints <= 100) {
      maxPoints = 100 + 13;
    }

    return maxPoints <= 0 ? 6 : maxPoints; // Add padding, ensure non-zero
  }

  double _calculateInterval() {
    double maxY = _calculateMaxY();
    if (maxY <= 5) return 1;

    return (maxY / 5).ceilToDouble();
  }
}
