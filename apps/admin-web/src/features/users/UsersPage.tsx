import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { listUsers } from './api';
import { TIER_META, type ProfileRow, type Tier } from './types';
import { TierBadge } from './TierBadge';
import { TierEditDrawer } from './TierEditDrawer';

export function UsersPage() {
  const { t } = useTranslation();
  const [search, setSearch] = useState('');
  const [tierFilter, setTierFilter] = useState<Tier | 'all'>('all');
  const [selected, setSelected] = useState<ProfileRow | null>(null);

  const users = useQuery({
    queryKey: ['users', search, tierFilter],
    queryFn: () => listUsers(search, tierFilter),
  });

  return (
    <div>
      <h1 className="text-xl font-bold mb-4">{t('nav.users')}</h1>

      <div className="flex gap-2 mb-4">
        <input
          className="flex-1 border rounded px-3 py-2 text-sm"
          placeholder="Нэр, и-мэйл хайх…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <select
          className="border rounded px-3 py-2 text-sm"
          value={tierFilter}
          onChange={(e) => setTierFilter(e.target.value as Tier | 'all')}
        >
          <option value="all">Бүгд</option>
          {(Object.keys(TIER_META) as Tier[]).map((t) => (
            <option key={t} value={t}>{TIER_META[t].label}</option>
          ))}
        </select>
      </div>

      <div className="bg-white rounded-lg border overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-gray-50 text-left text-xs uppercase text-gray-500">
            <tr>
              <th className="px-4 py-2">Нэр</th>
              <th className="px-4 py-2">И-мэйл</th>
              <th className="px-4 py-2">Tier</th>
              <th className="px-4 py-2">Хэл</th>
              <th className="px-4 py-2"></th>
            </tr>
          </thead>
          <tbody>
            {users.isLoading && (
              <tr><td colSpan={5} className="px-4 py-6 text-center text-gray-400">Ачааллаж байна…</td></tr>
            )}
            {users.error && (
              <tr><td colSpan={5} className="px-4 py-6 text-center text-red-600">{(users.error as Error).message}</td></tr>
            )}
            {users.data?.map((u) => (
              <tr key={u.id} className="border-t hover:bg-gray-50">
                <td className="px-4 py-2">{u.name || '—'}</td>
                <td className="px-4 py-2 text-gray-600">{u.email}</td>
                <td className="px-4 py-2"><TierBadge tier={u.tier} /></td>
                <td className="px-4 py-2 text-gray-600">{u.locale.toUpperCase()}</td>
                <td className="px-4 py-2">
                  <button className="text-blue-600 hover:underline" onClick={() => setSelected(u)}>
                    Tier →
                  </button>
                </td>
              </tr>
            ))}
            {users.data?.length === 0 && (
              <tr><td colSpan={5} className="px-4 py-6 text-center text-gray-400">Олдсонгүй</td></tr>
            )}
          </tbody>
        </table>
      </div>

      <TierEditDrawer user={selected} onClose={() => setSelected(null)} />
    </div>
  );
}
