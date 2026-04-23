# App store submission — iOS + Android

## Metadata (MN + EN)
- **Name:** COP17 Mongolia 2026
- **Subtitle / short desc:** UNCCD COP17 албан ёсны апп · Official COP17 app
- **Categories:** Reference (primary), Business (secondary)
- **Support URL:** https://cop17.mn/support
- **Privacy policy URL:** https://cop17.mn/legal/privacy

## Required assets
- Icon: 1024×1024 PNG (no alpha) + all sizes generated via `flutter_launcher_icons`
- iOS screenshots: 6.7" (iPhone 15 Pro Max), 5.5" (iPhone 8 Plus) — 6 screens: Home, Programme, Session detail, Wallet, Map, AI chatbot
- Android screenshots: Phone + Tablet 7" + Tablet 10" — same 6 screens
- Feature graphic (Play): 1024×500 — COP17 logo + skyline

## Privacy / data safety
We collect:
- **Account:** email (auth), name (profile)
- **Identifiers:** user ID (internal UUID), device FCM token (notifications)
- **Location:** only on explicit SOS or shuttle ETA — not continuous
- **Financial:** wallet balance (ours), NOT card/PAN (QPay/Stripe)
- **App interactions:** attendance events for analytics

Data linked to user: email, tier, attendance, wallet.
Data NOT collected: browsing history, contacts, photos, microphone, health.

Include `PrivacyInfo.xcprivacy` (iOS 17+) listing:
- `NSPrivacyTrackingDomains`: none (we don't track cross-site)
- API types used: `NSPrivacyAccessedAPICategoryUserDefaults`, `...FileTimestamp`, `...SystemBootTime`

## Android Play Data Safety form
Mirror the above in Play Console → Data safety.

## Permissions rationale (in app review notes)
| Permission | Why |
|---|---|
| Camera | QR scanning (Digital ID + session check-in) |
| Location (when in use) | SOS, shuttle ETA, indoor navigation |
| Notifications | Programme reminders, tier changes, emergency alerts |
| Biometric | Fast re-login; refresh token stored in OS keychain |

## Demo account for reviewers
- Email: `reviewer@cop17.mn`
- OTP: fixed `000000` in review build flag `REVIEW_MODE=1`
- Tier: VIP (to show full feature set)

## Build flavors
| Flavor | Base URL | Supabase | Debug |
|---|---|---|---|
| `dev` | localhost | local Supabase CLI | yes |
| `staging` | stg-api.cop17.mn | stg project | yes, Sentry staging |
| `prod` | api.cop17.mn | prod project | no |

Build: `flutter build ipa --flavor prod --dart-define-from-file=prod.json`.

## Submission timeline
- T-14 days: submit beta (TestFlight / Play Internal)
- T-10 days: submit prod for review
- T-5 days: reviewer approved; stage rollout 10 % → 50 % → 100 %
- T-1 day: final "ready for release" at 100 %
- Apr 12, 2026 (T-0): public
