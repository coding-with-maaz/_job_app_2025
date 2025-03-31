import 'package:flutter/material.dart';

class JobFilterDialog extends StatefulWidget {
  final String? selectedLocation;
  final String? selectedType;

  const JobFilterDialog({super.key, this.selectedLocation, this.selectedType});

  @override
  State<JobFilterDialog> createState() => _JobFilterDialogState();
}

class _JobFilterDialogState extends State<JobFilterDialog> {
  late String? _selectedLocation;
  late String? _selectedType;

  final List<String> _locations = [
    'New York',
    'San Francisco',
    'Seattle',
    'Boston',
    'Austin',
    'Chicago',
    'Remote',
  ];

  final List<String> _jobTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.selectedLocation;
    _selectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Jobs'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _locations.map((location) {
                    return ChoiceChip(
                      label: Text(location),
                      selected: _selectedLocation == location,
                      onSelected: (selected) {
                        setState(() {
                          _selectedLocation = selected ? location : null;
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Job Type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _jobTypes.map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = selected ? type : null;
                        });
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pop({'location': _selectedLocation, 'type': _selectedType});
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
