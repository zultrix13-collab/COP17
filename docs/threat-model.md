# COP17 — Threat model (STRIDE)

## System
- **Actors:** delegate, VIP, exhibitor, press, ops/admin, sponsor, QPay, OpenAI, Anthropic.
- **Trust boundary:** Supabase (auth + RLS) + NestJS BFF + Flutter/React clients.

## STRIDE summary

| Threat | Example | Mitigation |
|---|---|---|
| **S**poofing | Attacker shows a forged QR at the hall | HMAC-signed tokens with 15-min TTL; server-side verify on every scan |
| | Webhook forgery pretending to be QPay | HMAC signature check (`X-QPay-Signature`) over raw body |
| | Stolen admin session | Short Supabase access token (1h), refresh rotation, `admin_roles` double-check at every privileged call |
| **T**ampering | Client-side tier bump | RLS blocks `profiles.tier` write by self; only `service_role` via audited RPC |
| | Wallet balance manipulation | `rpc_wallet_debit`/`rpc_wallet_credit` under `SELECT FOR UPDATE`; clients never `UPDATE wallets` |
| | Order total rewrite | Server recalculates from products; `name_snap` + `unit_price` frozen per row |
| **R**epudiation | "I didn't upgrade that tier" | `tier_changes` audit log with admin_id, reason, immutable |
| | "Wallet debit wasn't me" | `wallet_txns` immutable, reference back to order / QPay invoice |
| **I**nformation disclosure | Exhibitor reads other exhibitors' meeting details | RLS: `b2b_meetings` only when requester or exhibitor matches `auth.uid()` |
| | Press reads VIP profile PII | Admin-only policy on protected fields; avoid returning `accreditation_id` to non-owner |
| | QR token in screenshot | Short TTL + HMAC; replay-attack value minutes, not days |
| **D**enial of service | OTP spam | Throttler 60 req/min IP + Supabase's built-in email rate limiter |
| | Opening-day burst | Read-heavy routes use Postgres replicas (Supabase read-replica) + CDN cache for public content |
| | AI cost exploit (prompt stuffing) | `ChatDto` max 500 chars, rate-limit `/ai/chat` per user, Claude `max_tokens: 400` |
| **E**levation of privilege | Delegate calls admin endpoints | `AdminGuard` verifies token → `admin_roles` table per request |
| | Self-elevate tier via RPC | RPCs check calling role; `service_role` key never ships to client |

## Data classification

| Class | Data | Storage rule |
|---|---|---|
| **Restricted** | OTP, access tokens, QR HMAC secret | Never logged. Redacted in Sentry via `beforeSend` |
| **Confidential** | email, name, accreditation_id, wallet balance | RLS-scoped, only admins read across users |
| **Internal** | tier, session attendance | Readable by self + admin |
| **Public** | sessions, sponsors, FAQ, announcements | Readable by any authenticated user |

## What we explicitly do NOT store
- **PAN / card data:** PCI-DSS scope is avoided — QPay / Stripe handles all card details; we only see their opaque tokens.
- **Device biometrics:** `local_auth` keeps FaceID/fingerprint in OS secure enclave.
- **Location history:** we only read location when user taps "Send location" on SOS; single point, inserted into `alerts_incidents`.
