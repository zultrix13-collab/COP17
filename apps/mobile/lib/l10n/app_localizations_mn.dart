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
  String get languageMn => 'Монгол';

  @override
  String get languageEn => 'English';

  @override
  String get languageTitle => 'Хэл';

  @override
  String get defaultLabel => 'Анхдагч';

  @override
  String get save => 'Хадгалах';

  @override
  String get cancel => 'Цуцлах';

  @override
  String get send => 'Илгээх';

  @override
  String get retry => 'Дахин оролдох';

  @override
  String get retryShort => 'Дахин';

  @override
  String get emailTitle => 'И-мэйл оруулах';

  @override
  String get emailPrompt => 'Бүртгэлтэй и-мэйл хаягаа оруулна уу.';

  @override
  String get sendCode => 'Код илгээх';

  @override
  String get otpTitle => 'Баталгаажуулалт';

  @override
  String otpSentTo(String email) {
    return '$email руу код илгээлээ';
  }

  @override
  String get verify => 'Баталгаажуулах';

  @override
  String welcomeGreeting(String name) {
    return 'Тавтай морил, $name!';
  }

  @override
  String get accessTierLabel => 'ТАНЫ ХАНДАЛТЫН ЭРХ';

  @override
  String get accessTierNote => 'Admin тохируулсан · Дүр өөрчлөгдвөл мэдэгдэнэ';

  @override
  String get getStarted => 'Эхэлцгээе →';

  @override
  String get permissionTitle => 'Зөвшөөрөл';

  @override
  String get permissionIntro => 'Апп илүү сайн ажиллахад зөвшөөрлүүд хэрэгтэй.';

  @override
  String get permLocation => 'Байршил';

  @override
  String get permLocationDesc => 'Яаралтай тусламж + алхалт тоолох';

  @override
  String get permNotification => 'Мэдэгдэл';

  @override
  String get permNotificationDesc => 'Хуваарь, зарлал, яаралтай';

  @override
  String get continueBtn => 'Үргэлжлүүлэх →';

  @override
  String get permSettingsNote => 'Settings-ээс өөрчлөх боломжтой';

  @override
  String get grant => 'Зөвшөөрөх';

  @override
  String get noSessions => 'Session нэмээгүй байна';

  @override
  String get noAgenda => 'Та ямар ч session-д бүртгүүлээгүй байна';

  @override
  String get sessionDetailTitle => 'Session дэлгэрэнгүй';

  @override
  String get notFound => 'Олдсонгүй';

  @override
  String get waitlisted => 'Суудал дүүрсэн — хүлээлтэд нэмэгдлээ';

  @override
  String get youAttended => 'Та ирсэн';

  @override
  String get giveFeedback => 'Үнэлгээ өгөх';

  @override
  String get goingRegister => 'Going — бүртгүүлэх ✓';

  @override
  String get infoTitle => 'Мэдээлэл';

  @override
  String get aiAssistant => 'AI туслах';

  @override
  String get sectionAnnouncements => '📢 Мэдэгдлүүд';

  @override
  String get sectionFlights => '✈ Нислэгийн мэдээлэл';

  @override
  String get noAnnouncements => 'Одоогоор мэдэгдэл алга';

  @override
  String get noFlights => 'Нислэгийн мэдээлэл алга';

  @override
  String get noFaq => 'FAQ алга';

  @override
  String get chatbotGreeting =>
      'Сайн байна уу! SIOP хөтөлбөр, байршил, FAQ асуултууд дээр туслая.';

  @override
  String get askQuestion => 'Асуулт бичих…';

  @override
  String get sponsorSolar => 'Нарны эрчим хүч · Booth G-14';

  @override
  String get myMeetings => 'Миний Meetings';

  @override
  String get searchCompany => 'Компани хайх';

  @override
  String get noExhibitors => 'Exhibitor алга';

  @override
  String get requestSent => 'Хүсэлт илгээгдлээ — admin батална';

  @override
  String get meetingRequestTitle => 'Meeting хүсэлт';

  @override
  String get chooseTime => 'Цаг сонгох';

  @override
  String get purpose => 'Зорилго';

  @override
  String get sendRequest => 'Хүсэлт илгээх';

  @override
  String get noMeetings => 'Meeting алга';

  @override
  String get feedbackSent => 'Үнэлгээ илгээгдлээ · +10 CO₂ оноо';

  @override
  String get feedbackTitle => 'Үнэлгээ';

  @override
  String get shareThoughts => 'Санал бодлоо хуваалцана уу';

  @override
  String get extraComment => 'Нэмэлт сэтгэгдэл (заавал биш)';

  @override
  String get sentAnonymously => 'Нэрсгүй илгээгдэнэ';

  @override
  String get digitalIdTitle => 'Дижитал үнэмлэх';

  @override
  String get digitalIdNote =>
      'Offline горимд ажиллана · 15 мин бүр refresh · HMAC signature';

  @override
  String get digitalIdQr => 'Дижитал үнэмлэх QR';

  @override
  String get tabIndoor => 'Дотоод';

  @override
  String get tabOutdoor => 'Гадаад';

  @override
  String get noPoi => 'POI алга';

  @override
  String floorLabel(Object floor) {
    return '$floor давхар';
  }

  @override
  String floorKind(Object floor, String kind) {
    return '$floor давхар · $kind';
  }

  @override
  String get mapNavNote =>
      'Turn-by-turn: QR checkpoint эсвэл BLE beacon-оор холын зайг урьдчилан тооцно (MAP-04).';

  @override
  String get balance => 'Үлдэгдэл';

  @override
  String get topUp => 'Цэнэглэх';

  @override
  String get recentTransactions => 'Сүүлийн гүйлгээ';

  @override
  String get noTransactions => 'Гүйлгээ алга';

  @override
  String get chooseSession => 'Session сонгох';

  @override
  String get pleaseChooseSession => 'Session сонгоно уу';

  @override
  String get walletBalance => 'Wallet үлдэгдэл';

  @override
  String get shop => 'Дэлгүүр';

  @override
  String get food => 'Хоол';

  @override
  String get transport => 'Тээвэр';

  @override
  String get profileNotFound => 'Профайл олдсонгүй';

  @override
  String get signOut => 'Гарах';

  @override
  String get noProducts => 'Бүтээгдэхүүн алга';

  @override
  String cartTotal(String total) {
    return 'Сагс — $total';
  }

  @override
  String get addToCart => '+ Сагс';

  @override
  String paidOrder(String order) {
    return 'Төлөгдсөн: #$order';
  }

  @override
  String get checkoutTitle => 'Төлбөр';

  @override
  String get total => 'Нийт';

  @override
  String walletEnough(String bal) {
    return '✓ Wallet: $bal — хангалттай';
  }

  @override
  String walletShort(String bal) {
    return '⚠ Үлдэгдэл $bal — дутуу байна';
  }

  @override
  String get payWithWallet => 'Wallet-ээр төлөх';

  @override
  String get topUpSuccess => 'Цэнэглэлт амжилттай';

  @override
  String get topUpAmount => 'Цэнэглэх дүн';

  @override
  String get payWithQpay => 'QPay-аар төлөх';

  @override
  String get scanQrUtility => 'Utility апп-аараа QR кодыг уншуулна уу';

  @override
  String amountLabel(String amount) {
    return 'Дүн: $amount';
  }

  @override
  String statusLabel(String status) {
    return 'Статус: $status';
  }

  @override
  String get check => 'Шалгах';

  @override
  String get locationSent => 'Байршил илгээгдлээ · Ops team мэдэгдэнэ';

  @override
  String get helpTitle => 'Тусламж';

  @override
  String get emergencyHelp => '🚨 Яаралтай тусламж';

  @override
  String get callMedical => '103 Эмнэлэг';

  @override
  String get callPolice => '102 Цагдаа';

  @override
  String get sendMyLocation => 'Миний байршил явуулах';

  @override
  String get helpSiopInfo => 'SIOP мэдээлэл, FAQ, хөтөлбөр';

  @override
  String get contactOperator => '📞 Оператортой холбогдох';

  @override
  String get operatorHours => 'Хүн хариулах · 08:00–22:00';

  @override
  String get emergencyProcedures => '📋 Яаралтай журам';

  @override
  String get emergencyProceduresDesc => 'Гал, газар хөдлөлт, эрүүл мэнд';

  @override
  String get tabLost => 'Гээсэн';

  @override
  String get tabFound => 'Олдсон';

  @override
  String get report => 'Мэдэгдэл';

  @override
  String get empty => 'Хоосон';

  @override
  String get whatLostFound => 'Юу гээсэн/олдсон?';

  @override
  String get extraDescription => 'Нэмэлт тайлбар';

  @override
  String get liveBroadcast => '▶ ШУУД ДАМЖУУЛАЛТ';

  @override
  String get openingCeremonyVenue => 'Opening Ceremony · Төрийн ордон';

  @override
  String get mediaAssets => 'Логонууд, зураг, баримт бичиг';

  @override
  String get interviewBooking => 'Ярилцлага захиалга';

  @override
  String get pressBadgeRequired => 'Press badge шаардлагатай';

  @override
  String get errNetwork => 'Интернэт холболт алдаатай байна.';

  @override
  String get errTooMany =>
      'Хэт олон удаа оролдлоо. 1 цагийн дараа дахин оролдоно уу.';

  @override
  String get errEmailNotRegistered =>
      'И-мэйл хаяг бүртгэлгүй байна. Зохион байгуулагчтай холбогдоно уу.';

  @override
  String get errOtpInvalid =>
      'Код буруу эсвэл хугацаа дууссан байна. Дахин код авна уу.';

  @override
  String get errAuthRequired => 'Нэвтрэх шаардлагатай. Та дахин нэвтэрнэ үү.';

  @override
  String get errTimeout => 'Хүсэлт хугацаа дуусав. Дахин оролдоно уу.';

  @override
  String get errGeneric => 'Алдаа гарлаа. Дахин оролдоно уу.';

  @override
  String get comingSoon => 'Удахгүй нэмэгдэнэ';

  @override
  String get tierExhibitor => 'Exhibitor';

  @override
  String get tierPress => 'Хэвлэл мэдээлэл';

  @override
  String get editName => 'Нэр засах';

  @override
  String get speakers => 'Илтгэгчид';

  @override
  String get noMediaAssets => 'Медиа файл алга';

  @override
  String hallLabel(String hall) {
    return '$hall танхим';
  }

  @override
  String get topUpNow => 'Одоо цэнэглэх';

  @override
  String get myAgendaTitle => 'Миний хуваарь';

  @override
  String get walletTitle => 'Цахим хэтэвч';

  @override
  String get mediaTitle => 'Медиа';

  @override
  String get scannerTitle => 'Check-in Scanner';

  @override
  String get b2bTitle => 'B2B Exhibitorууд';

  @override
  String get meetingBtn => 'Meeting';

  @override
  String get statusGoing => 'Бүртгүүлсэн ✓';

  @override
  String get statusWaitlist => 'Хүлээлтэд';

  @override
  String get statusAttended => 'Ирсэн';

  @override
  String get todayAgenda => 'Өнөөдрийн хуваарь';

  @override
  String get nextUp => 'Дараагийн';

  @override
  String get sectionQuickAccess => 'Хурдан хандалт';

  @override
  String get siopCongressLabel => '18-р SIOP Asia Congress';

  @override
  String get siopLocationDate => 'Улаанбаатар · 2026.06.25–28';

  @override
  String get deleteAccountTitle => 'Данс устгах хүсэлт';

  @override
  String get deleteAccountSubtitle =>
      'Данс болон өгөгдлөө устгуулах имэйл хүсэлт илгээх';

  @override
  String get deleteAccountDialogTitle => 'Данс устгах уу?';

  @override
  String get deleteAccountDialogBody =>
      'Имэйл апп нээгдэж данс устгах хүсэлтийн загвар бэлэн болно. Манай баг 7 хоногийн дотор хүсэлтийг биелүүлнэ.';

  @override
  String get deleteAccountConfirm => 'Хүсэлт илгээх';

  @override
  String get deleteAccountCancel => 'Болих';
}
