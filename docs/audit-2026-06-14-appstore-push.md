# SIOP Mongolia — App Store дахин push хийхэд хэрэгтэй гүний аудит (2026-06-14)

> Congress: **SIOP Asia 2026 (18th SIOP Asia Congress)**, Ulaanbaatar · 2026.06.25–28
> Аудит хийсэн огноо: 2026.06.14
> Хамрах хүрээ: App Store Connect submission (App 6764760687 "SIOP Mongolia", Bundle ID `com.app.cop17`), `apps/mobile` (iOS build/release pipeline)
> Suuri: `docs/audit-2026-06-13.md`-д бүх 8 зүйл шийдэгдсэний дараа, дараагийн TestFlight/ASC upload + "Add for Review" хийхэд шууд саад болох зүйлсийг шалгасан.

---

## 🔴 CRITICAL — "Add for Review" дарахаас өмнө заавал засах

### 1. ✅ ASC Version 1.0 дээр Build холбогдсон, submit хийгдсэн (ЗАСАГДСАН)
`https://appstoreconnect.apple.com/apps/6764760687/distribution/ios/version/inflight` дээрх "Build" хэсэгт зөвхөн **"Add Build"** товч харагдаж байсан — version 1.0-тэй холбогдсон build байгаагүй.

TestFlight дээр 0.1.0 (31–35) бүх build "Complete" статустай (35 нь хамгийн сүүлд, 2026.06.12 18:44, SIOP icon-той), гэхдээ эдгээр нь зөвхөн TestFlight-д л байсан — App Store version-д сонгогдоогүй байсан.

**Шийдэл (2026-06-14):** `flutter build ipa` ажиллуулж build 36-ыг архивлаж, `ExportOptions.plist`-ийн `destination=upload` тохиргоогоор шууд App Store Connect-рүү upload хийсэн. TestFlight дээр Processing дууссаны дараа build 36-ыг ASC Version 1.0-д "Add Build"-аар холбосон. Одоо status **"1.0 Waiting for Review"** — submission Apple-д илгээгдсэн.

### 2. ✅ iPad screenshot 0/10 — гэхдээ app Universal (ЗАСАГДСАН)
`apps/mobile/ios/Runner.xcodeproj/project.pbxproj` дээр `TARGETED_DEVICE_FAMILY = "1,2"` — өөрөөр хэлбэл app iPad дээр ажиллах боломжтой Universal app гэж тохируулагдсан. Гэвч ASC дээр "Previews and Screenshots" → iPad tab нь **"0 of 10 Screenshots"** — ямар ч iPad screenshot оруулаагүй (iPhone tab дээр 4/10 байна).

Apple Review iPad screenshot шаардахгүй бол анхаарал татахгүй, гэхдээ App нь iPad-д зөвшөөрөгдсэн тул review үед iPad дээр шалгаж магадгүй бөгөөд screenshot байхгүй нь reject шалтгаан болж болзошгүй.

