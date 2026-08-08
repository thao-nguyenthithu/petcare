import { Module } from '@nestjs/common';
import { MediaModule } from '../../media/media.module';
import { SitterMeController } from './sitter-me.controller';
import { SitterMeService } from './sitter-me.service';

// Trang cá nhân NCC
@Module({
  imports: [MediaModule],
  controllers: [SitterMeController],
  providers: [SitterMeService],
})
export class SitterMeModule {}
