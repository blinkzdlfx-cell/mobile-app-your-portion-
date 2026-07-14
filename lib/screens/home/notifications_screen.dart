import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.8),
                border: Border(bottom: BorderSide(color: AppTheme.surfaceVariant.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Mark all read',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // New section
                    Text(
                      'New',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _NotificationCard(
                      icon: Icons.menu_book_rounded,
                      iconBg: AppTheme.primaryFixed,
                      iconColor: AppTheme.onPrimaryFixed,
                      title: "Today's Portion Available",
                      message: "Read today's devotional.",
                      time: '2 mins ago',
                      isUnread: true,
                    ),
                    const SizedBox(height: 12),
                    _NotificationCard(
                      icon: Icons.agriculture_rounded,
                      iconBg: AppTheme.secondaryContainer,
                      iconColor: AppTheme.onSecondaryContainer,
                      title: 'Property Approved',
                      message: 'Listing now visible.',
                      time: '1 hour ago',
                      isUnread: true,
                    ),
                    const SizedBox(height: 32),
                    // Earlier section
                    Text(
                      'Earlier',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _NotificationCard(
                      icon: Icons.favorite_rounded,
                      iconBg: AppTheme.surfaceVariant,
                      iconColor: AppTheme.onSurfaceVariant,
                      title: 'Kingdom Project Approved',
                      message: 'Project reviewed and published.',
                      time: 'Yesterday',
                      isUnread: false,
                    ),
                    const SizedBox(height: 12),
                    _NotificationCard(
                      icon: Icons.campaign_rounded,
                      iconBg: AppTheme.surfaceVariant,
                      iconColor: AppTheme.onSurfaceVariant,
                      title: 'Announcement',
                      message: 'New community post.',
                      time: 'Tuesday',
                      isUnread: false,
                    ),
                    const SizedBox(height: 12),
                    _NotificationCard(
                      icon: Icons.verified_rounded,
                      iconBg: AppTheme.tertiaryFixed,
                      iconColor: AppTheme.onTertiaryFixed,
                      title: 'Trusted Member',
                      message: 'Verification approved.',
                      time: 'Oct 12',
                      isUnread: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const _NotificationCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnread ? AppTheme.surfaceContainerLowest : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceContainerHigh),
        boxShadow: isUnread ? [AppTheme.ambientShadow] : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppTheme.primaryContainer,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
