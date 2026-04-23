import { Body, Controller, Module, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { IsEnum, IsString, MaxLength, MinLength } from 'class-validator';
import { AuthGuard } from '../../common/auth.guard';
import { AdminGuard } from '../../common/admin.guard';
import { AiService } from './ai.service';
import { EmbeddingsService } from './embeddings.service';

class ChatDto {
  @IsString() @MinLength(2) @MaxLength(500)
  message!: string;

  @IsEnum(['mn', 'en'] as const)
  locale!: 'mn' | 'en';
}

@ApiTags('ai')
@Controller('ai')
class AiController {
  constructor(
    private readonly ai: AiService,
    private readonly embeddings: EmbeddingsService,
  ) {}

  @Post('chat')
  @ApiBearerAuth()
  @UseGuards(AuthGuard)
  chat(@Body() dto: ChatDto) {
    return this.ai.chat(dto.message, dto.locale);
  }

  @Post('reindex')
  @ApiBearerAuth()
  @UseGuards(AdminGuard)
  reindex() {
    return this.embeddings.reindex();
  }
}

@Module({
  controllers: [AiController],
  providers: [AiService, EmbeddingsService, AuthGuard, AdminGuard],
})
export class AiModule {}
