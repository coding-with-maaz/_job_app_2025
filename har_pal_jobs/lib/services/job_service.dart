import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/job.dart';
import 'package:logging/logging.dart';
import 'local_storage_service.dart';

class JobService {
  final _logger = Logger('JobService');
  final _storageService = LocalStorageService();
  final String baseUrl = 'http://s12.hosterpk.com:5000/api';
  final Duration timeout = const Duration(seconds: 10);

  Future<List<Job>> getJobs({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _logger.info(
        'Fetching jobs - Search: $search, Page: $page, Limit: $limit',
      );

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse(
        '$baseUrl/jobs',
      ).replace(queryParameters: queryParams);
      _logger.info('Request URL: $uri');

      final response = await http.get(uri).timeout(timeout);
      _logger.info('Response status: ${response.statusCode}');
      _logger.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> jobsData = data['data'] ?? [];
        return jobsData.map((json) => Job.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error fetching jobs: $e');
      rethrow;
    }
  }

  Future<List<Job>> getTodayJobs() async {
    try {
      _logger.info('Fetching today\'s jobs');
      final response = await http
          .get(Uri.parse('$baseUrl/jobs/today'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Job.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load today\'s jobs: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error fetching today\'s jobs: $e');
      rethrow;
    }
  }

  Future<Job> getJobById(String id) async {
    try {
      _logger.info('Fetching job with ID: $id');
      final response = await http
          .get(Uri.parse('$baseUrl/jobs/$id'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Job.fromJson(data);
      } else {
        throw Exception('Failed to load job: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error fetching job: $e');
      rethrow;
    }
  }

  Future<void> saveJob(String jobId) async {
    try {
      _logger.info('Saving job with ID: $jobId');
      final job = await getJobById(jobId);
      await _storageService.saveJob(job);
      _logger.info('Job saved successfully');
    } catch (e) {
      _logger.severe('Error saving job: $e');
      rethrow;
    }
  }

  Future<void> unsaveJob(String jobId) async {
    try {
      _logger.info('Unsaving job with ID: $jobId');
      await _storageService.unsaveJob(jobId);
      _logger.info('Job unsaved successfully');
    } catch (e) {
      _logger.severe('Error unsaving job: $e');
      rethrow;
    }
  }

  Future<bool> isJobSaved(String jobId) async {
    try {
      return await _storageService.isJobSaved(jobId);
    } catch (e) {
      _logger.severe('Error checking if job is saved: $e');
      return false;
    }
  }

  Future<List<Job>> getSavedJobs() async {
    try {
      return await _storageService.getSavedJobs();
    } catch (e) {
      _logger.severe('Error getting saved jobs: $e');
      return [];
    }
  }

  Future<void> applyForJob(
    String jobId, {
    required String name,
    required String email,
    required String phone,
    required String resume,
    String? coverLetter,
  }) async {
    try {
      _logger.info('Applying for job with ID: $jobId');
      final response = await http
          .post(
            Uri.parse('$baseUrl/jobs/$jobId/apply'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'phone': phone,
              'resume': resume,
              'coverLetter': coverLetter,
            }),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to apply for job: ${response.statusCode}');
      }
      _logger.info('Application submitted successfully');
    } catch (e) {
      _logger.severe('Error applying for job: $e');
      rethrow;
    }
  }
}
