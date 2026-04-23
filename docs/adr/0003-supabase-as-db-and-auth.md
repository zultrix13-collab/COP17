# ADR 0003 — Supabase as DB, Auth, Storage, Realtime

## Status
Accepted — 2026-04-23 (supersedes the raw Postgres/Redis/MinIO setup in ADR-0002)

## Context
Wireframe-аас гарсан шаардлагууд: PostGIS газрын зураг, pgvector RAG, tier-based RBAC, audit log, real-time dashboard, heavy admin CRUD, offline-first mobile, UN хурлын өгөгдлийн эзэмшил.

Firestore vs. Supabase-ийн харьцуулалт хийсний үндсэн дээр Supabase-ийг сонгов (Postgres native, RLS, PostGIS+pgvector).

## Decision
- **Supabase**-ийг дараах үүрэгт ашиглана:
  - **Postgres** (PostGIS + pgvector + CITEXT) — нэг DB
  - **Auth** — email OTP (нэмэлт custom OTP service бичих шаардлагагүй)
  - **Storage** — media, press kit, lost&found photos (MinIO-г солино)
  - **Realtime** — admin dashboard live stream
  - **Edge Functions** — legacy webhook-ууд
- **NestJS API** үлдэнэ — privileged server-side BFF:
  - QR HMAC issue/verify
  - QPay webhook, wallet transaction integrity
  - Push notification send (FCM admin SDK)
  - RAG endpoint (pgvector хайлт + Claude/OpenAI)
  - Bulk tier upgrade job queue
  - Supabase-т `service_role` key-ээр хандана.
- **Client (mobile + admin web)** — Supabase JS/Flutter SDK-аар DB + Auth + Storage-т шууд хандана. RLS policy хамгаална.
- **Firebase** — зөвхөн **Cloud Messaging (FCM/APNs)** push notification-д үлдэнэ.
- **Local dev** — `supabase` CLI (Postgres + Studio + Auth + Realtime + Storage-ийг docker-оор). Redis + Meilisearch-ийг docker-compose-д хадгална (push job queue, full-text search).

## Consequences
- `infra/migrations/*.sql` → `supabase/migrations/<timestamp>_*.sql` руу шилжинэ (Supabase CLI форматтай).
- Custom OTP service устгах боломжтой → `AuthService.requestOtp/verifyOtp` нь Supabase Admin SDK-г дуудна.
- RLS policy-г migration-д тодорхойлно — tier шалгалт DB давхарга дээр гарна.
- `auth.users` (Supabase built-in) ↔ `public.users` profile хүснэгт FK.
- Self-host боломж — `supabase selfhosted` Улаанбаатарт deploy хийж болно.

## Alternatives rejected
- **Firestore** — NoSQL join хязгаар, PostGIS/pgvector байхгүй, real-time read cost.
- **Hasura + raw Postgres** — GraphQL схем, OpenAPI-тай нийцэхгүй.
- **PostgREST гар суурилуулсан** — Supabase-ийн сарын нэмэлт үнэ багатай, CLI, Studio, Auth багц бэлэн.
