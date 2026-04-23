-- ===
-- 20260423000000_init.sql
-- ===
-- COP17 initial schema (Supabase)
create extension if not exists "pgcrypto";
create extension if not exists "citext";
create extension if not exists "postgis";
create extension if not exists "vector";

-- ────────────────────────────────────────────────────────────
-- Enums
-- ────────────────────────────────────────────────────────────
create type user_tier as enum ('green', 'blue', 'vip', 'exhibitor', 'press');
create type user_locale as enum ('mn', 'en');
create type attendance_status as enum ('going', 'waitlist', 'attended', 'cancelled');
create type txn_kind as enum ('topup', 'purchase', 'refund', 'transfer');
create type meeting_status as enum ('pending', 'approved', 'rejected', 'cancelled', 'completed');
create type admin_role as enum ('super_admin', 'ops_admin', 'content_editor', 'finance', 'moderator');

-- ────────────────────────────────────────────────────────────
-- Profile (extends auth.users)
-- ────────────────────────────────────────────────────────────
create table public.profiles (
  id               uuid primary key references auth.users(id) on delete cascade,
  email            citext unique not null,
  name             text not null default '',
  locale           user_locale not null default 'mn',
  tier             user_tier   not null default 'green',
  accreditation_id text unique,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create index on public.profiles (tier);

-- Auto-create a profile when auth.users is inserted
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Admin roles (separate table for RBAC beyond tier)
create table public.admin_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role    admin_role not null,
  created_at timestamptz not null default now()
);

-- Helper: is current user an admin?
-- SECURITY DEFINER so it bypasses RLS on admin_roles — otherwise the
-- admin_roles policy calls is_admin() which reads admin_roles → infinite
-- recursion → stack depth exceeded on any admin-gated write.
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admin_roles where user_id = auth.uid());
$$;

-- Accreditation whitelist — only registered delegates may sign up
create table public.accreditation_whitelist (
  email            citext primary key,
  name             text,
  initial_tier     user_tier not null default 'green',
  accreditation_id text unique,
  created_at       timestamptz not null default now()
);
alter table public.accreditation_whitelist enable row level security;
create policy "accred_admin" on public.accreditation_whitelist
  for all using (public.is_admin()) with check (public.is_admin());

-- ────────────────────────────────────────────────────────────
-- Tier audit log
-- ────────────────────────────────────────────────────────────
create table public.tier_changes (
  id         bigserial primary key,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  from_tier  user_tier,
  to_tier    user_tier not null,
  admin_id   uuid references auth.users(id),
  reason     text,
  created_at timestamptz not null default now()
);
create index on public.tier_changes (user_id);

-- ────────────────────────────────────────────────────────────
-- Programme
-- ────────────────────────────────────────────────────────────
create table public.speakers (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  org        text,
  bio_mn     text,
  bio_en     text,
  photo_url  text
);

create table public.sessions (
  id             uuid primary key default gen_random_uuid(),
  title_mn       text not null,
  title_en       text not null,
  hall           text not null,
  starts_at      timestamptz not null,
  ends_at        timestamptz not null,
  capacity       integer not null default 0,
  access_tiers   user_tier[] not null default array['green']::user_tier[],
  description_mn text,
  description_en text
);
create index on public.sessions (starts_at);

create table public.session_speakers (
  session_id uuid references public.sessions(id) on delete cascade,
  speaker_id uuid references public.speakers(id) on delete cascade,
  primary key (session_id, speaker_id)
);

create table public.attendance (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references public.profiles(id) on delete cascade,
  session_id    uuid not null references public.sessions(id) on delete cascade,
  status        attendance_status not null default 'going',
  qr_hash       text,
  checked_in_at timestamptz,
  created_at    timestamptz not null default now(),
  unique (user_id, session_id)
);

create table public.session_feedback (
  user_id    uuid not null references public.profiles(id) on delete cascade,
  session_id uuid not null references public.sessions(id) on delete cascade,
  rating     smallint not null check (rating between 1 and 5),
  comment    text,
  created_at timestamptz not null default now(),
  primary key (user_id, session_id)
);

