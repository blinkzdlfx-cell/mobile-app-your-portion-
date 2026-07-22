import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../models/property.dart';

class CreatePropertyScreen extends StatefulWidget {
  final Property? existingProperty;

  const CreatePropertyScreen({super.key, this.existingProperty});

  @override
  State<CreatePropertyScreen> createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
  final _supabaseService = SupabaseService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _initialized = false;
  bool? _canSell;
  bool _isSubmitting = false;
  String _selectedCategory = 'Farm Land';
  String _selectedListingType = 'For Sale';
  final Set<String> _features = {};
  List<PlatformFile> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isEditMode = false;

  final _categories = ['Farm Land', 'Land', 'House', 'Apartment', 'Room'];
  final _listingTypes = ['For Sale', 'For Lease'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _isEditMode = widget.existingProperty != null;
      if (_isEditMode) {
        _prefillForm(widget.existingProperty!);
      } else {
        _checkAccess();
      }
    }
  }

  void _prefillForm(Property p) {
    _titleController.text = p.title;
    _descriptionController.text = _extractDescription(p.description);
    _priceController.text = p.price.toString();
    _sizeController.text = p.sizeSqm?.toString() ?? '';
    _locationController.text = p.location;
    _phoneController.text = p.contactPhone ?? '';
    _selectedCategory = p.category;
    _existingImageUrls = List.from(p.images);

    if (p.description != null) {
      final lines = p.description!.split('\n');
      for (final line in lines) {
        if (line.startsWith('Features: ')) {
          for (final f in line.replaceFirst('Features: ', '').split(', ')) {
            if (f.isNotEmpty) _features.add(f);
          }
        }
        if (line.startsWith('Listing type: ')) {
          _selectedListingType = line.replaceFirst('Listing type: ', '');
        }
      }
    }
  }

  String _extractDescription(String? full) {
    if (full == null) return '';
    return full.split('\n').where((l) => !l.startsWith('Features:') && !l.startsWith('Listing type:')).join('\n').trim();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    final canSell = await _supabaseService.canSell();
    if (mounted) setState(() => _canSell = canSell);
  }

  static const int _maxImages = 8;

  int get _totalImageCount => _existingImageUrls.length + _selectedImages.length;

  Future<void> _pickImages() async {
    final remaining = _maxImages - _totalImageCount;
    if (remaining <= 0) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final combined = [..._selectedImages, ...result.files];
      setState(() => _selectedImages = combined.take(_maxImages - _existingImageUrls.length).toList());
    }
  }

  void _removeSelectedImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _removeExistingImage(String url) {
    setState(() => _existingImageUrls.remove(url));
  }

  Future<void> _saveOrSubmit(String status) async {
    if (status == 'pending' && !_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      List<String> imageUrls = List.from(_existingImageUrls);
      for (final file in _selectedImages) {
        if (file.path != null) {
          final url = await _supabaseService.uploadPropertyImage(file.path!);
          if (url != null) imageUrls.add(url);
        }
      }

      final featuresText = _features.isEmpty ? '' : 'Features: ${_features.join(', ')}';
      final fullDescription = [
        if (_descriptionController.text.isNotEmpty) _descriptionController.text,
        if (_selectedListingType.isNotEmpty) 'Listing type: $_selectedListingType',
        if (featuresText.isNotEmpty) featuresText,
      ].join('\n');

      if (_isEditMode) {
        await _supabaseService.updateProperty(widget.existingProperty!.id, {
          'title': _titleController.text.trim(),
          'description': fullDescription.isNotEmpty ? fullDescription : null,
          'category': _selectedCategory,
          'price': double.tryParse(_priceController.text.trim()) ?? 0,
          'location': _locationController.text.trim(),
          'size_sqm': double.tryParse(_sizeController.text.trim()),
          'contact_phone': _phoneController.text.trim(),
          'images': imageUrls,
          if (status == 'pending') 'status': 'pending',
          if (status == 'pending') 'rejection_reason': null,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status == 'draft' ? 'Draft saved' : 'Property submitted for review'),
              backgroundColor: AppTheme.primaryContainer,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final property = Property(
          id: '',
          sellerId: user.id,
          title: _titleController.text.trim(),
          description: fullDescription.isNotEmpty ? fullDescription : null,
          category: _selectedCategory,
          price: double.tryParse(_priceController.text.trim()) ?? 0,
          location: _locationController.text.trim(),
          sizeSqm: double.tryParse(_sizeController.text.trim()),
          contactPhone: _phoneController.text.trim(),
          images: imageUrls,
          status: status,
        );

        if (status == 'draft') {
          await _supabaseService.saveDraft(property);
        } else {
          await _supabaseService.createProperty(property);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status == 'draft' ? 'Draft saved' : 'Property submitted for review! An admin will approve it shortly.'),
              backgroundColor: AppTheme.primaryContainer,
            ),
          );
          Navigator.pushReplacementNamed(context, '/my-properties');
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString().split('Exception:').last}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  bool _validateForm() {
    if (_titleController.text.trim().isEmpty) { _showError('Please enter a property title'); return false; }
    if (_priceController.text.trim().isEmpty) { _showError('Please enter the price'); return false; }
    if (double.tryParse(_priceController.text.trim()) == null) { _showError('Please enter a valid price'); return false; }
    if (_locationController.text.trim().isEmpty) { _showError('Please enter the location'); return false; }
    if (_phoneController.text.trim().isEmpty) { _showError('Please enter your phone number'); return false; }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: !_isEditMode && _canSell == null
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : _isEditMode || _canSell! ? _buildForm() : _buildVerificationNeeded(),
      ),
    );
  }

  Widget _buildVerificationNeeded() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppTheme.primaryContainer.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user_outlined, size: 40, color: AppTheme.primaryContainer),
            ),
            const SizedBox(height: 24),
            Text('Verification Required',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 28)),
            const SizedBox(height: 12),
            Text('You need to be a verified seller to list properties.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant, height: 1.5)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryContainer, foregroundColor: AppTheme.onPrimary, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Go to Profile to Verify'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.onSurfaceVariant, minimumSize: const Size(double.infinity, 56), side: const BorderSide(color: AppTheme.outlineVariant), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface)),
              const SizedBox(width: 8),
              Text(_isEditMode ? 'Edit Property' : 'Create Property',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 22)),
            ],
          ),
          const SizedBox(height: 24),
          // Photo upload + previews
          if (_totalImageCount > 0)
            _buildImagePreviews(),
          if (_totalImageCount > 0) const SizedBox(height: 12),
          GestureDetector(
            onTap: _totalImageCount < _maxImages ? _pickImages : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: _totalImageCount > 0 ? AppTheme.primaryContainer : AppTheme.outlineVariant, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: _totalImageCount > 0 ? AppTheme.primaryContainer.withValues(alpha: 0.05) : AppTheme.surfaceContainerLowest,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_totalImageCount > 0 ? Icons.add_photo_alternate_outlined : Icons.camera_alt, color: AppTheme.primaryContainer, fill: 1),
                  const SizedBox(width: 8),
                  Text(
                    '$_totalImageCount / $_maxImages photos',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Form fields
          Text('Property Details', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface, fontSize: 20)),
          const SizedBox(height: 16),
          _buildField(_titleController, 'Title', 'e.g. Serene Greenfield Estate'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDropdown('Category', _selectedCategory, _categories, (v) => setState(() => _selectedCategory = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown('Listing Type', _selectedListingType, _listingTypes, (v) => setState(() => _selectedListingType = v))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildPriceField()),
              const SizedBox(width: 12),
              Expanded(child: _buildField(_sizeController, 'Land Size', 'e.g. 500', suffix: 'sqm')),
            ],
          ),
          const SizedBox(height: 16),
          _buildField(_locationController, 'Location', 'Search address or area', icon: Icons.location_on),
          const SizedBox(height: 16),
          _buildField(_descriptionController, 'Description', 'Describe the key features, atmosphere, and surroundings...', maxLines: 4),
          const SizedBox(height: 32),
          Text('Features', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface, fontSize: 20)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: ['Road Access', 'Electricity', 'Water Supply', 'Fenced', 'Survey Available', 'Registered Documents']
                .map((f) => _FeatureCheckbox(label: f, isSelected: _features.contains(f), onToggle: () => setState(() { if (_features.contains(f)) { _features.remove(f); } else { _features.add(f); } })))
                .toList(),
          ),
          const SizedBox(height: 32),
          Text('Contact Information', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildField(_phoneController, 'Phone Number', 'Enter your phone number'),
          const SizedBox(height: 32),
          // Buttons
          Row(
            children: [
              if (!_isEditMode)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => _saveOrSubmit('draft'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.onSurfaceVariant,
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: AppTheme.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_isSubmitting ? 'Saving...' : 'Save Draft'),
                  ),
                ),
              if (!_isEditMode) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _saveOrSubmit(_isEditMode ? widget.existingProperty!.status : 'pending'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    foregroundColor: AppTheme.onPrimary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimary)))
                      : Text(_isEditMode ? 'Update Property' : 'Submit Property'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photos', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._existingImageUrls.asMap().entries.map((e) => _buildImagePreview(e.value, isNetwork: true, index: e.key)),
            ..._selectedImages.asMap().entries.map((e) => _buildImagePreview(e.value.path!, isNetwork: false, index: e.key)),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview(String source, {required bool isNetwork, required int index}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 80, height: 80,
            child: isNetwork
                ? Image.network(source, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceVariant, child: const Icon(Icons.broken_image, color: AppTheme.outlineVariant)))
                : Image.file(File(source), fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceVariant, child: const Icon(Icons.broken_image, color: AppTheme.outlineVariant))),
          ),
        ),
        Positioned(
          top: 4, right: 4,
          child: GestureDetector(
            onTap: () => isNetwork
                ? _removeExistingImage(source)
                : _removeSelectedImage(index),
            child: Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, String hint, {int maxLines = 1, String? suffix, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: suffix != null ? TextInputType.number : null,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffix,
              prefixIcon: icon != null ? Icon(icon, color: AppTheme.onSurfaceVariant) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String> onChanged) {
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
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
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
            Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 20, color: isSelected ? AppTheme.primaryContainer : AppTheme.outlineVariant),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
