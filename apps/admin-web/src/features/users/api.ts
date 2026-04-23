import { supabase } from '../../lib/supabase';
import type { ProfileRow, Tier, TierChangeRow } from './types';

export async function listUsers(search: string, tier: Tier | 'all'): Promise<ProfileRow[]> {
  let q = supabase
    .from('profiles')
    .select('id, email, name, tier, locale, accreditation_id, created_at')
    .order('created_at', { ascending: false })
    .limit(200);
  if (tier !== 'all') q = q.eq('tier', tier);
  if (search.trim()) q = q.or(`email.ilike.%${search}%,name.ilike.%${search}%`);
  const { data, error } = await q;
  if (error) throw error;
  return data as ProfileRow[];
}

/**
 * Change a user's tier and write an audit entry.
 * RLS ensures only admins may execute both writes.
 */
export async function updateTier(
  userId: string,
  fromTier: Tier,
  toTier: Tier,
  reason: string,
): Promise<void> {
  if (fromTier === toTier) return;
  const adminId = (await supabase.auth.getUser()).data.user?.id ?? null;
  const { error: u } = await supabase.from('profiles').update({ tier: toTier }).eq('id', userId);
  if (u) throw u;
  const { error: l } = await supabase.from('tier_changes').insert({
    user_id: userId,
    from_tier: fromTier,
    to_tier: toTier,
    admin_id: adminId,
    reason,
  });
  if (l) throw l;
}

export async function tierAuditLog(userId: string): Promise<TierChangeRow[]> {
  const { data, error } = await supabase
    .from('tier_changes')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(50);
  if (error) throw error;
  return data as TierChangeRow[];
}

export async function tierCounts(): Promise<Record<Tier | 'total', number>> {
  const { data, error } = await supabase.from('profiles').select('tier');
  if (error) throw error;
  const out: Record<string, number> = { green: 0, blue: 0, vip: 0, exhibitor: 0, press: 0, total: 0 };
  for (const row of data as { tier: Tier }[]) {
    out[row.tier] = (out[row.tier] ?? 0) + 1;
    out.total += 1;
  }
  return out as Record<Tier | 'total', number>;
}
