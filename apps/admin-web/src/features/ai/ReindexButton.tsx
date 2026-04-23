import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';

const apiBase = import.meta.env.VITE_API_BASE_URL as string;

async function reindex() {
  const { data: { session } } = await supabase.auth.getSession();
  const res = await fetch(`${apiBase}/v1/ai/reindex`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${session?.access_token ?? ''}` },
  });
  if (!res.ok) throw new Error(await res.text());
  return res.json() as Promise<{ inserted: number }>;
}

export function ReindexButton() {
  const mut = useMutation({ mutationFn: reindex });
  return (
    <div>
      <button
        className="bg-black text-white rounded px-3 py-1.5 text-sm disabled:opacity-50"
        onClick={() => mut.mutate()}
        disabled={mut.isPending}
      >
        {mut.isPending ? '…' : 'Rebuild RAG index'}
      </button>
      {mut.data && (
        <span className="ml-3 text-xs text-green-600">{mut.data.inserted} chunks</span>
      )}
      {mut.error && (
        <span className="ml-3 text-xs text-red-600">{(mut.error as Error).message}</span>
      )}
    </div>
  );
}
