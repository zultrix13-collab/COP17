import { Body, Controller, Inject, Module, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { ArrayNotEmpty, IsArray, IsEnum, IsOptional, IsString } from 'class-validator';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_ADMIN } from '../../supabase/supabase.module';
import { AdminGuard } from '../../common/admin.guard';

const TIERS = ['green', 'blue', 'vip', 'exhibitor', 'press'] as const;
type Tier = (typeof TIERS)[number];

class BulkTierDto {
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  userIds!: string[];

  @IsEnum(TIERS)
  toTier!: Tier;

  @IsOptional()
  @IsString()
  reason?: string;
}

@ApiTags('admin')
@ApiBearerAuth()
@UseGuards(AdminGuard)
@Controller('admin')
class AdminController {
  constructor(@Inject(SUPABASE_ADMIN) private readonly sb: SupabaseClient) {}

  @Post('users/bulk-tier')
  async bulkTier(@Body() dto: BulkTierDto, @Req() req: any) {
    const { data: existing, error: selErr } = await this.sb
      .from('profiles')
      .select('id, tier')
      .in('id', dto.userIds);
    if (selErr) throw selErr;

    const toUpdate = existing!.filter((r) => r.tier !== dto.toTier);
    if (toUpdate.length === 0) return { updated: 0 };

    const { error: upErr } = await this.sb
      .from('profiles')
      .update({ tier: dto.toTier })
      .in('id', toUpdate.map((r) => r.id));
    if (upErr) throw upErr;

    const { error: logErr } = await this.sb.from('tier_changes').insert(
      toUpdate.map((r) => ({
        user_id: r.id,
        from_tier: r.tier,
        to_tier: dto.toTier,
        admin_id: req.adminUserId,
        reason: dto.reason ?? 'bulk upgrade',
      })),
    );
    if (logErr) throw logErr;

    // TODO: enqueue push notifications to each r.id via NotificationsService.
    return { updated: toUpdate.length };
  }
}

@Module({ controllers: [AdminController], providers: [AdminGuard] })
export class AdminModule {}
