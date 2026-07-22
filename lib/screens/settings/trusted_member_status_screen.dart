import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';

class TrustedMemberStatusScreen extends StatefulWidget {
  const TrustedMemberStatusScreen({super.key});

  @override
  State<TrustedMemberStatusScreen> createState() => _TrustedMemberStatusScreenState();
}

class _TrustedMemberStatusScreenState extends State<TrustedMemberStatusScreen> {
  String? _status;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('is_trusted_member')
          .filter('id', 'eq', user.id)
          .single();
      final isTrusted = profile['is_trusted_member'] as bool? ?? false;
      final req = await Supabase.instance.client
          .from('verification_requests')
          .select('status')
          .filter('user_id', 'eq', user.id)
          .maybeSingle();
      if (isTrusted) {
        _status = 'verified';
      } else if (req != null) {
        _status = req['status'] as String? ?? 'none';
      } else {
        _status = 'none';
      }
    } catch (_) {
      _status = 'none';
    }
    if (mounted) setState(() => _loading = false);
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
        title: Text('Trusted Member Status',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 22)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: _status == 'verified'
                          ? const Color(0xFFE6F4EA)
                          : _status == 'pending'
                              ? const Color(0xFFFFF3E0)
                              : AppTheme.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _status == 'verified' ? Icons.verified : _status == 'pending' ? Icons.hourglass_top : Icons.shield_outlined,
                      size: 40,
                      color: _status == 'verified'
                          ? const Color(0xFF137333)
                          : _status == 'pending'
                              ? const Color(0xFFB06000)
                              : AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _status == 'verified' ? 'Verified Member'
                        : _status == 'pending' ? 'Application Pending'
                        : 'Not a Trusted Member',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _status == 'verified'
                        ? 'Your account is verified. You have full access to all features.'
                        : _status == 'pending'
                            ? 'Your application is being reviewed. This usually takes 1-2 business days.'
                            : 'Become a trusted member to unlock seller features and build trust in the community.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  if (_status == 'none')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/become-trusted-member'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryContainer,
                          foregroundColor: AppTheme.onPrimary,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Apply Now',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                    ),
                  if (_status == 'pending')
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          side: const BorderSide(color: AppTheme.outlineVariant),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Application Submitted',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                    ),
                  if (_status == 'verified')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF137333), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Your trusted member status is active.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF137333))),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
