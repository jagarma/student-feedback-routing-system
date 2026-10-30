
import 'package:flutter/material.dart';
import 'services/feedback_api_service.dart';

class MyFeedbackPage extends StatefulWidget {
  const MyFeedbackPage({super.key});

  @override
  State<MyFeedbackPage> createState() => _MyFeedbackPageState();
}

class _MyFeedbackPageState extends State<MyFeedbackPage> {
  late Future<List<dynamic>> _feedbackFuture;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  void _loadFeedback() {
    _feedbackFuture = FeedbackApiService.getFeedback();
  }

  void _refreshFeedback() {
    setState(() {
      _loadFeedback();
    });
  }

  Color _getStatusColor(String status) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feedback'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Feedback',
            onPressed: _refreshFeedback,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: FutureBuilder<List<dynamic>>(
            future: _feedbackFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Unable to load feedback.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshFeedback,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final feedbackList = snapshot.data ?? [];

              if (feedbackList.isEmpty) {
                return const Center(
                  child: Text(
                    'No feedback records found.',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: feedbackList.length,
                itemBuilder: (context, index) {
                  final feedback =
                  Map<String, dynamic>.from(feedbackList[index]);

                  final title =
                      feedback['title']?.toString() ?? 'Untitled';

                  final category =
                      feedback['category']?.toString() ?? 'Unknown';

                  final description =
                      feedback['description']?.toString() ?? '';

                  final office =
                      feedback['assigned_office']?.toString() ??
                          'Not yet assigned';

                  final status =
                      feedback['status']?.toString() ?? 'Pending';

                  final statusColor = _getStatusColor(status);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category: $category'),
                            const SizedBox(height: 6),
                            Text(description),
                            const SizedBox(height: 8),
                            Text('Assigned Office: $office'),
                            const SizedBox(height: 8),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
