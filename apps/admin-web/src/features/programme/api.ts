import { supabase } from '../../lib/supabase';
import type { SessionInput, SessionRow, SpeakerRow } from './types';

export async function listSessions(): Promise<SessionRow[]> {
  const { data, error } = await supabase
    .from('sessions')
    .select('*')
    .order('starts_at', { ascending: true });
  if (error) throw error;
  return data as SessionRow[];
}

export async function createSession(input: SessionInput): Promise<SessionRow> {
  const { data, error } = await supabase.from('sessions').insert(input).select().single();
  if (error) throw error;
  return data as SessionRow;
}

export async function updateSession(id: string, input: Partial<SessionInput>): Promise<void> {
  const { error } = await supabase.from('sessions').update(input).eq('id', id);
  if (error) throw error;
}

export async function deleteSession(id: string): Promise<void> {
  const { error } = await supabase.from('sessions').delete().eq('id', id);
  if (error) throw error;
}

export async function listSpeakers(): Promise<SpeakerRow[]> {
  const { data, error } = await supabase
    .from('speakers')
    .select('*')
    .order('name');
  if (error) throw error;
  return data as SpeakerRow[];
}
