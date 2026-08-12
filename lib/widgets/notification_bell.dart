import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

/// Notification bell with a live unread badge (red dot + count).
///
/// Subscribes to Postgres realtime so the badge updates the moment an
/// admin action inserts a notification. Refreshes after the user returns
/// from the notifications screen (where notifications get marked read).
class NotificationBell extends StatefulWidget {
  final Color iconColor;
  final Color? backgroundColor;

  const NotificationBell({
    super.key,
    this.iconColor = AppTheme.onSurface,
    this.backgroundColor,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _supabaseService = SupabaseService();
  int _unread = 0;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _refresh();
    _subscribe();
  }

  @override
  void dispose() {
    if (_channel != null) _supabaseService.unsubscribeFromNotifications(_channel!);
    super.dispose();
  }

  Future<void> _refresh() async {
    final count = await _supabaseService.getUnreadNotificationCount();
    if (mounted) setState(() => _unread = count);
  }

  void _subscribe() {
    _channel = _supabaseService.subscribeToNotifications((record) {
      if (!mounted) return;
      setState(() => _unread += 1);
    });
  }

  Future<void> _open() async {
    await Navigator.of(context).pushNamed('/notifications');
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _open,
      style: widget.backgroundColor != null
          ? IconButton.styleFrom(backgroundColor: widget.backgroundColor)
          : null,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, color: widget.iconColor),
          if (_unread > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surface, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  _unread > 99 ? '99+' : '$_unread',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
