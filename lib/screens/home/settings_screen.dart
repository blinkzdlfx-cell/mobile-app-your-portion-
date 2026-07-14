import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.onSurface),
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
                _SettingsTile(icon: Icons.person_outline, title: 'Edit Profile', iconBg: AppTheme.primaryContainer.withValues(alpha: 0.1), iconColor: AppTheme.primaryContainer, onTap: () => Navigator.pushNamed(context, '/edit-profile')),
                _SettingsTile(icon: Icons.verified_user_outlined, title: 'Trusted Member Status', iconBg: AppTheme.primaryContainer.withValues(alpha: 0.1), iconColor: AppTheme.primaryContainer),
                _SettingsTile(icon: Icons.lock_outline, title: 'Change Password', iconBg: AppTheme.primaryContainer.withValues(alpha: 0.1), iconColor: AppTheme.primaryContainer),
              ]),
              const SizedBox(height: 24),
              // Preferences section
              _SectionHeader(text: 'Preferences'),
              const SizedBox(height: 8),
              _SettingsCard(items: [
                _SettingsTile(icon: Icons.notifications_outlined, title: 'Notifications', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary),
                _SettingsTile(icon: Icons.swap_horiz, title: 'Buyer & Seller Role', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary),
                _SettingsTile(icon: Icons.language, title: 'Language', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary, trailing: 'English'),
              ]),
              const SizedBox(height: 24),
              // Support section
              _SectionHeader(text: 'Support'),
              const SizedBox(height: 8),
              _SettingsCard(items: [
                _SettingsTile(icon: Icons.help_outline, title: 'Help Center', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary, onTap: () => Navigator.pushNamed(context, '/help-support')),
                _SettingsTile(icon: Icons.mail_outline, title: 'Contact Us', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary),
                _SettingsTile(icon: Icons.rate_review_outlined, title: 'Send Feedback', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary),
              ]),
              const SizedBox(height: 24),
              // About section
              _SectionHeader(text: 'About'),
              const SizedBox(height: 8),
              _SettingsCard(items: [
                _SettingsTile(icon: Icons.info_outline, title: 'About Your Portion', iconBg: AppTheme.surfaceContainer, iconColor: AppTheme.secondary),
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
                  onPressed: () {},
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: AppTheme.error, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
  final List<_SettingsTile> items;
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
  final String? trailing;
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
              Text(
                trailing!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}
