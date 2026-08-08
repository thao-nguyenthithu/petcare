import { Global, Module } from '@nestjs/common';
import { SystemSettingsService } from './system-settings.service';

// Global vì phải đúng MỘT bản cache, mỗi cụm một bản thì lệnh ghi hụt bản khác
@Global()
@Module({
  providers: [SystemSettingsService],
  exports: [SystemSettingsService],
})
export class ThamSoModule {}
