import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/skeleton/skeleton_layouts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribe();
  }

  @override
  void dispose() {
    if (_channel != null) {
      _supabaseService.unsubscribeFromNotifications(_channel!);
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final notifications = await _supabaseService.getNotifications();
      if (mounted) setState(() => _notifications = notifications);
    } catch (_) {
      // Keep existing list if fetch fails
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _subscribe() {
    _channel = _supabaseService.subscribeToNotifications((record) {
      if (!mounted) return;
      setState(() {
        _notifications = [
          record,
          ..._notifications.where((n) => n['id'] != record['id']),
        ];
      });
    });
  }

  Future<void> _markAllRead() async {
    await _supabaseService.markNotificationsRead();
    if (mounted) {
      setState(() {
        _notifications = _notifications
            .map((n) => {...n, 'is_read': true})
            .toList();
      });
    }
  }

  int get _unreadCount => _notifications.where((n) => n['is_read'] == false).length;

  @override
  Widget build(BuildContext context) {
    final newItems = _notifications.where((n) => n['is_read'] == false).toList();
    final earlierItems = _notifications.where((n) => n['is_read'] == true).toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
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
                    icon:  Icon(Icons.arrow_back, color: AppTheme.onSurface),
                    style: IconButton.styleFrom(backgroundColor: Colors.transparent),
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
                    onTap: _unreadCount > 0 ? _markAllRead : null,
                    child: Text(
                      'Mark all read',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _unreadCount > 0 ? AppTheme.primary : AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const SkeletonNotificationList()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.primary,
                      child: _notifications.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 160),
                                Icon(Icons.notifications_none,
                                  size: 56,
                                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.4)),
                                const SizedBox(height: 16),
                                Center(
                                  child: Text('No notifications yet',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.onSurfaceVariant,
                                    )),
                                ),
                              ],
                            )
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                              children: [
                                if (newItems.isNotEmpty) ...[
                                  _SectionLabel('New'),
                                  const SizedBox(height: 16),
                                  ...newItems.map((n) => _buildCard(context, n)),
                                  const SizedBox(height: 32),
                                ],
                                if (earlierItems.isNotEmpty) ...[
                                  _SectionLabel('Earlier'),
                                  const SizedBox(height: 16),
                                  ...earlierItems.map((n) => _buildCard(context, n)),
                                ],
                              ],
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> n) {
    final isUnread = n['is_read'] == false;
    final type = n['type'] as String? ?? 'general';
    final title = n['title'] as String? ?? '';
    final message = n['message'] as String? ?? '';
    final createdAt = n['created_at'] as String?;
    final (icon, iconBg, iconColor) = _iconForType(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
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
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                    )),
                  const SizedBox(height: 4),
                  Text(message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    )),
                  const SizedBox(height: 4),
                  Text(_timeAgo(createdAt),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.secondary,
                    )),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 10,
                height: 10,
                decoration:  BoxDecoration(
                  color: AppTheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  (IconData, Color, Color) _iconForType(String type) {
    switch (type) {
      case 'verification_terminated':
        return (Icons.gpp_bad_outlined, AppTheme.errorContainer, AppTheme.onErrorContainer);
      case 'verification_approved':
        return (Icons.verified_outlined, AppTheme.primaryFixed, AppTheme.onPrimaryFixed);
      case 'verification_rejected':
        return (Icons.cancel_outlined, AppTheme.errorContainer, AppTheme.onErrorContainer);
      case 'property_approved':
        return (Icons.agriculture_rounded, AppTheme.secondaryContainer, AppTheme.onSecondaryContainer);
      case 'project_approved':
        return (Icons.campaign_rounded, AppTheme.tertiaryFixed, AppTheme.onTertiaryFixed);
      default:
        return (Icons.notifications_outlined, AppTheme.surfaceContainer, AppTheme.secondary);
    }
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    final time = DateTime.tryParse(iso);
    if (time == null) return '';
    final diff = DateTime.now().difference(time.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    final local = time.toLocal();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[local.month - 1]} ${local.day}';
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppTheme.onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }
}
