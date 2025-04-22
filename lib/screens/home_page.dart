import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/auth.dart';

import 'bluetooth_page.dart';
import 'dashboard_page.dart';
import 'patient_page.dart';
import 'device_pairing_page.dart';

final GlobalKey<_HomePageState> homePageKey = GlobalKey<_HomePageState>();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();

  final User? user = Auth().currentUser!;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    PatientsScreen(),
    DevicePairingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToIPG() {
    print('i am here');
    setState(() {
      _selectedIndex = 2; // Set to IPG page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Thin bar at the very top
          Container(
            height: 25,
            color: const Color(0xFFC4D1D4),
          ),
          // Main content area with NavigationRail and page content
          Expanded(
            child: Row(
              children: [
                // Custom navigation rail to better match Figma design
                Container(
                  width: 80, // Reduced width of the tab bar
                  color: const Color(0xFF3D6673), 
                  child: Column(
                    children: [
                      _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
                      _buildNavItem(1, Icons.people_outlined, Icons.people, 'Patients'),
                      _buildNavItem(2, Icons.bluetooth_outlined, Icons.bluetooth, 'IPG'),
                    ],
                  ),
                ),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom navigation item builder to have more control over the design
  Widget _buildNavItem(int index, IconData iconOutlined, IconData iconFilled, String label) {
    final bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: 80,
        height: 80, // Make it square
        color: isSelected ? const Color(0xFF5A7983) : Colors.transparent, // Highlight background for selected item
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? iconFilled : iconOutlined,
              color: Colors.white,
              size: 30, // Reduced size
            ),
            const SizedBox(height: 4), // Small gap between icon and text
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11, // Smaller font size
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}