import 'dart:convert';
import 'package:logging/logging.dart';

class Job {
  static final _logger = Logger('Job');

  final String id;
  final String title;
  final String company;
  final String location;
  final String type;
  final String salary;
  final String description;
  final DateTime postedDate;
  final DateTime deadline;
  final List<String> requirements;
  final List<String> responsibilities;
  final bool isSaved;
  final bool isApplied;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.salary,
    required this.description,
    required this.postedDate,
    required this.deadline,
    required this.requirements,
    required this.responsibilities,
    this.isSaved = false,
    this.isApplied = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    _logger.fine('Parsing job JSON: ${json.toString()}');

    // Helper function to safely convert string to DateTime
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is DateTime) return date;
      try {
        if (date is int) {
          return DateTime.fromMillisecondsSinceEpoch(date);
        }
        return DateTime.parse(date.toString());
      } catch (e) {
        _logger.warning('Error parsing date: $e');
        return DateTime.now();
      }
    }

    // Helper function to safely convert dynamic to List<String>
    List<String> parseStringList(dynamic list) {
      if (list == null) return [];

      // If it's already a list, convert to strings
      if (list is List) {
        return list.map((item) => item.toString()).toList();
      }

      // If it's a string, try to parse it
      if (list is String) {
        // Remove any empty lines and trim each line
        final lines =
            list
                .split('\n')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .map((s) => s.startsWith('- ') ? s.substring(2) : s)
                .toList();

        if (lines.isNotEmpty) {
          _logger.fine('Parsed string list from newlines: $lines');
          return lines;
        }

        // If no newlines found, try JSON parsing
        try {
          final decoded = jsonDecode(list);
          if (decoded is List) {
            _logger.fine('Parsed string list from JSON: $decoded');
            return decoded.map((item) => item.toString()).toList();
          }
        } catch (e) {
          // If JSON parsing fails, split by commas
          final items =
              list
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();

          _logger.fine('Parsed string list from commas: $items');
          return items;
        }
      }

      _logger.warning('Could not parse string list, returning empty list');
      return [];
    }

    try {
      final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';
      final title = json['title']?.toString() ?? '';
      final company = json['company']?.toString() ?? '';
      final location = json['location']?.toString() ?? '';
      final type =
          json['type']?.toString() ?? json['job_type']?.toString() ?? '';
      final salary = json['salary']?.toString() ?? '';
      final description = json['description']?.toString() ?? '';
      final postedDate = parseDate(
        json['postedDate'] ??
            json['posted_date'] ??
            json['created_at'] ??
            json['createdAt'],
      );
      final deadline = parseDate(
        json['deadline'] ?? json['application_deadline'],
      );

      _logger.fine('Parsing requirements from: ${json['requirements']}');
      final requirements = parseStringList(json['requirements']);

      _logger.fine(
        'Parsing responsibilities from: ${json['responsibilities']}',
      );
      final responsibilities = parseStringList(json['responsibilities']);

      final isSaved = json['isSaved'] == true || json['is_saved'] == true;
      final isApplied = json['isApplied'] == true || json['is_applied'] == true;

      _logger.info('Successfully parsed job:');
      _logger.fine('ID: $id');
      _logger.fine('Title: $title');
      _logger.fine('Company: $company');
      _logger.fine('Location: $location');
      _logger.fine('Type: $type');
      _logger.fine('Requirements count: ${requirements.length}');
      _logger.fine('Responsibilities count: ${responsibilities.length}');

      return Job(
        id: id,
        title: title,
        company: company,
        location: location,
        type: type,
        salary: salary,
        description: description,
        postedDate: postedDate,
        deadline: deadline,
        requirements: requirements,
        responsibilities: responsibilities,
        isSaved: isSaved,
        isApplied: isApplied,
      );
    } catch (e) {
      _logger.severe('Error parsing job JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'salary': salary,
      'description': description,
      'postedDate': postedDate.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'requirements': requirements,
      'responsibilities': responsibilities,
      'isSaved': isSaved,
      'isApplied': isApplied,
    };
  }
}
