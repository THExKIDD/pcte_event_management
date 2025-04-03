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
                  :
              // Center(
              //     child: Container(
              //       padding: const EdgeInsets.all(10),
              //       color: Colors.amber,
              //       child: BarChart(
              //         BarChartData(
              //             barTouchData: BarTouchData(
              //                 enabled: false,
              //                 touchTooltipData: BarTouchTooltipData(
              //                     // tooltipBgColor: Colors.blueGrey,
              //                     tooltipRoundedRadius: 80,
              //                     tooltipMargin: 2)),
              //             groupsSpace: 80,
              //             rangeAnnotations: RangeAnnotations(
              //                 horizontalRangeAnnotations: [
              //                   HorizontalRangeAnnotation(
              //                       y1: 4,
              //                       color: const Color.fromARGB(
              //                           255, 214, 118, 111),
              //                       y2: 6),
              //                 ]),
              //             titlesData: FlTitlesData(
              //                 bottomTitles: AxisTitles(
              //                     drawBelowEverything: false,
              //                     // axisNameSize: 40,
              //                     sideTitles: SideTitles(
              //                         reservedSize: 120,
              //                         showTitles: true)),
              //                 rightTitles: AxisTitles(
              //                     sideTitles: SideTitles(
              //                         getTitlesWidget: (value, meta) {
              //                           return SideTitleWidget(
              //                               child: Icon(Icons.cabin),
              //                               meta: meta);
              //                         },
              //                         showTitles: true))

              //                 // show: false,
              //                 ),
              //             alignment: BarChartAlignment.center,
              //             barGroups: [
              //               BarChartGroupData(
              //                   x: 0,
              //                   barsSpace: 20,
              //                   barRods: [
              //                     BarChartRodData(toY: 10),
              //                     BarChartRodData(toY: 5),
              //                   ]),
              //               BarChartGroupData(x: 1, barRods: [
              //                 BarChartRodData(toY: 10),
              //                 BarChartRodData(toY: 5),
              //               ]),
              //               BarChartGroupData(x: 2, barRods: [
              //                 BarChartRodData(toY: 10),
              //                 BarChartRodData(toY: 5),
              //               ])
              //             ]),

              //         duration:
              //             Duration(milliseconds: 150), // Optional
              //         curve: Curves.linear, //
              //       ),
              //     ),
              //   )

              //
              // Scrollable Bar Chart

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed Y-Axis Labels with Title
                  // SizedBox(
                  //   width: 40,
                  //   height: 350,
                  //   child: Column(
                  //     children: [
                  //       Text(
                  //         'Points',
                  //         style: TextStyle(
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //       Expanded(
                  //         child: Column(
                  //           mainAxisAlignment:
                  //               MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             for (int i =
                  //                     tableData[0]['totalPoints'];
                  //                 i >= 0;
                  //                 i--)
                  //               Padding(
                  //                 padding: const EdgeInsets.only(
                  //                     right: 10),
                  //                 child: Text(
                  //                   i.toInt().toString(),
                  //                   style: TextStyle(
                  //                       fontSize: 10,
                  //                       fontWeight: FontWeight.w500),
                  //                 ),
                  //               ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // Scrollable Bar Chart

                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 3000,
                        height: 350,
                        child: BarChart(
                          BarChartData(
                            barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                    direction: TooltipDirection.top)),

                            alignment: BarChartAlignment.spaceAround,
                            // backgroundColor: Colors.yellow,
                            groupsSpace: 20,
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
                                        .toDouble(),
                                    color: Colors.blue,
                                    width: 30,
                                  ),
                                ],
                                showingTooltipIndicators: [0],
                                barsSpace: 10,
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'Classes ',
                                  style:
                                  TextStyle(color: Colors.black),
                                ),
                                drawBelowEverything: true,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 &&
                                        value.toInt() <
                                            tableData.length) {
                                      return SideTitleWidget(
                                        meta: meta,
                                        child: Text(
                                          tableData[value.toInt()]
                                          ['name'],
                                          style:
                                          TextStyle(fontSize: 8),
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
                                axisNameSize: tableData[0]
                                ['totalPoints']
                                    .toDouble() +
                                    5,
                                sideTitles: SideTitles(
                                  showTitles:
                                  true, // Disable y-axis labels in the chart
                                  interval: tableData[0]
                                  ['totalPoints']
                                      .toDouble() <
                                      2
                                      ? 1
                                      : tableData[0]['totalPoints']
                                      .toDouble() /
                                      5,
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
                            // barTouchData: BarTouchData(enabled: true),
                            maxY: tableData[0]['totalPoints']
                                .toDouble() +
                                4, // Keep the maxY setting
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: tableData.length,
                    itemBuilder: (context, index) {
                      return Card(
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
                            leading: Text('${index + 1}'),
                            title: Text(tableData[index]['name']),
                            subtitle: Text(tableData[index]['type'].toString()),
                            trailing: Text(
                                tableData[index]['totalPoints'].toString()),
                          ),
                        ),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}