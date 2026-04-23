# COP17 — Go-live checklist

Run through this ~2 weeks before Apr 12, 2026. Every item must be ✓ before go/no-go.

## Infrastructure
- [ ] Supabase prod project created, region = closest to UB (or self-hosted in UB datacenter)
- [ ] Postgres daily backup + PITR (7 days)
- [ ] Redis: managed (Upstash / ElastiCache) with persistence
- [ ] MinIO/S3: versioning + lifecycle rules
- [ ] DNS: `api.cop17.mn`, `admin.cop17.mn`, `cdn.cop17.mn` w/ TLS via Let's Encrypt (cert-manager)
- [ ] WAF in front of API (rate limit, geoblock optional)
- [ ] CDN in front of admin-web (CloudFront / Bunny)
- [ ] Auto-scaling: API min 3 / max 20 instances; connection pooling via PgBouncer (Supabase default)

## Security
- [ ] `QPAY_WEBHOOK_SECRET` set in prod; stub guard throws
- [ ] All `service_role` keys stored in KMS / sealed secrets
- [ ] CORS allowlist limited to `https://admin.cop17.mn`
- [ ] `helmet` CSP enabled (`NODE_ENV=production`)
- [ ] Swagger `/docs` disabled in prod
- [ ] Dependency audit clean (`npm audit --audit-level=high`)
- [ ] Penetration test report signed off
- [ ] PCI self-assessment SAQ-A completed (we're scope-minimized via QPay)
- [ ] Privacy policy + ToS live at `cop17.mn/legal`

## Observability
- [ ] Sentry project (API + mobile + admin-web), source maps uploaded
- [ ] Grafana dashboard: API p95, error rate, Postgres connections, Redis memory, QPay webhook success
- [ ] On-call PagerDuty rotation starts Apr 10 → Apr 25
- [ ] Alerts: p95>400ms (10m), err>1% (5m), DB conn>80%, disk>80%

## Data
- [ ] Seed: sessions, speakers, sponsors, FAQ, announcements, products imported from CMS
- [ ] Accreditation whitelist imported (CSV from registration system)
- [ ] Admin roles assigned (super_admin × 2, ops_admin × 6, finance × 2, moderator × 4)
- [ ] AI reindex run post-seed, `rag_chunks` >= expected count

## Clients
- [ ] iOS build uploaded to TestFlight, privacy manifest (`PrivacyInfo.xcprivacy`) present
- [ ] Android build signed with Play upload key, uploaded to internal track
- [ ] App review submitted ≥ 10 days before Apr 12
- [ ] App icons, screenshots (6.7" + 5.5"), descriptions (MN+EN) uploaded
- [ ] Admin-web build deployed behind auth-protected URL
- [ ] `VITE_SUPABASE_URL` + `VITE_API_BASE_URL` point to prod

## Load & resilience
- [ ] `loadtest/programme.js` passes SLO on staging at 500 VUs
- [ ] `loadtest/qr-checkin.js` passes at 100 VUs × 2 min
- [ ] Chaos test: kill one API pod during purchase load — no double-debits
- [ ] Failover drill: simulate Supabase unreachable — app degrades to offline cache

## On-site
- [ ] Ops laptops with scanner role pre-provisioned (`admin_roles` = moderator)
- [ ] BLE beacons deployed at halls A/B/Main, mapped to `pois.geom`
- [ ] QR check-in kiosks tested at each entry
- [ ] Venue Wi-Fi: Eduroam + COP17-Guest SSID, captive portal disabled for app domains
- [ ] Offline-mode test: airplane mode → app still shows cached programme + digital ID

## Go/No-go meeting
- [ ] Apr 5, 2026 — all sections signed by PM, Eng lead, Security lead, Ops lead
