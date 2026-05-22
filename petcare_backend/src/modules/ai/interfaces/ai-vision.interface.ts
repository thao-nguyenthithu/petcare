export interface AiVerifyResult {
  isSafe:      boolean;
  confidence:  number;
  reason:      string;
  rawResponse: Record<string, unknown>;
}

export interface IAiVisionService {
  verifyPetSafety(imageUrl: string): Promise<AiVerifyResult>;
}

export const AI_VISION_SERVICE = 'AI_VISION_SERVICE';
