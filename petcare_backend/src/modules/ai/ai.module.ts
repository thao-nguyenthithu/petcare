import { Module } from '@nestjs/common';
import { AiImageLoader } from './ai-image.loader';
import { AiVisionDispatcher } from './ai-vision.dispatcher';
import { AnthropicAdapter } from './adapters/anthropic.adapter';
import { GeminiAdapter } from './adapters/gemini.adapter';
import { AI_VISION_SERVICE } from './interfaces/ai-vision.interface';

@Module({
  providers: [
    AiImageLoader,
    AnthropicAdapter,
    GeminiAdapter,
    {
      provide: AI_VISION_SERVICE,
      useClass: AiVisionDispatcher,
    },
  ],
  exports: [AI_VISION_SERVICE],
})
export class AiModule {}
