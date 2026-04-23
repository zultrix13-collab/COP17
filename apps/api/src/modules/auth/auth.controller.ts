import { Body, Controller, HttpCode, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { IsEmail } from 'class-validator';
import { AuthService } from './auth.service';

class RequestOtpDto {
  @IsEmail()
  email!: string;
}

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  /**
   * Pre-check the email against the accreditation whitelist, then trigger
   * Supabase to email the OTP code. Verification + token issuance happen
   * client-side via supabase.auth.verifyOtp().
   */
  @Post('otp/request')
  @HttpCode(202)
  requestOtp(@Body() dto: RequestOtpDto) {
    return this.auth.requestOtp(dto.email);
  }
}
