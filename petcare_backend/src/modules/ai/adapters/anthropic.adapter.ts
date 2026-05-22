import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { IAiVisionService, AiVerifyResult } from '../interfaces/ai-vision.interface';

@Injectable()
export class AnthropicAdapter implements IAiVisionService {
  constructor(private config: ConfigService) {}

  verifyPetSafety(_imageUrl: string): Promise<AiVerifyResult> {
    // TODO: Sprint 5 — implement Claude Vision API call
    return Promise.reject(new Error('Not implemented yet'));
  }
}