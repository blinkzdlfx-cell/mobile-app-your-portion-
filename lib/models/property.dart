class Property {
  final String id;
  final String sellerId;
  final String title;
  final String? description;
  final String category;
  final double price;
  final String currency;
  final String location;
  final double? sizeSqm;
  final int? bedrooms;
  final int? bathrooms;
  final List<String> images;
  final String? contactWhatsapp;
  final String? contactPhone;
  final String? contactEmail;
  final String status;
  final bool isVerified;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Property({
    required this.id,
    required this.sellerId,
    required this.title,
    this.description,
    required this.category,
    required this.price,
    this.currency = 'USD',
    required this.location,
    this.sizeSqm,
    this.bedrooms,
    this.bathrooms,
    this.images = const [],
    this.contactWhatsapp,
    this.contactPhone,
    this.contactEmail,
    this.status = 'pending',
    this.isVerified = false,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  String get formattedPrice {
    if (price >= 1000) return '\$${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}k';
    return '\$${price.toInt()}';
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] as String,
      sellerId: map['seller_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      currency: (map['currency'] as String?) ?? 'USD',
      location: map['location'] as String,
      sizeSqm: (map['size_sqm'] as num?)?.toDouble(),
      bedrooms: map['bedrooms'] as int?,
      bathrooms: map['bathrooms'] as int?,
      images: (map['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      contactWhatsapp: map['contact_whatsapp'] as String?,
      contactPhone: map['contact_phone'] as String?,
      contactEmail: map['contact_email'] as String?,
      status: (map['status'] as String?) ?? 'pending',
      isVerified: (map['is_verified'] as bool?) ?? false,
      rejectionReason: map['rejection_reason'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'seller_id': sellerId,
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'currency': currency,
    'location': location,
    'size_sqm': sizeSqm,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'images': images,
    'contact_whatsapp': contactWhatsapp,
    'contact_phone': contactPhone,
    'contact_email': contactEmail,
    'status': status,
  };
}
