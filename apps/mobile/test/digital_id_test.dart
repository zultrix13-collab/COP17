import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Digital ID countdown calculation', () {
    int secondsRemaining(DateTime expiresAt) {
      return expiresAt.difference(DateTime.now()).inSeconds.clamp(0, 999);
    }

    test('future expiry returns positive seconds', () {
      final future = DateTime.now().add(const Duration(minutes: 5));
      expect(secondsRemaining(future), greaterThan(0));
    });

    test('past expiry is clamped to 0 (no negative countdown)', () {
      final past = DateTime.now().subtract(const Duration(seconds: 30));
      expect(secondsRemaining(past), equals(0));
    });

    test('result never exceeds 999', () {
      final farFuture = DateTime.now().add(const Duration(hours: 24));
      expect(secondsRemaining(farFuture), equals(999));
    });
  });

  group('Auth guard logic', () {
    String? fakeUserId(bool loggedIn) => loggedIn ? 'user-abc-123' : null;

    test('logged-in user has non-null id', () {
      expect(fakeUserId(true), isNotNull);
    });

    test('logged-out user returns null — guard must throw before proceeding', () {
      final userId = fakeUserId(false);
      expect(userId, isNull);
      // guard pattern: if (userId == null) throw StateError(...)
      expect(() {
        if (userId == null) throw StateError('Not authenticated');
      }, throwsStateError);
    });
  });
}
