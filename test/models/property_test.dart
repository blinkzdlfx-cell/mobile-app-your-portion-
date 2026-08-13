import 'package:flutter_test/flutter_test.dart';
import 'package:your_portion/models/property.dart';

void main() {
  group('Property', () {
    test('fromMap parses all fields', () {
      final property = Property.fromMap({
        'id': 'p1',
        'seller_id': 'u1',
        'title': '2-acre farmland',
        'description': 'Fertile soil',
        'category': 'Farm Land',
        'price': 25000,
        'currency': 'USD',
        'location': 'Kampala',
        'size_sqm': 8093.0,
        'bedrooms': 0,
        'bathrooms': 0,
        'images': ['https://example.com/a.jpg'],
        'contact_whatsapp': '+256700000000',
        'status': 'approved',
        'is_verified': true,
        'created_at': '2024-01-01T10:00:00Z',
      });

      expect(property.id, 'p1');
      expect(property.sellerId, 'u1');
      expect(property.title, '2-acre farmland');
      expect(property.category, 'Farm Land');
      expect(property.price, 25000);
      expect(property.location, 'Kampala');
      expect(property.sizeSqm, 8093.0);
      expect(property.images, ['https://example.com/a.jpg']);
      expect(property.status, 'approved');
      expect(property.isVerified, isTrue);
      expect(property.createdAt, DateTime.utc(2024, 1, 1, 10));
    });

    test('fromMap applies defaults for missing optional fields', () {
      final property = Property.fromMap({
        'id': 'p2',
        'seller_id': 'u1',
        'title': 'Plot',
        'category': 'Land',
        'price': 1000,
        'location': 'Entebbe',
      });

      expect(property.currency, 'USD');
      expect(property.images, isEmpty);
      expect(property.status, 'pending');
      expect(property.isVerified, isFalse);
      expect(property.createdAt, isNull);
    });

    test('toMap round-trips through fromMap', () {
      final property = Property(
        id: 'p3',
        sellerId: 'u2',
        title: '3-bedroom house',
        category: 'Houses',
        price: 45000,
        location: 'Mbarara',
        sizeSqm: 150.0,
        bedrooms: 3,
        bathrooms: 2,
        images: const ['https://example.com/b.jpg'],
      );

      final restored = Property.fromMap({...property.toMap(), 'id': 'p3'});

      expect(restored.title, property.title);
      expect(restored.price, property.price);
      expect(restored.sizeSqm, property.sizeSqm);
      expect(restored.bedrooms, 3);
      expect(restored.bathrooms, 2);
      expect(restored.images, property.images);
      expect(restored.currency, 'USD');
    });

    test('formattedPrice shortens thousands and keeps integers', () {
      expect(Property.fromMap(_base()..['price'] = 500).formattedPrice, r'$500');
      expect(Property.fromMap(_base()..['price'] = 1000).formattedPrice, r'$1k');
      expect(Property.fromMap(_base()..['price'] = 25000).formattedPrice, r'$25k');
      expect(Property.fromMap(_base()..['price'] = 12500).formattedPrice, r'$12.5k');
    });
  });
}

Map<String, dynamic> _base() => {
      'id': 'p',
      'seller_id': 'u',
      'title': 't',
      'category': 'Land',
      'price': 1000,
      'location': 'loc',
    };