-- ────────────────────────────────────────────────────────────
-- Wallet
-- ────────────────────────────────────────────────────────────
create table public.wallets (
  user_id    uuid primary key references public.profiles(id) on delete cascade,
  balance    bigint not null default 0,
  currency   text not null default 'MNT',
  updated_at timestamptz not null default now()
);

create table public.wallet_txns (
  id         bigserial primary key,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  kind       txn_kind not null,
  amount     bigint not null,
  reference  text,
  provider   text,
  created_at timestamptz not null default now()
);
create index on public.wallet_txns (user_id, created_at desc);

-- ────────────────────────────────────────────────────────────
-- B2B meetings
-- ────────────────────────────────────────────────────────────
create table public.b2b_meetings (
  id           uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id),
  exhibitor_id uuid not null references public.profiles(id),
  starts_at    timestamptz not null,
  ends_at      timestamptz not null,
  status       meeting_status not null default 'pending',
  purpose      text,
  created_at   timestamptz not null default now()
);

-- ────────────────────────────────────────────────────────────
-- Lost & Found, Notifications, Alerts, POIs, Content, RAG
-- ────────────────────────────────────────────────────────────
create table public.lost_found (
  id          uuid primary key default gen_random_uuid(),
  kind        text not null check (kind in ('lost', 'found', 'claimed')),
  title       text not null,
  description text,
  photo_url   text,
  reporter_id uuid references public.profiles(id),
  created_at  timestamptz not null default now()
);

create table public.notifications (
  id           bigserial primary key,
  user_id      uuid references public.profiles(id) on delete cascade,
  topic        text not null,
  locale       user_locale not null,
  title        text not null,
  body         text not null,
  delivered_at timestamptz,
  created_at   timestamptz not null default now()
);

-- Device tokens for FCM/APNs push delivery. Multiple devices per user.
create table public.device_tokens (
  id         bigserial primary key,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  platform   text not null check (platform in ('ios', 'android', 'web')),
  token      text not null,
  last_seen  timestamptz not null default now(),
  unique (user_id, token)
);
create index on public.device_tokens (user_id);

create table public.alerts_incidents (
  id          bigserial primary key,
  severity    text not null check (severity in ('info', 'warn', 'critical')),
  title       text not null,
  body        text,
  status      text not null default 'open',
  resolved_at timestamptz,
  created_at  timestamptz not null default now()
);

create table public.pois (
  id      uuid primary key default gen_random_uuid(),
  name_mn text not null,
  name_en text not null,
  kind    text not null,
  floor   integer,
  geom    geography(Point, 4326)
);
create index on public.pois using gist (geom);

create table public.sponsors (
  id       uuid primary key default gen_random_uuid(),
  name     text not null,
  tier     text not null,
  logo_url text,
  booth    text
);

create table public.faq (
  id          uuid primary key default gen_random_uuid(),
  question_mn text not null,
  question_en text not null,
  answer_mn   text not null,
  answer_en   text not null,
  ordering    integer not null default 0
);

create table public.announcements (
  id           uuid primary key default gen_random_uuid(),
  title_mn     text not null,
  title_en     text not null,
  body_mn      text,
  body_en      text,
  severity     text not null default 'info',
  published_at timestamptz,
  created_at   timestamptz not null default now()
);

create table public.flights (
  id        uuid primary key default gen_random_uuid(),
  flight_no text not null,
  origin    text,
  scheduled timestamptz,
  actual    timestamptz,
  status    text
);

create table public.rag_chunks (
  id        bigserial primary key,
  source    text not null,
  source_id text not null,
  locale    user_locale not null,
  content   text not null,
  embedding vector(1536)
);
create index on public.rag_chunks using ivfflat (embedding vector_cosine_ops);

