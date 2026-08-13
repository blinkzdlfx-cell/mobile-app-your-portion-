import 'package:flutter_test/flutter_test.dart';
import 'package:your_portion/models/daily_portion.dart';

void main() {
  group('DailyPortion', () {
    test('fromMap parses fields', () {
      final portion = DailyPortion.fromMap({
        'id': 'd1',
        'title': 'The Good Seed',
        'content': 'Paragraph one.',
        'scripture_reference': 'Matthew 13:8',
        'category': 'Parable',
        'is_published': true,
        'publish_date': '2024-01-01T00:00:00Z',
      });

      expect(portion.title, 'The Good Seed');
      expect(portion.scriptureReference, 'Matthew 13:8');
      expect(portion.category, 'Parable');
      expect(portion.isPublished, isTrue);
      expect(portion.publishDate, DateTime.utc(2024, 1, 1));
    });

    test('paragraphs splits on blank lines and drops empties', () {
      final portion = DailyPortion(
        id: 'd2',
        title: 't',
        content: 'First paragraph.\n\nSecond paragraph.\n\n\nThird.',
      );

      expect(portion.paragraphs, hasLength(3));
      expect(portion.paragraphs.first, 'First paragraph.');
      expect(portion.paragraphs.last, 'Third.');
    });

    test('paragraphs handles single paragraph', () {
      final portion = DailyPortion(id: 'd3', title: 't', content: 'Only one.');

      expect(portion.paragraphs, ['Only one.']);
    });
  });
}