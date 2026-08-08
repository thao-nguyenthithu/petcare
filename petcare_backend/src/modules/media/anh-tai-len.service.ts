import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { kiemTraAnh, type UploadedImage } from './image-upload';
import { SupabaseService } from './supabase.service';

@Injectable()
export class AnhTaiLenService {
  constructor(private readonly supabase: SupabaseService) {}

  async dayLen(
    bucket: string,
    thuMuc: string,
    files: UploadedImage[],
  ): Promise<string[]> {
    if (!files?.length) return [];
    const daKiem = files.map((f) => ({ file: f, kieu: kiemTraAnh(f) }));
    await this.supabase.ensurePrivateBucket(bucket);
    const duong: string[] = [];
    for (const { file, kieu } of daKiem) {
      const path = `${thuMuc}/${randomUUID()}.${kieu.duoi}`;
      await this.supabase.uploadFile(
        bucket,
        path,
        file.buffer!,
        kieu.contentType,
      );
      duong.push(path);
    }
    return duong;
  }
}
