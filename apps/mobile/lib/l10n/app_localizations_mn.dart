// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Mongolian (`mn`).
class AppL10nMn extends AppL10n {
  AppL10nMn([String locale = 'mn']) : super(locale);

  @override
  String get appTitle => 'SIOP';

  @override
  String get navHome => 'Нүүр';

  @override
  String get navProgramme => 'Хөтөлбөр';

  @override
  String get navInfo => 'Мэдээлэл';

  @override
  String get navServices => 'Үйлчилгээ';

  @override
  String get navMap => 'Газрын зураг';

  @override
  String get navProfile => 'Профайл';

  @override
  String get tierGreen => 'Green Zone';

  @override
  String get tierBlue => 'Blue Zone';

  @override
  String get tierVip => 'VIP';

  @override
  String get otpPrompt => 'Та и-мэйл хаягаа оруулна уу';

  @override
  String get otpSend => 'Код илгээх';

  @override
  String get languageMn => 'Монгол';

  @override
  String get languageEn => 'English';
}
