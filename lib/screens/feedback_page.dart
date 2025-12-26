import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  Future<void> _sendEmail() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final message = _messageController.text.trim();

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'support@example.com', // Replace with your email
        queryParameters: {
          'subject': 'App Feedback from $name',
          'body': 'Name: $name\nEmail: $email\n\n$message',
        },
      );

      try {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        } else {
          // Fallback: Show a dialog with the feedback for manual copy
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Copy Feedback"),
              content: SingleChildScrollView(
                child: Text(
                  'Name: $name\nEmail: $email\n\n$message',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Close"),
                ),
              ],
            ),
          );
        }

        // Clear the form after sending or showing fallback
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email client'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Feedback"),
        backgroundColor: const Color(0xFF00C853),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Enter your email";
                  final regex = RegExp(r'\S+@\S+\.\S+');
                  if (!regex.hasMatch(val)) return "Enter a valid email";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: "Message",
                  prefixIcon: Icon(Icons.message),
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter your feedback" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _sendEmail,
                icon: const Icon(Icons.send),
                label: const Text("Send Feedback"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
