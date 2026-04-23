import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { deleteSession, listSessions } from './api';
import type { SessionRow } from './types';
import { SessionEditModal } from './SessionEditModal';
import { TIER_META } from '../users/types';

export function ProgrammePage() {
  const { t } = useTranslation();
  const [editing, setEditing] = useState<SessionRow | 'new' | null>(null);
  const qc = useQueryClient();

  const sessions = useQuery({ queryKey: ['sessions'], queryFn: listSessions });
  const del = useMutation({
    mutationFn: (id: string) => deleteSession(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['sessions'] }),
  });

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-xl font-bold">{t('nav.programme')}</h1>
        <button className="bg-black text-white rounded px-3 py-1.5 text-sm"
          onClick={() => setEditing('new')}>+ Session</button>
      </div>

      <div className="bg-white rounded-lg border overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-gray-50 text-left text-xs uppercase text-gray-500">
            <tr>
              <th className="px-4 py-2">Огноо</th>
              <th className="px-4 py-2">Гарчиг</th>
              <th className="px-4 py-2">Танхим</th>
              <th className="px-4 py-2">Хүчин чадал</th>
              <th className="px-4 py-2">Эрх</th>
              <th className="px-4 py-2"></th>
            </tr>
          </thead>
          <tbody>
            {sessions.isLoading && <tr><td colSpan={6} className="p-6 text-center text-gray-400">…</td></tr>}
            {sessions.data?.map((s) => (
              <tr key={s.id} className="border-t hover:bg-gray-50">
                <td className="px-4 py-2 text-gray-600">{new Date(s.starts_at).toLocaleString('mn-MN', { dateStyle: 'short', timeStyle: 'short' })}</td>
                <td className="px-4 py-2">{s.title_mn}</td>
                <td className="px-4 py-2 text-gray-600">{s.hall}</td>
                <td className="px-4 py-2 text-gray-600">{s.capacity}</td>
                <td className="px-4 py-2">
                  <div className="flex gap-1">
                    {s.access_tiers.map((t) => (
                      <span key={t} className="text-xs" title={TIER_META[t].label}>{TIER_META[t].emoji}</span>
                    ))}
                  </div>
                </td>
                <td className="px-4 py-2">
                  <button className="text-blue-600 hover:underline text-xs mr-2" onClick={() => setEditing(s)}>Засах</button>
                  <button className="text-red-600 hover:underline text-xs"
                    onClick={() => { if (confirm('Устгах уу?')) del.mutate(s.id); }}>Устгах</button>
                </td>
              </tr>
            ))}
            {sessions.data?.length === 0 && (
              <tr><td colSpan={6} className="p-6 text-center text-gray-400">Session нэмээгүй байна</td></tr>
            )}
          </tbody>
        </table>
      </div>

      <SessionEditModal session={editing} onClose={() => setEditing(null)} />
    </div>
  );
}
