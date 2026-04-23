import { useQuery } from '@tanstack/react-query';
import { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { supabase } from '../../lib/supabase';
import { tierCounts } from '../users/api';
import { TIER_META, type Tier } from '../users/types';
import { ReindexButton } from '../ai/ReindexButton';
import { dashboardStats } from './stats';

export function DashboardPage() {
  const { t } = useTranslation();
  const counts = useQuery({ queryKey: ['tier-counts'], queryFn: tierCounts, refetchInterval: 30_000 });
  const stats = useQuery({ queryKey: ['dashboard'], queryFn: dashboardStats, refetchInterval: 15_000 });

  // Realtime: push an invalidate on any attendance INSERT so "today's check-ins"
  // updates without waiting for the 15s poll.
  useEffect(() => {
    const ch = supabase
      .channel('dash-attendance')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'attendance' }, () => {
        stats.refetch();
      })
      .subscribe();
    return () => { void ch.unsubscribe(); };
  }, [stats]);

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <h1 className="text-xl font-bold">{t('nav.dashboard')}</h1>
        <ReindexButton />
      </div>

      <div className="grid grid-cols-3 gap-4 mb-6">
        <StatCard label="Оролцогч нийт" value={stats.data?.totalUsers ?? '…'} color="#111" />
        <StatCard label="Идэвхтэй session" value={stats.data?.activeSessions ?? '…'} color={TIER_META.blue.color} />
        <StatCard label="Өнөөдөр ирсэн" value={stats.data?.attendanceToday ?? '…'} color={TIER_META.green.color} />
      </div>

      <div className="grid grid-cols-3 gap-4 mb-6">
        <StatCard label="⏳ Meeting хүсэлт" value={stats.data?.pendingMeetings ?? '…'} color={TIER_META.exhibitor.color} />
        <StatCard label="🔴 Alerts" value={stats.data?.openAlerts ?? '…'} color="#DC2626" />
        <StatCard label="💎 VIP" value={counts.data?.vip ?? '…'} color={TIER_META.vip.color} />
      </div>

      <div className="grid grid-cols-5 gap-3 mb-6">
        {(Object.keys(TIER_META) as Tier[]).map((tier) => (
          <StatCard
            key={tier}
            label={`${TIER_META[tier].emoji} ${TIER_META[tier].label}`}
            value={counts.data?.[tier] ?? '…'}
            color={TIER_META[tier].color}
          />
        ))}
      </div>

      <div className="bg-white rounded-lg border p-4">
        <h2 className="text-sm font-semibold uppercase text-gray-500 mb-3">🔥 Хамгийн их хүн (өнөөдөр)</h2>
        {stats.data?.topSessions.length === 0 && (
          <div className="text-xs text-gray-400">Өгөгдөл алга</div>
        )}
        {stats.data?.topSessions.map((s) => (
          <div key={s.id} className="flex justify-between border-b last:border-b-0 py-2 text-sm">
            <span>
              <span className="font-medium">{s.title_mn}</span>
              <span className="text-gray-500"> · {s.hall}</span>
            </span>
            <span className="font-bold">{s.count}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function StatCard({ label, value, color }: { label: string; value: number | string; color: string }) {
  return (
    <div className="rounded-lg bg-white p-4 border">
      <div className="text-xs text-gray-500">{label}</div>
      <div className="text-2xl font-bold" style={{ color }}>{value}</div>
    </div>
  );
}
