import {
  Body,
  Controller,
  Delete,
  Inject,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { IsEnum, IsString } from 'class-validator';
import { SupabaseClient } from '@supabase/supabase-js';
import { AuthGuard } from '../../common/auth.guard';
import { SUPABASE_ADMIN } from '../../supabase/supabase.module';

class RegisterTokenDto {
  @IsString()
  token!: string;

  @IsEnum(['ios', 'android', 'web'] as const)
  platform!: 'ios' | 'android' | 'web';
}

@ApiTags('device-tokens')
@ApiBearerAuth()
@UseGuards(AuthGuard)
@Controller('device-tokens')
export class DeviceTokensController {
  constructor(@Inject(SUPABASE_ADMIN) private readonly sb: SupabaseClient) {}

  @Post()
  async register(@Body() dto: RegisterTokenDto, @Req() req: any) {
    await this.sb.from('device_tokens').upsert(
      {
        user_id: req.userId,
        platform: dto.platform,
        token: dto.token,
        last_seen: new Date().toISOString(),
      },
      { onConflict: 'user_id,token' },
    );
    return { ok: true };
  }

  @Delete()
  async unregister(@Body('token') token: string, @Req() req: any) {
    await this.sb
      .from('device_tokens')
      .delete()
      .eq('user_id', req.userId)
      .eq('token', token);
    return { ok: true };
  }
}
