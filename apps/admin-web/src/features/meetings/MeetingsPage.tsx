import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';

interface Meeting {
  id: string;
  requester_id: string;
  exhibitor_id: string;
  starts_at: string;
  ends_at: string;
  status: string;
  purpose: string | null;
  created_at: string;
}

async function listMeetings(status: string): Promise<Meeting[]> {
  let q = supabase.from('b2b_meetings').select('*').order('starts_at');
  if (status !== 'all') q = q.eq('status', status);
  const { data, error } = await q;
  if (error) throw error;
  return data as Meeting[];
}

async function setStatus(id: string, status: 'approved' | 'rejected') {
  const { error } = await supabase.from('b2b_meetings').update({ status }).eq('id', id);
  if (error) throw error;
}

export function MeetingsPage() {
  const qc = useQueryClient();
  const pending = useQuery({ queryKey: ['meetings', 'pending'], queryFn: () => listMeetings('pending') });
  const upcoming = useQuery({ queryKey: ['meetings', 'approved'], queryFn: () => listMeetings('approved') });

  const act = useMutation({
    mutationFn: ({ id, s }: { id: string; s: 'approved' | 'rejected' }) => setStatus(id, s),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['meetings'] });
    },
  });

  return (
    <div>
      <h1 className="text-xl font-bold mb-4">B2B Meetings</h1>

      <section className="mb-6">
        <h2 className="text-sm font-semibold uppercase text-gray-500 mb-2">
          Хүлээгдэж буй ({pending.data?.length ?? 0})
        </h2>
        <MeetingsTable
          rows={pending.data ?? []}
          actions={(m) => (
            <div className="flex gap-2">
              <button
                className="bg-green-600 text-white rounded px-2 py-1 text-xs"
                onClick={() => act.mutate({ id: m.id, s: 'approved' })}
              >
                Батлах
              </button>
              <button
                className="bg-red-600 text-white rounded px-2 py-1 text-xs"
                onClick={() => act.mutate({ id: m.id, s: 'rejected' })}
              >
                Татгалзах
              </button>
            </div>
          )}
        />
      </section>

      <section>
        <h2 className="text-sm font-semibold uppercase text-gray-500 mb-2">
          Баталгаажсан ({upcoming.data?.length ?? 0})
        </h2>
        <MeetingsTable rows={upcoming.data ?? []} />
      </section>
    </div>
  );
}

function MeetingsTable({ rows, actions }: { rows: Meeting[]; actions?: (m: Meeting) => React.ReactNode }) {
  return (
    <div className="bg-white rounded border overflow-hidden">
      <table className="w-full text-sm">
        <thead className="bg-gray-50 text-left text-xs uppercase text-gray-500">
          <tr>
            <th className="px-3 py-2">Эхлэх</th>
            <th className="px-3 py-2">Requester</th>
            <th className="px-3 py-2">Exhibitor</th>
            <th className="px-3 py-2">Зорилго</th>
            {actions && <th className="px-3 py-2"></th>}
          </tr>
        </thead>
        <tbody>
          {rows.map((m) => (
            <tr key={m.id} className="border-t">
              <td className="px-3 py-2">{new Date(m.starts_at).toLocaleString('mn-MN')}</td>
              <td className="px-3 py-2 font-mono text-xs">{m.requester_id.slice(0, 8)}</td>
              <td className="px-3 py-2 font-mono text-xs">{m.exhibitor_id.slice(0, 8)}</td>
              <td className="px-3 py-2 text-xs">{m.purpose ?? '—'}</td>
              {actions && <td className="px-3 py-2">{actions(m)}</td>}
            </tr>
          ))}
          {rows.length === 0 && (
            <tr><td colSpan={actions ? 5 : 4} className="p-4 text-center text-gray-400">Хоосон</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
