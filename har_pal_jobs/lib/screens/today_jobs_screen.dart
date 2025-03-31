import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/job_service.dart';
import 'job_details_screen.dart';

class TodayJobsScreen extends StatefulWidget {
  const TodayJobsScreen({super.key});

  @override
  State<TodayJobsScreen> createState() => _TodayJobsScreenState();
}

class _TodayJobsScreenState extends State<TodayJobsScreen> {
  final JobService _jobService = JobService();
  List<Job> _jobs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodayJobs();
  }

  Future<void> _loadTodayJobs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final jobs = await _jobService.getTodayJobs();
      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveJob(String jobId) async {
    try {
      await _jobService.saveJob(jobId);
      _loadTodayJobs(); // Reload to update saved status
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save job: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Jobs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement job filters
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading jobs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTodayJobs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs posted today',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new opportunities',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTodayJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _jobs.length,
        itemBuilder: (context, index) {
          final job = _jobs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                job.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    job.company,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        job.location,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.work_outline, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        job.type,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        job.salary,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Posted today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  job.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color:
                      job.isSaved
                          ? Theme.of(context).colorScheme.primary
                          : null,
                ),
                onPressed: () => _saveJob(job.id),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => JobDetailsScreen(jobId: job.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
