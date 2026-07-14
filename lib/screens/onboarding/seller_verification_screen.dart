import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class SellerVerificationScreen extends StatefulWidget {
  const SellerVerificationScreen({super.key});

  @override
  State<SellerVerificationScreen> createState() => _SellerVerificationScreenState();
}

class _SellerVerificationScreenState extends State<SellerVerificationScreen> {
  final _supabaseService = SupabaseService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasPendingRequest = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _checkPending();
    }
  }

  Future<void> _checkPending() async {
    final existing = await _supabaseService.getPendingRequest('seller');
    if (mounted) setState(() => _hasPendingRequest = existing != null);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final meta = user?.userMetadata;
      await _supabaseService.submitVerificationRequest(
        requestType: 'seller',
        fullName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : (meta?['full_name'] as String?) ?? '',
        phone: _phoneController.text.trim(),
        reason: _reasonController.text.trim(),
      );
      if (mounted) {
        setState(() => _hasPendingRequest = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seller verification submitted! An admin will review it shortly.'),
            backgroundColor: AppTheme.primaryContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.onBackground),
                    style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceContainer),
                  ),
                  const Spacer(),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.storefront_outlined, color: AppTheme.primary, size: 28),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 32),
              if (_hasPendingRequest) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryContainer.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.hourglass_top, size: 48, color: AppTheme.primaryContainer),
                      const SizedBox(height: 16),
                      Text('Request Pending',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onBackground)),
                      const SizedBox(height: 8),
                      Text('Your seller verification request is being reviewed. You\'ll be able to list properties once approved.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                        textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ] else ...[
                Text('Become a Seller',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppTheme.onBackground, fontSize: 28),
                  textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text('Get verified to list properties and create Kingdom projects on Your Portion.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurfaceVariant, height: 1.5),
                  textAlign: TextAlign.center),
                const SizedBox(height: 24),
                _InputField(label: 'Full Name', controller: _nameController, hint: 'Enter your full name'),
                const SizedBox(height: 12),
                _InputField(label: 'Phone Number', controller: _phoneController, hint: 'Enter your phone number', keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _InputField(label: 'Why do you want to sell?', controller: _reasonController, hint: 'Tell us about what you plan to sell...', maxLines: 4),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer,
                      foregroundColor: AppTheme.onPrimary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 24, height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimary)))
                        : const Text('Submit Request'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, size: 18, color: AppTheme.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(child: Text(
                        'All sellers are verified to ensure a safe and trustworthy marketplace.',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant, height: 1.5))),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int? maxLines;

  const _InputField({required this.label, required this.controller, this.hint, this.keyboardType, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.surfaceVariant),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}