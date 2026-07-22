import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  String? _selectedRole;
  bool _isSaving = false;
  bool _isLoaded = false;
  bool _hasSession = true;

  bool get _hasSelection => _selectedRole != null;

  @override
  void initState() {
    super.initState();
    _checkExistingRole();
  }

  Future<void> _checkExistingRole() async {
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;

    if (session == null || user == null) {
      if (mounted) setState(() {
        _isLoaded = true;
        _hasSession = false;
      });
      return;
    }

    final role = user.userMetadata?['role'] as String?;
    if (role != null && role.isNotEmpty) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) setState(() => _isLoaded = true);
    }
  }

  Future<void> _saveRole() async {
    if (!_hasSelection) return;
    setState(() => _isSaving = true);

    final role = _selectedRole!;

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'role': role}),
      );

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').update({
          'role': role,
          'email': user.email,
        }).filter('id', 'eq', user.id);

        if (mounted) {
          if (role == 'seller') {
            Navigator.pushReplacementNamed(context, '/document-upload');
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        final msg = e.toString();
        if (msg.contains('session') || msg.contains('AuthRetryableFetchException')) {
          _hasSession = false;
          setState(() {});
        } else if (msg.contains('42501') || msg.contains('row-level security')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please sign in again to continue.'),
              backgroundColor: AppTheme.error,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something went wrong. Please try signing in again.'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                    style: IconButton.styleFrom(backgroundColor: Colors.transparent),
                  ),
                  const Spacer(),
                  Text(
                    'Your Portion',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  if (!_hasSession)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
                      child: Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _hasSession ? _buildRoleSelection() : _buildEmailVerification(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailVerification() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                size: 40,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Verify Your Email',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We\'ve sent a verification email to your inbox. Please confirm your email address, then sign in to get started.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: AppTheme.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Go to Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Text(
          'How will you use Your Portion?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.onBackground,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the option that best describes you. You can change this later at any time.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _RoleCard(
          icon: Icons.search_rounded,
          title: 'Buyer',
                      subtitle: 'Browse farmland, land, houses, apartments, and rooms.',
          isSelected: _selectedRole == 'buyer',
          onTap: () => setState(() => _selectedRole = 'buyer'),
        ),
        const SizedBox(height: 12),
        _RoleCard(
          icon: Icons.storefront_rounded,
          title: 'Seller',
          subtitle: 'List properties for sale or lease and manage your listings with ease.',
          isSelected: _selectedRole == 'seller',
          onTap: () => setState(() => _selectedRole = 'seller'),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_hasSelection && !_isSaving) ? _saveRole : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasSelection ? AppTheme.primaryContainer : AppTheme.outlineVariant,
              foregroundColor: _hasSelection ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
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
                : Text(_selectedRole == 'seller' ? 'Continue to Verification' : 'Continue'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              side: const BorderSide(color: AppTheme.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Skip for now',
              style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'You can update your role anytime from your profile settings.',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFf8faf9) : AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryContainer : AppTheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [AppTheme.ambientShadow] : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFe8f0ec) : AppTheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.onBackground,
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.radio_button_checked,
                color: AppTheme.primaryContainer,
              )
            else
              const Icon(
                Icons.radio_button_off,
                color: AppTheme.outlineVariant,
              ),
          ],
        ),
      ),
    );
  }
}
