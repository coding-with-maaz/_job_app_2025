import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/job.dart';
import '../services/job_service.dart';
import '../widgets/job_filter_dialog.dart';
import 'job_details_screen.dart';
import 'search_results_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final JobService _jobService = JobService();
  final _logger = Logger('JobsScreen');
  final TextEditingController _searchController = TextEditingController();
  List<Job> _jobs = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedLocation;
  String? _selectedType;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreJobs();
    }
  }

  Future<void> _loadJobs({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _jobs = [];
        _hasMore = true;
      });
    }

    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _logger.info('Loading jobs - Page: $_currentPage');
      final jobs = await _jobService.getJobs(
        page: _currentPage,
        limit: _itemsPerPage,
      );

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _jobs = jobs;
        } else {
          _jobs.addAll(jobs);
        }
        _hasMore = jobs.length == _itemsPerPage;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      _logger.severe('Error loading jobs: $e');
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load jobs: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreJobs() async {
    if (_isLoading || _error != null) return;

    print('Loading more jobs - Current page: $_currentPage');
    setState(() {
      _currentPage++;
    });

    await _loadJobs(refresh: false);
  }

  Future<void> _saveJob(String jobId) async {
    try {
      await _jobService.saveJob(jobId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job saved successfully')));
      _loadJobs(); // Reload to update saved status
    } catch (e) {
      print('Error saving job: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save job. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(query: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final result = await showDialog<Map<String, String?>>(
                context: context,
                builder:
                    (context) => JobFilterDialog(
                      selectedLocation: _selectedLocation,
                      selectedType: _selectedType,
                    ),
              );

              if (result != null) {
                setState(() {
                  _selectedLocation = result['location'];
                  _selectedType = result['type'];
                });
                _loadJobs();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
          ),
          if (_selectedLocation != null || _selectedType != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedLocation != null)
                    Chip(
                      label: Text(_selectedLocation!),
                      onDeleted: () {
                        setState(() {
                          _selectedLocation = null;
                        });
                        _loadJobs();
                      },
                    ),
                  if (_selectedType != null)
                    Chip(
                      label: Text(_selectedType!),
                      onDeleted: () {
                        setState(() {
                          _selectedType = null;
                        });
                        _loadJobs();
                      },
                    ),
                ],
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _jobs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _jobs.isEmpty) {
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
            ElevatedButton(onPressed: _loadJobs, child: const Text('Retry')),
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
              'No jobs found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: _jobs.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _jobs.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final job = _jobs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                job.title,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
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
                      Flexible(
                        child: Text(
                          job.location,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.work_outline, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          job.type,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          job.salary,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Posted ${_getTimeAgo(job.postedDate)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
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

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
