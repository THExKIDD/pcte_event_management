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
  final currentYear = DateTime.now().year;
  int? selectedYear;

  @override
  void initState() {
    log(widget.eventId);
    super.initState();
    selectedYear = currentYear;
    _fetchResult(currentYear);
  }

  Future<void> _fetchResult(int year) async {
    setState(() {
      isLoading = true;
    });

    try {
      ResultApiCalls resultApiCalls = ResultApiCalls();
      Map<String, dynamic> results = await resultApiCalls.getResultById(
        eventId: widget.eventId,
        year: year,
      );

      log('table data result : $results');

      List<Map<String, dynamic>> resultList =
          List<Map<String, dynamic>>.from(results['result']);

      setState(() {
        tableData = resultList;
        isLoading = false;
        noResultsAvailable = tableData.isEmpty;
      });

      // log("Results  : $tableData");
    } catch (e) {
      setState(() {
        isLoading = false;
        noResultsAvailable = true;
      });
      log("Error fetching results: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final podiumWidth =
        isSmallScreen ? screenSize.width * 0.22 : screenSize.width * 0.2;
    final podiumSpacing = isSmallScreen ? 2.0 : 8.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9E2A2F),
        title: const Text("Event Results",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      drawer: const CustomDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year Selector Card
                  Padding(
                    padding: EdgeInsets.all(screenSize.width * 0.04),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.04,
                          vertical: screenSize.height * 0.01,
                        ),
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Select Year',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.calendar_today,
                                color: const Color(0xFF9E2A2F)),
                          ),
                          value: selectedYear,
                          hint: Text('Choose a year',
                              style: TextStyle(color: Colors.grey[700])),
                          items: List<int>.generate(
                            currentYear - 2024 + 1,
                            (index) => 2024 + index,
                          ).reversed.map((year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            if (newValue != null && newValue != selectedYear) {
                              setState(() {
                                selectedYear = newValue;
                              });
                              _fetchResult(newValue);
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  if (isLoading)
                    Container(
                      height: constraints.maxHeight * 0.6,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF9E2A2F)),
                      ),
                    )
                  else if (noResultsAvailable)
                    Container(
                      height: constraints.maxHeight * 0.6,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events_outlined,
                              size: screenSize.width * 0.15,
                              color: Colors.grey[400]),
                          SizedBox(height: screenSize.height * 0.02),
                          Text('No Results Available',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.045,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        // Winners Section
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.04),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(screenSize.width * 0.04),
                              child: Column(
                                children: [
                                  Text("Event Winners",
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF9E2A2F),
                                      )),
                                  SizedBox(height: screenSize.height * 0.02),
                                  SizedBox(
                                    height: screenSize.height * 0.25,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        // Podium Base
                                        Container(
                                          height: screenSize.height * 0.02,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            _buildPodiumStand(
                                              position: 2,
                                              height: screenSize.height * 0.15,
                                              width: podiumWidth,
                                              color: Colors.grey[400]!,
                                              name: tableData.length > 1
                                                  ? tableData[1]['name']
                                                  : "N/A",
                                              screenWidth: screenSize.width,
                                              spacing: podiumSpacing,
                                            ),
                                            _buildPodiumStand(
                                              position: 1,
                                              height: screenSize.height * 0.2,
                                              width: podiumWidth,
                                              color: const Color(0xFFFFD700),
                                              name: tableData.isNotEmpty
                                                  ? tableData[0]['name']
                                                  : "N/A",
                                              screenWidth: screenSize.width,
                                              spacing: podiumSpacing,
                                            ),
                                            _buildPodiumStand(
                                              position: 3,
                                              height: screenSize.height * 0.1,
                                              width: podiumWidth,
                                              color: const Color(0xFFCD7F32),
                                              name: tableData.length > 2
                                                  ? tableData[2]['name']
                                                  : "N/A",
                                              screenWidth: screenSize.width,
                                              spacing: podiumSpacing,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenSize.height * 0.03),

                        // Leaderboard Section
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.04),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(screenSize.width * 0.04),
                              child: Column(
                                children: [
                                  Text("Leaderboard",
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF9E2A2F),
                                      )),
                                  SizedBox(height: screenSize.height * 0.02),
                                  _buildLeaderboardTable(screenSize.width),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.03),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPodiumStand({
    required int position,
    required double height,
    required double width,
    required Color color,
    required String name,
    required double screenWidth,
    required double spacing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$position",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (position == 1)
                  Icon(Icons.star,
                      color: Colors.white, size: screenWidth * 0.07),
              ],
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Container(
            constraints: BoxConstraints(
              maxWidth: width * 1.25,
            ),
            padding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.015, horizontal: screenWidth * 0.01),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Flexible(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTable(double screenWidth) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(
          minWidth: screenWidth * 0.8,
          maxWidth: screenWidth * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(screenWidth * 0.18),
            1: FixedColumnWidth(screenWidth * 0.5),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            const TableRow(
              decoration: BoxDecoration(
                color: Color(0xFF9E2A2F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Center(
                    child: Text("Rank",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("Class",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
            ...tableData.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> data = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: index.isOdd ? Colors.grey[50] : Colors.white,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: index < 3
                              ? const Color(0xFF9E2A2F)
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      data["name"] ?? "N/A",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
