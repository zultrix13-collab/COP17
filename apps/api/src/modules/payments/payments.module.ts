import { Body, Controller, Get, Module, Param, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { IsInt, IsString, Min } from 'class-validator';
import { AuthGuard } from '../../common/auth.guard';
import { WalletModule } from '../wallet/wallet.module';
import { QPayService } from './qpay.service';
import { QPayWebhookGuard } from './qpay-webhook.guard';

class TopUpDto {
  @IsInt() @Min(1000)
  amount!: number;
}

class WebhookDto {
  @IsString()
  qpayInvoiceId!: string;
}

@ApiTags('payments')
@Controller('payments/qpay')
class PaymentsController {
  constructor(private readonly qpay: QPayService) {}

  @Post('top-up')
  @ApiBearerAuth()
  @UseGuards(AuthGuard)
  topUp(@Body() dto: TopUpDto, @Req() req: any) {
    return this.qpay.createTopUp(req.userId, dto.amount);
  }

  @Get(':invoiceId/status')
  @ApiBearerAuth()
  @UseGuards(AuthGuard)
  status(@Param('invoiceId') invoiceId: string) {
    return this.qpay.status(invoiceId).then((status) => ({ status }));
  }

  /**
   * QPay → our webhook. No AuthGuard; QPay authenticates via signed body /
   * HMAC header in production. Add verification once credentials are in.
   */
  @Post('webhook')
  @UseGuards(QPayWebhookGuard)
  async webhook(@Body() dto: WebhookDto) {
    await this.qpay.handleWebhook(dto.qpayInvoiceId);
    return { ok: true };
  }
}

@Module({
  imports: [WalletModule],
  controllers: [PaymentsController],
  providers: [QPayService, AuthGuard, QPayWebhookGuard],
  exports: [QPayService],
})
export class PaymentsModule {}
