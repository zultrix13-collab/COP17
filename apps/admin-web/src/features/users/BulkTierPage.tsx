import { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { TIER_META, type Tier } from './types';

const apiBase = import.meta.env.VITE_API_BASE_URL as string;

interface ParsedRow { email: string; matched: boolean; userId?: string; currentTier?: Tier }

async function resolveEmails(emails: string[]): Promise<ParsedRow[]> {
  const clean = emails.map((e) => e.trim().toLowerCase()).filter(Boolean);
  const { data, error } = await supabase
    .from('profiles')
    .select('id, email, tier')
    .in('email', clean);
  if (error) throw error;
  const map = new Map((data as { id: string; email: string; tier: Tier }[]).map((r) => [r.email, r]));
  return clean.map((email) => {
    const hit = map.get(email);
    return hit
      ? { email, matched: true, userId: hit.id, currentTier: hit.tier }
      : { email, matched: false };
  });
}

async function bulkTier(userIds: string[], toTier: Tier, reason: string) {
  const { data: { session } } = await supabase.auth.getSession();
  const res = await fetch(`${apiBase}/v1/admin/users/bulk-tier`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${session?.access_token ?? ''}`,
    },
    body: JSON.stringify({ userIds, toTier, reason }),
  });
  if (!res.ok) throw new Error(await res.text());
  return res.json() as Promise<{ updated: number }>;
}

export function BulkTierPage() {
  const [raw, setRaw] = useState('');
  const [toTier, setToTier] = useState<Tier>('blue');
  const [reason, setReason] = useState('bulk upgrade');
  const [preview, setPreview] = useState<ParsedRow[] | null>(null);

  const parseCsv = (text: string) => text.split(/[\r\n,;]+/).map((s) => s.trim()).filter(Boolean);

  const previewMut = useMutation({
    mutationFn: () => resolveEmails(parseCsv(raw)),
    onSuccess: (rows) => setPreview(rows),
  });

  const applyMut = useMutation({
    mutationFn: () => bulkTier(
      (preview ?? []).filter((r) => r.matched).map((r) => r.userId!),
      toTier,
      reason,
    ),
    onSuccess: () => {
      setPreview(null);
      setRaw('');
    },
  });

  const matched = preview?.filter((r) => r.matched) ?? [];
  const missed = preview?.filter((r) => !r.matched) ?? [];

  return (
    <div>
      <h1 className="text-xl font-bold mb-4">Bulk tier upgrade</h1>

      <div className="bg-white border rounded-lg p-4 mb-4">
        <label className="text-xs text-gray-500 uppercase">Email жагсаалт</label>
        <textarea
          className="w-full border rounded p-2 mt-1 font-mono text-sm"
          rows={6}
          placeholder={'one@example.mn\ntwo@example.mn'}
          value={raw}
          onChange={(e) => setRaw(e.target.value)}
        />
        <div className="flex gap-2 mt-3 items-center">
          <label className="text-xs text-gray-500">Шинэ tier</label>
          <select className="border rounded px-2 py-1 text-sm"
            value={toTier} onChange={(e) => setToTier(e.target.value as Tier)}>
            {(Object.keys(TIER_META) as Tier[]).map((t) => (
              <option key={t} value={t}>{TIER_META[t].emoji} {TIER_META[t].label}</option>
            ))}
          </select>
          <input className="border rounded px-2 py-1 text-sm flex-1"
            placeholder="Шалтгаан / тэмдэглэл"
            value={reason} onChange={(e) => setReason(e.target.value)} />
          <button
            className="bg-black text-white rounded px-3 py-1 text-sm disabled:opacity-50"
            disabled={previewMut.isPending || !raw.trim()}
            onClick={() => previewMut.mutate()}
          >
            {previewMut.isPending ? '…' : 'Preview'}
          </button>
        </div>
        {previewMut.error && (
          <div className="text-xs text-red-600 mt-2">{(previewMut.error as Error).message}</div>
        )}
      </div>

      {preview && (
        <div className="bg-white border rounded-lg p-4">
          <div className="flex gap-4 text-sm mb-3">
            <span>✓ {matched.length} олдсон</span>
            <span className="text-red-600">{missed.length} олдоогүй</span>
          </div>
          <table className="w-full text-sm mb-3">
            <thead className="text-xs uppercase text-gray-500 text-left">
              <tr>
                <th className="px-2 py-1">Email</th>
                <th className="px-2 py-1">Статус</th>
                <th className="px-2 py-1">Одоогийн tier</th>
              </tr>
            </thead>
            <tbody>
              {preview.map((r) => (
                <tr key={r.email} className="border-t">
                  <td className="px-2 py-1">{r.email}</td>
                  <td className="px-2 py-1 text-xs">
                    {r.matched
                      ? <span className="text-green-600">Олдсон</span>
                      : <span className="text-red-600">Олдоогүй</span>}
                  </td>
                  <td className="px-2 py-1 text-xs">{r.currentTier ?? '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <button
            className="bg-black text-white rounded px-4 py-2 text-sm disabled:opacity-50"
            disabled={matched.length === 0 || applyMut.isPending}
            onClick={() => applyMut.mutate()}
          >
            {applyMut.isPending ? '…' : `${matched.length} хэрэглэгч → ${TIER_META[toTier].label}`}
          </button>
          {applyMut.data && (
            <div className="text-xs text-green-600 mt-2">Updated: {applyMut.data.updated}</div>
          )}
          {applyMut.error && (
            <div className="text-xs text-red-600 mt-2">{(applyMut.error as Error).message}</div>
          )}
        </div>
      )}
    </div>
  );
}
