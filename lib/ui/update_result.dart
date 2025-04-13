import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/Api_Calls/result_api_calls.dart';
// Ensure this file contains the ResultApiCall class
import 'package:pcte_event_management/Models/result_model.dart';

import '../Api_Calls/class_api.dart';
import '../Models/class_model.dart';

class UpdateResult extends StatefulWidget {
  const UpdateResult({super.key, required this.id});
  final String id;
  @override
  State<UpdateResult> createState() => _UpdateResultState();
}

class _UpdateResultState extends State<UpdateResult> {
  int currentYear = DateTime.now().year;
  int? selectedYear;

  String? resultId;

  bool gettingResult = false;
  bool noResult = false;
  List<ClassModel> resultData = [];
  List<ClassModel> allClasses = [];
  List<ClassModel> filteredClasses = [];
  TextEditingController searchController = TextEditingController();
  ClassModel? firstPlace;
  ClassModel? secondPlace;
  ClassModel? thirdPlace;
  bool isLoading = true;

  final Color primaryColor = Color(0xFF9E2A2F);

  void startup() async {
    await fetchClasses();
    await _fetchResult(selectedYear!);
  }

  @override
  void initState() {
    super.initState();
    selectedYear = currentYear;
    startup();
  }

  Future<void> _fetchResult(int year) async {
    setState(() {
      isLoading = true;
    });

    try {
      ResultApiCalls resultApiCalls = ResultApiCalls();
      Map<String, dynamic> results =
          await resultApiCalls.getResultById(eventId: widget.id, year: year);
      resultId = results['_id'];

      if (results.isEmpty) {
        developer.log("No results found for the selected year: $year");
        setState(() {
          isLoading = false;
          gettingResult = false;
          noResult = true;
        });
        return;
      }

      allClasses.asMap().forEach((index, result) {
        if (result.id == results['result'][0]['_id']) {
          firstPlace = result;
        } else if (result.id == results['result'][1]['_id']) {
          developer.log("First id: ${result.id}");

          secondPlace = result;
        } else if (result.id == results['result'][2]['_id']) {
          developer.log("First id: ${result.id}");

          thirdPlace = result;
        }
      });

      setState(() {
        resultId = results['_id'];
        isLoading = false;
        gettingResult = true;
      });
      return;
    } catch (e) {
      setState(() {
        isLoading = false;
        gettingResult = false;
        noResult = true;
      });
      developer.log("Error fetching results: $e");
    }
  }

  Future<void> fetchClasses() async {
    setState(() {
      isLoading = true;
    });

    final classes = await ApiService.getAllClasses();

    if (classes.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      allClasses = classes;
      filteredClasses = classes;
      isLoading = false;
    });
  }

  void filterClasses(String query) {
    // setState(() {
    filteredClasses = allClasses
        .where((c) => c.name!.toLowerCase().contains(query.toLowerCase()))
        .toList();
    // });
  }

  void selectWinner(ClassModel classModel, int position) {
    setState(() {
      if (position == 1) firstPlace = classModel;
      if (position == 2) secondPlace = classModel;
      if (position == 3) thirdPlace = classModel;
    });
  }

  void updateResults() async {
    if (firstPlace == null || secondPlace == null || thirdPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select all winners!'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    List<String> classIds = [
      firstPlace!.id!,
      secondPlace!.id!,
      thirdPlace!.id!,
    ];

    final resultModel = ResultModel(
      id: resultId,
      year: selectedYear!,
      eventId: widget.id,
      classIds: classIds,
    );

    final resultApi = ApiCalls();
    String? resultRes = await resultApi.createResult(resultModel);

    if (resultRes != null && resultRes.contains('success'.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Results updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update results!'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log("Event id : ${widget.id}");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Result",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          if (!isLoading && !noResult)
            IconButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text("Delete Result"),
                          content: Text(
                              "Are you sure you want to delete this result?"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel")),
                            TextButton(
                                onPressed: () async {
                                  final resultApi = ResultApiCalls();
                                  final result =
                                      await resultApi.deleteResult(resultId!);
                                  if (result) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Result deleted successfully!'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to delete result!'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                child: Text("Delete"))
                          ],
                        );
                      });
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                ))
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : noResult
              ? Center(
                  child: Text(
                    "No results found for the event",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF5F5F5),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
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
                              if (newValue != null &&
                                  newValue != selectedYear) {
                                setState(() {
                                  selectedYear = newValue;
                                });
                                _fetchResult(newValue);
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        if (gettingResult)
                          Text(
                            "Select  Classes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        SizedBox(height: 10),
                        Expanded(
                          child: filteredClasses.isEmpty
                              ? Center(
                                  child: Text(
                                    "No classes found",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredClasses.length,
                                  itemBuilder: (context, index) {
                                    ClassModel classModel =
                                        filteredClasses[index];
                                    bool isSelected =
                                        classModel == firstPlace ||
                                            classModel == secondPlace ||
                                            classModel == thirdPlace;

                                    return Card(
                                      elevation: 2,
                                      margin: EdgeInsets.only(bottom: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: isSelected
                                            ? BorderSide(
                                                color: primaryColor, width: 2)
                                            : BorderSide.none,
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        title: Text(
                                          classModel.name ?? "Unknown Class",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        trailing: Container(
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? primaryColor
                                                : Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: PopupMenuButton<int>(
                                            icon: Icon(
                                              Icons.emoji_events,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                            ),
                                            onSelected: (value) =>
                                                selectWinner(classModel, value),
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                  value: 1,
                                                  child: Text("🥇 1st Place")),
                                              PopupMenuItem(
                                                  value: 2,
                                                  child: Text("🥈 2nd Place")),
                                              PopupMenuItem(
                                                  value: 3,
                                                  child: Text("🥉 3rd Place")),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        SizedBox(height: 16),
                        if (gettingResult)
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Final Results",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: updateResults,
                                        icon: Icon(Icons.save),
                                        label: Text("Update"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(height: 24),
                                  ResultItem(
                                    position: "1st Place",
                                    emoji: "🥇",
                                    name: firstPlace?.name,
                                    color: primaryColor,
                                  ),
                                  ResultItem(
                                    position: "2nd Place",
                                    emoji: "🥈",
                                    name: secondPlace?.name,
                                    color: primaryColor,
                                  ),
                                  ResultItem(
                                    position: "3rd Place",
                                    emoji: "🥉",
                                    name: thirdPlace?.name,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class ResultItem extends StatelessWidget {
  final String position;
  final String emoji;
  final String? name;
  final Color color;

  const ResultItem({
    super.key,
    required this.position,
    required this.emoji,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: name != null ? color : Colors.grey.shade300,
          width: name != null ? 1 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  name ?? "Not Selected",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: name != null ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
