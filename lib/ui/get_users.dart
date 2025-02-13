import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/ui/UserUpdateScreen.dart';

class GetAllUsers extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  const GetAllUsers({super.key, required this.items});

  @override
  State<GetAllUsers> createState() => _GetAllUsersState();
}

class _GetAllUsersState extends State<GetAllUsers> {
  TextEditingController searchController = TextEditingController();


  List<Map<String, dynamic>> filteredItems = [];
  @override
  void initState() {
    super.initState();


    filteredItems = List.from(widget.items);
  }

  void filterSearch(String query) {
    setState(() {
      filteredItems = widget.items
          .where((item) => item['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'All Faculty',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF9E2A2F),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onChanged: filterSearch,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.015),
                      title: Text(
                        filteredItems[index]['name'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
                      ),
                      subtitle: Text(
                        'Type: ${filteredItems[index]['user_type']}',
                        style: TextStyle(color: Colors.grey[700], fontSize: screenWidth * 0.035),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final userId = filteredItems[index]['_id'].toString();
                              log(userId);

                              Navigator.push(context, MaterialPageRoute(builder: (_) => UserUpdateScreen(userId: userId,)));

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF9E2A2F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Update',
                              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