-- ────────────────────────────────────────────────────────────
-- Row-Level Security
-- ────────────────────────────────────────────────────────────
alter table public.profiles       enable row level security;
alter table public.admin_roles    enable row level security;
alter table public.tier_changes   enable row level security;
alter table public.sessions       enable row level security;
alter table public.speakers       enable row level security;
alter table public.attendance     enable row level security;
alter table public.wallets        enable row level security;
alter table public.wallet_txns    enable row level security;
alter table public.b2b_meetings   enable row level security;
alter table public.lost_found     enable row level security;
alter table public.notifications  enable row level security;
alter table public.device_tokens  enable row level security;
create policy "device_tokens_own" on public.device_tokens for all
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());
alter table public.alerts_incidents enable row level security;
alter table public.pois           enable row level security;
alter table public.sponsors       enable row level security;
alter table public.faq            enable row level security;
alter table public.announcements  enable row level security;
alter table public.flights        enable row level security;
alter table public.rag_chunks     enable row level security;

-- Profiles: user reads/updates own; admins read all
create policy "profiles_self_read"   on public.profiles for select using (auth.uid() = id or public.is_admin());
create policy "profiles_self_update" on public.profiles for update using (auth.uid() = id);
create policy "profiles_admin_all"   on public.profiles for all using (public.is_admin()) with check (public.is_admin());

-- admin_roles: only admins
create policy "admin_roles_admin" on public.admin_roles for all using (public.is_admin()) with check (public.is_admin());

-- tier_changes: user sees own, admin sees all; only admin writes
create policy "tier_changes_read"       on public.tier_changes for select using (user_id = auth.uid() or public.is_admin());
create policy "tier_changes_admin_write" on public.tier_changes for insert with check (public.is_admin());

-- Public content: everyone authenticated may read
create policy "sessions_read"      on public.sessions      for select using (auth.uid() is not null);
create policy "speakers_read"      on public.speakers      for select using (auth.uid() is not null);
create policy "sponsors_read"      on public.sponsors      for select using (auth.uid() is not null);
create policy "faq_read"           on public.faq           for select using (auth.uid() is not null);
create policy "announcements_read" on public.announcements for select using (auth.uid() is not null);
create policy "flights_read"       on public.flights       for select using (auth.uid() is not null);
create policy "pois_read"          on public.pois          for select using (auth.uid() is not null);
-- Admin-only writes
create policy "sessions_admin_write"      on public.sessions      for all using (public.is_admin()) with check (public.is_admin());
create policy "speakers_admin_write"      on public.speakers      for all using (public.is_admin()) with check (public.is_admin());
create policy "sponsors_admin_write"      on public.sponsors      for all using (public.is_admin()) with check (public.is_admin());
create policy "faq_admin_write"           on public.faq           for all using (public.is_admin()) with check (public.is_admin());
create policy "announcements_admin_write" on public.announcements for all using (public.is_admin()) with check (public.is_admin());
create policy "flights_admin_write"       on public.flights       for all using (public.is_admin()) with check (public.is_admin());
create policy "pois_admin_write"          on public.pois          for all using (public.is_admin()) with check (public.is_admin());

-- Attendance: user manages own; admin all
create policy "attendance_own" on public.attendance for all
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());

alter table public.session_feedback enable row level security;
create policy "feedback_own" on public.session_feedback for all
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid());

-- Wallet: user reads own, writes go through service_role (NestJS BFF)
create policy "wallet_self_read"      on public.wallets    for select using (user_id = auth.uid() or public.is_admin());
create policy "wallet_txns_self_read" on public.wallet_txns for select using (user_id = auth.uid() or public.is_admin());

-- B2B meetings: parties + admin
create policy "b2b_own" on public.b2b_meetings for all
  using (requester_id = auth.uid() or exhibitor_id = auth.uid() or public.is_admin())
  with check (requester_id = auth.uid() or exhibitor_id = auth.uid() or public.is_admin());

-- Lost & found: all authenticated read; own or admin write
create policy "lf_read"  on public.lost_found for select using (auth.uid() is not null);
create policy "lf_write" on public.lost_found for insert with check (reporter_id = auth.uid() or public.is_admin());
create policy "lf_admin" on public.lost_found for update using (public.is_admin());

