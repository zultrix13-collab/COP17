import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { downloadCsv } from './csv';
import { TIER_META, type Tier } from '../users/types';

interface AttendanceBySession {
  session_id: string;
  title_mn: string;
  hall: string;
  starts_at: string;
  going: number;
  attended: number;
  waitlist: number;
}

async function attendanceReport(): Promise<AttendanceBySession[]> {
  // Join + aggregate manually because PostgREST doesn't group.
  const { data: sessions, error: sErr } = await supabase
    .from('sessions')
    .select('id, title_mn, hall, starts_at');
  if (sErr) throw sErr;

  const { data: att, error: aErr } = await supabase
    .from('attendance')
    .select('session_id, status');
  if (aErr) throw aErr;

  const tally = new Map<string, AttendanceBySession>();
  for (const s of sessions ?? []) {
    tally.set(s.id, {
      session_id: s.id,
      title_mn: s.title_mn,
      hall: s.hall,
      starts_at: s.starts_at,
      going: 0,
      attended: 0,
      waitlist: 0,
    });
  }
  for (const row of (att ?? []) as { session_id: string; status: string }[]) {
    const t = tally.get(row.session_id);
    if (!t) continue;
    if (row.status === 'going')    t.going += 1;
    if (row.status === 'attended') t.attended += 1;
    if (row.status === 'waitlist') t.waitlist += 1;
  }
  return [...tally.values()].sort((a, b) => a.starts_at.localeCompare(b.starts_at));
}

async function tierReport(): Promise<{ tier: Tier; count: number }[]> {
  const { data, error } = await supabase.from('profiles').select('tier');
  if (error) throw error;
  const counts = new Map<Tier, number>();
  for (const row of data as { tier: Tier }[]) {
    counts.set(row.tier, (counts.get(row.tier) ?? 0) + 1);
  }
  return (Object.keys(TIER_META) as Tier[]).map((t) => ({ tier: t, count: counts.get(t) ?? 0 }));
}

export function ReportsPage() {
  const att = useQuery({ queryKey: ['report-attendance'], queryFn: attendanceReport });
  const tier = useQuery({ queryKey: ['report-tier'], queryFn: tierReport });

  return (
    <div>
      <h1 className="text-xl font-bold mb-4">Тайлан / Export</h1>

      <section className="mb-6">
        <div className="flex justify-between items-center mb-2">
          <h2 className="text-sm font-semibold uppercase text-gray-500">Ирц · Session</h2>
          <button
            className="border rounded px-2 py-1 text-xs"
            disabled={!att.data}
            onClick={() => downloadCsv('attendance.csv', att.data ?? [])}
          >
            ⬇ CSV
          </button>
        </div>
        <div className="bg-white border rounded overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 text-left text-xs uppercase text-gray-500">
              <tr>
                <th className="px-3 py-2">Session</th>
                <th className="px-3 py-2">Hall</th>
                <th className="px-3 py-2">Эхлэх</th>
                <th className="px-3 py-2 text-right">Going</th>
                <th className="px-3 py-2 text-right">Attended</th>
                <th className="px-3 py-2 text-right">Waitlist</th>
              </tr>
            </thead>
            <tbody>
              {att.data?.map((r) => (
                <tr key={r.session_id} className="border-t">
                  <td className="px-3 py-2">{r.title_mn}</td>
                  <td className="px-3 py-2 text-gray-600">{r.hall}</td>
                  <td className="px-3 py-2 text-gray-600">{new Date(r.starts_at).toLocaleString('mn-MN')}</td>
                  <td className="px-3 py-2 text-right">{r.going}</td>
                  <td className="px-3 py-2 text-right font-semibold">{r.attended}</td>
                  <td className="px-3 py-2 text-right text-yellow-600">{r.waitlist}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <section>
        <div className="flex justify-between items-center mb-2">
          <h2 className="text-sm font-semibold uppercase text-gray-500">Tier distribution</h2>
          <button
            className="border rounded px-2 py-1 text-xs"
            disabled={!tier.data}
            onClick={() => downloadCsv('tiers.csv', tier.data ?? [])}
          >
            ⬇ CSV
          </button>
        </div>
        <div className="bg-white border rounded p-4">
          {tier.data?.map((r) => (
            <div key={r.tier} className="mb-2">
              <div className="flex justify-between text-sm mb-1">
                <span>{TIER_META[r.tier].emoji} {TIER_META[r.tier].label}</span>
                <span className="font-semibold">{r.count}</span>
              </div>
              <div className="h-2 bg-gray-200 rounded">
                <div
                  className="h-full rounded"
                  style={{
                    width: `${Math.min(100, (r.count / Math.max(1, tier.data!.reduce((s, x) => s + x.count, 0))) * 100)}%`,
                    background: TIER_META[r.tier].color,
                  }}
                />
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
