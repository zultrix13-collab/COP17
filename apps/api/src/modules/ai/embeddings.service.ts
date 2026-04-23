import { Inject, Injectable, Logger } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_ADMIN } from '../../supabase/supabase.module';

/**
 * Uses OpenAI's `text-embedding-3-small` (1536-dim) to match our `vector(1536)` column.
 * Swap for any 1536-d embedding model (Voyage voyage-3, Cohere embed-english-v3) by
 * replacing `embed()` only.
 */
@Injectable()
export class EmbeddingsService {
  private readonly log = new Logger(EmbeddingsService.name);

  constructor(@Inject(SUPABASE_ADMIN) private readonly sb: SupabaseClient) {}

  async embed(texts: string[]): Promise<number[][]> {
    const key = process.env.OPENAI_API_KEY;
    if (!key) throw new Error('OPENAI_API_KEY not set');
    const res = await fetch('https://api.openai.com/v1/embeddings', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${key}` },
      body: JSON.stringify({ model: 'text-embedding-3-small', input: texts }),
    });
    if (!res.ok) throw new Error(`Embeddings API ${res.status}: ${await res.text()}`);
    const json = (await res.json()) as { data: { embedding: number[] }[] };
    return json.data.map((d) => d.embedding);
  }

  /**
   * Rebuild the `rag_chunks` table from sessions, faq, announcements.
   * Idempotent: deletes + re-inserts in one pass. Run from admin UI or cron.
   */
  async reindex(): Promise<{ inserted: number }> {
    const records: Array<{
      source: string;
      source_id: string;
      locale: 'mn' | 'en';
      content: string;
    }> = [];

    const { data: sessions } = await this.sb
      .from('sessions')
      .select('id, title_mn, title_en, hall, starts_at, description_mn, description_en');
    for (const s of sessions ?? []) {
      records.push({
        source: 'session', source_id: s.id, locale: 'mn',
        content: `${s.title_mn} · ${s.hall} · ${s.starts_at}\n${s.description_mn ?? ''}`,
      });
      records.push({
        source: 'session', source_id: s.id, locale: 'en',
        content: `${s.title_en} · ${s.hall} · ${s.starts_at}\n${s.description_en ?? ''}`,
      });
    }

    const { data: faqs } = await this.sb.from('faq').select('*');
    for (const f of faqs ?? []) {
      records.push({ source: 'faq', source_id: f.id, locale: 'mn',
        content: `Q: ${f.question_mn}\nA: ${f.answer_mn}` });
      records.push({ source: 'faq', source_id: f.id, locale: 'en',
        content: `Q: ${f.question_en}\nA: ${f.answer_en}` });
    }

    const { data: anns } = await this.sb.from('announcements').select('*');
    for (const a of anns ?? []) {
      records.push({ source: 'announcement', source_id: a.id, locale: 'mn',
        content: `${a.title_mn}\n${a.body_mn ?? ''}` });
      records.push({ source: 'announcement', source_id: a.id, locale: 'en',
        content: `${a.title_en}\n${a.body_en ?? ''}` });
    }

    if (records.length === 0) return { inserted: 0 };

    // Batch 96 at a time (OpenAI limit is much higher but keeps payload small).
    const embeddings: number[][] = [];
    for (let i = 0; i < records.length; i += 96) {
      const batch = records.slice(i, i + 96).map((r) => r.content);
      const vectors = await this.embed(batch);
      embeddings.push(...vectors);
    }

    await this.sb.from('rag_chunks').delete().gte('id', 0);
    const rows = records.map((r, i) => ({ ...r, embedding: embeddings[i] }));
    const { error } = await this.sb.from('rag_chunks').insert(rows);
    if (error) throw error;

    this.log.log(`reindex: ${rows.length} chunks inserted`);
    return { inserted: rows.length };
  }

  async search(query: string, locale: 'mn' | 'en', k = 6): Promise<string[]> {
    const [vector] = await this.embed([query]);
    const { data, error } = await this.sb.rpc('match_rag_chunks', {
      p_query: vector,
      p_locale: locale,
      p_k: k,
    });
    if (error) throw error;
    return (data as { content: string }[]).map((r) => r.content);
  }
}
