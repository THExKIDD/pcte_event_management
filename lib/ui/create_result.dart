import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import 'package:pcte_event_management/Api_Calls/api_calls.dart';
// Ensure this file contains the ResultApiCall class
import 'package:pcte_event_management/Models/result_model.dart';

import '../Api_Calls/class_api.dart';
import '../Models/class_model.dart';

class CreateResult extends StatefulWidget {
  CreateResult({super.key, required this.id});
  final String id;
  @override
  _CreateResultState createState() => _CreateResultState();
}

class _CreateResultState extends State<CreateResult> {
  List<ResultModel> resultData = [];
  List<ClassModel> allClasses = [];
  List<ClassModel> filteredClasses = [];
  TextEditingController searchController = TextEditingController();
  ClassModel? firstPlace;
  ClassModel? secondPlace;
  ClassModel? thirdPlace;
  bool isLoading = true;

  final Color primaryColor = Color(0xFF9E2A2F);

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    setState(() {
      isLoading = true;
    });

    List<ClassModel> classes = await ApiService.getAllClasses();

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
      eventId: widget.id,
      classIds: classIds,
    );

    final resultApi = ApiCalls();
    developer.log('Result Model: ${resultModel.toJson()}');
    String? resultRes = await resultApi.createResult(resultModel);

    if (resultRes != null && resultRes.isNotEmpty) {
      developer.log('Result created successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text(resultRes),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      developer.log('Result creation failed!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Failed to create result!'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Create Result",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
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
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: "Search Class",
                          labelStyle: TextStyle(color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                          ),
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          filteredClasses = allClasses
                              .where((c) => c.name!
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Classes",
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
                                ClassModel classModel = filteredClasses[index];
                                bool isSelected = classModel == firstPlace ||
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
                                        borderRadius: BorderRadius.circular(8),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      borderRadius: BorderRadius.circular(8),
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
          Column(
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: name != null ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
