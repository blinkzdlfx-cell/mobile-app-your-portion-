import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/property.dart';
import '../models/property_review.dart';
import '../models/kingdom_project.dart';
import '../models/daily_portion.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  // ======== PROFILE ========

  Future<UserProfile?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final profile = await _client
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();
    if (profile == null) return null;
    return UserProfile.fromMap(profile);
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('profiles').update(updates).eq('id', user.id);
  }

  // ======== PROPERTIES ========

  /// Approved listings, filtered and paginated server-side.
  ///
  /// [sortBy]: 'newest' (default), 'price_asc', or 'price_desc'.
  Future<List<Property>> getProperties({
    String? category,
    String sortBy = 'newest',
    int page = 0,
    int pageSize = 20,
  }) async {
    var query = _client
        .from('properties')
        .select('*')
        .eq('status', 'approved');
    if (category != null && category != 'All Listings') {
      query = query.eq('category', category);
    }
    final sorted = switch (sortBy) {
      'price_asc' => query.order('price', ascending: true),
      'price_desc' => query.order('price', ascending: false),
      _ => query.order('created_at', ascending: false),
    };
    final response = await sorted.range(page * pageSize, page * pageSize + pageSize - 1);
    return (response as List)
        .cast<Map<String, dynamic>>()
        .map(Property.fromMap)
        .toList();
  }

  /// Approved listings by ids (used for saved properties), newest first.
  Future<List<Property>> getPropertiesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final response = await _client
        .from('properties')
        .select('*')
        .inFilter('id', ids)
        .eq('status', 'approved')
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>().map(Property.fromMap).toList();
  }

  Future<List<Property>> getMyProperties() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final response = await _client
        .from('properties')
        .select('*')
        .eq('seller_id', user.id)
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>().map(Property.fromMap).toList();
  }

  Future<void> createProperty(Property property) async {
    await _client.from('properties').insert(property.toMap());
  }

  Future<void> updateProperty(String id, Map<String, dynamic> updates) async {
    await _client.from('properties').update(updates).filter('id', 'eq', id);
  }

  Future<void> deleteProperty(String id) async {
    await _client.from('properties').delete().filter('id', 'eq', id);
  }

  Future<void> saveDraft(Property property) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final data = property.toMap();
    data['status'] = 'draft';
    await _client.from('properties').insert(data);
  }

  Future<void> updateDraft(String id, Map<String, dynamic> updates) async {
    await _client.from('properties').update(updates).filter('id', 'eq', id);
  }

  Future<void> archiveProperty(String id) async {
    await _client.from('properties').update({'status': 'archived'}).filter('id', 'eq', id);
  }

  Future<void> reactivateProperty(String id) async {
    await _client.from('properties').update({'status': 'approved'}).filter('id', 'eq', id);
  }

  // ======== SAVED PROPERTIES ========

  Future<List<String>> getSavedPropertyIds() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final response = await _client
        .from('saved_properties')
        .select('property_id')
        .eq('user_id', user.id);
    return (response as List)
        .cast<Map<String, dynamic>>()
        .map((e) => e['property_id'] as String)
        .toList();
  }

  Future<void> saveProperty(String propertyId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('saved_properties').insert({
      'user_id': user.id,
      'property_id': propertyId,
    });
  }

  Future<void> unsaveProperty(String propertyId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('saved_properties').delete().filter('user_id', 'eq', user.id).filter('property_id', 'eq', propertyId);
  }

  // ======== KINGDOM PROJECTS ========

  Future<List<KingdomProject>> getProjects() async {
    final response = await _client
        .from('kingdom_projects')
        .select('*')
        .inFilter('status', ['active', 'completed'])
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>().map(KingdomProject.fromMap).toList();
  }

  Future<List<KingdomProject>> getMyProjects() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final response = await _client
        .from('kingdom_projects')
        .select('*')
        .eq('creator_id', user.id)
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>().map(KingdomProject.fromMap).toList();
  }

  Future<void> createProject(KingdomProject project) async {
    await _client.from('kingdom_projects').insert(project.toMap());
  }

  // ======== DAILY PORTIONS ========

  /// All published portions, newest first.
  Future<List<DailyPortion>> getPortions() async {
    final response = await _client
        .from('daily_portions')
        .select('*')
        .eq('is_published', true)
        .order('publish_date', ascending: false);
    return (response as List).cast<Map<String, dynamic>>().map(DailyPortion.fromMap).toList();
  }

  /// The portion published for today, falling back to the latest published
  /// portion so the app never shows an empty state while content is being seeded.
  Future<DailyPortion?> getTodayPortion() async {
    final all = await getPortions();
    if (all.isEmpty) return null;
    final today = DateTime.now();
    for (final p in all) {
      final date = p.publishDate;
      if (date != null && date.year == today.year && date.month == today.month && date.day == today.day) {
        return p;
      }
    }
    return all.first;
  }

  Future<DailyPortion?> getPortionById(String id) async {
    final row = await _client
        .from('daily_portions')
        .select('*')
        .eq('id', id)
        .eq('is_published', true)
        .maybeSingle();
    if (row == null) return null;
    return DailyPortion.fromMap(row);
  }

  Future<bool> isPortionRead(String portionId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    try {
      final row = await _client
          .from('portion_reads')
          .select('*')
          .eq('user_id', user.id)
          .eq('portion_id', portionId)
          .maybeSingle();
      return row != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> markPortionRead(String portionId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    try {
      await _client.from('portion_reads').upsert(
        {'user_id': user.id, 'portion_id': portionId, 'read_at': DateTime.now().toIso8601String()},
        onConflict: 'user_id,portion_id',
      );
    } catch (_) {
      // Table not migrated yet (00012) — read status silently skipped.
    }
  }

  Future<String?> getPortionReflection(String portionId) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      final row = await _client
          .from('portion_reflections')
          .select('content')
          .eq('user_id', user.id)
          .eq('portion_id', portionId)
          .maybeSingle();
      if (row == null) return null;
      return row['content'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> savePortionReflection(String portionId, String content) async {
    final user = _client.auth.currentUser;
    if (user == null || content.trim().isEmpty) return;
    try {
      await _client.from('portion_reflections').upsert(
        {
          'user_id': user.id,
          'portion_id': portionId,
          'content': content.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,portion_id',
      );
    } catch (_) {
      // Table not migrated yet (00012) — reflection silently skipped.
    }
  }

  // ======== BOOKMARKED PORTIONS ========

  Future<List<DailyPortion>> getBookmarkedPortions() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final rows = await _client
        .from('bookmarked_portions')
        .select('portion_id')
        .eq('user_id', user.id);
    final portionIds = (rows as List)
        .cast<Map<String, dynamic>>()
        .map((b) => b['portion_id'] as String)
        .toSet();
    if (portionIds.isEmpty) return [];
    final portions = await _client
        .from('daily_portions')
        .select('*')
        .inFilter('id', portionIds.toList());
    return (portions as List).cast<Map<String, dynamic>>().map(DailyPortion.fromMap).toList();
  }

  Future<bool> isPortionBookmarked(String portionId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    final row = await _client
        .from('bookmarked_portions')
        .select('*')
        .eq('user_id', user.id)
        .eq('portion_id', portionId)
        .maybeSingle();
    return row != null;
  }

  Future<void> bookmarkPortion(String portionId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('bookmarked_portions').insert({
      'user_id': user.id,
      'portion_id': portionId,
    });
  }

  Future<void> removeBookmarkedPortion(String portionId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('bookmarked_portions').delete().filter('user_id', 'eq', user.id).filter('portion_id', 'eq', portionId);
  }

  // ======== VERIFICATION REQUESTS ========

  Future<void> submitVerificationRequest({
    required String requestType,
    String? fullName,
    String? phone,
    String? reason,
    String? idDocumentUrl,
    String? idType,
    String? faceImageUrl,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _ensureProfileExists(user);

    final data = <String, dynamic>{
      'user_id': user.id,
      'request_type': requestType,
    };
    if (fullName != null) data['full_name'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (reason != null) data['reason'] = reason;
    if (idDocumentUrl != null) data['id_document_url'] = idDocumentUrl;
    if (idType != null) data['id_type'] = idType;
    if (faceImageUrl != null) data['face_image_url'] = faceImageUrl;
    await _client.from('verification_requests').insert(data);
  }

  Future<void> _ensureProfileExists(User user) async {
    try {
      final existing = await _client.from('profiles').select('id').filter('id', 'eq', user.id).maybeSingle();
      if (existing != null) return;
      await _client.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'],
        'role': user.userMetadata?['role'] ?? 'buyer',
      });
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getPendingRequest(String requestType) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _client
        .from('verification_requests')
        .select('*')
        .eq('user_id', user.id)
        .eq('request_type', requestType)
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getLatestVerificationRequest(String requestType) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _client
        .from('verification_requests')
        .select('*')
        .eq('user_id', user.id)
        .eq('request_type', requestType)
        .order('created_at', ascending: false)
        .maybeSingle();
  }

  /// Status helpers for a verification request.
  /// Returns 'pending', 'approved', 'rejected', 'terminated', or 'none'.
  static String verificationStatus(Map<String, dynamic>? request) {
    if (request == null) return 'none';
    final status = request['status'] as String? ?? 'none';
    if (status == 'approved' && request['terminated_at'] != null) return 'terminated';
    return status;
  }

  static String? verificationReason(Map<String, dynamic>? request) {
    if (request == null) return null;
    final reason = request['termination_reason'] as String? ?? request['admin_note'] as String?;
    return reason;
  }

  Future<String> _uploadBytes(String bucket, String path, Uint8List bytes, String extension) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final session = _client.auth.currentSession;
    final token = session?.accessToken;
    if (token == null) throw Exception('No session token');

    final fileName = '$path/${DateTime.now().millisecondsSinceEpoch}.$extension';
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

    final mediaType = _contentTypeFor(extension);

    final uri = Uri.parse('$supabaseUrl/storage/v1/object/$bucket/$fileName');
    final request = http.MultipartRequest('POST', uri)
      ..headers['apikey'] = anonKey
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: mediaType,
      ));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Upload failed ($response.statusCode): $body');
    }

    return '$supabaseUrl/storage/v1/object/public/$bucket/$fileName';
  }

  static MediaType _contentTypeFor(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'heic':
      case 'heif':
        return MediaType('image', 'heic');
      case 'pdf':
        return MediaType('application', 'pdf');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  Future<String> uploadVerificationDocument({required Uint8List bytes, required String extension}) async {
    return _uploadBytes('verification_documents', '${_client.auth.currentUser?.id}/documents', bytes, extension);
  }

  Future<String> uploadFaceImage({required Uint8List bytes, required String extension}) async {
    return _uploadBytes('verification_documents', '${_client.auth.currentUser?.id}/face', bytes, extension);
  }

  Future<String?> uploadPropertyImage({required Uint8List bytes, required String extension}) async {
    try {
      return await _uploadBytes('property_images', '${_client.auth.currentUser?.id}', bytes, extension);
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadAvatar({required Uint8List bytes, required String extension}) async {
    try {
      return await _uploadBytes('avatars', '${_client.auth.currentUser?.id}/avatar', bytes, extension);
    } catch (_) {
      return null;
    }
  }

  // ======== REVIEWS ========

  Future<List<PropertyReview>> getReviews(String propertyId) async {
    final response = await _client
        .from('reviews')
        .select('*, reviewer:profiles(full_name, is_seller_verified)')
        .eq('property_id', propertyId)
        .order('created_at', ascending: false);
    return (response as List)
        .cast<Map<String, dynamic>>()
        .map(PropertyReview.fromMap)
        .toList();
  }

  Future<PropertyReview?> getMyReview(String propertyId) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('reviews')
        .select('*, reviewer:profiles(full_name, is_seller_verified)')
        .eq('property_id', propertyId)
        .eq('reviewer_id', user.id)
        .maybeSingle();
    if (row == null) return null;
    return PropertyReview.fromMap(row);
  }

  Future<void> addReview(String propertyId, int rating, String? comment) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    await _client.from('reviews').insert({
      'property_id': propertyId,
      'reviewer_id': user.id,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<void> updateReview(String reviewId, int rating, String? comment) async {
    await _client.from('reviews').update({
      'rating': rating,
      'comment': comment,
    }).eq('id', reviewId);
  }

  Future<void> deleteReview(String reviewId) async {
    await _client.from('reviews').delete().eq('id', reviewId);
  }

  // ======== SEARCH ========

  Future<List<Property>> searchProperties(String query, {int limit = 10}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final response = await _client
        .from('properties')
        .select('*')
        .eq('status', 'approved')
        .ilike('title', '%$q%')
        .order('created_at', ascending: false)
        .limit(limit);
    return (response as List).cast<Map<String, dynamic>>().map(Property.fromMap).toList();
  }

  Future<List<KingdomProject>> searchProjects(String query, {int limit = 10}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final response = await _client
        .from('kingdom_projects')
        .select('*')
        .inFilter('status', ['active', 'completed'])
        .ilike('title', '%$q%')
        .order('created_at', ascending: false)
        .limit(limit);
    return (response as List).cast<Map<String, dynamic>>().map(KingdomProject.fromMap).toList();
  }

  Future<List<DailyPortion>> searchPortions(String query, {int limit = 10}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final response = await _client
        .from('daily_portions')
        .select('*')
        .eq('is_published', true)
        .ilike('title', '%$q%')
        .order('publish_date', ascending: false)
        .limit(limit);
    return (response as List).cast<Map<String, dynamic>>().map(DailyPortion.fromMap).toList();
  }

  // ======== ACCOUNT ========

  bool isEmailVerified() {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    return user.emailConfirmedAt != null || (user.userMetadata?['email_verified'] as bool?) == true;
  }

  /// Deletes the user's account via the `delete-account` edge function.
  /// Requires deployment: `supabase functions deploy delete-account`.
  Future<void> deleteAccount() async {
    final response = await _client.functions.invoke('delete-account');
    if (response.status >= 400) {
      final data = response.data as Map<String, dynamic>?;
      throw Exception(data?['error'] ?? 'Account deletion failed');
    }
  }

  // ======== ADMIN METHODS ========

  Future<List<Map<String, dynamic>>> getPendingVerificationRequests() async {
    final response = await _client
        .from('verification_requests')
        .select('*')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPendingProperties() async {
    final response = await _client
        .from('properties')
        .select('*')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPendingProjects() async {
    final response = await _client
        .from('kingdom_projects')
        .select('*')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<void> approveVerificationRequest(String requestId, String userId, String requestType) async {
    await _client.from('verification_requests').update({
      'status': 'approved',
      'reviewed_by': _client.auth.currentUser?.id,
    }).filter('id', 'eq', requestId);

    if (requestType == 'seller') {
      await _client.from('profiles').update({'is_seller_verified': true}).filter('id', 'eq', userId);
    } else if (requestType == 'trusted_member') {
      await _client.from('profiles').update({'is_trusted_member': true}).filter('id', 'eq', userId);
    }
  }

  Future<void> rejectVerificationRequest(String requestId, String reason) async {
    await _client.from('verification_requests').update({
      'status': 'rejected',
      'admin_note': reason,
      'reviewed_by': _client.auth.currentUser?.id,
    }).filter('id', 'eq', requestId);
  }

  // ======== NOTIFICATIONS ========

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final response = await _client
        .from('notifications')
        .select('*')
        .filter('user_id', 'eq', user.id)
        .filter('channel', 'eq', 'in_app')
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<int> getUnreadNotificationCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;
    try {
      final response = await _client
          .from('notifications')
          .select('is_read')
          .eq('user_id', user.id)
          .eq('channel', 'in_app')
          .eq('is_read', false);
      final list = (response as List).cast<Map<String, dynamic>>();
      return list.length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markNotificationsRead() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client
        .from('notifications')
        .update({'is_read': true})
        .filter('user_id', 'eq', user.id)
        .filter('is_read', 'eq', false);
  }

  RealtimeChannel subscribeToNotifications(void Function(Map<String, dynamic>) onInsert) {
    final user = _client.auth.currentUser;
    final channel = _client
        .channel('notifications-${user?.id ?? 'anon'}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final record = payload.newRecord;
            if (record['user_id'] == user?.id) onInsert(record);
          },
        );
    channel.subscribe();
    return channel;
  }

  void unsubscribeFromNotifications(RealtimeChannel channel) {
    _client.removeChannel(channel);
  }

  Future<void> approveProperty(String propertyId) async {
    await _client.from('properties').update({
      'status': 'approved',
      'is_verified': true,
    }).filter('id', 'eq', propertyId);
  }

  Future<void> rejectProperty(String propertyId, String reason) async {
    await _client.from('properties').update({
      'status': 'rejected',
      'rejection_reason': reason,
    }).filter('id', 'eq', propertyId);
  }

  Future<void> approveProject(String projectId) async {
    await _client.from('kingdom_projects').update({
      'status': 'active',
    }).filter('id', 'eq', projectId);
  }

  Future<void> rejectProject(String projectId, String reason) async {
    await _client.from('kingdom_projects').update({
      'status': 'rejected',
      'rejection_reason': reason,
    }).filter('id', 'eq', projectId);
  }

  // ======== ROLE HELPERS ========

  Future<bool> canSell() async {
    final profile = await getCurrentProfile();
    return profile?.canSell ?? false;
  }

  Future<bool> isAdmin() async {
    final profile = await getCurrentProfile();
    return profile?.role == 'admin';
  }
}
