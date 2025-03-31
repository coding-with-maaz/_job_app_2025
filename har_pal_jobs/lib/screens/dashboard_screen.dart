import 'package:flutter/material.dart';
import 'package:har_pal_jobs/widgets/stats_card.dart';
import 'package:har_pal_jobs/widgets/chart_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: const [
                StatsCard(
                  title: 'Total Jobs',
                  value: '120',
                  icon: Icons.work,
                  color: Colors.blue,
                ),
                StatsCard(
                  title: 'Active Jobs',
                  value: '85',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                StatsCard(
                  title: 'Companies',
                  value: '45',
                  icon: Icons.business,
                  color: Colors.orange,
                ),
                StatsCard(
                  title: 'Applications',
                  value: '250',
                  icon: Icons.person_add,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Job Distribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ChartCard(
              title: 'Jobs by Location',
              child: SizedBox(
                height: 200,
                child: Center(
                  child: Text('Location Chart will be implemented here'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const ChartCard(
              title: 'Jobs by Type',
              child: SizedBox(
                height: 200,
                child: Center(
                  child: Text('Job Type Chart will be implemented here'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
