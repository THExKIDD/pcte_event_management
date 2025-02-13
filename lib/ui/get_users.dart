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

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> items = [];


  List<Map<String, dynamic>> filteredItems = [];
  @override
  void initState() {
    super.initState();
    _fetchItems();

  }

  Future<List<Map<String, dynamic>>> filteredItemsGetter()
  async {
    try {

      SecureStorage secureStorage = SecureStorage();
      ApiCalls apiCalls = ApiCalls();

      String? token =  await secureStorage.getData('jwtToken');

      final filteredItems = await apiCalls.getFacultyCall(token!);
      return filteredItems;



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
    items = await filteredItemsGetter(); // Await the result
    setState(() {
      filteredItems = List.from(items); // Update filteredItems
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
                              bool isActive = filteredItems[index]['is_active'];

                              Navigator.push(context, MaterialPageRoute(builder: (_) => UserUpdateScreen(userId: userId,isActive: isActive)));

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