**Шийдэл (2026-06-14):** `Runner.xcodeproj/project.pbxproj` дотор бүх 3 build config (Debug/Release/Profile)-ийн `TARGETED_DEVICE_FAMILY = "1,2"` → `"1"` болгож зөвхөн iPhone-д хязгаарласан (app-ийн UI iPad layout дээр тестлэгдээгүй байсан тул). Дараагийн `flutter build ipa` build-д энэ өөрчлөлт орно, ASC дээр iPad screenshot шаардлагагүй болно.
### 3. ✅ App Review Information → Contact Information бөглөгдсөн (ЗАСАГДСАН)
"App Review Information" хэсэгт **First name, Last name, Phone number, Email** бүгд хоосон байсан (зөвхөн Sign-In Information [#5, өмнөх аудитаар бэлдсэн delegate@siop.mn / SiopAsia2026!] бөглөгдсөн байсан).

**Шийдэл (2026-06-14):** Contact Information-д Sunber Khatanbaatar (+97699791144, sunber1289@gmail.com) бөглөгдсөн.


---

## 🟠 HIGH — Submission-ийн чанарт нөлөөлнө, гэхдээ шууд блок биш

### 4. ✅ GoogleService-Info.plist bundle ID зөрчил + Push notification бүрэн ажиллахгүй (ЗАСАГДСАН)
- `apps/mobile/ios/Runner/GoogleService-Info.plist` дотор `BUNDLE_ID = com.app.siop`, `PROJECT_ID = siop-ub2026` — гэтэл ASC App Information-д бүртгэгдсэн жинхэнэ bundle ID бол **`com.app.cop17`** (`project.pbxproj`-тай таарч байна). Firebase config өөр bundle ID/project-д зориулагдсан тул ажиллахгүй.
- Энэ файл нь `project.pbxproj` дотор **бүртгэгдээгүй** (Copy Bundle Resources-д ороогүй) — IPA дотор bundle хийгдэхгүй.
- `lib/main.dart` дотор `Firebase.initializeApp()` хэзээ ч дуудагдаагүй.
- `lib/features/notifications/push_registration.dart`-ийн `registerPushToken()` функц нь хаана ч дуудагдаагүй dead code.

**Шийдэл (2026-06-14):**
- Firebase console (`console.firebase.google.com/project/cop17-ub2026`) дээр `com.app.cop17` bundle ID-тай шинэ iOS app бүртгэж, зөв `GoogleService-Info.plist` татаж авсан (`PROJECT_ID = cop17-ub2026`, `BUNDLE_ID = com.app.cop17`).
- Энэ файлыг `apps/mobile/ios/Runner/GoogleService-Info.plist`-руу солиод, `Runner.xcodeproj/project.pbxproj`-ийн Copy Bundle Resources build phase-д бүртгэсэн (өмнө нь бүртгэгдээгүй байсан тул IPA дотор bundle хийгдэхгүй байсан).
- `lib/main.dart`-д `Firebase.initializeApp()`-г `WidgetsFlutterBinding.ensureInitialized()`-ийн дараа нэмсэн.
- `lib/features/shell/main_shell.dart`-ыг `ConsumerStatefulWidget` болгож, `initState`-д `registerPushToken(ref)`-г дуудаж эхлүүлсэн (FCM permission/token + `/device-tokens`-руу post).
- `registerPushToken()`-ийг try/catch-аар хамгаалсан — backend `/device-tokens` endpoint байхгүй үед ч app crash хийхгүй, зөвхөн push registration нь "best-effort" болно.
- `flutter analyze` (No issues found), `flutter test` (pre-existing `error_view_test.dart` package нэрний алдааг эс тооцвол бүх тест pass) шалгасан.

**Үлдсэн мэдэгдэх зүйл:** `apps/api` backend дээр `/device-tokens` endpoint болон FCM admin SDK fan-out хараахан хийгдээгүй (өмнөх аудитаар зориудаар устгасан backend) — push token бүртгэгддэг болсон ч, серверээс push илгээх хэсэг дараагийн iteration-д хэрэгжих ёстой.

### 5. ✅ SIOP rebrand-ийн commit хийгдээгүй өөрчлөлтүүд + дараагийн build number bump (ЗАСАГДСАН)
`git status` дээр доорх файлууд **uncommitted**:
- `apps/mobile/lib/{app/theme.dart, features/home/home_page.dart, features/map/map_page.dart, features/onboarding/splash_page.dart, features/onboarding/welcome_page.dart, features/profile/profile_repository.dart, features/programme/programme_repository.dart}` — бүгд зөв SIOP Asia 2026 rebrand (огноо Jun 25–28, лого, demo data) контентыг агуулж байна.
- `apps/mobile/pubspec.yaml` — `description:` SIOP Asia 2026 болгож шинэчилсэн.

Одоогийн `pubspec.yaml` дотор `version: 0.1.0+35` — гэхдээ build **35 нь TestFlight дээр аль хэдийн оршдог**. Дараагийн `flutter build ipa` / upload хийхэд ASC build number unique байх шаардлагатай тул **`+36`** болгож bump хийх ёстой.

**Шийдэл (2026-06-14):**
1. Дээрх 8 файлыг `feat(mobile): rebrand to SIOP Asia 2026 and bump build to 36` commit-д оруулсан (lib/ доторх 7 rebrand файл + pubspec.yaml + brand asset солилт).
2. `pubspec.yaml`-ийн `version`-ийг `0.1.0+36` болгож bump хийсэн.
3. **Үлдсэн алхам:** `flutter build ipa` ажиллуулж шинэ build (36)-ыг ASC-руу upload хийж, version 1.0-д "Add Build"-аар холбох (CRITICAL #1-ийг шийднэ) — энэ нь CI/local машин дээр Xcode-той хийгдэх ёстой тул энэ session-ээс гадна хийгдэх ажил.

---

## 🟢 LOW — Cosmetic / out-of-scope

### 6. `apps/admin-web` дотор хуучин "COP17 Admin" branding үлдсэн
`src/locales/mn.json`, `en.json` дотор `"app": {"title": "COP17 Admin"}`, мөн `LoginPage.tsx` дотор `<div>COP17 Admin</div>` болон `placeholder="admin@cop17.mn"`. Энэ нь mobile App Store submission-д шууд нөлөөгүй (admin-web тусдаа deploy), гэхдээ branding consistency-ийн үүднээс дараа засаж болно.

### 7. Support URL хуучин repo замтай (`/COP17/legal/support.html`)
ASC дээрх Support URL: `https://zultrix13-collab.github.io/COP17/legal/support.html` — repo нэр `COP17` хэвээр (GitHub Pages замын нэг хэсэг). Хуудасны контент SIOP-аар зөв шинэчлэгдсэн (`docs: add bilingual support/contact page for SIOP Asia 2026 app` commit), зөвхөн URL дотор "COP17" үг үлдсэн — функциональ асуудал биш.

---

## ✅ Зөв шалгагдсан зүйлс (засвар шаардлагагүй)

- **Keywords**: `SIOP,SIOP Asia,pediatric oncology,congress,Mongolia,Ulaanbaatar,conference,medical,childhood cancer` — зөв бөглөгдсөн.
- **Sign-In Information**: "Sign-in required" checked, `delegate@siop.mn` / `SiopAsia2026!` — өмнөх аудитын #5-тай таарна.
- **Promotional Text / Description / Version / Copyright / Marketing URL**: бүгд SIOP Asia 2026-д тохируулагдсан, бөглөгдсөн.
- **iPhone 6.5" Screenshots**: 4/10 оруулсан, SIOP Asia 2026 branding-тай (profile, agenda, services, home).

---

## Эрэмбэлсэн зорилт

| # | Зорилт | Priority | Status |
|---|--------|----------|--------|
| 1 | ASC Version 1.0-д Build холбох ("Add Build") | 🔴 Critical | ✅ Done (build 36 холбогдсон, submit хийгдсэн) |
| 2 | iPad screenshot 0/10 — Universal эсэхийг шийдэх (screenshot нэмэх эсвэл iPhone-only болгох) | 🔴 Critical | ✅ Done (iPhone-only болгосон) |
| 3 | App Review Information → Contact Information бөглөх | 🔴 Critical | ✅ Done |
| 4 | GoogleService-Info.plist bundle ID зөрчил + push notification ажиллахгүй асуудал | 🟠 High | ✅ Done |
| 5 | Uncommitted SIOP rebrand commit хийх + pubspec version `0.1.0+36` bump | 🟠 High | ✅ Done (build upload үлдсэн) |
| 6 | admin-web "COP17 Admin" residual branding | 🟢 Low | Дараа |
| 7 | Support URL дотор "COP17" зам нэр үлдсэн | 🟢 Low | Дараа |

---

*Энэ баримт нь 2026.06.14-ний өдрийн ASC submission state + codebase snapshot дээр үндэслэсэн. #1–#5 (бүх 🔴 Critical, 🟠 High) шийдэгдсэн, build 36 submit хийгдсэн ("Waiting for Review"). Үлдсэн ганц #6/#7 (🟢 Low, cosmetic) — submission-д нөлөөгүй, дараа хийнэ.*
