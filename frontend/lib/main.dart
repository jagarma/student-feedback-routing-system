
import 'package:flutter/material.dart';
import 'student_dashboard.dart';
import 'services/feedback_api_service.dart';

void main() {
  runApp(const StudentFeedbackApp());
}

class StudentFeedbackApp extends StatelessWidget {
  const StudentFeedbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Feedback Routing System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const StudentDashboard(),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();

  final _studentNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _feedbackController = TextEditingController();

  String _category = 'Academic';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _studentNameController.dispose();
    _titleController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await FeedbackApiService.submitFeedback(
        studentName: _studentNameController.text.trim(),
        title: _titleController.text.trim(),
        category: _category,
        description: _feedbackController.text.trim(),
      );

      if (!mounted) return;

      final routingSuccess = result['routing_success'] == true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            routingSuccess
                ? 'Feedback submitted and routed successfully!'
                : 'Feedback saved, but routing requires manual review.',
          ),
          backgroundColor:
          routingSuccess ? Colors.green : Colors.orange,
        ),
      );

      // Clear fields after successful API submission.
      _studentNameController.clear();
      _titleController.clear();
      _feedbackController.clear();

      setState(() {
        _category = 'Academic';
      });

      _formKey.currentState?.reset();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Feedback Routing System'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Submit Student Feedback',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Student Name
                      TextFormField(
                        controller: _studentNameController,
                        decoration: const InputDecoration(
                          labelText: 'Student Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Feedback Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Feedback Title',
                          hintText: 'Enter a short title',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter a feedback title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Feedback Category
                      DropdownButtonFormField<String>(
                        key: ValueKey(_category),
                        initialValue: _category,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Feedback Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'Academic',
                          'Facilities',
                          'Student Services',
                          'Others',
                        ].map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                          if (value != null) {
                            setState(() {
                              _category = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // Feedback Description
                      TextFormField(
                        controller: _feedbackController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Your Feedback',
                          hintText:
                          'Enter your feedback here...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your feedback';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      FilledButton(
                        onPressed:
                        _isSubmitting ? null : _submitFeedback,
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                          child: _isSubmitting
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text('Submit Feedback'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
