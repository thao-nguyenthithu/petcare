import { Module } from '@nestjs/common';
import { SitterServicesController } from './sitter-services.controller';
import { SitterServicesService } from './sitter-services.service';

@Module({
  controllers: [SitterServicesController],
  providers: [SitterServicesService],
})
export class SitterServicesModule {}
