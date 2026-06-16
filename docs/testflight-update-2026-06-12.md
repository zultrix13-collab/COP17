# TestFlight Update — 2026-06-12

## Зорилго
TestFlight дээр хамгийн сүүлийн өөрчлөлтүүд (build 26) ороогүй байсныг засаж, шинэ build-ийг App Store Connect рүү upload хийх.

## Хийсэн ажлууд

### 1. Code өөрчлөлт
- `apps/mobile/lib/l10n/app_localizations.dart` — `appTitle` localization-ийг `COP17` → `SIOP` болгож засав (өмнөх commit-үүдэд хийсэн COP17 → SIOP rebrand-ийн дутуу үлдсэн хэсэг).
- `apps/mobile/pubspec.yaml` — `version: 0.1.0+25` → `0.1.0+26` болгож build number нэмэгдүүлэв.
- Commit: `b976458` — "chore(mobile): bump build number to 26, update appTitle to SIOP in l10n"

### 2. Build
- `apps/mobile/build_testflight.sh` script ашиглан `flutter build ipa --release` гүйцэтгэв.
- Build үр дүн:
  - Version Number: `0.1.0`
  - Build Number: `26`
  - Display Name: `SIOP`
  - Bundle Identifier: `com.app.cop17`
  - Archive: `build/ios/archive/Runner.xcarchive` (213.1MB)

### 3. App Store Connect рүү Upload
- `ios/ExportOptions.plist`-д `destination: upload` тохиргоотой тул `xcodebuild -exportArchive` шууд App Store Connect рүү upload хийдэг.
- Upload амжилттай дууссан:
  ```
  Progress 100%: Upload succeeded.
  Uploaded Runner
  ** EXPORT SUCCEEDED **
  ```
- Анхааруулга (warning, upload-д саад болохгүй): `objective_c.framework` dSYM upload амжилтгүй — зөвхөн crash symbolication-д нөлөөлнө.

### 4. GitHub CLI
- `gh auth login --web` ашиглан GitHub CLI-г дахин нэвтрүүлэв (account: `zultrix13-collab`). PR статус харагдах боллоо.

## Одоогийн статус
- App Store Connect дээр build 26 **processing** шатанд явж байна (10-30 минут, заримдаа илүү хугацаа авдаг).
- TestFlight app дээр одоогоор хуучин **Build 22** харагдаж байна — энэ нь processing дуусаагүй учраас хэвийн.
- Processing дуусаад build 26 нь TestFlight-ийн Builds жагсаалтад гарч ирэх ёстой.

## Дараагийн алхамууд (санал)
1. ~5-10 минутын дараа App Store Connect → TestFlight хэсгээс build 26-ийн processing статусыг шалгах.
2. Build боловсруулагдаж дууссаны дараа TestFlight tester-уудад түгээх (Internal/External testing group).
3. **App Icon болон Launch Image** одоогоор Flutter-ийн placeholder хэвээр байгаа — App Store review-д асуудал гарахаас өмнө бодит icon/launch image тавих хэрэгтэй (тусдаа даалгавар).
