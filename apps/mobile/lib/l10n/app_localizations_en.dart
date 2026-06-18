// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SIOP';

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
  String get languageMn => 'Монгол';

  @override
  String get languageEn => 'English';

  @override
  String get languageTitle => 'Language';

  @override
  String get defaultLabel => 'Default';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get send => 'Send';

  @override
  String get retry => 'Try again';

  @override
  String get retryShort => 'Retry';

  @override
  String get emailTitle => 'Enter email';

  @override
  String get emailPrompt => 'Enter your registered email address.';

  @override
  String get sendCode => 'Send code';

  @override
  String get otpTitle => 'Verification';

  @override
  String otpSentTo(String email) {
    return 'Code sent to $email';
  }

  @override
  String get verify => 'Verify';

  @override
  String welcomeGreeting(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get accessTierLabel => 'YOUR ACCESS TIER';

  @override
  String get accessTierNote =>
      'Set by admin · You\'ll be notified if it changes';

  @override
  String get getStarted => 'Let\'s get started →';

  @override
  String get permissionTitle => 'Permissions';

  @override
  String get permissionIntro =>
      'The app needs a few permissions to work better.';

  @override
  String get permLocation => 'Location';

  @override
  String get permLocationDesc => 'Emergency help + step counting';

  @override
  String get permNotification => 'Notifications';

  @override
  String get permNotificationDesc => 'Schedule, announcements, emergencies';

  @override
  String get continueBtn => 'Continue →';

  @override
  String get permSettingsNote => 'You can change this in Settings';

  @override
  String get grant => 'Allow';

  @override
  String get noSessions => 'No sessions added';

  @override
  String get noAgenda => 'You haven\'t registered for any sessions';

  @override
  String get sessionDetailTitle => 'Session details';

  @override
  String get notFound => 'Not found';

  @override
  String get waitlisted => 'Seats full — added to waitlist';

  @override
  String get youAttended => 'You attended';

  @override
  String get giveFeedback => 'Give feedback';

  @override
  String get goingRegister => 'Going — register ✓';

  @override
  String get infoTitle => 'Information';

  @override
  String get aiAssistant => 'AI assistant';

  @override
  String get sectionAnnouncements => '📢 Announcements';

  @override
  String get sectionFlights => '✈ Flight info';

  @override
  String get noAnnouncements => 'No announcements yet';

  @override
  String get noFlights => 'No flight info';

  @override
  String get noFaq => 'No FAQ';

  @override
  String get chatbotGreeting =>
      'Hello! I can help with the SIOP programme, venue, and FAQ.';

  @override
  String get askQuestion => 'Type a question…';

  @override
  String get sponsorSolar => 'Solar energy · Booth G-14';

  @override
  String get myMeetings => 'My meetings';

  @override
  String get searchCompany => 'Search company';

  @override
  String get noExhibitors => 'No exhibitors';

  @override
  String get requestSent => 'Request sent — admin will approve';

  @override
  String get meetingRequestTitle => 'Meeting request';

  @override
  String get chooseTime => 'Choose time';

  @override
  String get purpose => 'Purpose';

  @override
  String get sendRequest => 'Send request';

  @override
  String get noMeetings => 'No meetings';

  @override
  String get feedbackSent => 'Feedback sent · +10 CO₂ points';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get shareThoughts => 'Share your thoughts';

  @override
  String get extraComment => 'Additional comment (optional)';

  @override
  String get sentAnonymously => 'Sent anonymously';

  @override
  String get digitalIdTitle => 'Digital ID';

  @override
  String get digitalIdNote =>
      'Works offline · Refreshes every 15 min · HMAC signature';

  @override
  String get digitalIdQr => 'Digital ID QR';

  @override
  String get tabIndoor => 'Indoor';

  @override
  String get tabOutdoor => 'Outdoor';

  @override
  String get noPoi => 'No POI';

  @override
  String floorLabel(Object floor) {
    return 'Floor $floor';
  }

  @override
  String floorKind(Object floor, String kind) {
    return 'Floor $floor · $kind';
  }

  @override
  String get mapNavNote =>
      'Turn-by-turn: distance is pre-computed via QR checkpoints or BLE beacons (MAP-04).';

  @override
  String get balance => 'Balance';

  @override
  String get topUp => 'Top up';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get chooseSession => 'Choose session';

  @override
  String get pleaseChooseSession => 'Please choose a session';

  @override
  String get walletBalance => 'Wallet balance';

  @override
  String get shop => 'Shop';

  @override
  String get food => 'Food';

  @override
  String get transport => 'Transport';

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get signOut => 'Sign out';

  @override
  String get noProducts => 'No products';

  @override
  String cartTotal(String total) {
    return 'Cart — $total';
  }

  @override
  String get addToCart => '+ Cart';

  @override
  String paidOrder(String order) {
    return 'Paid: #$order';
  }

  @override
  String get checkoutTitle => 'Payment';

  @override
  String get total => 'Total';

  @override
  String walletEnough(String bal) {
    return '✓ Wallet: $bal — sufficient';
  }

  @override
  String walletShort(String bal) {
    return '⚠ Balance $bal — insufficient';
  }

  @override
  String get payWithWallet => 'Pay with wallet';

  @override
  String get topUpSuccess => 'Top-up successful';

  @override
  String get topUpAmount => 'Top-up amount';

  @override
  String get payWithQpay => 'Pay with QPay';

  @override
  String get scanQrUtility => 'Scan the QR code with your utility app';

  @override
  String amountLabel(String amount) {
    return 'Amount: $amount';
  }

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String get check => 'Check';

  @override
  String get locationSent => 'Location sent · Ops team notified';

  @override
  String get helpTitle => 'Help';

  @override
  String get emergencyHelp => '🚨 Emergency help';

  @override
  String get callMedical => '103 Medical';

  @override
  String get callPolice => '102 Police';

  @override
  String get sendMyLocation => 'Send my location';

  @override
  String get helpSiopInfo => 'SIOP info, FAQ, programme';

  @override
  String get contactOperator => '📞 Contact operator';

  @override
  String get operatorHours => 'Live answer · 08:00–22:00';

  @override
  String get emergencyProcedures => '📋 Emergency procedures';

  @override
  String get emergencyProceduresDesc => 'Fire, earthquake, health';

  @override
  String get tabLost => 'Lost';

  @override
  String get tabFound => 'Found';

  @override
  String get report => 'Report';

  @override
  String get empty => 'Empty';

  @override
  String get whatLostFound => 'What did you lose / find?';

  @override
  String get extraDescription => 'Additional description';

  @override
  String get liveBroadcast => '▶ LIVE BROADCAST';

  @override
  String get openingCeremonyVenue => 'Opening Ceremony · State Palace';

  @override
  String get mediaAssets => 'Logos, images, documents';

  @override
  String get interviewBooking => 'Interview booking';

  @override
  String get pressBadgeRequired => 'Press badge required';

  @override
  String get errNetwork => 'Network connection error.';

  @override
  String get errTooMany => 'Too many attempts. Try again in 1 hour.';

  @override
  String get errEmailNotRegistered =>
      'Email not registered. Please contact the organizer.';

  @override
  String get errOtpInvalid => 'Code is wrong or expired. Request a new code.';

  @override
  String get errAuthRequired => 'Sign in required. Please sign in again.';

  @override
  String get errTimeout => 'Request timed out. Please try again.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get tierExhibitor => 'Exhibitor';

  @override
  String get tierPress => 'Press';

  @override
  String get editName => 'Edit name';

  @override
  String get speakers => 'Speakers';

  @override
  String get noMediaAssets => 'No media files yet';

  @override
  String hallLabel(String hall) {
    return 'Hall: $hall';
  }

  @override
  String get topUpNow => 'Top up now';

  @override
  String get myAgendaTitle => 'My Agenda';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get mediaTitle => 'Media';

  @override
  String get scannerTitle => 'Check-in Scanner';

  @override
  String get b2bTitle => 'B2B Exhibitors';

  @override
  String get meetingBtn => 'Meeting';

  @override
  String get statusGoing => 'Going ✓';

  @override
  String get statusWaitlist => 'Waitlist';

  @override
  String get statusAttended => 'Attended';

  @override
  String get todayAgenda => 'Today\'s agenda';

  @override
  String get nextUp => 'Next up';

  @override
  String get sectionQuickAccess => 'Quick access';

  @override
  String get siopCongressLabel => '18th SIOP Asia Congress';

  @override
  String get siopLocationDate => 'Ulaanbaatar · Jun 25–28, 2026';

  @override
  String get deleteAccountTitle => 'Request account deletion';

  @override
  String get deleteAccountSubtitle =>
      'Send an email request to delete your account and data';

  @override
  String get deleteAccountDialogTitle => 'Delete account?';

  @override
  String get deleteAccountDialogBody =>
      'This will open your email app with a pre-filled deletion request. Our team will process it within 7 days.';

  @override
  String get deleteAccountConfirm => 'Send request';

  @override
  String get deleteAccountCancel => 'Cancel';
}
