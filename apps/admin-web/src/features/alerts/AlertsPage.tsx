import { useEffect, useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';

interface Alert {
  id: number;
  severity: 'info' | 'warn' | 'critical';
  title: string;
  body: string | null;
  status: 'open' | 'resolved';
  resolved_at: string | null;
  created_at: string;
}

async function listAlerts(status: 'open' | 'resolved'): Promise<Alert[]> {
  const { data, error } = await supabase
    .from('alerts_incidents')
    .select('*')
    .eq('status', status)
    .order('created_at', { ascending: false })
    .limit(100);
  if (error) throw error;
  return data as Alert[];
}

async function resolveAlert(id: number) {
  const { error } = await supabase
    .from('alerts_incidents')
    .update({ status: 'resolved', resolved_at: new Date().toISOString() })
    .eq('id', id);
  if (error) throw error;
}

async function createAlert(payload: { severity: 'info' | 'warn' | 'critical'; title: string; body: string }) {
  const { error } = await supabase.from('alerts_incidents').insert(payload);
  if (error) throw error;
}

export function AlertsPage() {
  const qc = useQueryClient();
  const open = useQuery({ queryKey: ['alerts', 'open'], queryFn: () => listAlerts('open') });
  const resolved = useQuery({ queryKey: ['alerts', 'resolved'], queryFn: () => listAlerts('resolved') });

  useEffect(() => {
    const ch = supabase
      .channel('alerts-realtime')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'alerts_incidents' }, () => {
        qc.invalidateQueries({ queryKey: ['alerts'] });
      })
      .subscribe();
    return () => { void ch.unsubscribe(); };
  }, [qc]);

  const resolve = useMutation({
    mutationFn: resolveAlert,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['alerts'] }),
  });
  const create = useMutation({
    mutationFn: createAlert,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['alerts'] }),
  });

  const [severity, setSeverity] = useState<'info' | 'warn' | 'critical'>('warn');
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');

  return (
    <div>
      <h1 className="text-xl font-bold mb-4">Alerts / Incidents</h1>

      <div className="bg-white border rounded-lg p-4 mb-6">
        <div className="text-sm font-semibold mb-2">Шинэ alert үүсгэх</div>
        <div className="flex gap-2 flex-wrap">
          <select className="border rounded px-2 py-1 text-sm"
            value={severity} onChange={(e) => setSeverity(e.target.value as any)}>
            <option value="info">info</option>
            <option value="warn">warn</option>
            <option value="critical">critical</option>
          </select>
          <input className="border rounded px-2 py-1 text-sm flex-1 min-w-[220px]"
            placeholder="Гарчиг" value={title} onChange={(e) => setTitle(e.target.value)} />
          <input className="border rounded px-2 py-1 text-sm flex-1 min-w-[220px]"
            placeholder="Тайлбар" value={body} onChange={(e) => setBody(e.target.value)} />
          <button
            className="bg-black text-white rounded px-3 py-1 text-sm disabled:opacity-50"
            disabled={!title || create.isPending}
            onClick={() => {
              create.mutate({ severity, title, body });
              setTitle('');
              setBody('');
            }}
          >
            Нэмэх
          </button>
        </div>
      </div>

      <section className="mb-6">
        <h2 className="text-sm font-semibold uppercase text-gray-500 mb-2">
          🔴 Нээлттэй ({open.data?.length ?? 0})
        </h2>
        <AlertsList items={open.data ?? []} onResolve={(id) => resolve.mutate(id)} />
      </section>

      <section>
        <h2 className="text-sm font-semibold uppercase text-gray-500 mb-2">
          ✓ Шийдвэрлэсэн
        </h2>
        <AlertsList items={resolved.data ?? []} />
      </section>
    </div>
  );
}

function AlertsList({ items, onResolve }: { items: Alert[]; onResolve?: (id: number) => void }) {
  if (items.length === 0) return <div className="text-xs text-gray-400 px-4 py-6">Хоосон</div>;
  return (
    <div className="space-y-2">
      {items.map((a) => {
        const color = a.severity === 'critical' ? '#DC2626'
          : a.severity === 'warn' ? '#B45309' : '#1A6EF5';
        return (
          <div key={a.id} className="bg-white border rounded p-3 flex items-start justify-between gap-3">
            <div className="flex-1">
              <div className="flex items-center gap-2">
                <span className="text-xs font-bold" style={{ color }}>{a.severity.toUpperCase()}</span>
                <span className="text-xs text-gray-500">
                  {new Date(a.created_at).toLocaleString('mn-MN')}
                </span>
              </div>
              <div className="font-semibold">{a.title}</div>
              {a.body && <div className="text-xs text-gray-600 mt-1 whitespace-pre-wrap">{a.body}</div>}
            </div>
            {onResolve && (
              <button
                className="bg-green-600 text-white rounded px-2 py-1 text-xs self-center"
                onClick={() => onResolve(a.id)}
              >
                ✓ Шийдвэрлэсэн
              </button>
            )}
          </div>
        );
      })}
    </div>
  );
}
