import { Inject, Injectable, Logger } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_ADMIN } from '../../supabase/supabase.module';

export interface PushPayload {
  userIds: string[];
  topic: string;
  title: { mn: string; en: string };
  body:  { mn: string; en: string };
  data?: Record<string, string>;
}

@Injectable()
export class NotificationsService {
  private readonly log = new Logger(NotificationsService.name);

  constructor(@Inject(SUPABASE_ADMIN) private readonly sb: SupabaseClient) {}

  /**
   * Record notifications in DB (locale-per-user) and hand off to FCM.
   * FCM admin SDK wiring is intentionally deferred — add `firebase-admin`
   * package and service-account JSON, then replace `sendViaFcm` body.
   */
  async send(payload: PushPayload): Promise<{ queued: number }> {
    const { data: profiles, error } = await this.sb
      .from('profiles')
      .select('id, locale')
      .in('id', payload.userIds);
    if (error) throw error;

    const rows = profiles!.map((p) => ({
      user_id: p.id,
      topic: payload.topic,
      locale: p.locale,
      title: p.locale === 'en' ? payload.title.en : payload.title.mn,
      body:  p.locale === 'en' ? payload.body.en  : payload.body.mn,
    }));
    const { error: insErr } = await this.sb.from('notifications').insert(rows);
    if (insErr) throw insErr;

    await this.sendViaFcm(rows, payload.data);
    return { queued: rows.length };
  }

  private async sendViaFcm(
    rows: { user_id: string; title: string; body: string }[],
    _data?: Record<string, string>,
  ): Promise<void> {
    // TODO: load device tokens from `device_tokens` table and send via firebase-admin.
    this.log.log(`[FCM stub] would send ${rows.length} notifications`);
  }
}
