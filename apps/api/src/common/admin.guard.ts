import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_ADMIN } from '../supabase/supabase.module';

/**
 * Requires a valid Supabase access token whose user has a row in admin_roles.
 * Attaches `req.adminUserId` for downstream handlers.
 */
@Injectable()
export class AdminGuard implements CanActivate {
  constructor(@Inject(SUPABASE_ADMIN) private readonly admin: SupabaseClient) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const req = ctx.switchToHttp().getRequest();
    const header: string | undefined = req.headers['authorization'];
    if (!header?.startsWith('Bearer ')) throw new UnauthorizedException();
    const token = header.slice(7);

    const userClient = createClient(
      process.env.SUPABASE_URL!,
      process.env.SUPABASE_ANON_KEY!,
      { global: { headers: { Authorization: `Bearer ${token}` } } },
    );
    const { data: authData } = await userClient.auth.getUser();
    if (!authData.user) throw new UnauthorizedException();

    const { data: role } = await this.admin
      .from('admin_roles')
      .select('role')
      .eq('user_id', authData.user.id)
      .maybeSingle();
    if (!role) throw new ForbiddenException('Admin only');

    req.adminUserId = authData.user.id;
    req.adminRole = role.role;
    return true;
  }
}
