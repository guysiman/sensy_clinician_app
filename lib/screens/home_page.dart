import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth.dart';

import 'dashboard_page.dart';
import 'patient_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser!;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardScreen(),
    PatientsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Color(0xFF61838D),
            destinations: [
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 0
                      ? Icons.dashboard
                      : Icons.dashboard_outlined,
                  color: Colors.white,
                  size: 40,
                ),
                label: Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 1 ? Icons.people : Icons.people_outlined,
                  color: Colors.white,
                  size: 40,
                ),
                label: Text(
                  'Patients',
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
    );
  }
}
