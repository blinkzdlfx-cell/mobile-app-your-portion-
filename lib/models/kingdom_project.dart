class KingdomProject {
  final String id;
  final String creatorId;
  final String title;
  final String? description;
  final String? category;
  final double? goalAmount;
  final double raisedAmount;
  final String status;
  final String? contactWhatsapp;
  final String? contactPhone;
  final String? contactEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KingdomProject({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description,
    this.category,
    this.goalAmount,
    this.raisedAmount = 0,
    this.status = 'pending',
    this.contactWhatsapp,
    this.contactPhone,
    this.contactEmail,
    this.createdAt,
    this.updatedAt,
  });

  double get progressPercent =>
      goalAmount != null && goalAmount! > 0 ? (raisedAmount / goalAmount!).clamp(0, 1) : 0;

  factory KingdomProject.fromMap(Map<String, dynamic> map) {
    return KingdomProject(
      id: map['id'] as String,
      creatorId: map['creator_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String?,
      goalAmount: (map['goal_amount'] as num?)?.toDouble(),
      raisedAmount: ((map['raised_amount'] as num?) ?? 0).toDouble(),
      status: (map['status'] as String?) ?? 'pending',
      contactWhatsapp: map['contact_whatsapp'] as String?,
      contactPhone: map['contact_phone'] as String?,
      contactEmail: map['contact_email'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'creator_id': creatorId,
    'title': title,
    'description': description,
    'category': category,
    'goal_amount': goalAmount,
    'raised_amount': raisedAmount,
    'status': status,
    'contact_whatsapp': contactWhatsapp,
    'contact_phone': contactPhone,
    'contact_email': contactEmail,
  };
}
