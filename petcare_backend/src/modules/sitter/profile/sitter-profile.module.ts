import { Module } from '@nestjs/common';
import { MediaModule } from '../../media/media.module';
import { SitterProfileController } from './sitter-profile.controller';
import { SitterProfileService } from './sitter-profile.service';

@Module({
  imports: [MediaModule],
  controllers: [SitterProfileController],
  providers: [SitterProfileService],
})
export class SitterProfileModule {}
