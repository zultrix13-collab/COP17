import { Controller, Get, Headers, Inject, Module, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_ADMIN } from '../../supabase/supabase.module';

export type Tier = 'green' | 'blue' | 'vip' | 'exhibitor' | 'press';

@ApiTags('users')
@Controller('users')
class UsersController {
  constructor(@Inject(SUPABASE_ADMIN) private readonly admin: SupabaseClient) {}

  @Get('me')
  async me(@Headers('authorization') auth?: string) {
    if (!auth?.startsWith('Bearer ')) throw new UnauthorizedException();
    const token = auth.slice(7);

    // Resolve the caller from their access token via a per-request client.
    const userClient = createClient(
      process.env.SUPABASE_URL!,
      process.env.SUPABASE_ANON_KEY!,
      { global: { headers: { Authorization: `Bearer ${token}` } } },
    );
    const { data: authData } = await userClient.auth.getUser();
    if (!authData.user) throw new UnauthorizedException();

    const { data, error } = await this.admin
      .from('profiles')
      .select('id, email, name, locale, tier')
      .eq('id', authData.user.id)
      .maybeSingle();
    if (error) throw error;
    if (!data) throw new NotFoundException();
    return data;
  }
}

@Module({ controllers: [UsersController] })
export class UsersModule {}
