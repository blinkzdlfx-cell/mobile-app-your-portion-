import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _push = true;
  bool _email = true;
  bool _inApp = true;
  bool _marketplace = true;
  bool _kingdomProjects = false;
  bool _dailyPortion = true;

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
        title: Text('Notifications',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, 'Delivery Method', [
              _buildSwitch('Push Notifications', Icons.notifications_outlined, _push, (v) => setState(() => _push = v)),
              _buildSwitch('Email Notifications', Icons.email_outlined, _email, (v) => setState(() => _email = v)),
              _buildSwitch('In-App Notifications', Icons.chat_bubble_outline, _inApp, (v) => setState(() => _inApp = v)),
            ]),
            const SizedBox(height: 24),
            _buildSection(context, 'Topics', [
              _buildSwitch('Marketplace Updates', Icons.store_outlined, _marketplace, (v) => setState(() => _marketplace = v)),
              _buildSwitch('Kingdom Projects', Icons.handshake_outlined, _kingdomProjects, (v) => setState(() => _kingdomProjects = v)),
              _buildSwitch('Daily Portion', Icons.auto_stories_outlined, _dailyPortion, (v) => setState(() => _dailyPortion = v)),
            ]),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Preferences are saved locally for now.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.onSurfaceVariant, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.surfaceVariant),
          ),
          child: Material(
            color: AppTheme.surfaceContainerLowest,
            type: MaterialType.card,
            borderRadius: BorderRadius.circular(16),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.secondary, size: 18),
      ),
      title: Text(title, style: const TextStyle(color: AppTheme.onSurface, fontSize: 15)),
      activeColor: AppTheme.primaryContainer,
    );
  }
}
