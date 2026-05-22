import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { IAiVisionService, AiVerifyResult } from '../interfaces/ai-vision.interface';

@Injectable()
export class AnthropicAdapter implements IAiVisionService {
  constructor(private config: ConfigService) {}

  async verifyPetSafety(imageUrl: string): Promise<AiVerifyResult> {
    // TODO: Sprint 5 — implement Claude Vision API call
    throw new Error('Not implemented yet');
  }
}
