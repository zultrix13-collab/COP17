import { Body, Controller, Module, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { IsArray, IsObject, IsOptional, IsString } from 'class-validator';
import { AdminGuard } from '../../common/admin.guard';
import { AuthGuard } from '../../common/auth.guard';
import { NotificationsService, PushPayload } from './notifications.service';
import { DeviceTokensController } from './device-tokens.controller';

class SendDto implements PushPayload {
  @IsArray() @IsString({ each: true })
  userIds!: string[];

  @IsString()
  topic!: string;

  @IsObject()
  title!: { mn: string; en: string };

  @IsObject()
  body!: { mn: string; en: string };

  @IsOptional() @IsObject()
  data?: Record<string, string>;
}

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(AdminGuard)
@Controller('notifications')
class NotificationsController {
  constructor(private readonly svc: NotificationsService) {}

  @Post('send')
  send(@Body() dto: SendDto) {
    return this.svc.send(dto);
  }
}

@Module({
  controllers: [NotificationsController, DeviceTokensController],
  providers: [NotificationsService, AdminGuard, AuthGuard],
  exports: [NotificationsService],
})
export class NotificationsModule {}
