import 'package:flutter_test/flutter_test.dart';

import 'package:cop17/core/env.dart';

void main() {
  group('Reviewer bypass constants', () {
    test('reviewEmail is the expected delegate address', () {
      expect(reviewEmail, 'delegate@siop.mn');
    });

    test('reviewCode is exactly 6 digits', () {
      expect(reviewCode.length, 6,
          reason: 'OTP input has maxLength=6 so code must be exactly 6 chars');
      expect(int.tryParse(reviewCode), isNotNull,
          reason: 'reviewCode must be numeric');
    });

    test('reviewCode does not match a real Supabase OTP (all-zeros etc.)', () {
      expect(reviewCode, isNot('000000'));
      expect(reviewCode, isNot('123456'));
    });

    test('reviewSession starts as false', () {
      expect(reviewSession, isFalse,
          reason: 'Must be false at startup — only true after reviewer login');
    });
  });
}
