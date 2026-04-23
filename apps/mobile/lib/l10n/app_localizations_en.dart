// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'COP17';

  @override
  String get navHome => 'Home';

  @override
  String get navProgramme => 'Programme';

  @override
  String get navInfo => 'Info';

  @override
  String get navServices => 'Services';

  @override
  String get navMap => 'Map';

  @override
  String get navProfile => 'Profile';

  @override
  String get tierGreen => 'Green Zone';

  @override
  String get tierBlue => 'Blue Zone';

  @override
  String get tierVip => 'VIP';

  @override
  String get otpPrompt => 'Please enter your email';

  @override
  String get otpSend => 'Send code';

  @override
  String get languageMn => 'Монгол';

  @override
  String get languageEn => 'English';
}
