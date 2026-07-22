import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  int _rating = 0;
  bool _sending = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!'),
          backgroundColor: AppTheme.primaryContainer),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Send Feedback',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text('Help us improve Your Portion. Rate your experience and leave a comment.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text('Rate your experience',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurface)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final filled = i < _rating;
                        return IconButton(
                          icon: Icon(
                            filled ? Icons.star : Icons.star_border,
                            color: filled ? const Color(0xFFFFB800) : AppTheme.outlineVariant,
                            size: 36,
                          ),
                          onPressed: () => setState(() => _rating = i + 1),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _subjectCtrl,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: Icon(Icons.subject, color: AppTheme.onSurfaceVariant),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a subject' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Your feedback',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Icon(Icons.feedback_outlined, color: AppTheme.onSurfaceVariant),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Share your feedback' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _sending ? null : _handleSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: AppTheme.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _sending
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.onPrimary))
                    : const Text('Send Feedback', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
