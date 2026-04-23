import type { Tier } from '../users/types';

export interface SessionRow {
  id: string;
  title_mn: string;
  title_en: string;
  hall: string;
  starts_at: string;
  ends_at: string;
  capacity: number;
  access_tiers: Tier[];
  description_mn: string | null;
  description_en: string | null;
}

export interface SpeakerRow {
  id: string;
  name: string;
  org: string | null;
  bio_mn: string | null;
  bio_en: string | null;
  photo_url: string | null;
}

export type SessionInput = Omit<SessionRow, 'id'>;
