import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService {
  private client: SupabaseClient;

  constructor(private config: ConfigService) {
    const supabaseUrl = this.config.get<string>('SUPABASE_URL');
    const supabaseKey = this.config.get<string>('SUPABASE_SERVICE_KEY');

    if (!supabaseUrl || !supabaseKey) {
        throw new Error('Thiếu SUPABASE_URL hoặc SUPABASE_SERVICE_KEY trong file .env');
    }

    this.client = createClient(supabaseUrl, supabaseKey);
}

  getClient(): SupabaseClient {
    return this.client;
  }

  async deleteFile(bucket: string, path: string): Promise<void> {
    const { error } = await this.client.storage
      .from(bucket)
      .remove([path]);
    if (error) throw new Error(error.message);
  }
}