-- Notifications: user reads own
create policy "notif_own" on public.notifications for select using (user_id = auth.uid() or public.is_admin());

-- Alerts: admin only
create policy "alerts_admin" on public.alerts_incidents for all using (public.is_admin()) with check (public.is_admin());

-- RAG: authenticated read; admin writes (re-index job via service_role)
create policy "rag_read" on public.rag_chunks for select using (auth.uid() is not null);

-- ===
-- 20260423010000_services.sql
-- ===
-- Services module: catalog, orders, QPay invoices, transport, wallet RPC.

create type product_kind as enum ('shop', 'food', 'esim');
create type order_status as enum ('pending', 'paid', 'fulfilled', 'cancelled', 'refunded');
create type invoice_status as enum ('pending', 'paid', 'expired', 'failed');
create type transport_kind as enum ('shuttle', 'taxi', 'airport');
create type transport_status as enum ('requested', 'assigned', 'completed', 'cancelled');

-- ────────────────────────────────────────────────────────────
-- Catalog
-- ────────────────────────────────────────────────────────────
create table public.products (
  id        uuid primary key default gen_random_uuid(),
  kind      product_kind not null,
  vendor    text,
  name_mn   text not null,
  name_en   text not null,
  description_mn text,
  description_en text,
  price     bigint not null check (price >= 0),
  image_url text,
  stock     integer,         -- null = unlimited
  active    boolean not null default true,
  created_at timestamptz not null default now()
);
create index on public.products (kind) where active;

create table public.orders (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  status     order_status not null default 'pending',
  total      bigint not null,
  currency   text not null default 'MNT',
  created_at timestamptz not null default now(),
  paid_at    timestamptz
);
create index on public.orders (user_id, created_at desc);

create table public.order_items (
  id          bigserial primary key,
  order_id    uuid not null references public.orders(id) on delete cascade,
  product_id  uuid not null references public.products(id),
  quantity    integer not null check (quantity > 0),
  unit_price  bigint not null,
  name_snap   text not null
);

-- ────────────────────────────────────────────────────────────
-- QPay invoices (top-ups)
-- ────────────────────────────────────────────────────────────
create table public.qpay_invoices (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references public.profiles(id) on delete cascade,
  amount          bigint not null check (amount > 0),
  qpay_invoice_id text unique,
  qr_text         text,
  deep_link       text,
  status          invoice_status not null default 'pending',
  paid_at         timestamptz,
  expires_at      timestamptz not null,
  created_at      timestamptz not null default now()
);
create index on public.qpay_invoices (user_id, created_at desc);
create index on public.qpay_invoices (status) where status = 'pending';

-- ────────────────────────────────────────────────────────────
-- Transport
-- ────────────────────────────────────────────────────────────
create table public.transport_requests (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles(id) on delete cascade,
  kind        transport_kind not null,
  origin      text,
  destination text,
  scheduled   timestamptz,
  status      transport_status not null default 'requested',
  flight_no   text,
  notes       text,
  created_at  timestamptz not null default now()
);

-- ────────────────────────────────────────────────────────────
-- Wallet RPCs — atomic debit/credit via SELECT FOR UPDATE
-- ────────────────────────────────────────────────────────────

-- Ensure every profile has a wallet row on creation.
create or replace function public.ensure_wallet() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.wallets (user_id) values (new.id)
  on conflict (user_id) do nothing;
  return new;
end $$;
create trigger on_profile_created_wallet
  after insert on public.profiles
  for each row execute function public.ensure_wallet();

-- Debit. Called from service_role (API). Returns new balance.
create or replace function public.rpc_wallet_debit(
  p_user_id uuid,
  p_amount bigint,
  p_reference text,
  p_kind txn_kind default 'purchase'
) returns bigint
language plpgsql security definer set search_path = public as $$
declare
  v_balance bigint;
