class PropertyReview {
  final String id;
  final String propertyId;
  final String reviewerId;
  final int rating;
  final String? comment;
  final String? reviewerName;
  final bool reviewerVerified;
  final DateTime? createdAt;

  PropertyReview({
    required this.id,
    required this.propertyId,
    required this.reviewerId,
    required this.rating,
    this.comment,
    this.reviewerName,
    this.reviewerVerified = false,
    this.createdAt,
  });

  factory PropertyReview.fromMap(Map<String, dynamic> map) {
    final reviewer = map['reviewer'] as Map<String, dynamic>?;
    return PropertyReview(
      id: map['id'] as String,
      propertyId: map['property_id'] as String,
      reviewerId: map['reviewer_id'] as String,
      rating: (map['rating'] as num).toInt(),
      comment: map['comment'] as String?,
      reviewerName: reviewer?['full_name'] as String?,
      reviewerVerified: (reviewer?['is_seller_verified'] as bool?) ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'property_id': propertyId,
        'rating': rating,
        'comment': comment,
      };
}
