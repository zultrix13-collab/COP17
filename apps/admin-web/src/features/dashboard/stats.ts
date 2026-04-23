import { supabase } from '../../lib/supabase';

export interface DashboardStats {
  totalUsers: number;
  attendanceToday: number;
  activeSessions: number;
  pendingTier: number;
  pendingMeetings: number;
  openAlerts: number;
  topSessions: { id: string; title_mn: string; hall: string; count: number }[];
}

export async function dashboardStats(): Promise<DashboardStats> {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);
  const now = new Date().toISOString();

  const [usersCnt, attCnt, activeCnt, mtgCnt, alertCnt, topRaw] = await Promise.all([
    supabase.from('profiles').select('*', { count: 'exact', head: true }),
    supabase.from('attendance').select('*', { count: 'exact', head: true })
      .gte('checked_in_at', today.toISOString()).lt('checked_in_at', tomorrow.toISOString()),
    supabase.from('sessions').select('*', { count: 'exact', head: true })
      .lte('starts_at', now).gte('ends_at', now),
    supabase.from('b2b_meetings').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
    supabase.from('alerts_incidents').select('*', { count: 'exact', head: true }).eq('status', 'open'),
    // Top 5 sessions by Going count today.
    supabase.from('attendance')
      .select('session:sessions(id, title_mn, hall, starts_at)')
      .eq('status', 'going')
      .gte('session.starts_at', today.toISOString()),
  ]);

  const counts = new Map<string, { id: string; title_mn: string; hall: string; count: number }>();
  for (const row of (topRaw.data ?? []) as any[]) {
    const s = row.session;
    if (!s) continue;
    const entry = counts.get(s.id) ?? { id: s.id, title_mn: s.title_mn, hall: s.hall, count: 0 };
    entry.count += 1;
    counts.set(s.id, entry);
  }
  const topSessions = [...counts.values()].sort((a, b) => b.count - a.count).slice(0, 5);

  return {
    totalUsers: usersCnt.count ?? 0,
    attendanceToday: attCnt.count ?? 0,
    activeSessions: activeCnt.count ?? 0,
    pendingTier: 0, // TODO wire accreditation upgrade requests
    pendingMeetings: mtgCnt.count ?? 0,
    openAlerts: alertCnt.count ?? 0,
    topSessions,
  };
}
