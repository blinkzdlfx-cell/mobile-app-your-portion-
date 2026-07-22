import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class BuyerSellerRoleScreen extends StatefulWidget {
  const BuyerSellerRoleScreen({super.key});

  @override
  State<BuyerSellerRoleScreen> createState() => _BuyerSellerRoleScreenState();
}

class _BuyerSellerRoleScreenState extends State<BuyerSellerRoleScreen> {
  String _selectedRole = 'buyer';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final role = user.userMetadata?['role'] as String?;
      if (role != null && role.isNotEmpty) {
        _selectedRole = role;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'role': _selectedRole}),
      );
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').update({
          'role': _selectedRole,
        }).filter('id', 'eq', user.id);
      }
      if (mounted) {
        if (_selectedRole == 'seller') {
          final profile = await SupabaseService().getCurrentProfile();
          final isVerified = profile?.isSellerVerified ?? false;
          if (!isVerified) {
            Navigator.pushReplacementNamed(context, '/document-upload');
            return;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role updated successfully'), backgroundColor: AppTheme.primaryContainer),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update role: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
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
        title: Text('Buyer & Seller Role',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 22)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text('Choose how you want to use Your Portion.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  _roleCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Buyer',
                    subtitle: 'Browse properties, save listings, and connect with sellers.',
                    selected: _selectedRole == 'buyer',
                    onTap: () => setState(() => _selectedRole = 'buyer'),
                  ),
                  const SizedBox(height: 12),
                  _roleCard(
                    icon: Icons.store_outlined,
                    title: 'Seller',
                    subtitle: 'List properties, manage your listings, and connect with buyers.',
                    selected: _selectedRole == 'seller',
                    onTap: () => setState(() => _selectedRole = 'seller'),
                  ),
                  const SizedBox(height: 12),
                  _roleCard(
                    icon: Icons.swap_horiz,
                    title: 'Both',
                    subtitle: 'Buy and sell properties on Your Portion.',
                    selected: _selectedRole == 'both',
                    onTap: () => setState(() => _selectedRole = 'both'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer,
                      foregroundColor: AppTheme.onPrimary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.onPrimary))
                        : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _roleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primaryContainer : AppTheme.surfaceVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryContainer.withValues(alpha: 0.1) : AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: selected ? AppTheme.primaryContainer : AppTheme.secondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ),
            Radio<String>(
              value: title.toLowerCase() == 'both' ? 'both' : title.toLowerCase(),
              groupValue: _selectedRole,
              onChanged: (v) => setState(() => _selectedRole = v!),
              activeColor: AppTheme.primaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}
