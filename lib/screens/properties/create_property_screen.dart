import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class CreatePropertyScreen extends StatefulWidget {
  const CreatePropertyScreen({super.key});

  @override
  State<CreatePropertyScreen> createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final canSell = await _supabaseService.canSell();
    if (!canSell && mounted) {
      Navigator.of(context).pushReplacementNamed('/marketplace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be a verified seller to list properties.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
  final Set<String> _features = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
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
                    icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
                  ),
                  const SizedBox(width: 8),
                  Text('Create Property',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 22)),
                ],
              ),
              const SizedBox(height: 24),
              // Photo upload
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.outlineVariant, width: 2, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.surfaceContainerLowest,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: AppTheme.surfaceContainer, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: AppTheme.primaryContainer, fill: 1),
                    ),
                    const SizedBox(height: 12),
                    Text('Upload Property Photos', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Property Details', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface, fontSize: 20)),
              const SizedBox(height: 16),
              _buildField('Title', 'e.g. Serene Greenfield Estate'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Category', 'Farm Land', ['Farm Land', 'Land', 'House', 'Apartment', 'Room'])),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdown('Listing Type', 'For Sale', ['For Sale', 'For Lease'])),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildPriceField('Price', '\$')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildFieldWithSuffix('Land Size', 'e.g. 500', 'sqm')),
                ],
              ),
              const SizedBox(height: 16),
              _buildFieldWithPrefix('Location', 'Search address or area', Icons.location_on),
              const SizedBox(height: 16),
              _buildField('Description', 'Describe the key features, atmosphere, and surroundings...', maxLines: 4),
              const SizedBox(height: 32),
              Text('Features', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface, fontSize: 20)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: ['Road Access', 'Electricity', 'Water Supply', 'Fenced', 'Survey Available', 'Registered Documents']
                    .map((f) => _FeatureCheckbox(label: f, isSelected: _features.contains(f), onToggle: () {
                           setState(() {
                             if (_features.contains(f)) { _features.remove(f); } else { _features.add(f); }
                           });
                        }))
                    .toList(),
              ),
              const SizedBox(height: 32),
              Text('Contact Information', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _buildField('Phone Number', 'Enter your phone number'),
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
                  child: const Text('Submit Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            maxLines: maxLines,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: Theme.of(context).textTheme.bodyMedium,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField(String label, String prefix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(prefixText: prefix, border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldWithSuffix(String label, String hint, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(hintText: hint, suffixText: suffix, border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldWithPrefix(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hint, prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant),
              border: InputBorder.none, contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureCheckbox extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onToggle;
  const _FeatureCheckbox({required this.label, required this.isSelected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryContainer.withValues(alpha: 0.08) : AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryContainer : AppTheme.surfaceContainerHigh),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: isSelected ? AppTheme.primaryContainer : AppTheme.outlineVariant,
            ),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
