import 'package:flutter_test/flutter_test.dart';
import 'package:your_portion/models/kingdom_project.dart';

void main() {
  group('KingdomProject', () {
    test('progressPercent clamps between 0 and 1', () {
      KingdomProject project(double raised) => KingdomProject(
            id: 'k',
            creatorId: 'u',
            title: 'Church Building',
            goalAmount: 10000,
            raisedAmount: raised,
          );

      expect(project(0).progressPercent, 0);
      expect(project(5000).progressPercent, 0.5);
      expect(project(15000).progressPercent, 1.0);
    });

    test('progressPercent is zero when no goal is set', () {
      final project = KingdomProject(
        id: 'k',
        creatorId: 'u',
        title: 'Outreach',
        raisedAmount: 500,
      );

      expect(project.progressPercent, 0);
    });

    test('fromMap parses fields', () {
      final project = KingdomProject.fromMap({
        'id': 'k1',
        'creator_id': 'u1',
        'title': 'Water Well',
        'description': 'Clean water for the village',
        'category': 'Community',
        'goal_amount': 5000,
        'raised_amount': 1250,
        'status': 'approved',
        'created_at': '2024-01-01T10:00:00Z',
      });

      expect(project.title, 'Water Well');
      expect(project.goalAmount, 5000);
      expect(project.raisedAmount, 1250);
      expect(project.status, 'approved');
      expect(project.progressPercent, 0.25);
    });
  });
}