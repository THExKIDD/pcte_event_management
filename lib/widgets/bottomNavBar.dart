import 'package:flutter/material.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/ui/class_events.dart';
import 'package:pcte_event_management/ui/home.dart';

class bottomNavBar extends StatefulWidget {
  const bottomNavBar({super.key});

  @override
  State<bottomNavBar> createState() => _bottomNavBarState();
}

class _bottomNavBarState extends State<bottomNavBar> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  String? _userType;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final secureStorage = SecureStorage();
    final type = await secureStorage.getData('user_type');
    setState(() {
      _userType = type;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
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
          _userType == 'Class' ? ClassEventsScreen() : HomeScreen(),
          _buildPage('Page 2', Colors.green),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? const Icon(Icons.home, color: Colors.red)
                : const Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? const Icon(Icons.bar_chart, color: Colors.red)
                : const Icon(Icons.bar_chart, color: Colors.black),
            label: 'Results',
          ),
        ],
      ),
    );
  }

  Widget _buildPage(String title, Color color) {
    return Center(
      child: Container(
        color: color,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}