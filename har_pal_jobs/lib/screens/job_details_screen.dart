import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/job_service.dart';
import 'package:share_plus/share_plus.dart';
import 'saved_jobs_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final JobService _jobService = JobService();
  Job? _job;
  bool _isLoading = true;
  String? _error;
  bool _isApplyDialogOpen = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _resumeController = TextEditingController();
  final _coverLetterController = TextEditingController();
  bool _isSaving = false;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _resumeController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _loadJobDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final job = await _jobService.getJobById(widget.jobId);
      if (!mounted) return;

      setState(() {
        _job = job;
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

  Future<void> _saveJob() async {
    if (_job == null) return;

    try {
      setState(() => _isSaving = true);
      await _jobService.saveJob(_job!.id);
      if (!mounted) return;

      await _loadJobDetails(); // Reload to update saved status
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job saved successfully!')));

      // Navigate to SavedJobsScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SavedJobsScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save job: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _applyForJob() async {
    if (_job == null) return;

    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isApplying = true);
      await _jobService.applyForJob(
        _job!.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        resume: _resumeController.text,
        coverLetter: _coverLetterController.text,
      );
      if (!mounted) return;

      await _loadJobDetails(); // Reload to update applied status
      setState(() => _isApplyDialogOpen = false);
      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to apply for job: $e')));
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  void _resetForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _resumeController.clear();
    _coverLetterController.clear();
  }

  Future<void> _shareJob() async {
    if (_job == null) return;

    try {
      await Share.share(
        'Check out this job at ${_job!.company}: ${_job!.title}\n'
        'Location: ${_job!.location}\n'
        'Type: ${_job!.type}\n'
        'Salary: ${_job!.salary}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to share job')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _job?.title ?? 'Job Details',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_job != null) ...[
            IconButton(icon: const Icon(Icons.share), onPressed: _shareJob),
            IconButton(
              icon: Icon(
                _job!.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color:
                    _job!.isSaved
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
              onPressed: _isSaving ? null : _saveJob,
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_isApplyDialogOpen)
            _ApplyDialog(
              isOpen: _isApplyDialogOpen,
              onClose: () => setState(() => _isApplyDialogOpen = false),
              onSubmit: _applyForJob,
              isSubmitting: _isApplying,
              formKey: _formKey,
              nameController: _nameController,
              emailController: _emailController,
              phoneController: _phoneController,
              resumeController: _resumeController,
              coverLetterController: _coverLetterController,
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading job details...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading job details',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadJobDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_job == null) {
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
              'Job not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'The job you\'re looking for might have been removed or is no longer available.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _job!.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.business, size: 16),
                const SizedBox(width: 4),
                Text(_job!.company),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(_job!.location),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(Icons.work, _job!.type),
                _buildChip(Icons.attach_money, _job!.salary),
                _buildChip(
                  Icons.access_time,
                  'Posted ${_getTimeAgo(_job!.postedDate)}',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection('Description', _job!.description),
            const SizedBox(height: 24),
            _buildListSection(
              'Requirements',
              _job!.requirements,
              Icons.check_circle_outline,
            ),
            const SizedBox(height: 24),
            _buildListSection(
              'Responsibilities',
              _job!.responsibilities,
              Icons.arrow_right,
            ),
            const SizedBox(height: 24),
            _buildSection('Application Deadline', _formatDate(_job!.deadline)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _job!.isApplied
                        ? null
                        : () => setState(() => _isApplyDialogOpen = true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _job!.isApplied ? 'Applied' : 'Apply Now',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(content, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildListSection(
    String title,
    List<String> items,
    IconData iconData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(iconData, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _ApplyDialog extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController resumeController;
  final TextEditingController coverLetterController;

  const _ApplyDialog({
    required this.isOpen,
    required this.onClose,
    required this.onSubmit,
    required this.isSubmitting,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.resumeController,
    required this.coverLetterController,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Apply for Job',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: onClose),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                    return 'Name can only contain letters and spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: '+1234567890',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: resumeController,
                decoration: const InputDecoration(
                  labelText: 'Resume URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                  hintText: 'https://example.com/resume.pdf',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your resume URL';
                  }
                  try {
                    final uri = Uri.parse(value);
                    if (!uri.hasScheme || !uri.hasAuthority) {
                      return 'Please enter a valid URL';
                    }
                    if (!value.toLowerCase().endsWith('.pdf')) {
                      return 'Resume must be a PDF file';
                    }
                  } catch (e) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: coverLetterController,
                decoration: const InputDecoration(
                  labelText: 'Cover Letter (Optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length < 50) {
                      return 'Cover letter should be at least 50 characters';
                    }
                    if (value.length > 1000) {
                      return 'Cover letter should not exceed 1000 characters';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onClose,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : onSubmit,
                      child:
                          isSubmitting
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Submit Application'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
