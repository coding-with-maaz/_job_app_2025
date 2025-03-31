import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/local_storage_service.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_indicator.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({Key? key}) : super(key: key);

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final _storageService = LocalStorageService();
  List<Job> _savedJobs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedJobs();
  }

  Future<void> _loadSavedJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jobs = await _storageService.getSavedJobs();
      setState(() {
        _savedJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load saved jobs: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _unsaveJob(String jobId) async {
    try {
      await _storageService.unsaveJob(jobId);
      setState(() {
        _savedJobs.removeWhere((job) => job.id == jobId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unsave job: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavedJobs,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSavedJobs,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_savedJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No saved jobs yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jobs you save will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSavedJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _savedJobs.length,
        itemBuilder: (context, index) {
          final job = _savedJobs[index];
          return Dismissible(
            key: Key(job.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _unsaveJob(job.id);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: JobCard(job: job),
            ),
          );
        },
      ),
    );
  }
}
