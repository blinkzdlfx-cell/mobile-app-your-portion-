import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Optional push notifications via Firebase Cloud Messaging.
///
/// Fully guarded: if Firebase is not configured yet (no `google-services.json`
/// on Android / `GoogleService-Info.plist` on iOS), the app still runs normally
/// and in-app notifications keep working.
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;
  PushNotificationService._();

  bool _ready = false;

  bool get isReady => _ready;

  /// Call once after Supabase.initialize().
  Future<void> init() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      _ready = true;

      messaging.onTokenRefresh.listen((token) => _syncToken(token));
      _syncToken(await messaging.getToken() ?? '');

      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final user = data.session?.user;
        if (user != null && _cachedToken != null) _syncToken(_cachedToken!);
      });
    } catch (e) {
      debugPrint('Push notifications unavailable (Firebase not configured?): $e');
    }
  }

  String? _cachedToken;

  Future<void> _syncToken(String token) async {
    if (token.isEmpty || !_ready) return;
    _cachedToken = token;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await Supabase.instance.client.from('device_tokens').upsert(
        {
          'user_id': user.id,
          'token': token,
          'platform': platform,
        },
        onConflict: 'user_id,token',
      );
    } catch (_) {
      // DB not set up yet (migration 00011 not run) — push silently skipped.
    }
  }

  /// Removes the current user's device tokens. Call BEFORE signOut.
  Future<void> unregister() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || !_ready) return;
    try {
      await Supabase.instance.client
          .from('device_tokens')
          .delete()
          .filter('user_id', 'eq', user.id);
    } catch (_) {}
  }
}
