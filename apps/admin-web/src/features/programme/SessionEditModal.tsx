import { useEffect, useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { TIER_META, type Tier } from '../users/types';
import { createSession, updateSession } from './api';
import type { SessionInput, SessionRow } from './types';

const ALL_TIERS = Object.keys(TIER_META) as Tier[];

const empty: SessionInput = {
  title_mn: '',
  title_en: '',
  hall: '',
  starts_at: new Date().toISOString().slice(0, 16),
  ends_at: new Date().toISOString().slice(0, 16),
  capacity: 100,
  access_tiers: ['green'],
  description_mn: null,
  description_en: null,
};

export function SessionEditModal({
  session,
  onClose,
}: {
  session: SessionRow | null | 'new';
  onClose: () => void;
}) {
  const [form, setForm] = useState<SessionInput>(empty);
  const qc = useQueryClient();

  useEffect(() => {
    if (session === 'new') {
      setForm(empty);
    } else if (session) {
      setForm({
        title_mn: session.title_mn,
        title_en: session.title_en,
        hall: session.hall,
        starts_at: session.starts_at.slice(0, 16),
        ends_at: session.ends_at.slice(0, 16),
        capacity: session.capacity,
        access_tiers: session.access_tiers,
        description_mn: session.description_mn,
        description_en: session.description_en,
      });
    }
  }, [session]);

  const mut = useMutation({
    mutationFn: async () => {
      const payload = {
        ...form,
        starts_at: new Date(form.starts_at).toISOString(),
        ends_at: new Date(form.ends_at).toISOString(),
      };
      if (session === 'new') await createSession(payload);
      else if (session) await updateSession(session.id, payload);
    },
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ['sessions'] });
      onClose();
    },
  });

  if (!session) return null;

  const toggleTier = (t: Tier) => {
    setForm((f) => ({
      ...f,
      access_tiers: f.access_tiers.includes(t)
        ? f.access_tiers.filter((x) => x !== t)
        : [...f.access_tiers, t],
    }));
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30">
      <div className="bg-white rounded-xl w-[520px] max-h-[90vh] overflow-y-auto p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-bold">{session === 'new' ? 'Session нэмэх' : 'Session засах'}</h2>
          <button onClick={onClose} className="text-gray-500">✕</button>
        </div>

        <div className="grid grid-cols-2 gap-3">
          <Field label="Гарчиг (МН)">
            <input className="input" value={form.title_mn}
              onChange={(e) => setForm({ ...form, title_mn: e.target.value })} />
          </Field>
          <Field label="Title (EN)">
            <input className="input" value={form.title_en}
              onChange={(e) => setForm({ ...form, title_en: e.target.value })} />
          </Field>
          <Field label="Танхим">
            <input className="input" value={form.hall}
              onChange={(e) => setForm({ ...form, hall: e.target.value })} />
          </Field>
          <Field label="Хүчин чадал">
            <input type="number" className="input" value={form.capacity}
              onChange={(e) => setForm({ ...form, capacity: Number(e.target.value) })} />
          </Field>
          <Field label="Эхлэх">
            <input type="datetime-local" className="input" value={form.starts_at}
              onChange={(e) => setForm({ ...form, starts_at: e.target.value })} />
          </Field>
          <Field label="Дуусах">
            <input type="datetime-local" className="input" value={form.ends_at}
              onChange={(e) => setForm({ ...form, ends_at: e.target.value })} />
          </Field>
        </div>

        <div className="mt-4">
          <div className="text-xs font-semibold uppercase text-gray-500 mb-2">Хандах эрх</div>
          <div className="flex flex-wrap gap-2">
            {ALL_TIERS.map((t) => {
              const on = form.access_tiers.includes(t);
              return (
                <button key={t} onClick={() => toggleTier(t)}
                  className={`px-2 py-1 text-xs rounded-full border ${on ? 'bg-black text-white border-black' : 'text-gray-600'}`}>
                  {TIER_META[t].emoji} {TIER_META[t].label}
                </button>
              );
            })}
          </div>
        </div>

        <Field label="Тайлбар (МН)">
          <textarea className="input" rows={2} value={form.description_mn ?? ''}
            onChange={(e) => setForm({ ...form, description_mn: e.target.value || null })} />
        </Field>
        <Field label="Description (EN)">
          <textarea className="input" rows={2} value={form.description_en ?? ''}
            onChange={(e) => setForm({ ...form, description_en: e.target.value || null })} />
        </Field>

        <button
          className="w-full bg-black text-white rounded py-2 mt-4 text-sm disabled:opacity-50"
          disabled={mut.isPending || !form.title_mn || !form.title_en || !form.hall}
          onClick={() => mut.mutate()}
        >
          {mut.isPending ? '…' : 'Хадгалах'}
        </button>
        {mut.error && <div className="text-xs text-red-600 mt-2">{(mut.error as Error).message}</div>}
      </div>

      <style>{`.input { width: 100%; border: 1px solid #d1d5db; border-radius: 6px; padding: 6px 8px; font-size: 13px; }`}</style>
    </div>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <label className="block mt-2">
      <span className="text-xs text-gray-500">{label}</span>
      {children}
    </label>
  );
}
