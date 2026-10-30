import 'staff_dashboard.dart';
import 'package:flutter/material.dart';
import 'services/feedback_api_service.dart';

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key});

  @override
  State<StaffDashboardPage> createState() =>
      _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage> {
  final List<String> offices = [
    'Academic Affairs Office',
    'Facilities Management Office',
    'Student Services Office',
    'General Administration Office',
  ];

  String selectedOffice = 'Academic Affairs Office';

  List<Map<String, dynamic>> feedbackRecords = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final records = await FeedbackApiService.getFeedback();

      if (!mounted) return;

      setState(() {
        feedbackRecords = records
            .map((record) =>
        Map<String, dynamic>.from(record as Map))
            .toList();
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignedFeedback = feedbackRecords.where((feedback) {
      return feedback['assigned_office'] == selectedOffice;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isLoading ? null : _loadFeedback,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Feedback',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: _buildContent(assignedFeedback),
        ),
      ),
    );
  }

  Widget _buildContent(
      List<Map<String, dynamic>> assignedFeedback,
      ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Unable to load staff feedback.'),
            const SizedBox(height: 12),
            Text(errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadFeedback,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Office Feedback Management',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'View feedback automatically routed to university offices.',
        ),
        const SizedBox(height: 24),

        DropdownButtonFormField<String>(
          initialValue: selectedOffice,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Select Office',
            border: OutlineInputBorder(),
          ),
          items: offices.map((office) {
            return DropdownMenuItem(
              value: office,
              child: Text(
                office,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedOffice = value;
              });
            }
          },
        ),

        const SizedBox(height: 24),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Total Assigned Feedback',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${assignedFeedback.length}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Assigned Feedback Records',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        if (assignedFeedback.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No feedback assigned to this office.',
              ),
            ),
          ),

        ...assignedFeedback.map((feedback) {
          final title =
              feedback['title']?.toString() ?? 'Untitled';

          final category =
              feedback['category']?.toString() ?? 'Unknown';

          final description =
              feedback['description']?.toString() ?? '';

          final status =
              feedback['status']?.toString() ?? 'Pending';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Category: $category'),
                  const SizedBox(height: 6),
                  Text(description),
                  const SizedBox(height: 8),
                  Text(
                    'Status: $status',
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
