import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n? of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n);
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('mn')
  ];

  /// No description provided for @appTitle.
  ///
  /// In mn, this message translates to:
  /// **'SIOP'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In mn, this message translates to:
  /// **'Нүүр'**
  String get navHome;

  /// No description provided for @navProgramme.
  ///
  /// In mn, this message translates to:
  /// **'Хөтөлбөр'**
  String get navProgramme;

  /// No description provided for @navInfo.
  ///
  /// In mn, this message translates to:
  /// **'Мэдээлэл'**
  String get navInfo;

  /// No description provided for @navServices.
  ///
  /// In mn, this message translates to:
  /// **'Үйлчилгээ'**
  String get navServices;

  /// No description provided for @navMap.
  ///
  /// In mn, this message translates to:
  /// **'Газрын зураг'**
  String get navMap;

  /// No description provided for @navProfile.
  ///
  /// In mn, this message translates to:
  /// **'Профайл'**
  String get navProfile;

  /// No description provided for @tierGreen.
  ///
  /// In mn, this message translates to:
  /// **'Green Zone'**
  String get tierGreen;

  /// No description provided for @tierBlue.
  ///
  /// In mn, this message translates to:
  /// **'Blue Zone'**
  String get tierBlue;

  /// No description provided for @tierVip.
  ///
  /// In mn, this message translates to:
  /// **'VIP'**
  String get tierVip;

  /// No description provided for @languageMn.
  ///
  /// In mn, this message translates to:
  /// **'Монгол'**
  String get languageMn;

  /// No description provided for @languageEn.
  ///
  /// In mn, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageTitle.
  ///
  /// In mn, this message translates to:
  /// **'Хэл'**
  String get languageTitle;

  /// No description provided for @defaultLabel.
  ///
  /// In mn, this message translates to:
  /// **'Анхдагч'**
  String get defaultLabel;

  /// No description provided for @save.
  ///
  /// In mn, this message translates to:
  /// **'Хадгалах'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In mn, this message translates to:
  /// **'Цуцлах'**
  String get cancel;

  /// No description provided for @send.
  ///
  /// In mn, this message translates to:
  /// **'Илгээх'**
  String get send;

  /// No description provided for @retry.
  ///
  /// In mn, this message translates to:
  /// **'Дахин оролдох'**
  String get retry;

  /// No description provided for @retryShort.
  ///
  /// In mn, this message translates to:
  /// **'Дахин'**
  String get retryShort;

  /// No description provided for @emailTitle.
  ///
  /// In mn, this message translates to:
  /// **'И-мэйл оруулах'**
  String get emailTitle;

  /// No description provided for @emailPrompt.
  ///
  /// In mn, this message translates to:
  /// **'Бүртгэлтэй и-мэйл хаягаа оруулна уу.'**
  String get emailPrompt;

  /// No description provided for @sendCode.
  ///
  /// In mn, this message translates to:
  /// **'Код илгээх'**
  String get sendCode;

  /// No description provided for @otpTitle.
  ///
  /// In mn, this message translates to:
  /// **'Баталгаажуулалт'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In mn, this message translates to:
  /// **'{email} руу код илгээлээ'**
  String otpSentTo(String email);

  /// No description provided for @verify.
  ///
  /// In mn, this message translates to:
  /// **'Баталгаажуулах'**
  String get verify;

  /// No description provided for @welcomeGreeting.
  ///
  /// In mn, this message translates to:
  /// **'Тавтай морил, {name}!'**
  String welcomeGreeting(String name);

  /// No description provided for @accessTierLabel.
  ///
  /// In mn, this message translates to:
  /// **'ТАНЫ ХАНДАЛТЫН ЭРХ'**
  String get accessTierLabel;

  /// No description provided for @accessTierNote.
  ///
  /// In mn, this message translates to:
  /// **'Admin тохируулсан · Дүр өөрчлөгдвөл мэдэгдэнэ'**
  String get accessTierNote;

  /// No description provided for @getStarted.
  ///
  /// In mn, this message translates to:
  /// **'Эхэлцгээе →'**
  String get getStarted;

  /// No description provided for @permissionTitle.
  ///
  /// In mn, this message translates to:
  /// **'Зөвшөөрөл'**
  String get permissionTitle;

  /// No description provided for @permissionIntro.
  ///
  /// In mn, this message translates to:
  /// **'Апп илүү сайн ажиллахад зөвшөөрлүүд хэрэгтэй.'**
  String get permissionIntro;

  /// No description provided for @permLocation.
  ///
  /// In mn, this message translates to:
  /// **'Байршил'**
  String get permLocation;

  /// No description provided for @permLocationDesc.
  ///
  /// In mn, this message translates to:
  /// **'Яаралтай тусламж + алхалт тоолох'**
  String get permLocationDesc;

  /// No description provided for @permNotification.
  ///
  /// In mn, this message translates to:
  /// **'Мэдэгдэл'**
  String get permNotification;

  /// No description provided for @permNotificationDesc.
  ///
  /// In mn, this message translates to:
  /// **'Хуваарь, зарлал, яаралтай'**
  String get permNotificationDesc;

  /// No description provided for @continueBtn.
  ///
  /// In mn, this message translates to:
  /// **'Үргэлжлүүлэх →'**
  String get continueBtn;

  /// No description provided for @permSettingsNote.
  ///
  /// In mn, this message translates to:
  /// **'Settings-ээс өөрчлөх боломжтой'**
  String get permSettingsNote;

  /// No description provided for @grant.
  ///
  /// In mn, this message translates to:
  /// **'Зөвшөөрөх'**
  String get grant;

  /// No description provided for @noSessions.
  ///
  /// In mn, this message translates to:
  /// **'Session нэмээгүй байна'**
  String get noSessions;

  /// No description provided for @noAgenda.
  ///
  /// In mn, this message translates to:
  /// **'Та ямар ч session-д бүртгүүлээгүй байна'**
  String get noAgenda;

  /// No description provided for @sessionDetailTitle.
  ///
  /// In mn, this message translates to:
  /// **'Session дэлгэрэнгүй'**
  String get sessionDetailTitle;

  /// No description provided for @notFound.
  ///
  /// In mn, this message translates to:
  /// **'Олдсонгүй'**
  String get notFound;

  /// No description provided for @waitlisted.
  ///
  /// In mn, this message translates to:
  /// **'Суудал дүүрсэн — хүлээлтэд нэмэгдлээ'**
  String get waitlisted;

  /// No description provided for @youAttended.
  ///
  /// In mn, this message translates to:
  /// **'Та ирсэн'**
  String get youAttended;

  /// No description provided for @giveFeedback.
  ///
  /// In mn, this message translates to:
  /// **'Үнэлгээ өгөх'**
  String get giveFeedback;

  /// No description provided for @goingRegister.
  ///
  /// In mn, this message translates to:
  /// **'Going — бүртгүүлэх ✓'**
  String get goingRegister;

  /// No description provided for @infoTitle.
  ///
  /// In mn, this message translates to:
  /// **'Мэдээлэл'**
  String get infoTitle;

  /// No description provided for @aiAssistant.
  ///
  /// In mn, this message translates to:
  /// **'AI туслах'**
  String get aiAssistant;

  /// No description provided for @sectionAnnouncements.
  ///
  /// In mn, this message translates to:
  /// **'📢 Мэдэгдлүүд'**
  String get sectionAnnouncements;

  /// No description provided for @sectionFlights.
  ///
  /// In mn, this message translates to:
  /// **'✈ Нислэгийн мэдээлэл'**
  String get sectionFlights;

  /// No description provided for @noAnnouncements.
  ///
  /// In mn, this message translates to:
  /// **'Одоогоор мэдэгдэл алга'**
  String get noAnnouncements;

  /// No description provided for @noFlights.
  ///
  /// In mn, this message translates to:
  /// **'Нислэгийн мэдээлэл алга'**
  String get noFlights;

  /// No description provided for @noFaq.
  ///
  /// In mn, this message translates to:
  /// **'FAQ алга'**
  String get noFaq;

  /// No description provided for @chatbotGreeting.
  ///
  /// In mn, this message translates to:
  /// **'Сайн байна уу! SIOP хөтөлбөр, байршил, FAQ асуултууд дээр туслая.'**
  String get chatbotGreeting;

  /// No description provided for @askQuestion.
  ///
  /// In mn, this message translates to:
  /// **'Асуулт бичих…'**
  String get askQuestion;

  /// No description provided for @sponsorSolar.
  ///
  /// In mn, this message translates to:
  /// **'Нарны эрчим хүч · Booth G-14'**
  String get sponsorSolar;

  /// No description provided for @myMeetings.
  ///
  /// In mn, this message translates to:
  /// **'Миний Meetings'**
  String get myMeetings;

  /// No description provided for @searchCompany.
  ///
  /// In mn, this message translates to:
  /// **'Компани хайх'**
  String get searchCompany;

  /// No description provided for @noExhibitors.
  ///
  /// In mn, this message translates to:
  /// **'Exhibitor алга'**
  String get noExhibitors;

  /// No description provided for @requestSent.
  ///
  /// In mn, this message translates to:
  /// **'Хүсэлт илгээгдлээ — admin батална'**
  String get requestSent;

  /// No description provided for @meetingRequestTitle.
  ///
  /// In mn, this message translates to:
  /// **'Meeting хүсэлт'**
  String get meetingRequestTitle;

  /// No description provided for @chooseTime.
  ///
  /// In mn, this message translates to:
  /// **'Цаг сонгох'**
  String get chooseTime;

  /// No description provided for @purpose.
  ///
  /// In mn, this message translates to:
  /// **'Зорилго'**
  String get purpose;

  /// No description provided for @sendRequest.
  ///
  /// In mn, this message translates to:
  /// **'Хүсэлт илгээх'**
  String get sendRequest;

  /// No description provided for @noMeetings.
  ///
  /// In mn, this message translates to:
  /// **'Meeting алга'**
  String get noMeetings;

  /// No description provided for @feedbackSent.
  ///
  /// In mn, this message translates to:
  /// **'Үнэлгээ илгээгдлээ · +10 CO₂ оноо'**
  String get feedbackSent;

  /// No description provided for @feedbackTitle.
  ///
  /// In mn, this message translates to:
  /// **'Үнэлгээ'**
  String get feedbackTitle;

  /// No description provided for @shareThoughts.
  ///
  /// In mn, this message translates to:
  /// **'Санал бодлоо хуваалцана уу'**
  String get shareThoughts;

  /// No description provided for @extraComment.
  ///
  /// In mn, this message translates to:
  /// **'Нэмэлт сэтгэгдэл (заавал биш)'**
  String get extraComment;

  /// No description provided for @sentAnonymously.
  ///
  /// In mn, this message translates to:
  /// **'Нэрсгүй илгээгдэнэ'**
  String get sentAnonymously;

  /// No description provided for @digitalIdTitle.
  ///
  /// In mn, this message translates to:
  /// **'Дижитал үнэмлэх'**
  String get digitalIdTitle;

  /// No description provided for @digitalIdNote.
  ///
  /// In mn, this message translates to:
  /// **'Offline горимд ажиллана · 15 мин бүр refresh · HMAC signature'**
  String get digitalIdNote;

  /// No description provided for @digitalIdQr.
  ///
  /// In mn, this message translates to:
  /// **'Дижитал үнэмлэх QR'**
  String get digitalIdQr;

  /// No description provided for @tabIndoor.
  ///
  /// In mn, this message translates to:
  /// **'Дотоод'**
  String get tabIndoor;

  /// No description provided for @tabOutdoor.
  ///
  /// In mn, this message translates to:
  /// **'Гадаад'**
  String get tabOutdoor;

  /// No description provided for @noPoi.
  ///
  /// In mn, this message translates to:
  /// **'POI алга'**
  String get noPoi;

  /// No description provided for @floorLabel.
  ///
  /// In mn, this message translates to:
  /// **'{floor} давхар'**
  String floorLabel(Object floor);

  /// No description provided for @floorKind.
  ///
  /// In mn, this message translates to:
  /// **'{floor} давхар · {kind}'**
  String floorKind(Object floor, String kind);

  /// No description provided for @mapNavNote.
  ///
  /// In mn, this message translates to:
  /// **'Turn-by-turn: QR checkpoint эсвэл BLE beacon-оор холын зайг урьдчилан тооцно (MAP-04).'**
  String get mapNavNote;

  /// No description provided for @balance.
  ///
  /// In mn, this message translates to:
  /// **'Үлдэгдэл'**
  String get balance;

  /// No description provided for @topUp.
  ///
  /// In mn, this message translates to:
  /// **'Цэнэглэх'**
  String get topUp;

  /// No description provided for @recentTransactions.
  ///
  /// In mn, this message translates to:
  /// **'Сүүлийн гүйлгээ'**
  String get recentTransactions;

  /// No description provided for @noTransactions.
  ///
  /// In mn, this message translates to:
  /// **'Гүйлгээ алга'**
  String get noTransactions;

  /// No description provided for @chooseSession.
  ///
  /// In mn, this message translates to:
  /// **'Session сонгох'**
  String get chooseSession;

  /// No description provided for @pleaseChooseSession.
  ///
  /// In mn, this message translates to:
  /// **'Session сонгоно уу'**
  String get pleaseChooseSession;

  /// No description provided for @walletBalance.
  ///
  /// In mn, this message translates to:
  /// **'Wallet үлдэгдэл'**
  String get walletBalance;

  /// No description provided for @shop.
  ///
  /// In mn, this message translates to:
  /// **'Дэлгүүр'**
  String get shop;

  /// No description provided for @food.
  ///
  /// In mn, this message translates to:
  /// **'Хоол'**
  String get food;

  /// No description provided for @transport.
  ///
  /// In mn, this message translates to:
  /// **'Тээвэр'**
  String get transport;

  /// No description provided for @profileNotFound.
  ///
  /// In mn, this message translates to:
  /// **'Профайл олдсонгүй'**
  String get profileNotFound;

  /// No description provided for @signOut.
  ///
  /// In mn, this message translates to:
  /// **'Гарах'**
  String get signOut;

  /// No description provided for @noProducts.
  ///
  /// In mn, this message translates to:
  /// **'Бүтээгдэхүүн алга'**
  String get noProducts;

  /// No description provided for @cartTotal.
  ///
  /// In mn, this message translates to:
  /// **'Сагс — {total}'**
  String cartTotal(String total);

  /// No description provided for @addToCart.
  ///
  /// In mn, this message translates to:
  /// **'+ Сагс'**
  String get addToCart;

  /// No description provided for @paidOrder.
  ///
  /// In mn, this message translates to:
  /// **'Төлөгдсөн: #{order}'**
  String paidOrder(String order);

  /// No description provided for @checkoutTitle.
  ///
  /// In mn, this message translates to:
  /// **'Төлбөр'**
  String get checkoutTitle;

  /// No description provided for @total.
  ///
  /// In mn, this message translates to:
  /// **'Нийт'**
  String get total;

  /// No description provided for @walletEnough.
  ///
  /// In mn, this message translates to:
  /// **'✓ Wallet: {bal} — хангалттай'**
  String walletEnough(String bal);

  /// No description provided for @walletShort.
  ///
  /// In mn, this message translates to:
  /// **'⚠ Үлдэгдэл {bal} — дутуу байна'**
  String walletShort(String bal);

  /// No description provided for @payWithWallet.
  ///
  /// In mn, this message translates to:
  /// **'Wallet-ээр төлөх'**
  String get payWithWallet;

  /// No description provided for @topUpSuccess.
  ///
  /// In mn, this message translates to:
  /// **'Цэнэглэлт амжилттай'**
  String get topUpSuccess;

  /// No description provided for @topUpAmount.
  ///
  /// In mn, this message translates to:
  /// **'Цэнэглэх дүн'**
  String get topUpAmount;

  /// No description provided for @payWithQpay.
  ///
  /// In mn, this message translates to:
  /// **'QPay-аар төлөх'**
  String get payWithQpay;

  /// No description provided for @scanQrUtility.
  ///
  /// In mn, this message translates to:
  /// **'Utility апп-аараа QR кодыг уншуулна уу'**
  String get scanQrUtility;

  /// No description provided for @amountLabel.
  ///
  /// In mn, this message translates to:
  /// **'Дүн: {amount}'**
  String amountLabel(String amount);

  /// No description provided for @statusLabel.
  ///
  /// In mn, this message translates to:
  /// **'Статус: {status}'**
  String statusLabel(String status);

  /// No description provided for @check.
  ///
  /// In mn, this message translates to:
  /// **'Шалгах'**
  String get check;

  /// No description provided for @locationSent.
  ///
  /// In mn, this message translates to:
  /// **'Байршил илгээгдлээ · Ops team мэдэгдэнэ'**
  String get locationSent;

  /// No description provided for @helpTitle.
  ///
  /// In mn, this message translates to:
  /// **'Тусламж'**
  String get helpTitle;

  /// No description provided for @emergencyHelp.
  ///
  /// In mn, this message translates to:
  /// **'🚨 Яаралтай тусламж'**
  String get emergencyHelp;

  /// No description provided for @callMedical.
  ///
  /// In mn, this message translates to:
  /// **'103 Эмнэлэг'**
  String get callMedical;

  /// No description provided for @callPolice.
  ///
  /// In mn, this message translates to:
  /// **'102 Цагдаа'**
  String get callPolice;

  /// No description provided for @sendMyLocation.
  ///
  /// In mn, this message translates to:
  /// **'Миний байршил явуулах'**
  String get sendMyLocation;

  /// No description provided for @helpSiopInfo.
  ///
  /// In mn, this message translates to:
  /// **'SIOP мэдээлэл, FAQ, хөтөлбөр'**
  String get helpSiopInfo;

  /// No description provided for @contactOperator.
  ///
  /// In mn, this message translates to:
  /// **'📞 Оператортой холбогдох'**
  String get contactOperator;

  /// No description provided for @operatorHours.
  ///
  /// In mn, this message translates to:
  /// **'Хүн хариулах · 08:00–22:00'**
  String get operatorHours;

  /// No description provided for @emergencyProcedures.
  ///
  /// In mn, this message translates to:
  /// **'📋 Яаралтай журам'**
  String get emergencyProcedures;

  /// No description provided for @emergencyProceduresDesc.
  ///
  /// In mn, this message translates to:
  /// **'Гал, газар хөдлөлт, эрүүл мэнд'**
  String get emergencyProceduresDesc;

  /// No description provided for @tabLost.
  ///
  /// In mn, this message translates to:
  /// **'Гээсэн'**
  String get tabLost;

  /// No description provided for @tabFound.
  ///
  /// In mn, this message translates to:
  /// **'Олдсон'**
  String get tabFound;

  /// No description provided for @report.
  ///
  /// In mn, this message translates to:
  /// **'Мэдэгдэл'**
  String get report;

  /// No description provided for @empty.
  ///
  /// In mn, this message translates to:
  /// **'Хоосон'**
  String get empty;

  /// No description provided for @whatLostFound.
  ///
  /// In mn, this message translates to:
  /// **'Юу гээсэн/олдсон?'**
  String get whatLostFound;

  /// No description provided for @extraDescription.
  ///
  /// In mn, this message translates to:
  /// **'Нэмэлт тайлбар'**
  String get extraDescription;

  /// No description provided for @liveBroadcast.
  ///
  /// In mn, this message translates to:
  /// **'▶ ШУУД ДАМЖУУЛАЛТ'**
  String get liveBroadcast;

  /// No description provided for @openingCeremonyVenue.
  ///
  /// In mn, this message translates to:
  /// **'Opening Ceremony · Төрийн ордон'**
  String get openingCeremonyVenue;

  /// No description provided for @mediaAssets.
  ///
  /// In mn, this message translates to:
  /// **'Логонууд, зураг, баримт бичиг'**
  String get mediaAssets;

  /// No description provided for @interviewBooking.
  ///
  /// In mn, this message translates to:
  /// **'Ярилцлага захиалга'**
  String get interviewBooking;

  /// No description provided for @pressBadgeRequired.
  ///
  /// In mn, this message translates to:
  /// **'Press badge шаардлагатай'**
  String get pressBadgeRequired;

  /// No description provided for @errNetwork.
  ///
  /// In mn, this message translates to:
  /// **'Интернэт холболт алдаатай байна.'**
  String get errNetwork;

  /// No description provided for @errTooMany.
  ///
  /// In mn, this message translates to:
  /// **'Хэт олон удаа оролдлоо. 1 цагийн дараа дахин оролдоно уу.'**
  String get errTooMany;

  /// No description provided for @errEmailNotRegistered.
  ///
  /// In mn, this message translates to:
  /// **'И-мэйл хаяг бүртгэлгүй байна. Зохион байгуулагчтай холбогдоно уу.'**
  String get errEmailNotRegistered;

  /// No description provided for @errOtpInvalid.
  ///
  /// In mn, this message translates to:
  /// **'Код буруу эсвэл хугацаа дууссан байна. Дахин код авна уу.'**
  String get errOtpInvalid;

  /// No description provided for @errAuthRequired.
  ///
  /// In mn, this message translates to:
  /// **'Нэвтрэх шаардлагатай. Та дахин нэвтэрнэ үү.'**
  String get errAuthRequired;

  /// No description provided for @errTimeout.
  ///
  /// In mn, this message translates to:
  /// **'Хүсэлт хугацаа дуусав. Дахин оролдоно уу.'**
  String get errTimeout;

  /// No description provided for @errGeneric.
  ///
  /// In mn, this message translates to:
  /// **'Алдаа гарлаа. Дахин оролдоно уу.'**
  String get errGeneric;

  /// No description provided for @comingSoon.
  ///
  /// In mn, this message translates to:
  /// **'Удахгүй нэмэгдэнэ'**
  String get comingSoon;

  /// No description provided for @tierExhibitor.
  ///
  /// In mn, this message translates to:
  /// **'Exhibitor'**
  String get tierExhibitor;

  /// No description provided for @tierPress.
  ///
  /// In mn, this message translates to:
  /// **'Хэвлэл мэдээлэл'**
  String get tierPress;

  /// No description provided for @editName.
  ///
  /// In mn, this message translates to:
  /// **'Нэр засах'**
  String get editName;

  /// No description provided for @speakers.
  ///
  /// In mn, this message translates to:
  /// **'Илтгэгчид'**
  String get speakers;

  /// No description provided for @noMediaAssets.
  ///
  /// In mn, this message translates to:
  /// **'Медиа файл алга'**
  String get noMediaAssets;

  /// No description provided for @hallLabel.
  ///
  /// In mn, this message translates to:
  /// **'{hall} танхим'**
  String hallLabel(String hall);

  /// No description provided for @topUpNow.
  ///
  /// In mn, this message translates to:
  /// **'Одоо цэнэглэх'**
  String get topUpNow;

  /// No description provided for @myAgendaTitle.
  ///
  /// In mn, this message translates to:
  /// **'Миний хуваарь'**
  String get myAgendaTitle;

  /// No description provided for @walletTitle.
  ///
  /// In mn, this message translates to:
  /// **'Цахим хэтэвч'**
  String get walletTitle;

  /// No description provided for @mediaTitle.
  ///
  /// In mn, this message translates to:
  /// **'Медиа'**
  String get mediaTitle;

  /// No description provided for @scannerTitle.
  ///
  /// In mn, this message translates to:
  /// **'Check-in Scanner'**
  String get scannerTitle;

  /// No description provided for @b2bTitle.
  ///
  /// In mn, this message translates to:
  /// **'B2B Exhibitorууд'**
  String get b2bTitle;

  /// No description provided for @meetingBtn.
  ///
  /// In mn, this message translates to:
  /// **'Meeting'**
  String get meetingBtn;

  /// No description provided for @statusGoing.
  ///
  /// In mn, this message translates to:
  /// **'Бүртгүүлсэн ✓'**
  String get statusGoing;

  /// No description provided for @statusWaitlist.
  ///
  /// In mn, this message translates to:
  /// **'Хүлээлтэд'**
  String get statusWaitlist;

  /// No description provided for @statusAttended.
  ///
  /// In mn, this message translates to:
  /// **'Ирсэн'**
  String get statusAttended;

  /// No description provided for @todayAgenda.
  ///
  /// In mn, this message translates to:
  /// **'Өнөөдрийн хуваарь'**
  String get todayAgenda;

  /// No description provided for @nextUp.
  ///
  /// In mn, this message translates to:
  /// **'Дараагийн'**
  String get nextUp;

  /// No description provided for @sectionQuickAccess.
  ///
  /// In mn, this message translates to:
  /// **'Хурдан хандалт'**
  String get sectionQuickAccess;

  /// No description provided for @siopCongressLabel.
  ///
  /// In mn, this message translates to:
  /// **'18-р SIOP Asia Congress'**
  String get siopCongressLabel;

  /// No description provided for @siopLocationDate.
  ///
  /// In mn, this message translates to:
  /// **'Улаанбаатар · 2026.06.25–28'**
  String get siopLocationDate;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In mn, this message translates to:
  /// **'Данс устгах хүсэлт'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In mn, this message translates to:
  /// **'Данс болон өгөгдлөө устгуулах имэйл хүсэлт илгээх'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In mn, this message translates to:
  /// **'Данс устгах уу?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogBody.
  ///
  /// In mn, this message translates to:
  /// **'Имэйл апп нээгдэж данс устгах хүсэлтийн загвар бэлэн болно. Манай баг 7 хоногийн дотор хүсэлтийг биелүүлнэ.'**
  String get deleteAccountDialogBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In mn, this message translates to:
  /// **'Хүсэлт илгээх'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountCancel.
  ///
  /// In mn, this message translates to:
  /// **'Болих'**
  String get deleteAccountCancel;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'mn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'mn':
      return AppL10nMn();
  }

  throw FlutterError(
      'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
