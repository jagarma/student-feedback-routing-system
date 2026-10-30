
import 'package:flutter/material.dart';
import 'services/feedback_api_service.dart';

class FeedbackStatusPage extends StatefulWidget {
  const FeedbackStatusPage({super.key});

  @override
  State<FeedbackStatusPage> createState() =>
      _FeedbackStatusPageState();
}

class _FeedbackStatusPageState extends State<FeedbackStatusPage> {
  List<Map<String, dynamic>> feedbackRecords = [];

  int selectedIndex = 0;
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

        selectedIndex = 0;
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
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  int _currentStep(String status) {
    switch (status) {
      case 'Pending':
        return 1;
      case 'In Progress':
        return 2;
      case 'Resolved':
        return 3;
      default:
        return 0;
    }
  }

  String _latestUpdate(String status, String office) {
    switch (status) {
      case 'Pending':
        return office == 'Not yet assigned'
            ? 'Feedback has been submitted but is not yet assigned.'
            : 'Feedback is assigned to $office and is awaiting review.';

      case 'In Progress':
        return 'Feedback is currently marked as In Progress.';

      case 'Resolved':
        return 'Feedback is currently marked as Resolved.';

      default:
        return 'Current feedback status: $status';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Status Tracking'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isLoading ? null : _loadFeedback,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load feedback status.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFeedback,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (feedbackRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text('No feedback records found.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeedback,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    final feedback = feedbackRecords[selectedIndex];

    final title =
        feedback['title']?.toString() ?? 'Untitled Feedback';

    final category =
        feedback['category']?.toString() ?? 'Unknown';

    final office =
        feedback['assigned_office']?.toString() ??
            'Not yet assigned';

    final status =
        feedback['status']?.toString() ?? 'Unknown';

    final feedbackId =
        feedback['id']?.toString() ?? 'N/A';

    final steps = [
      'Submitted',
      'Pending',
      'In Progress',
      'Resolved',
    ];

    final currentStep = _currentStep(status);
    final statusColor = _statusColor(status);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Track Your Feedback',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select a feedback record to view its current status.',
        ),
        const SizedBox(height: 24),

        DropdownButtonFormField<int>(
          key: ValueKey(
            '${feedbackRecords.length}-$selectedIndex',
          ),
          initialValue: selectedIndex,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Select Feedback',
            border: OutlineInputBorder(),
          ),
          items: List.generate(
            feedbackRecords.length,
                (index) {
              final record = feedbackRecords[index];

              final recordId =
                  record['id']?.toString() ?? 'N/A';

              final recordTitle =
                  record['title']?.toString() ?? 'Untitled';

              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                  '#$recordId - $recordTitle',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedIndex = value;
              });
            }
          },
        ),

        const SizedBox(height: 24),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text('Feedback ID: $feedbackId'),

                const SizedBox(height: 8),

                Text('Category: $category'),

                const SizedBox(height: 8),

                Text('Assigned Office: $office'),

                const SizedBox(height: 12),

                Text(
                  'Current Status: $status',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const Divider(height: 32),

                const Text(
                  'Progress Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'This overview reflects the current '
                      'database status. Historical stage '
                      'timestamps are not yet recorded.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 16),

                ...List.generate(steps.length, (index) {
                  final reached = index <= currentStep;

                  return ListTile(
                    leading: Icon(
                      reached
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: reached
                          ? Colors.green
                          : Colors.grey,
                    ),
                    title: Text(steps[index]),
                    subtitle: Text(
                      reached
                          ? 'At or before current stage'
                          : 'Not yet reached',
                    ),
                  );
                }),

                const Divider(height: 32),

                const Text(
                  'Current Status Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(_latestUpdate(status, office)),

                const SizedBox(height: 16),

                const Text(
                  'For the latest information, '
                      'press the refresh button.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
