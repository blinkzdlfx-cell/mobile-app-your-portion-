import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

Color _colorForUser(String id) {
  final colors = [
    const Color(0xFF1B4332),
    const Color(0xFF4A6572),
    const Color(0xFF7B4F4A),
    const Color(0xFF3A6B4A),
    const Color(0xFF6B4A6B),
    const Color(0xFF3A6B6B),
    const Color(0xFF6B6B3A),
    const Color(0xFF8B5E3C),
    const Color(0xFF5B4A7B),
    const Color(0xFF4A7B5B),
  ];
  return colors[id.hashCode.abs() % colors.length];
}

String _initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  if (parts.length == 1 && parts[0].isNotEmpty) {
    return parts[0][0].toUpperCase();
  }
  return '?';
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _supabaseService = SupabaseService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isSaving = false;
  String _avatarInitials = '?';
  Color _avatarColor = AppTheme.primaryContainer;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata;
    final name = (meta?['full_name'] as String?) ?? '';
    _nameController.text = name;
    _emailController.text = user?.email ?? '';
    _phoneController.text = meta?['phone'] as String? ?? '';
    _locationController.text = meta?['location'] as String? ?? '';
    _avatarInitials = _initials(name);
    _avatarColor = _colorForUser(user?.id ?? '');
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final location = _locationController.text.trim();

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': name,
            'phone': phone,
            'location': location,
          },
        ),
      );

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await _supabaseService.updateProfile({
          'full_name': name,
          'phone': phone,
          'location': location,
        });
      }

      if (mounted) {
        setState(() {
          _avatarInitials = _initials(name);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.primaryContainer,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${error.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            children: [
              // App bar
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                  ),
                  const Spacer(),
                  Text(
                    'Edit Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: _avatarColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surfaceVariant),
                    ),
                    child: Center(
                      child: Text(
                        _avatarInitials,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surfaceVariant),
                      ),
                      child: const Icon(Icons.edit, size: 18, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Personal Information
              Text(
                'PERSONAL INFORMATION',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _InputField(label: 'Full Name', controller: _nameController),
              const SizedBox(height: 12),
              _InputField(label: 'Email Address', controller: _emailController, readOnly: true),
              const SizedBox(height: 12),
              _InputField(label: 'Phone Number', controller: _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _InputField(
                label: 'Location',
                controller: _locationController,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 32),
              // Save
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    foregroundColor: AppTheme.onPrimary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimary),
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your personal information is securely protected and only used to improve your experience within the Your Portion community.',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
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
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool readOnly;

  const _InputField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? AppTheme.surfaceVariant : AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.surfaceVariant),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: readOnly ? AppTheme.onSurfaceVariant : AppTheme.onSurface,
            ),
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.onSurfaceVariant) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}