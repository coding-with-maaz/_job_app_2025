import 'package:flutter/material.dart';
import '../services/job_service.dart';

class SaveJobIcon extends StatefulWidget {
  final String jobId;
  final double size;
  final Color? color;

  const SaveJobIcon({
    super.key,
    required this.jobId,
    this.size = 24.0,
    this.color,
  });

  @override
  State<SaveJobIcon> createState() => _SaveJobIconState();
}

class _SaveJobIconState extends State<SaveJobIcon> {
  final _jobService = JobService();
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    setState(() => _isLoading = true);
    try {
      final isSaved = await _jobService.isJobSaved(widget.jobId);
      setState(() => _isSaved = isSaved);
    } catch (e) {
      debugPrint('Error checking saved status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSave() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      if (_isSaved) {
        await _jobService.unsaveJob(widget.jobId);
      } else {
        await _jobService.saveJob(widget.jobId);
      }
      setState(() => _isSaved = !_isSaved);
    } catch (e) {
      debugPrint('Error toggling save: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved ? 'Failed to unsave job' : 'Failed to save job',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon:
          _isLoading
              ? SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color ?? Theme.of(context).primaryColor,
                  ),
                ),
              )
              : Icon(
                _isSaved ? Icons.favorite : Icons.favorite_border,
                color:
                    _isSaved
                        ? Colors.red
                        : (widget.color ?? Theme.of(context).primaryColor),
                size: widget.size,
              ),
      onPressed: _toggleSave,
      tooltip: _isSaved ? 'Unsave job' : 'Save job',
    );
  }
}
