# COP17 — Operations runbook

## Environments
- **dev** — local docker-compose (Postgres, Redis, MinIO, Meilisearch)
- **staging** — pre-event rehearsal cluster
- **prod** — COP17 live (Aug 17–28, 2026)

## Deploy
1. PR → CI (lint, typecheck, test) → review → merge to `main`.
2. Tag `vX.Y.Z` → GitHub Actions builds Docker images + Flutter artifacts.
3. ArgoCD/kubectl apply to staging → smoke tests → promote to prod.

## On-call
- Rotation: 24/7 during Aug 15–30, 2026. Primary + secondary.
- Escalation: on-call → lead → CTO.

## Key SLOs
- API p95 < 400ms, error rate < 0.5%
- Mobile crash-free sessions > 99.5%
- Push delivery p95 < 30s
- QR verification p95 < 200ms (on-site)

## Incident response
1. Ack in #cop17-ops Slack within 5 min.
2. Open alert incident in admin dashboard (`/admin/alerts`).
3. Investigate → mitigate → postmortem within 48h.

## Common runbooks
### OTP spike / brute force
- Check `auth/otp/*` rate-limiter metrics.
- Block offending IP via WAF.
- Raise throttle config if organic spike (opening day).

### Wallet reconcile mismatch
- Pause top-ups.
- Run `scripts/reconcile-qpay.ts --date=YYYY-MM-DD`.
- Compare `wallet_txns` vs QPay dashboard.

### Venue Wi-Fi outage
- Mobile apps degrade to offline: cached programme + digital ID remain usable.
- QR scanners continue in offline mode (validate HMAC locally, sync when online).

### Bulk tier upgrade stuck
- Check `jobs.tier_bulk` queue in Redis.
- Re-enqueue from admin UI `/admin/users/bulk`.

### Supabase outage
- Read cache: mobile keeps a 24h Drift snapshot of programme + digital ID.
- Writes (Going, feedback, lost&found report) queue locally; sync on reconnect.
- Admin-web: show banner, disable mutations, reads continue via TanStack Query cache.
- If outage > 15 min: post to #cop17-ops + venue info desk announces "app degraded mode."

### QPay webhook not firing
- Confirm via `GET /payments/qpay/:id/status` — our poll fallback should eventually credit.
- If QPay dashboard shows "paid" but our invoice stuck: manual trigger via SQL
  (`select rpc_wallet_credit(...)`) **after** verifying no duplicate credit.

### AI chatbot returns hallucinations
- Check `rag_chunks` row count (Dashboard → Reindex button should show > 200 chunks).
- If embedding provider outage: disable chatbot entrypoint (feature flag `FEATURE_AI=false`) — falls back to FAQ.

### Push notification backlog
- Check `notifications` table with `delivered_at IS NULL` and `created_at < now() - 5 min`.
- Inspect FCM admin SDK logs for 429 (quota) or invalid token errors.
- Rotate invalid tokens out of `device_tokens`.

## On-site rehearsal (T-7 days)
Goal: catch real-venue problems before delegates arrive.

- [ ] **Wi-Fi saturation:** 200 staff phones connect simultaneously — measure Supabase latency from venue network.
- [ ] **QR check-in throughput:** each entry lane scans 100 QR tokens in 5 minutes. Target: p95 < 400 ms end-to-end.
- [ ] **BLE beacon mapping:** walk every hall with the app, verify `pois.geom` positions match.
- [ ] **Cell signal dead zones:** mark basements / back halls; confirm app offline fallback.
- [ ] **Battery drain:** 8-hour simulated delegate day (QR refresh + navigation). Target: < 20 % drain on iPhone 12+.
- [ ] **Scanner kiosk cold boot:** unplug/replug — scanner app relaunches and resumes inside 30 s.
- [ ] **SOS flow:** trigger from outside a hall; Ops admin sees alert in dashboard within 10 s.
- [ ] **Fire drill:** simulate alert severity=critical, confirm push reaches 500 test devices.

## Failure mode matrix

| Component down | User impact | Mitigation in place |
|---|---|---|
| Supabase (DB) | Writes blocked; reads from client cache | Drift cache, offline queue |
| NestJS API | QR check-in, QPay top-up, AI chat fail | Load-balanced replicas, graceful degradation badge |
| QPay | Top-ups blocked | Show banner "Wallet recharge temporarily unavailable"; existing balance still spends |
| Anthropic | AI chat 5xx | `/ai/chat` returns fallback "Please visit info desk" |
| OpenAI embeddings | Reindex blocked | Use stale index; re-queue via admin |
| FCM | Push delayed | In-app banner still shows (Supabase Realtime) |
| Venue Wi-Fi | Most services degraded | Offline-first cache; QR HMAC verifiable offline by scanner |
