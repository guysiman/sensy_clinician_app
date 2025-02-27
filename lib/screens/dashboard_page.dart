import 'package:flutter/material.dart';
import '../components/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1) A thin bar at the very top
          Container(
            height: 30, // Adjust thickness as needed
            color: Colors.white,
          ),
          // 2) The "Dashboard" header below the thin bar
          Container(
            height: 48, // Adjust height as needed
            color: Colors.white,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          // 3) Your existing content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row of metric cards with horizontal scroll
                  SizedBox(
                    height: 150,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 160,
                            child: MetricCard(
                              icon: Icons.people,
                              iconColor: Colors.orange,
                              title: 'All patients',
                              value: '2,135',
                              percentageChange: 1.35,
                              prevValue: '2,015',
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            width: 160,
                            child: MetricCard(
                              icon: Icons.calendar_today,
                              iconColor: Colors.redAccent,
                              title: 'All sessions',
                              value: '3,890',
                              percentageChange: -0.35,
                              prevValue: '3,501',
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            width: 160,
                            child: MetricCard(
                              icon: Icons.access_time,
                              iconColor: Colors.greenAccent,
                              title: 'Average time of use per day',
                              value: '1h 23m',
                              percentageChange: 0.83,
                              prevValue: '860',
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            width: 160,
                            child: MetricCard(
                              icon: Icons.directions_walk,
                              iconColor: Colors.blueAccent,
                              title: 'All walking mode sessions',
                              value: '980',
                              percentageChange: -0.35,
                              prevValue: '1039',
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            width: 160,
                            child: MetricCard(
                              icon: Icons.healing,
                              iconColor: Colors.purple,
                              title: 'All pain relief sessions',
                              value: '234',
                              percentageChange: 1.35,
                              prevValue: '221',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Patient Data section
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('Patient data table would go here'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
