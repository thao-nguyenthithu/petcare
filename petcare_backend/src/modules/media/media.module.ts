import { Global, Module } from '@nestjs/common';
import { AnhKyService } from './anh-ky.service';
import { AnhTaiLenService } from './anh-tai-len.service';
import { SupabaseService } from './supabase.service';

@Global()
@Module({
  providers: [SupabaseService, AnhTaiLenService, AnhKyService],
  exports: [SupabaseService, AnhTaiLenService, AnhKyService],
})
export class MediaModule {}
