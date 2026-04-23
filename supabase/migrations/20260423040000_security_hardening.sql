-- Security hardening: close 5 vulnerabilities found in v1 RLS audit.
-- Each section explains the attack scenario it blocks.

-- ============================================================
-- #1  Tier self-escalation via profiles UPDATE
-- ============================================================
-- Attack: authenticated user calls
--   update profiles set tier='vip' where id = auth.uid();
-- Original policy `profiles_self_update` allowed ALL columns on own row.
-- Mitigation: BEFORE UPDATE trigger clamps tier + accreditation_id back
-- to the prior value unless the caller is admin.

create or replace function public.profile_update_guard()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then
    new.tier := old.tier;
    new.accreditation_id := old.accreditation_id;
  end if;
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists profile_update_guard on public.profiles;
create trigger profile_update_guard
  before update on public.profiles
  for each row execute function public.profile_update_guard();

-- ============================================================
-- #2  Attendance fraud via self-set status='attended'
-- ============================================================
-- Attack: user inserts
--   attendance(session_id, status='attended', checked_in_at=now())
-- bypassing the QR scanner. Original `attendance_own` ALL policy allowed it.
-- Mitigation: trigger clamps privileged fields on non-admin writes.

create or replace function public.attendance_guard()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then
    if new.status = 'attended' then new.status := 'going'; end if;
    new.checked_in_at := null;
    new.qr_hash := null;
  end if;
  return new;
end $$;

drop trigger if exists attendance_guard on public.attendance;
create trigger attendance_guard
  before insert or update on public.attendance
  for each row execute function public.attendance_guard();

-- ============================================================
-- #3  B2B self-approval
-- ============================================================
-- Attack: user inserts / updates their own meeting with status='approved'.
-- Original `b2b_own` policy allowed it.
-- Mitigation: trigger forces status to 'pending' on non-admin inserts and
-- only allows non-admin updates to set status='cancelled'.

create or replace function public.b2b_meeting_guard()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if public.is_admin() then return new; end if;
  if tg_op = 'INSERT' then
    new.status := 'pending';
  elsif tg_op = 'UPDATE' then
    -- non-admin can only cancel; other status changes are reverted.
    if new.status <> old.status and new.status <> 'cancelled' then
      new.status := old.status;
    end if;
  end if;
  return new;
end $$;

drop trigger if exists b2b_meeting_guard on public.b2b_meetings;
create trigger b2b_meeting_guard
  before insert or update on public.b2b_meetings
  for each row execute function public.b2b_meeting_guard();

-- ============================================================
-- #4  SOS insert broken by admin-only policy on alerts_incidents
-- ============================================================
-- Mobile help page _sendLocationSos inserts a 'critical' alert; current
-- policy blocks non-admins. Split admin-only into per-command policies
-- so any authenticated user may INSERT, but only admin may SELECT/UPDATE.

drop policy if exists "alerts_admin" on public.alerts_incidents;
create policy "alerts_user_insert"   on public.alerts_incidents for insert
  with check (auth.uid() is not null);
create policy "alerts_admin_select"  on public.alerts_incidents for select using (public.is_admin());
create policy "alerts_admin_update"  on public.alerts_incidents for update using (public.is_admin());
create policy "alerts_admin_delete"  on public.alerts_incidents for delete using (public.is_admin());

-- ============================================================
-- #5  Wallet RPCs callable by any authenticated user
-- ============================================================
-- Attack: authenticated user calls
--   select rpc_wallet_debit(p_user_id='<victim>', p_amount=...)
-- draining another user's wallet. SECURITY DEFINER bypasses RLS so the
-- only protection is the GRANT list.
-- Mitigation: revoke EXECUTE from authenticated + anon. Only service_role
-- (NestJS BFF) may call. Clients must go through /wallet/purchase.

revoke execute on function public.rpc_wallet_debit(uuid, bigint, text, txn_kind) from public, anon, authenticated;
revoke execute on function public.rpc_wallet_credit(uuid, bigint, text, text, txn_kind) from public, anon, authenticated;

-- ============================================================
-- Defense in depth: set explicit search_path on remaining SECURITY DEFINER
-- functions (handle_new_user and ensure_wallet already had it).
-- ============================================================
alter function public.handle_new_user() set search_path = public;
alter function public.ensure_wallet() set search_path = public;
