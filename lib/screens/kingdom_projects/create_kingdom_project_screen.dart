import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../models/kingdom_project.dart';

class CreateKingdomProjectScreen extends StatefulWidget {
  const CreateKingdomProjectScreen({super.key});

  @override
  State<CreateKingdomProjectScreen> createState() => _CreateKingdomProjectScreenState();
}

class _CreateKingdomProjectScreenState extends State<CreateKingdomProjectScreen> {
  final _supabaseService = SupabaseService();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _goalController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _goalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    final canSell = await _supabaseService.canSell();
    if (!canSell && mounted) {
      Navigator.of(context).pushReplacementNamed('/kingdom-projects');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be a verified seller to create kingdom projects.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final goal = double.tryParse(_goalController.text.trim());
    if (title.isEmpty) {
      _showError('Please enter a project title.');
      return;
    }
    if (goal == null || goal <= 0) {
      _showError('Please enter a valid funding goal.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final description = [
        if (_locationController.text.trim().isNotEmpty) 'Location: ${_locationController.text.trim()}',
        if (_descriptionController.text.trim().isNotEmpty) _descriptionController.text.trim(),
      ].join('\n');

      final project = KingdomProject(
        id: '',
        creatorId: user.id,
        title: title,
        description: description.isNotEmpty ? description : null,
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        goalAmount: goal,
        status: 'pending',
      );

      await _supabaseService.createProject(project);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project submitted! An admin will review it shortly.'),
            backgroundColor: AppTheme.primaryContainer,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Text('Create Kingdom Project',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 20)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your project will be reviewed by an admin before going live.',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _Field(
                label: 'Project Title *',
                hint: 'e.g. Grace Community Sanctuary',
                controller: _titleController,
              ),
              const SizedBox(height: 16),
              _Field(
                label: 'Category',
                hint: 'e.g. Church Building, Education, Missions',
                controller: _categoryController,
              ),
              const SizedBox(height: 16),
              _Field(
                label: 'Location',
                hint: 'City, Country',
                prefixIcon: Icons.location_on,
                controller: _locationController,
              ),
              const SizedBox(height: 16),
              _Field(
                label: 'Funding Goal *',
                hint: '0.00',
                prefixText: '\$',
                keyboardType: TextInputType.number,
                controller: _goalController,
              ),
              const SizedBox(height: 16),
              _Field(
                label: 'Description',
                hint: 'Describe your Kingdom project, its purpose, impact, and how funds will be used...',
                maxLines: 5,
                controller: _descriptionController,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer, foregroundColor: AppTheme.onPrimary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimary),
                          ),
                        )
                      : const Text('Submit Project'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, hint;
  final IconData? prefixIcon;
  final String? prefixText;
  final int maxLines;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    this.prefixIcon,
    this.prefixText,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.onSurfaceVariant) : null,
              prefixText: prefixText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
