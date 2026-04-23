# Accessibility (WCAG 2.1 AA)

Both apps must clear these before public release.

## Flutter (mobile)
- [ ] All tappable widgets ≥ 44×44 (use `IconButton`, `FilledButton` defaults)
- [ ] Every `Image` and icon has a `semanticLabel`
- [ ] Dynamic text scale: test at `MediaQuery.textScaleFactor = 2.0`; nothing overflows
- [ ] Colors: tier pills passed contrast with WebAIM checker (≥ 4.5:1)
- [ ] TalkBack + VoiceOver walk-through of onboarding, programme → Going, SOS
- [ ] Focus order is top-to-bottom, left-to-right on all pages (no negative tab index)
- [ ] Form fields have visible labels, not just hints

## Admin web
- [ ] Every `<button>` reachable by Tab, visible focus ring (`outline: 2px solid`)
- [ ] `<table>` has `<thead>` + scope; screen readers announce columns
- [ ] Color never the sole carrier of meaning (tier badge has emoji + text, alerts have severity word)
- [ ] axe-core CI: 0 serious/critical violations (add `@axe-core/playwright`)
- [ ] Keyboard-only session: login → approve meeting → logout, no dead-ends
- [ ] `aria-live` on toast notifications

## Content
- [ ] All Монгол strings proofread by native copy editor
- [ ] All English strings proofread by UN-style editor
- [ ] PDF press kit files tagged / OCR'd (screen-reader accessible)
- [ ] Emergency procedures page tested at zoom 200 %

## Localization QA
- [ ] Flutter: hot-swap `locale` = `en` → no untranslated keys
- [ ] Admin-web: same via `i18n.changeLanguage('en')`
- [ ] Date/number formatting uses locale (`mn_MN` / `en_US`) — spot-check wallet + agenda
- [ ] RTL readiness: not required for MN/EN but avoid hard-coded `Alignment.centerLeft` in shared widgets
