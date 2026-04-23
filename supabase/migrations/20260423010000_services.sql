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
