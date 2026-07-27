import { Module } from '@nestjs/common';
import { AnthropicAdapter } from './adapters/anthropic.adapter';
import { AI_VISION_SERVICE } from './interfaces/ai-vision.interface';

@Module({
  providers: [
    {
      provide: AI_VISION_SERVICE,
      useClass: AnthropicAdapter,
    },
  ],
  exports: [AI_VISION_SERVICE],
})
export class AiModule {}
