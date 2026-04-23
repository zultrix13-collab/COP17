import { useEffect, useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { TIER_META, type ProfileRow, type Tier } from './types';
import { tierAuditLog, updateTier } from './api';
import { TierBadge } from './TierBadge';

export function TierEditDrawer({
  user,
  onClose,
}: {
  user: ProfileRow | null;
  onClose: () => void;
}) {
  const [newTier, setNewTier] = useState<Tier>(user?.tier ?? 'green');
  const [reason, setReason] = useState('');
  const qc = useQueryClient();

  useEffect(() => {
    if (user) {
      setNewTier(user.tier);
      setReason('');
    }
  }, [user]);

  const audit = useQuery({
    queryKey: ['tier-audit', user?.id],
    queryFn: () => tierAuditLog(user!.id),
    enabled: !!user,
  });

  const mut = useMutation({
    mutationFn: () => updateTier(user!.id, user!.tier, newTier, reason),
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ['users'] });
      await qc.invalidateQueries({ queryKey: ['tier-counts'] });
      await qc.invalidateQueries({ queryKey: ['tier-audit', user?.id] });
      onClose();
    },
  });

  if (!user) return null;

  return (
    <div className="fixed inset-0 z-50 flex">
      <div className="flex-1 bg-black/30" onClick={onClose} />
      <aside className="w-96 bg-white h-full overflow-y-auto p-5 shadow-xl">
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-bold">Tier тохируулах</h2>
          <button className="text-gray-500" onClick={onClose}>✕</button>
        </div>

        <div className="mb-4">
          <div className="text-sm font-semibold">{user.name || '—'}</div>
          <div className="text-xs text-gray-500">{user.email}</div>
          <div className="mt-2"><TierBadge tier={user.tier} /></div>
        </div>

        <div className="mb-3 text-xs font-semibold uppercase text-gray-500">Шинэ tier</div>
        <div className="space-y-2 mb-4">
          {(Object.keys(TIER_META) as Tier[]).map((t) => (
            <label
              key={t}
              className={`flex items-center gap-2 border rounded-lg p-2 cursor-pointer ${
                newTier === t ? 'border-black bg-gray-50' : 'border-gray-200'
              }`}
            >
              <input
                type="radio"
                checked={newTier === t}
                onChange={() => setNewTier(t)}
                className="sr-only"
              />
              <span className="text-base">{TIER_META[t].emoji}</span>
              <span className="text-sm font-medium">{TIER_META[t].label}</span>
              {newTier === t && <span className="ml-auto text-xs text-green-600">✓</span>}
            </label>
          ))}
        </div>

        <label className="text-xs font-semibold uppercase text-gray-500">Тэмдэглэл</label>
        <textarea
          className="w-full border rounded p-2 text-sm mt-1 mb-4"
          rows={2}
          placeholder="UN delegate verified…"
          value={reason}
          onChange={(e) => setReason(e.target.value)}
        />

        <button
          className="w-full bg-black text-white rounded py-2 text-sm disabled:opacity-50"
          disabled={newTier === user.tier || mut.isPending}
          onClick={() => mut.mutate()}
        >
          {mut.isPending ? '…' : 'Хадгалах'}
        </button>
        {mut.error && <div className="text-xs text-red-600 mt-2">{(mut.error as Error).message}</div>}

        <div className="mt-6">
          <div className="text-xs font-semibold uppercase text-gray-500 mb-2">Tier өөрчлөлтийн лог</div>
          {audit.data?.length === 0 && <div className="text-xs text-gray-400">Лог хоосон</div>}
          {audit.data?.map((row) => (
            <div key={row.id} className="border rounded p-2 mb-2 bg-gray-50">
              <div className="flex justify-between text-xs font-semibold">
                <span>
                  {row.from_tier ?? '—'} → {row.to_tier}
                </span>
                <span className="text-gray-500">{new Date(row.created_at).toLocaleString('mn-MN')}</span>
              </div>
              {row.reason && <div className="text-xs text-gray-600 mt-1">{row.reason}</div>}
            </div>
          ))}
        </div>
      </aside>
    </div>
  );
}
