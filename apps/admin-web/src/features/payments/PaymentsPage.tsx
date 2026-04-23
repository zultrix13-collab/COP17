import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';

const money = new Intl.NumberFormat('mn-MN', { style: 'currency', currency: 'MNT', maximumFractionDigits: 0 });

interface Txn {
  id: number;
  user_id: string;
  kind: string;
  amount: number;
  reference: string | null;
  provider: string | null;
  created_at: string;
}
interface Invoice {
  id: string;
  user_id: string;
  amount: number;
  status: string;
  qpay_invoice_id: string | null;
  created_at: string;
  paid_at: string | null;
}

export function PaymentsPage() {
  const txns = useQuery<Txn[]>({
    queryKey: ['wallet_txns'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('wallet_txns')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(100);
      if (error) throw error;
      return data as Txn[];
    },
  });

  const pending = useQuery<Invoice[]>({
    queryKey: ['qpay_pending'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('qpay_invoices')
        .select('*')
        .eq('status', 'pending')
        .order('created_at', { ascending: false })
        .limit(50);
      if (error) throw error;
      return data as Invoice[];
    },
    refetchInterval: 15_000,
  });

  return (
    <div>
      <h1 className="text-xl font-bold mb-4">Payments</h1>

      <section className="mb-6">
        <h2 className="text-sm font-semibold uppercase text-gray-500 mb-2">
          Pending top-ups ({pending.data?.length ?? 0})
        </h2>
        <div className="bg-white rounded border">
          <table className="w-full text-sm">
            <thead className="text-xs uppercase text-gray-500 text-left">
              <tr>
                <th className="px-3 py-2">QPay invoice</th>
                <th className="px-3 py-2">User</th>
                <th className="px-3 py-2">Amount</th>
                <th className="px-3 py-2">Created</th>
              </tr>
            </thead>
            <tbody>
              {pending.data?.map((i) => (
                <tr key={i.id} className="border-t">
                  <td className="px-3 py-2 font-mono text-xs">{i.qpay_invoice_id ?? '—'}</td>
                  <td className="px-3 py-2 font-mono text-xs">{i.user_id.slice(0, 8)}</td>
                  <td className="px-3 py-2">{money.format(i.amount)}</td>
                  <td className="px-3 py-2">{new Date(i.created_at).toLocaleString('mn-MN')}</td>
                </tr>
              ))}
              {pending.data?.length === 0 && (
                <tr><td colSpan={4} className="p-4 text-center text-gray-400">Pending хоосон</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </section>

      <section>
        <h2 className="text-sm font-semibold uppercase text-gray-500 mb-2">Сүүлийн гүйлгээнүүд</h2>
        <div className="bg-white rounded border">
          <table className="w-full text-sm">
            <thead className="text-xs uppercase text-gray-500 text-left">
              <tr>
                <th className="px-3 py-2">User</th>
                <th className="px-3 py-2">Kind</th>
                <th className="px-3 py-2">Amount</th>
                <th className="px-3 py-2">Reference</th>
                <th className="px-3 py-2">Provider</th>
                <th className="px-3 py-2">When</th>
              </tr>
            </thead>
            <tbody>
              {txns.data?.map((t) => (
                <tr key={t.id} className="border-t">
                  <td className="px-3 py-2 font-mono text-xs">{t.user_id.slice(0, 8)}</td>
                  <td className="px-3 py-2">{t.kind}</td>
                  <td className={`px-3 py-2 font-semibold ${t.amount < 0 ? 'text-red-600' : 'text-green-600'}`}>
                    {t.amount > 0 ? '+' : ''}{money.format(t.amount)}
                  </td>
                  <td className="px-3 py-2 text-xs text-gray-600">{t.reference ?? '—'}</td>
                  <td className="px-3 py-2 text-xs text-gray-600">{t.provider ?? '—'}</td>
                  <td className="px-3 py-2 text-xs text-gray-500">{new Date(t.created_at).toLocaleString('mn-MN')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
