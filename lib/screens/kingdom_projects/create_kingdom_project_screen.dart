import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class CreateKingdomProjectScreen extends StatefulWidget {
  const CreateKingdomProjectScreen({super.key});

  @override
  State<CreateKingdomProjectScreen> createState() => _CreateKingdomProjectScreenState();
}

class _CreateKingdomProjectScreenState extends State<CreateKingdomProjectScreen> {
  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _checkAccess();
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
              // Cover image
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.outlineVariant, width: 2, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: AppTheme.surfaceVariant, shape: BoxShape.circle),
                      child: const Icon(Icons.add_photo_alternate, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text('Upload a Cover Image',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('High resolution, minimal text recommended',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _Field(label: 'Project Title', hint: 'e.g. Grace Community Sanctuary'),
              const SizedBox(height: 16),
              _Field(label: 'Category', hint: 'e.g. Church Building, Education, Missions'),
              const SizedBox(height: 16),
              _Field(label: 'Location', hint: 'City, Country', prefixIcon: Icons.location_on),
              const SizedBox(height: 16),
              _Field(label: 'Funding Goal', hint: '0.00', prefixText: '\$'),
              const SizedBox(height: 16),
              _Field(label: 'Description', hint: 'Describe your Kingdom project, its purpose, impact, and how funds will be used...', maxLines: 5),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer, foregroundColor: AppTheme.onPrimary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Project'),
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

  const _Field({required this.label, required this.hint, this.prefixIcon, this.prefixText, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
          child: TextField(
            maxLines: maxLines,
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