begin
  if p_amount <= 0 then
    raise exception 'amount must be positive';
  end if;

  select balance into v_balance
    from public.wallets where user_id = p_user_id for update;
  if v_balance is null then
    insert into public.wallets (user_id) values (p_user_id);
    v_balance := 0;
  end if;
  if v_balance < p_amount then
    raise exception 'insufficient funds' using errcode = 'P0001';
  end if;

  update public.wallets
    set balance = balance - p_amount, updated_at = now()
    where user_id = p_user_id
    returning balance into v_balance;

  insert into public.wallet_txns (user_id, kind, amount, reference)
    values (p_user_id, p_kind, -p_amount, p_reference);

  return v_balance;
end $$;

create or replace function public.rpc_wallet_credit(
  p_user_id uuid,
  p_amount bigint,
  p_reference text,
  p_provider text default null,
  p_kind txn_kind default 'topup'
) returns bigint
language plpgsql security definer set search_path = public as $$
declare
  v_balance bigint;
begin
  if p_amount <= 0 then
    raise exception 'amount must be positive';
  end if;

  insert into public.wallets (user_id) values (p_user_id) on conflict do nothing;
  update public.wallets
    set balance = balance + p_amount, updated_at = now()
    where user_id = p_user_id
    returning balance into v_balance;

  insert into public.wallet_txns (user_id, kind, amount, reference, provider)
    values (p_user_id, p_kind, p_amount, p_reference, p_provider);

  return v_balance;
end $$;

-- ────────────────────────────────────────────────────────────
-- RLS
-- ────────────────────────────────────────────────────────────
alter table public.products           enable row level security;
alter table public.orders             enable row level security;
alter table public.order_items        enable row level security;
alter table public.qpay_invoices      enable row level security;
alter table public.transport_requests enable row level security;

-- Catalog: everyone reads active products; admin writes.
create policy "products_read" on public.products for select using (active or public.is_admin());
create policy "products_admin_write" on public.products for all
  using (public.is_admin()) with check (public.is_admin());

-- Orders / items / invoices / transport: user sees own, admin all.
-- Writes go through RPC + service_role, so client-side insert is disallowed.
create policy "orders_read" on public.orders for select
  using (user_id = auth.uid() or public.is_admin());
create policy "order_items_read" on public.order_items for select
  using (exists (select 1 from public.orders o
                 where o.id = order_id and (o.user_id = auth.uid() or public.is_admin())));
create policy "qpay_read" on public.qpay_invoices for select
  using (user_id = auth.uid() or public.is_admin());
create policy "transport_own" on public.transport_requests for all
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());

-- ===
-- 20260423020000_ai_rpc.sql
-- ===
-- pgvector kNN helper for RAG retrieval.
create or replace function public.match_rag_chunks(
  p_query vector(1536),
  p_locale user_locale,
  p_k int default 6
) returns table (
  id bigint,
  source text,
  source_id text,
  content text,
  similarity float
)
language sql stable as $$
  select
    id,
    source,
    source_id,
    content,
    1 - (embedding <=> p_query) as similarity
  from public.rag_chunks
  where locale = p_locale
  order by embedding <=> p_query
  limit p_k;
$$;

-- ===
-- 20260423030000_b2b.sql
-- ===
-- Exhibitor profile extension (1:1 with profiles where tier='exhibitor').
create table public.exhibitor_profiles (
  user_id     uuid primary key references public.profiles(id) on delete cascade,
  company     text not null,
  sector      text,
  country     text,
  booth       text,
  website     text,
  logo_url    text,
  description_mn text,
  description_en text,
  created_at  timestamptz not null default now()
);

alter table public.exhibitor_profiles enable row level security;
create policy "exhibitor_read" on public.exhibitor_profiles for select
  using (auth.uid() is not null);
create policy "exhibitor_self_write" on public.exhibitor_profiles for all
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());

-- Convenience view: exhibitor + base profile, only for active exhibitor tier.
create or replace view public.exhibitors_view as
  select p.id as user_id, p.name as contact_name, p.email,
         e.company, e.sector, e.country, e.booth, e.website, e.logo_url,
         e.description_mn, e.description_en
  from public.profiles p
  join public.exhibitor_profiles e on e.user_id = p.id
  where p.tier = 'exhibitor';

