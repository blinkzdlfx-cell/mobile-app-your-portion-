import 'package:flutter_test/flutter_test.dart';
import 'package:your_portion/models/property_review.dart';

void main() {
  group('PropertyReview', () {
    test('fromMap parses fields with reviewer join', () {
      final review = PropertyReview.fromMap({
        'id': 'r1',
        'property_id': 'p1',
        'reviewer_id': 'u1',
        'rating': 5,
        'comment': 'Great land',
        'reviewer': {
          'full_name': 'John Doe',
          'is_seller_verified': true,
        },
        'created_at': '2024-01-01T10:00:00Z',
      });

      expect(review.id, 'r1');
      expect(review.propertyId, 'p1');
      expect(review.reviewerId, 'u1');
      expect(review.rating, 5);
      expect(review.comment, 'Great land');
      expect(review.reviewerName, 'John Doe');
      expect(review.reviewerVerified, isTrue);
      expect(review.createdAt, DateTime.utc(2024, 1, 1, 10));
    });

    test('fromMap tolerates missing reviewer join', () {
      final review = PropertyReview.fromMap({
        'id': 'r2',
        'property_id': 'p1',
        'reviewer_id': 'u1',
        'rating': 3,
      });

      expect(review.reviewerName, isNull);
      expect(review.reviewerVerified, isFalse);
      expect(review.comment, isNull);
      expect(review.createdAt, isNull);
    });

    test('toMap contains only insertable fields', () {
      final review = PropertyReview(
        id: 'r3',
        propertyId: 'p1',
        reviewerId: 'u1',
        rating: 4,
        comment: 'Good',
      );

      final map = review.toMap();
      expect(map['property_id'], 'p1');
      expect(map['rating'], 4);
      expect(map['comment'], 'Good');
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('reviewer_id'), isFalse);
    });
  });
}