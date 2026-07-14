class UserProfile {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? location;
  final String role; // 'buyer', 'seller', or 'both'
  final bool isSellerVerified;
  final bool isTrustedMember;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.location,
    this.role = 'buyer',
    this.isSellerVerified = false,
    this.isTrustedMember = false,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  String get firstName => fullName?.trim().split(' ').first ?? 'Friend';

  bool get canSell => role == 'admin' || (isSellerVerified && (role == 'seller' || role == 'both'));

  bool get canBuy => true; // everyone can buy

  bool get isBoth => role == 'both';

  String get displayRole {
    if (role == 'admin') return 'Admin';
    if (role == 'both') return 'Buyer & Seller';
    if (role == 'seller') return 'Seller';
    return 'Buyer';
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String?,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      location: map['location'] as String?,
      role: (map['role'] as String?) ?? 'buyer',
      isSellerVerified: (map['is_seller_verified'] as bool?) ?? false,
      isTrustedMember: (map['is_trusted_member'] as bool?) ?? false,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'phone': phone,
    'location': location,
    'role': role,
    'is_seller_verified': isSellerVerified,
    'is_trusted_member': isTrustedMember,
    'avatar_url': avatarUrl,
  };
}
