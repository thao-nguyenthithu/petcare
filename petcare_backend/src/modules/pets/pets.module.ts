import { Module } from '@nestjs/common';
import { MediaModule } from '../media/media.module';
import { PetsController } from './pets.controller';
import { PetsService } from './pets.service';
import { PreventionsService } from './preventions.service';

@Module({
  imports: [MediaModule],
  controllers: [PetsController],
  providers: [PetsService, PreventionsService],
})
export class PetsModule {}
