import 'package:flutter_test/flutter_test.dart';
import 'package:your_portion/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('displayRole maps all roles', () {
      UserProfile profile(String role) => UserProfile(id: 'u', role: role);

      expect(profile('admin').displayRole, 'Admin');
      expect(profile('both').displayRole, 'Buyer & Seller');
      expect(profile('seller').displayRole, 'Seller');
      expect(profile('buyer').displayRole, 'Buyer');
    });

    test('canSell requires verified seller role', () {
      UserProfile verified(String role) => UserProfile(
            id: 'u',
            role: role,
            isSellerVerified: true,
          );

      expect(verified('seller').canSell, isTrue);
      expect(verified('both').canSell, isTrue);
      expect(verified('admin').canSell, isTrue);
      expect(verified('buyer').canSell, isFalse);
      expect(UserProfile(id: 'u', role: 'seller').canSell, isFalse);
    });

    test('firstName falls back to Friend', () {
      expect(UserProfile(id: 'u', fullName: 'John Doe').firstName, 'John');
      expect(UserProfile(id: 'u').firstName, 'Friend');
    });

    test('fromMap applies defaults', () {
      final profile = UserProfile.fromMap({'id': 'u'});

      expect(profile.role, 'buyer');
      expect(profile.isSellerVerified, isFalse);
      expect(profile.isTrustedMember, isFalse);
      expect(profile.fullName, isNull);
    });
  });
}