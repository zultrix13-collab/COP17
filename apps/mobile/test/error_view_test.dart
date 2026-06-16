import 'package:cop17/core/widgets/error_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorView.friendlyMessage', () {
    String msg(String raw) => ErrorView.friendlyMessage(Exception(raw));

    test('network errors → internet message', () {
      expect(msg('SocketException: Connection refused'),
          contains('Интернэт'));
      expect(msg('NetworkError: failed'), contains('Интернэт'));
      expect(msg('Failed host lookup: example.com'), contains('Интернэт'));
    });

    test('rate limit → retry-after message', () {
      expect(msg('rate limit exceeded'), contains('1 цаг'));
      expect(msg('Too many requests'), contains('1 цаг'));
      expect(msg('HTTP 429'), contains('1 цаг'));
    });

    test('invalid user / unconfirmed → organizer contact message', () {
      expect(msg('user not found'), contains('бүртгэлгүй'));
      expect(msg('email not confirmed'), contains('бүртгэлгүй'));
      expect(msg('invalid login credentials'), contains('бүртгэлгүй'));
    });

    test('OTP/token invalid → code-expired message', () {
      expect(msg('otp expired'), contains('Код буруу'));
      expect(msg('token is invalid'), contains('Код буруу'));
    });

    test('401 / unauthorized → re-login message', () {
      expect(msg('401 Unauthorized'), contains('дахин нэвтэр'));
      expect(msg('not authenticated'), contains('дахин нэвтэр'));
    });

    test('timeout → timeout message', () {
      expect(msg('TimeoutException'), contains('хугацаа'));
      expect(msg('receiveTimeout'), contains('хугацаа'));
    });

    test('unknown error → generic fallback', () {
      expect(msg('something completely unknown'), contains('Алдаа гарлаа'));
    });

    test('case-insensitive matching', () {
      expect(msg('SOCKETEXCEPTION: oops'), contains('Интернэт'));
      expect(msg('TIMEOUT occurred'), contains('хугацаа'));
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
