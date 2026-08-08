import { Module } from '@nestjs/common';
import { SitterOrdersModule } from '../orders/sitter-orders.module';
import { SitterScheduleController } from './sitter-schedule.controller';
import { ScheduleSettingsService } from './schedule-settings.service';
import { ScheduleViewService } from './schedule-view.service';
import { SitterScheduleService } from './sitter-schedule.service';

@Module({
  imports: [SitterOrdersModule],
  controllers: [SitterScheduleController],
  providers: [
    SitterScheduleService,
    ScheduleViewService,
    ScheduleSettingsService,
  ],
})
export class SitterScheduleModule {}
