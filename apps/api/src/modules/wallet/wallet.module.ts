import { Body, Controller, Get, Module, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { ArrayNotEmpty, IsArray, IsInt, IsString, Min, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { AuthGuard } from '../../common/auth.guard';
import { WalletService } from './wallet.service';

class CartItemDto {
  @IsString() productId!: string;
  @IsInt() @Min(1) quantity!: number;
}

class PurchaseDto {
  @IsArray() @ArrayNotEmpty() @ValidateNested({ each: true }) @Type(() => CartItemDto)
  items!: CartItemDto[];
}

@ApiTags('wallet')
@ApiBearerAuth()
@UseGuards(AuthGuard)
@Controller('wallet')
class WalletController {
  constructor(private readonly svc: WalletService) {}

  @Get('balance')
  balance(@Req() req: any) {
    return this.svc.balance(req.userId).then((balance) => ({ balance }));
  }

  @Post('purchase')
  purchase(@Body() dto: PurchaseDto, @Req() req: any) {
    return this.svc.purchase(req.userId, dto.items);
  }
}

@Module({
  controllers: [WalletController],
  providers: [WalletService, AuthGuard],
  exports: [WalletService],
})
export class WalletModule {}
