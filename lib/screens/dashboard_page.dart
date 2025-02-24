import 'package:flutter/material.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row of metric cards with horizontal scroll
            SizedBox(
              height: 120, // Adjusted height for more squarish appearance
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 160, // Adjusted width for more squarish appearance
                      child: MetricCard(
                        icon: Icons.people,
                        iconColor: Colors.orange,
                        title: 'All patients',
                        value: '2,135',
                        percentageChange: 1.35,
                        subtitle: '2,015',
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: MetricCard(
                        icon: Icons.calendar_today,
                        iconColor: Colors.redAccent,
                        title: 'All sessions',
                        value: '3,890',
                        percentageChange: -0.35,
                        subtitle: '3,501',
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: MetricCard(
                        icon: Icons.access_time,
                        iconColor: Colors.greenAccent,
                        title: 'Average time of use per day',
                        value: '1h 23m',
                        percentageChange: 0.83,
                        subtitle: '860',
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: MetricCard(
                        icon: Icons.directions_walk,
                        iconColor: Colors.blueAccent,
                        title: 'All walking mode sessions',
                        value: '980',
                        percentageChange: -0.35,
                        subtitle: '1039',
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: MetricCard(
                        icon: Icons.healing,
                        iconColor: Colors.purple,
                        title: 'All pain relief sessions',
                        value: '234',
                        percentageChange: 1.35,
                        subtitle: '221',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Patient Data section
            SizedBox(height: 24),
            Text(
              'Patient Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('Patient data table would go here'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}