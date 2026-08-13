class DailyPortion {
  final String id;
  final String title;
  final String content;
  final String? scriptureReference;
  final String? category;
  final bool isPublished;
  final DateTime? publishDate;
  final DateTime? createdAt;

  DailyPortion({
    required this.id,
    required this.title,
    required this.content,
    this.scriptureReference,
    this.category,
    this.isPublished = false,
    this.publishDate,
    this.createdAt,
  });

  factory DailyPortion.fromMap(Map<String, dynamic> map) {
    return DailyPortion(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      scriptureReference: map['scripture_reference'] as String?,
      category: map['category'] as String?,
      isPublished: (map['is_published'] as bool?) ?? false,
      publishDate: map['publish_date'] != null
          ? DateTime.tryParse(map['publish_date'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'scripture_reference': scriptureReference,
        'category': category,
        'is_published': isPublished,
        'publish_date': publishDate?.toIso8601String(),
      };

  /// Splits the plain-text content into paragraphs for rendering.
  List<String> get paragraphs =>
      content.split(RegExp(r'\n\s*\n')).map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
}
