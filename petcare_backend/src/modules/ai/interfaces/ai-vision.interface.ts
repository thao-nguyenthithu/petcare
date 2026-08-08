export type TrangThaiXacMinh = 'DAT' | 'KHONG_DAT' | 'CHUA_XAC_MINH_DUOC';

export interface AiVerifyResult {
  trangThai: TrangThaiXacMinh;
  isSafe: boolean;
  confidence: number;
  code: string;
  reason: string;
  rawResponse: Record<string, unknown>;
}

export interface IAiVisionService {
  verifyPetSafety(imageUrl: string): Promise<AiVerifyResult>;
}

export const AI_VISION_SERVICE = 'AI_VISION_SERVICE';
