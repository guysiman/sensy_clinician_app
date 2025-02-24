import 'package:flutter/material.dart';
import '../components/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 24),
            // Row of metric cards with horizontal scroll
            SizedBox(
              height: 150,
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

            // Patient Data section
            SizedBox(height: 24),
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
    );
  }
}
