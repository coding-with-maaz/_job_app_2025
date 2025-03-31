import 'package:flutter/material.dart';
import 'jobs_screen.dart';
import 'today_jobs_screen.dart';
import 'search_results_screen.dart';
import 'saved_jobs_screen.dart';
import '../widgets/animated_tab_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeContent();
      case 1:
        return const JobsScreen();
      case 2:
        return const TodayJobsScreen();
      case 3:
        return const SavedJobsScreen();
      default:
        return const HomeContent();
    }
  }

  void _onItemTapped(int index) {
    if (index >= 0 && index < 4) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildScreen(_selectedIndex),
      ),
      bottomNavigationBar: AnimatedTabBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  void _handleSearch(BuildContext context, String query) {
    if (query.trim().isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(query: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Find Your Perfect\nJob Match',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Search from thousands of job opportunities across industries and locations.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Job title, company, or keywords...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onSubmitted: (value) => _handleSearch(context, value),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildLocationChip(context, 'New York'),
                    _buildLocationChip(context, 'San Francisco'),
                    _buildLocationChip(context, 'Seattle'),
                    _buildLocationChip(context, 'Boston'),
                    _buildLocationChip(context, 'Austin'),
                    _buildLocationChip(context, 'Remote'),
                  ],
                ),
              ],
            ),
          ),

          // Job Categories Section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse Jobs by Type',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find the perfect job that matches your work style',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildJobTypeCard(context, 'Full-time', Icons.work),
                    _buildJobTypeCard(context, 'Part-time', Icons.schedule),
                    _buildJobTypeCard(context, 'Contract', Icons.description),
                    _buildJobTypeCard(context, 'Internship', Icons.school),
                  ],
                ),
              ],
            ),
          ),

          // Features Section
          Container(
            padding: const EdgeInsets.all(24.0),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why Use JobFinder',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tools and resources for your job search success',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeatureCard(
                  'Powerful Search',
                  'Find relevant jobs with our advanced search and filtering options.',
                  Icons.search,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  'Top Companies',
                  'Access opportunities from leading companies across industries.',
                  Icons.business,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  'Real-time Updates',
                  'Get notified about new jobs matching your preferences instantly.',
                  Icons.notifications,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip(BuildContext context, String location) {
    return ActionChip(
      label: Text(location),
      avatar: const Icon(Icons.location_on_outlined, size: 16),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) =>
                    SearchResultsScreen(query: '', initialLocation: location),
          ),
        );
      },
    );
  }

  Widget _buildJobTypeCard(BuildContext context, String type, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) =>
                      SearchResultsScreen(query: '', initialType: type),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                type,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
