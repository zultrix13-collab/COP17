# ADR 0002 — Stack: Flutter + React + NestJS + Postgres

## Status
Accepted — 2026-04-23

## Context
COP17 needs cross-platform mobile (iOS+Android), a rich admin web, and a backend that supports RBAC, i18n (MN/EN), offline-capable clients, and PostGIS/pgvector.

## Decision
- **Mobile:** Flutter 3.24 (single codebase, strong perf, first-class offline via Drift).
- **Admin web:** React + Vite + TypeScript + TanStack Query/Table + Tailwind.
- **Backend:** NestJS (TS) — shares types with admin web via OpenAPI codegen. Monorepo via pnpm.
- **DB:** PostgreSQL 16 + PostGIS (maps) + pgvector (RAG) + Redis (cache, rate-limit) + MinIO/S3 + Meilisearch.
- **Infra:** Docker Compose in dev, Kubernetes (or Fly.io) in prod. GitHub Actions CI.

## Alternatives considered
- React Native + Expo — Flutter chosen for offline/perf + indoor map canvas freedom.
- FastAPI — deferred: NestJS keeps one TS monorepo; Python spike only for RAG service.
- MongoDB — relational shape + PostGIS + pgvector win on Postgres.

## Consequences
- Single `pnpm install` covers API + web. Flutter is a separate toolchain.
- OpenAPI is the contract — generated types go to `packages/shared-types` and consumed by both sides.
