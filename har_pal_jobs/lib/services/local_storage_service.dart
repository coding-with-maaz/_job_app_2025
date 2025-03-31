import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job.dart';

class LocalStorageService {
  static const String _savedJobsKey = 'saved_jobs';
  static final LocalStorageService _instance = LocalStorageService._internal();
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  Future<List<Job>> getSavedJobs() async {
    await _ensureInitialized();
    final String? savedJobsJson = _prefs.getString(_savedJobsKey);
    if (savedJobsJson == null) return [];

    try {
      final List<dynamic> savedJobsList = jsonDecode(savedJobsJson);
      return savedJobsList.map((json) => Job.fromJson(json)).toList();
    } catch (e) {
      print('Error decoding saved jobs: $e');
      return [];
    }
  }

  Future<void> saveJob(Job job) async {
    await _ensureInitialized();
    try {
      final savedJobs = await getSavedJobs();
      if (!savedJobs.any((j) => j.id == job.id)) {
        savedJobs.add(job);
        await _prefs.setString(
          _savedJobsKey,
          jsonEncode(savedJobs.map((j) => j.toJson()).toList()),
        );
      }
    } catch (e) {
      print('Error saving job: $e');
      rethrow;
    }
  }

  Future<void> unsaveJob(String jobId) async {
    await _ensureInitialized();
    try {
      final savedJobs = await getSavedJobs();
      savedJobs.removeWhere((job) => job.id == jobId);
      await _prefs.setString(
        _savedJobsKey,
        jsonEncode(savedJobs.map((j) => j.toJson()).toList()),
      );
    } catch (e) {
      print('Error unsaving job: $e');
      rethrow;
    }
  }

  Future<bool> isJobSaved(String jobId) async {
    await _ensureInitialized();
    try {
      final savedJobs = await getSavedJobs();
      return savedJobs.any((job) => job.id == jobId);
    } catch (e) {
      print('Error checking if job is saved: $e');
      return false;
    }
  }
}
