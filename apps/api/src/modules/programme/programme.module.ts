import { Controller, Get, Inject, Module, Param, Res } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_ADMIN } from '../../supabase/supabase.module';

@ApiTags('programme')
@Controller('programme')
class ProgrammeController {
  constructor(@Inject(SUPABASE_ADMIN) private readonly sb: SupabaseClient) {}

  /**
   * iCalendar export for a user's agenda. `userId` is a path param; in
   * production lock down behind auth or a per-user signed URL.
   */
  @Get(':userId/agenda.ics')
  async agendaIcs(@Param('userId') userId: string, @Res() res: Response) {
    const { data, error } = await this.sb
      .from('attendance')
      .select('session:sessions(id, title_mn, title_en, hall, starts_at, ends_at, description_mn)')
      .eq('user_id', userId);
    if (error) {
      res.status(500).send(error.message);
      return;
    }

    const lines: string[] = [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//COP17//EN',
    ];
    for (const row of (data ?? []) as Array<{ session: any }>) {
      const s = row.session;
      if (!s) continue;
      lines.push(
        'BEGIN:VEVENT',
        `UID:${s.id}@cop17.mn`,
        `SUMMARY:${escape(s.title_mn)}`,
        `LOCATION:${escape(s.hall)}`,
        `DTSTART:${toIcsDate(s.starts_at)}`,
        `DTEND:${toIcsDate(s.ends_at)}`,
        s.description_mn ? `DESCRIPTION:${escape(s.description_mn)}` : '',
        'END:VEVENT',
      );
    }
    lines.push('END:VCALENDAR');

    res.setHeader('Content-Type', 'text/calendar; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="cop17-agenda.ics"');
    res.send(lines.filter(Boolean).join('\r\n'));
  }
}

const escape = (s: string) => s.replace(/[\\;,]/g, (m) => `\\${m}`).replace(/\n/g, '\\n');
const toIcsDate = (iso: string) => iso.replace(/[-:]/g, '').replace(/\.\d+/, '');

@Module({ controllers: [ProgrammeController] })
export class ProgrammeModule {}
