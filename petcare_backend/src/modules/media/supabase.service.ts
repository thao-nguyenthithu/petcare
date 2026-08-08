import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService {
  private client: SupabaseClient;

  private readonly khoDaSan = new Set<string>();

  constructor(private config: ConfigService) {
    const supabaseUrl = this.config.get<string>('SUPABASE_URL');
    const supabaseKey = this.config.get<string>('SUPABASE_SERVICE_KEY');

    if (!supabaseUrl || !supabaseKey) {
      throw new Error(
        'Thiếu SUPABASE_URL hoặc SUPABASE_SERVICE_KEY trong file .env',
      );
    }

    this.client = createClient(supabaseUrl, supabaseKey);
  }

  getClient(): SupabaseClient {
    return this.client;
  }

  async uploadFile(
    bucket: string,
    path: string,
    file: Buffer,
    contentType: string,
  ): Promise<string> {
    const { error } = await this.client.storage
      .from(bucket)
      .upload(path, file, { contentType, upsert: false });
    if (error) throw new Error(error.message);
    return path;
  }

  getPublicUrl(bucket: string, path: string): string {
    return this.client.storage.from(bucket).getPublicUrl(path).data.publicUrl;
  }

  async ensurePublicBucket(bucket: string): Promise<void> {
    if (this.khoDaSan.has(bucket)) return;
    const { error } = await this.client.storage.createBucket(bucket, {
      public: true,
    });
    if (error && !/exist|duplicate/i.test(error.message)) {
      throw new Error(error.message);
    }
    this.khoDaSan.add(bucket);
  }

  async ensurePrivateBucket(bucket: string): Promise<void> {
    if (this.khoDaSan.has(bucket)) return;
    const { error } = await this.client.storage.createBucket(bucket, {
      public: false,
    });
    if (error) {
      if (!/exist|duplicate/i.test(error.message)) {
        throw new Error(error.message);
      }
      const { error: loi } = await this.client.storage.updateBucket(bucket, {
        public: false,
      });
      if (loi) throw new Error(loi.message);
    }
    this.khoDaSan.add(bucket);
  }

  async deleteFile(bucket: string, path: string): Promise<void> {
    const { error } = await this.client.storage.from(bucket).remove([path]);
    if (error) throw new Error(error.message);
  }
}
