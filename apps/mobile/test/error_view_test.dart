import 'package:cop17/core/widgets/error_view.dart';
import 'package:cop17/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // friendlyMessage now returns localized strings, so we load the Mongolian
  // AppL10n and assert the mapping against the l10n getters (robust to ARB
  // wording changes).
  late AppL10n l10n;
  setUpAll(() async {
    l10n = await AppL10n.delegate.load(const Locale('mn'));
  });

  group('ErrorView.friendlyMessage', () {
    String msg(String raw) => ErrorView.friendlyMessage(l10n, Exception(raw));

    test('network errors → internet message', () {
      expect(msg('SocketException: Connection refused'), l10n.errNetwork);
      expect(msg('NetworkError: failed'), l10n.errNetwork);
      expect(msg('Failed host lookup: example.com'), l10n.errNetwork);
    });

    test('rate limit → retry-after message', () {
      expect(msg('rate limit exceeded'), l10n.errTooMany);
      expect(msg('Too many requests'), l10n.errTooMany);
      expect(msg('HTTP 429'), l10n.errTooMany);
    });

    test('invalid user / unconfirmed → organizer contact message', () {
      expect(msg('user not found'), l10n.errEmailNotRegistered);
      expect(msg('email not confirmed'), l10n.errEmailNotRegistered);
      expect(msg('invalid login credentials'), l10n.errEmailNotRegistered);
    });

    test('OTP/token invalid → code-expired message', () {
      expect(msg('otp expired'), l10n.errOtpInvalid);
      expect(msg('token is invalid'), l10n.errOtpInvalid);
    });

    test('401 / unauthorized → re-login message', () {
      expect(msg('401 Unauthorized'), l10n.errAuthRequired);
      expect(msg('not authenticated'), l10n.errAuthRequired);
    });

    test('timeout → timeout message', () {
      expect(msg('TimeoutException'), l10n.errTimeout);
      expect(msg('receiveTimeout'), l10n.errTimeout);
    });

    test('unknown error → generic fallback', () {
      expect(msg('something completely unknown'), l10n.errGeneric);
    });

    test('case-insensitive matching', () {
      expect(msg('SOCKETEXCEPTION: oops'), l10n.errNetwork);
      expect(msg('TIMEOUT occurred'), l10n.errTimeout);
    });
  });

  group('OTP input validation logic', () {
    bool isValidOtp(String code) => code.trim().length == 6;

    test('6-digit code is valid', () {
      expect(isValidOtp('123456'), isTrue);
      expect(isValidOtp('000000'), isTrue);
    });

    test('codes shorter than 6 are rejected', () {
      expect(isValidOtp(''), isFalse);
      expect(isValidOtp('12345'), isFalse);
    });

    test('codes longer than 6 are rejected', () {
      expect(isValidOtp('1234567'), isFalse);
      expect(isValidOtp('99265541'), isFalse); // the 8-digit code bug
    });
  });
}
