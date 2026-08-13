import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../services/push_notification_service.dart';
import '../../services/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _supabaseService = SupabaseService();
  String _role = 'buyer';
  bool _isSellerVerified = false;
  bool _hasPendingVerification = false;
  String? _verificationStatus;
  bool _loaded = false;
  bool _emailVerified = false;
  bool _deletingAccount = false;
  bool _darkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final meta = user.userMetadata;
    final role = (meta?['role'] as String?) ?? 'buyer';
    final profile = await _supabaseService.getCurrentProfile();
    final verificationRequest = await _supabaseService.getLatestVerificationRequest('seller');
    final status = SupabaseService.verificationStatus(verificationRequest);
    final emailVerified = _supabaseService.isEmailVerified();
    if (mounted) {
      setState(() {
        _role = profile?.role ?? role;
        _isSellerVerified = profile?.isSellerVerified ?? false;
        _hasPendingVerification = status == 'pending';
        _verificationStatus = status;
        _emailVerified = emailVerified;
        _darkMode = AppSettings.themeMode.value == ThemeMode.dark;
      });
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account, your profile, '
          'your listings, and all associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deletingAccount = true);
    try {
      await _supabaseService.deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
    } catch (e) {
      if (mounted) {
        setState(() => _deletingAccount = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await PushNotificationService().unregister();
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
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
                    icon:  Icon(Icons.arrow_back_ios_new, color: AppTheme.onSurface),
                  ),
                  const Spacer(),
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              // Account section
              _SectionHeader(text: 'Account'),
              const SizedBox(height: 8),
              _SettingsCard(items: [
                _SettingsTile(icon: Icons.person_outline, title: 'Edit Profile', iconBg: AppTheme.primaryContainer.withValues(alpha: 0.1), iconColor: AppTheme.primaryContainer, trailing: _EmailVerifiedBadge(verified: _emailVerified), onTap: () => Navigator.pushNamed(context, '/edit-profile')),
                _SettingsTile(icon: Icons.verified_user_outlined, title: 'Trusted Member Status', iconBg: AppTheme.primaryContainer.withValues(alpha: 0.1), iconColor: AppTheme.primaryContainer, onTap: () => Navigator.pushNamed(context, '/trusted-member-status')),
                _SettingsTile(icon: Icons.lock_outline, title: 'Change Password', iconBg: AppTheme.primaryContainer.withValues(alpha: 0.1), iconColor: AppTheme.primaryContainer, onTap: () => Navigator.pushNamed(context, '/change-password')),
                _SettingsTile(icon: Icons.mark_email_read_outlined, title: 'Email Verification', iconBg: AppTheme.errorContainer.withValues(alpha: 0.1), iconColor: AppTheme.onErrorContainer, trailing: _EmailVerifiedBadge(verified: _emailVerified, showLabel: false), onTap: null),
                if (_role == 'seller' && !_isSellerVerified)
                  _SettingsTile(
                    icon: Icons.badge_outlined,
                    title: 'Seller Verification',
                    iconBg: AppTheme.primaryContainer.withValues(alpha: 0.1),
                    iconColor: AppTheme.primaryContainer,
                    trailing: _hasPendingVerification
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                 Icon(Icons.hourglass_top, size: 12, color: AppTheme.primaryContainer),
                                const SizedBox(width: 4),
                                Text('Pending',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppTheme.primaryContainer, fontSize: 11)),
                              ],
                            ),
                          )
                        : (_verificationStatus == 'rejected' || _verificationStatus == 'terminated')
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorContainer.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                     Icon(Icons.info_outline, size: 12, color: AppTheme.onErrorContainer),
                                    const SizedBox(width: 4),
                                    Text(_verificationStatus == 'rejected' ? 'Rejected' : 'Terminated',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: AppTheme.onErrorContainer, fontSize: 11)),
                                  ],
                                ),
                              )
                            : null,
                    onTap: _hasPendingVerification
                        ? null
                        : () => Navigator.pushNamed(context, '/seller-verification'),
                  ),
              ]),
              const SizedBox(height: 24),
              // Preferences section
              _SectionHeader(text: 'Preferences'),
              const SizedBox(height: 8),
              _SettingsCard(items: [
                _SettingsTile(icon: Icons.notifications_outlined, title: 'Notifications', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary, onTap: () => Navigator.pushNamed(context, '/notification-settings')),
                _SettingsTile(icon: Icons.swap_horiz, title: 'Buyer & Seller Role', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary, onTap: () => Navigator.pushNamed(context, '/buyer-seller-role')),
                _SettingsTile(icon: Icons.language, title: 'Language', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary, trailing: Text('English', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)), onTap: () => Navigator.pushNamed(context, '/language')),
                _DarkModeTile(
                  value: _darkMode,
                  onChanged: (value) {
                    AppSettings.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    setState(() => _darkMode = value);
                  },
                ),
              ]),
              const SizedBox(height: 24),
              // Support section
              _SectionHeader(text: 'Support'),
              const SizedBox(height: 8),
              _SettingsCard(items: [
                _SettingsTile(icon: Icons.help_outline, title: 'Help Center', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary, onTap: () => Navigator.pushNamed(context, '/help-support')),
                _SettingsTile(icon: Icons.mail_outline, title: 'Contact Us', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary, onTap: () => Navigator.pushNamed(context, '/contact-us')),
                _SettingsTile(icon: Icons.rate_review_outlined, title: 'Send Feedback', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary, onTap: () => Navigator.pushNamed(context, '/send-feedback')),
              ]),
              const SizedBox(height: 24),
              // About section
              _SectionHeader(text: 'About'),
              const SizedBox(height: 8),
              _SettingsCard(items: [
                _SettingsTile(icon: Icons.info_outline, title: 'About Your Portion', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary, onTap: () => Navigator.pushNamed(context, '/about')),
                _SettingsTile(icon: Icons.shield_outlined, title: 'Privacy Policy', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary),
                _SettingsTile(icon: Icons.description_outlined, title: 'Terms & Conditions', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    minimumSize: const Size(double.infinity, 56),
                    side:  BorderSide(color: AppTheme.error, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Delete account
              TextButton.icon(
                onPressed: _deletingAccount ? null : _handleDeleteAccount,
                icon: _deletingAccount
                    ?  SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.error),
                      )
                    : const Icon(Icons.delete_outline),
                label: const Text('Delete Account'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkModeTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DarkModeTile({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.dark_mode_outlined, color: AppTheme.secondary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Dark Mode',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.primaryContainer,
            onChanged: onChanged,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _EmailVerifiedBadge extends StatelessWidget {
  final bool verified;
  final bool showLabel;
  const _EmailVerifiedBadge({required this.verified, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    final color = verified ? const Color(0xFF2E7D32) : AppTheme.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(verified ? Icons.verified : Icons.error_outline, size: 12, color: color),
              if (showLabel) ...[
                const SizedBox(width: 4),
                Text(
                  verified ? 'Verified' : 'Unverified',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceVariant),
        boxShadow: [AppTheme.ambientShadow],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          return Column(
            children: [
              if (entry.key > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 72),
                  child: Divider(height: 1, color: AppTheme.surfaceVariant),
                ),
              entry.value,
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconBg;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.iconBg,
    required this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurface,
                ),
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 8),
            ],
             Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}
