import 'package:flutter/material.dart';

class ListViewPage extends StatefulWidget {
  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> items = [
    {'name': 'John Doe', 'subject': 'A', 'trailer': false},
    {'name': 'Jane Smith', 'subject': 'B', 'trailer': true},
    {'name': 'Mike Johnson', 'subject': 'C', 'trailer': false},
  ];

  List<Map<String, dynamic>> filteredItems = [];
  @override
  void initState() {
    super.initState();
    filteredItems = List.from(items);
  }

  void filterSearch(String query) {
    setState(() {
      filteredItems = items
          .where((item) => item['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customized ListView',
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
                      'Sub: ${filteredItems[index]['subject']}',
                      style: TextStyle(color: Colors.grey[700], fontSize: screenWidth * 0.035),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: filteredItems[index]['trailer'],
                          activeColor: Color(0xFF9E2A2F),
                          onChanged: (bool? value) {
                            setState(() {
                              filteredItems[index]['trailer'] = value;
                              int originalIndex = items.indexWhere((item) => item['name'] == filteredItems[index]['name']);
                              if (originalIndex != -1) {
                                items[originalIndex]['trailer'] = value;
                              }
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Updated ${filteredItems[index]['name']}')),
                            );
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
    );
  }
}
