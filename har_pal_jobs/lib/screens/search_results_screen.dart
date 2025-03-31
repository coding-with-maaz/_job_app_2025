import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/job_service.dart';
import '../widgets/job_filter_dialog.dart';
import 'job_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  final String? initialLocation;
  final String? initialType;

  const SearchResultsScreen({
    super.key,
    required this.query,
    this.initialLocation,
    this.initialType,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final JobService _jobService = JobService();
  List<Job> _jobs = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedLocation;
  String? _selectedType;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _selectedType = widget.initialType;
    _loadSearchResults();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreResults();
    }
  }

  Future<void> _loadSearchResults({bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _jobs = [];
      });
    }

    try {
      final jobs = await _jobService.getJobs(
        search: widget.query,
        page: _currentPage,
      );

      if (!mounted) return;

      setState(() {
        if (reset) {
          _jobs = jobs;
        } else {
          _jobs.addAll(jobs);
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoading) return;

    setState(() {
      _currentPage++;
    });

    await _loadSearchResults(reset: false);
  }

  Future<void> _saveJob(String jobId) async {
    try {
      await _jobService.saveJob(jobId);
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job saved successfully')));
      _loadSearchResults(); // Reload to update saved status
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save job: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.query.isEmpty
              ? 'Filtered Jobs'
              : 'Results for "${widget.query}"',
        ),
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

              if (result != null && mounted) {
                setState(() {
                  _selectedLocation = result['location'];
                  _selectedType = result['type'];
                });
                _loadSearchResults();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
                        _loadSearchResults();
                      },
                    ),
                  if (_selectedType != null)
                    Chip(
                      label: Text(_selectedType!),
                      onDeleted: () {
                        setState(() {
                          _selectedType = null;
                        });
                        _loadSearchResults();
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
              'Error loading results',
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
              onPressed: _loadSearchResults,
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
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSearchResults,
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
