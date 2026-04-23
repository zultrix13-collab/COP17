import { TIER_META, type Tier } from './types';

export function TierBadge({ tier }: { tier: Tier }) {
  const m = TIER_META[tier];
  return (
    <span
      className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-semibold"
      style={{ color: m.color, background: `${m.color}1a` }}
    >
      <span>{m.emoji}</span>
      {m.label}
    </span>
  );
}
