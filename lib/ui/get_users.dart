import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/ui/UserUpdateScreen.dart';

class GetAllUsers extends StatefulWidget {
  const GetAllUsers({super.key});

  @override
  State<GetAllUsers> createState() => _GetAllUsersState();
}

class _GetAllUsersState extends State<GetAllUsers> {
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<List<Map<String, dynamic>>> itemsGetter() async {
    try {
      SecureStorage secureStorage = SecureStorage();
      ApiCalls apiCalls = ApiCalls();

      String? token = await secureStorage.getData('jwtToken');
      log(token ?? 'no token');

      final items = await apiCalls.getFacultyCall(token!);
      return items;
    } on Exception catch (e) {
      log(e.toString());
      return [];
    }
  }

  void filterSearch(String query) {
    setState(() {
      filteredItems = items
          .where((item) => item['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchItems() async {
    items = await itemsGetter(); // Await the result
    setState(() {
      filteredItems = List.from(items);
      isLoading = false; // Update filteredItems
    });
    log(filteredItems.toString());
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
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
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
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
                    margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.01),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.015),
                      title: Text(
                        filteredItems[index]['name'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Type: ${filteredItems[index]['user_type']}',
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: screenWidth * 0.035),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Email: ${filteredItems[index]['email'] ?? 'N/A'}',
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: screenWidth * 0.035),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Phone: ${filteredItems[index]['phone_number'] ?? 'N/A'}',
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: screenWidth * 0.035),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final userId = filteredItems[index]['_id'].toString();
                              final name = filteredItems[index]['name'].toString();
                              final email = filteredItems[index]['email'].toString();
                              final phone = filteredItems[index]['phone_number'].toString();
                              log(userId);
                              bool isActive = filteredItems[index]['is_active'];

                              final bool result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => UserUpdateScreen(
                                          userId: userId,
                                          isActive: isActive,
                                          name: name,
                                          email: email,
                                          phone: phone,
                                      )));
                              log(result.toString());

                              if (result) {
                                _fetchItems();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF9E2A2F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Update',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.035),
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