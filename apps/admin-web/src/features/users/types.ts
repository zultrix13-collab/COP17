export type Tier = 'green' | 'blue' | 'vip' | 'exhibitor' | 'press';

export interface ProfileRow {
  id: string;
  email: string;
  name: string;
  tier: Tier;
  locale: 'mn' | 'en';
  accreditation_id: string | null;
  created_at: string;
}

export interface TierChangeRow {
  id: number;
  user_id: string;
  from_tier: Tier | null;
  to_tier: Tier;
  admin_id: string | null;
  reason: string | null;
  created_at: string;
}

export const TIER_META: Record<Tier, { label: string; emoji: string; color: string }> = {
  green:     { label: 'Green Zone', emoji: '🟢', color: '#16a34a' },
  blue:      { label: 'Blue Zone',  emoji: '🔵', color: '#1a6ef5' },
  vip:       { label: 'VIP',         emoji: '💎', color: '#7c3aed' },
  exhibitor: { label: 'Exhibitor',  emoji: '🏢', color: '#b45309' },
  press:     { label: 'Press',      emoji: '📰', color: '#0369a1' },
};
