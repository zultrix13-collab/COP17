# COP17 — UNCCD COP17 Ulaanbaatar 2026

Mobile app (Flutter) + Admin back office (React) + Backend API (NestJS BFF) for the
17th UNCCD Conference of the Parties.

**Event:** August 17–28, 2026 · Ulaanbaatar, Mongolia
**Venues:** State Palace (Төрийн ордон) — plenary · Exhibition Center (Үзэсгэлэнгийн төв) — technical summits

Backed by **Supabase** (Postgres + PostGIS + pgvector + Auth + Storage + Realtime).

## Repo layout

```
apps/
  api/          NestJS BFF (QR HMAC, QPay webhook, push, RAG endpoint)
  admin-web/    React + Vite admin SPA
  mobile/       Flutter app (iOS + Android)
packages/
  design-tokens/   Shared color/spacing tokens (JSON + Dart)
  shared-types/    Generated types from OpenAPI
supabase/
  config.toml      Supabase CLI config
  migrations/      SQL migrations (schema + RLS)
  seed.sql         Dev seed
  templates/       Auth email templates (OTP)
infra/
  docker/          Redis + Meilisearch (Supabase CLI brings Postgres)
  k8s/             Production manifests
docs/              OpenAPI, ADRs (0001–0003), runbook
```

## Quick start

**Prerequisites:** [Supabase CLI](https://supabase.com/docs/guides/cli), Node 20+, pnpm 9, Docker, Flutter 3.24.

```bash
cp .env.example .env

# 1. Start Supabase (Postgres + Auth + Studio + Realtime + Storage)
supabase start
#   → prints URL, anon key, service_role key → copy into .env

# 2. Aux services
pnpm db:up       # Redis + Meilisearch

# 3. Install + run
pnpm install
pnpm dev:api     # API on :3000   (docs at /docs)
pnpm dev:admin   # Admin on :5173

# 4. Mobile
cd apps/mobile && flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=http://localhost:54321 \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

## Architecture at a glance

- **Supabase** is the source of truth (DB, Auth, Storage, Realtime). RLS policies enforce tier-based access at the DB layer.
- **NestJS BFF** owns server-only logic that cannot live in the client: QR HMAC, QPay webhook, push notification send, RAG chatbot, bulk tier jobs. Authenticated with the Supabase `service_role` key.
- **Clients** (Flutter + React admin) talk to Supabase directly for DB reads/writes (RLS-protected) and to NestJS for privileged endpoints.
- **Firebase** is used only for **Cloud Messaging** (push delivery on iOS/Android).

See ADRs:
- [0002 stack choices](docs/adr/0002-stack-choices.md)
- [0003 Supabase as DB + auth](docs/adr/0003-supabase-as-db-and-auth.md)

Plan: `/Users/huhenege/.claude/plans/wireframe-fluttering-prism.md`.
