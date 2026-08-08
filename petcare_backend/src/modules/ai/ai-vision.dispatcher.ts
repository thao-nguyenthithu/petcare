import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { SystemSettingsService } from '../admin/system-settings.service';
import { AnthropicAdapter } from './adapters/anthropic.adapter';
import { GeminiAdapter } from './adapters/gemini.adapter';
import {
  AiVerifyResult,
  IAiVisionService,
} from './interfaces/ai-vision.interface';

@Injectable()
export class AiVisionDispatcher implements IAiVisionService, OnModuleInit {
  private readonly logger = new Logger(AiVisionDispatcher.name);

  constructor(
    private readonly thamSo: SystemSettingsService,
    private readonly anthropic: AnthropicAdapter,
    private readonly gemini: GeminiAdapter,
  ) {}

  onModuleInit() {
    const nha = this.thamSo.nhaAi();
    if (!this.chon().coKhoa()) {
      this.logger.error(
        `Nhà cung cấp nhận diện ảnh đang chọn là ${nha} nhưng thiếu khoá API, mọi lượt quét sẽ trả về chưa xác minh được`,
      );
    }
  }

  // Đọc lại tham số mỗi lượt gọi
  private chon(): AnthropicAdapter | GeminiAdapter {
    return this.thamSo.nhaAi() === 'gemini' ? this.gemini : this.anthropic;
  }

  verifyPetSafety(imageUrl: string): Promise<AiVerifyResult> {
    return this.chon().verifyPetSafety(imageUrl);
  }
}
