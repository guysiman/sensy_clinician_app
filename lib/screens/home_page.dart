import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/auth.dart';

import 'bluetooth_page.dart';
import 'dashboard_page.dart';
import 'patient_page.dart';

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
    BluetoothPage(),
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
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  indicatorColor: const Color(0xFF61838D),
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(
                        _selectedIndex == 0
                            ? Icons.dashboard
                            : Icons.dashboard_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                      label: const Text(
                        'Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: Icon(
                        _selectedIndex == 1
                            ? Icons.people
                            : Icons.people_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                      label: const Text(
                        'Patients',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: Icon(
                        Icons.bluetooth,
                        color: Colors.white,
                        size: 40,
                      ),
                      label: const Text(
                        'IPG',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
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
}
