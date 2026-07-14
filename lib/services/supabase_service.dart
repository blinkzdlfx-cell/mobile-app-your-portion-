import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/property.dart';
import '../models/kingdom_project.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  // ======== PROFILE ========

  Future<UserProfile?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final profiles = await _client.from('profiles').select('*');
    final list = profiles as List;
    final match = list.cast<Map<String, dynamic>>().where((p) => p['id'] == user.id).toList();
    if (match.isEmpty) return null;
    return UserProfile.fromMap(match.first);
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('profiles').update(updates).filter('id', 'eq', user.id);
  }

  // ======== PROPERTIES ========

  Future<List<Property>> getProperties({String? category}) async {
    final response = await _client.from('properties').select('*');
    var list = (response as List).cast<Map<String, dynamic>>();
    if (category != null && category != 'All Listings') {
      list = list.where((p) => p['category'] == category).toList();
    }
    list.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
    return list.map((e) => Property.fromMap(e)).toList();
  }

  Future<List<Property>> getMyProperties() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final response = await _client.from('properties').select('*');
    final list = (response as List).cast<Map<String, dynamic>>()
        .where((p) => p['seller_id'] == user.id)
        .toList();
    return list.map((e) => Property.fromMap(e)).toList();
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

  // ======== SAVED PROPERTIES ========

  Future<List<String>> getSavedPropertyIds() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final response = await _client.from('saved_properties').select('*');
    final list = (response as List).cast<Map<String, dynamic>>()
        .where((s) => s['user_id'] == user.id)
        .toList();
    return list.map((e) => e['property_id'] as String).toList();
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
    final response = await _client.from('kingdom_projects').select('*');
    final list = (response as List).cast<Map<String, dynamic>>()
        .where((p) => (p['status'] == 'active' || p['status'] == 'completed'))
        .toList();
    return list.map((e) => KingdomProject.fromMap(e)).toList();
  }

  Future<List<KingdomProject>> getMyProjects() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final response = await _client.from('kingdom_projects').select('*');
    final list = (response as List).cast<Map<String, dynamic>>()
        .where((p) => p['creator_id'] == user.id)
        .toList();
    return list.map((e) => KingdomProject.fromMap(e)).toList();
  }

  Future<void> createProject(KingdomProject project) async {
    await _client.from('kingdom_projects').insert(project.toMap());
  }

  // ======== BOOKMARKED PORTIONS ========

  Future<List<Map<String, dynamic>>> getBookmarkedPortions() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final response = await _client.from('bookmarked_portions').select('*');
    final bookmarkRows = (response as List).cast<Map<String, dynamic>>()
        .where((b) => b['user_id'] == user.id)
        .toList();
    final portionIds = bookmarkRows.map((b) => b['portion_id'] as String).toList();
    if (portionIds.isEmpty) return [];
    final portions = await _client.from('daily_portions').select('*');
    final list = (portions as List).cast<Map<String, dynamic>>()
        .where((p) => portionIds.contains(p['id'] as String))
        .toList();
    return list;
  }

  Future<bool> isPortionBookmarked(String portionId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    final response = await _client.from('bookmarked_portions').select('*');
    final list = (response as List).cast<Map<String, dynamic>>()
        .where((b) => b['user_id'] == user.id && b['portion_id'] == portionId)
        .toList();
    return list.isNotEmpty;
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
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('verification_requests').insert({
      'user_id': user.id,
      'request_type': requestType,
      'full_name': fullName,
      'phone': phone,
      'reason': reason,
    });
  }

  Future<Map<String, dynamic>?> getPendingRequest(String requestType) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final response = await _client.from('verification_requests').select('*');
    final list = (response as List).cast<Map<String, dynamic>>()
        .where((r) => r['user_id'] == user.id && r['request_type'] == requestType && r['status'] == 'pending')
        .toList();
    return list.isNotEmpty ? list.first : null;
  }

  // ======== ADMIN METHODS ========

  Future<List<Map<String, dynamic>>> getPendingVerificationRequests() async {
    final response = await _client.from('verification_requests').select('*');
    final list = (response as List).cast<Map<String, dynamic>>()
        .where((r) => r['status'] == 'pending')
        .toList();
    list.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
    return list;
  }

  Future<List<Map<String, dynamic>>> getPendingProperties() async {
    final response = await _client.from('properties').select('*');
    final list = (response as List).cast<Map<String, dynamic>>()
        .where((p) => p['status'] == 'pending')
        .toList();
    list.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
    return list;
  }

  Future<List<Map<String, dynamic>>> getPendingProjects() async {
    final response = await _client.from('kingdom_projects').select('*');
    final list = (response as List).cast<Map<String, dynamic>>()
        .where((p) => p['status'] == 'pending')
        .toList();
    list.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
    return list;
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
