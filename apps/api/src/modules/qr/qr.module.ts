import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Inject,
  Module,
  Post,
  Query,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { IsString } from 'class-validator';
import { createHmac, timingSafeEqual } from 'node:crypto';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_ADMIN } from '../../supabase/supabase.module';
import { AdminGuard } from '../../common/admin.guard';

const QR_TTL_SEC = 15 * 60;

class CheckInDto {
  @IsString() token!: string;
  @IsString() sessionId!: string;
}

@ApiTags('qr')
@Controller('qr')
class QrController {
  constructor(@Inject(SUPABASE_ADMIN) private readonly sb: SupabaseClient) {}

  /** Issue a signed digital-ID token for the caller's user. */
  @Get('issue')
  issue(@Query('userId') userId: string) {
    if (!userId) throw new BadRequestException('userId required');
    const issuedAt = Math.floor(Date.now() / 1000);
    const expiresAt = issuedAt + QR_TTL_SEC;
    const payload = `${userId}.${issuedAt}.${expiresAt}`;
    return { token: `${payload}.${sign(payload)}`, expiresAt };
  }

  /** Parse and validate a token. Does NOT touch attendance. */
  @Post('verify')
  verify(@Query('token') token: string) {
    const parsed = parseAndVerify(token);
    return parsed;
  }

  /**
   * Scanner flow: verify the delegate's token, then mark attendance for
   * the session the scanner station is assigned to.
   * Admin-guarded: only ops staff may call.
   */
  @Post('check-in')
  @ApiBearerAuth()
  @UseGuards(AdminGuard)
  async checkIn(@Body() dto: CheckInDto) {
    const parsed = parseAndVerify(dto.token);
    const { error } = await this.sb.from('attendance').upsert(
      {
        user_id: parsed.userId,
        session_id: dto.sessionId,
        status: 'attended',
        checked_in_at: new Date().toISOString(),
      },
      { onConflict: 'user_id,session_id' },
    );
    if (error) throw error;
    return { ok: true, userId: parsed.userId };
  }
}

function sign(payload: string): string {
  const secret = process.env.QR_HMAC_SECRET ?? 'dev-qr';
  return createHmac('sha256', secret).update(payload).digest('base64url');
}

function parseAndVerify(token: string) {
  const parts = token.split('.');
  if (parts.length !== 4) throw new UnauthorizedException('Malformed token');
  const [userId, issuedAt, expiresAt, sig] = parts;
  if (Number(expiresAt) < Math.floor(Date.now() / 1000)) {
    throw new UnauthorizedException('Expired');
  }
  const expected = sign(`${userId}.${issuedAt}.${expiresAt}`);
  const a = Buffer.from(sig);
  const b = Buffer.from(expected);
  if (a.length !== b.length || !timingSafeEqual(a, b)) {
    throw new UnauthorizedException('Bad signature');
  }
  return { userId, issuedAt: Number(issuedAt), expiresAt: Number(expiresAt) };
}

@Module({ controllers: [QrController], providers: [AdminGuard] })
export class QrModule {}
