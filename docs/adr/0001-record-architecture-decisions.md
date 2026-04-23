# ADR 0001 — Record architecture decisions

## Status
Accepted — 2026-04-23

## Context
We need to capture non-trivial architectural decisions so future contributors understand the why.

## Decision
Use lightweight ADRs (Nygard format) in `docs/adr/NNNN-title.md`. One decision per file. Immutable after "Accepted".

## Consequences
- Low ceremony, diff-friendly.
- Supersede via new ADR, never edit an accepted one.
