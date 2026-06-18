import 'package:flutter_test/flutter_test.dart';

import 'package:cop17/core/env.dart';

void main() {
  group('Reviewer bypass constants', () {
    // reviewEmail / reviewCode are injected via --dart-define from
    // dart_defines.json (gitignored). They are empty when tests run without
    // those defines (e.g. CI). When present, they must satisfy the contract
    // below; the production build always passes them via --dart-define-from-file.
    test('reviewEmail, when configured, looks like an email address', () {
      if (reviewEmail.isEmpty) {
        markTestSkipped('REVIEW_EMAIL not provided via --dart-define');
        return;
      }
      expect(reviewEmail, contains('@'));
    });

    test('reviewCode, when configured, is exactly 6 numeric digits', () {
      if (reviewCode.isEmpty) {
        markTestSkipped('REVIEW_CODE not provided via --dart-define');
        return;
      }
      expect(reviewCode.length, 6,
          reason: 'OTP input has maxLength=6 so code must be exactly 6 chars');
      expect(int.tryParse(reviewCode), isNotNull,
          reason: 'reviewCode must be numeric');
      expect(reviewCode, isNot('000000'));
      expect(reviewCode, isNot('123456'));
    });

    test('reviewSession starts as false', () {
      expect(reviewSession, isFalse,
          reason: 'Must be false at startup — only true after reviewer login');
    });
  });
}
