
import 'package:flutter/material.dart';
import 'package:pcte_event_management/ui/home.dart';




class bottomNavBar extends StatefulWidget {
  const bottomNavBar({super.key});

  @override
  State<bottomNavBar> createState() => _bottomNavBarState();
}

class _bottomNavBarState extends State<bottomNavBar> {
  int _selectedIndex = 0;

  // Create a PageController for the horizontal scroll effect
  final PageController _pageController = PageController();

  // Function to change page based on BottomNavigationBar selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Navigate to the selected page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
         HomeScreen(),
          _buildPage('Page 2', Colors.green),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: _selectedIndex==0?Icon(Icons.home ,  color: Colors.red):Icon(Icons.home ,  color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex==1?Icon(Icons.bar_chart ,  color: Colors.red):Icon(Icons.bar_chart ,  color: Colors.black),
            label: 'Results',
          ),

        ],
      ),
    );
  }

  // Helper function to build pages
  Widget _buildPage(String title, Color color) {
    return Center(
      child: Container(
        color: color,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
