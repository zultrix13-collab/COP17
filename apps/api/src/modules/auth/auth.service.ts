import { ForbiddenException, Inject, Injectable } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_ADMIN } from '../../supabase/supabase.module';

@Injectable()
export class AuthService {
  constructor(@Inject(SUPABASE_ADMIN) private readonly supabase: SupabaseClient) {}

  async requestOtp(email: string) {
    // 1. Accreditation whitelist check — only registered delegates may sign in.
    const { data: allowed, error: lookupErr } = await this.supabase
      .from('accreditation_whitelist')
      .select('email')
      .eq('email', email.toLowerCase())
      .maybeSingle();
    if (lookupErr) throw lookupErr;
    if (!allowed) {
      throw new ForbiddenException('Email is not registered for COP17');
    }

    // 2. Ask Supabase to email the OTP code.
    //    Client will POST the code to supabase.auth.verifyOtp({ email, token }).
    const { error } = await this.supabase.auth.signInWithOtp({
      email,
      options: { shouldCreateUser: true },
    });
    if (error) throw error;
    return { status: 'sent', expiresInSec: 300 };
  }
}
