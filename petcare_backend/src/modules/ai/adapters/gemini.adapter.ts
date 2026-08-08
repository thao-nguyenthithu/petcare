import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AiImageLoader } from '../ai-image.loader';
import {
  chuaXacMinhDuoc,
  docBaoCao,
  ketLuanTuBaoCao,
  maLoiTheoTrangThai,
} from '../ai-ket-luan';
import {
  PROMPT_HE_THONG,
  PROMPT_NGUOI_DUNG,
  SCHEMA_GEMINI,
} from '../ai-prompt';
import { HAN_CHO_GOI_AI_MS } from '../ai.constants';
import {
  AiVerifyResult,
  IAiVisionService,
} from '../interfaces/ai-vision.interface';

const MODEL = 'gemini-2.5-flash';

const GOC_API = 'https://generativelanguage.googleapis.com/v1beta/models';

type TraLoiGemini = {
  candidates?: {
    content?: { parts?: { text?: string }[] };
    finishReason?: string;
  }[];
  usageMetadata?: { promptTokenCount?: number; candidatesTokenCount?: number };
};

@Injectable()
export class GeminiAdapter implements IAiVisionService {
  private readonly logger = new Logger(GeminiAdapter.name);

  constructor(
    private readonly config: ConfigService,
    private readonly loader: AiImageLoader,
  ) {}

  coKhoa(): boolean {
    return Boolean(this.config.get<string>('ai.geminiApiKey'));
  }

  async verifyPetSafety(imageUrl: string): Promise<AiVerifyResult> {
    const apiKey = this.config.get<string>('ai.geminiApiKey');
    if (!apiKey) {
      this.logger.error(
        'Thiếu GEMINI_API_KEY trong khi Gemini đang là nhà cung cấp đang chọn',
      );
      return chuaXacMinhDuoc('THIEU_KHOA_API');
    }
    const anh = await this.loader.tai(imageUrl);
    if (!anh.ok) return chuaXacMinhDuoc(anh.code);

    const dauVet: Record<string, unknown> = {
      nhaCungCap: 'gemini',
      model: MODEL,
    };
    try {
      const res = await fetch(`${GOC_API}/${MODEL}:generateContent`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        signal: AbortSignal.timeout(HAN_CHO_GOI_AI_MS),
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: PROMPT_HE_THONG }] },
          contents: [
            {
              role: 'user',
              parts: [
                {
                  inline_data: {
                    mime_type: anh.anh.contentType,
                    data: anh.anh.base64,
                  },
                },
                { text: PROMPT_NGUOI_DUNG },
              ],
            },
          ],
          generationConfig: {
            temperature: 0,
            responseMimeType: 'application/json',
            responseSchema: SCHEMA_GEMINI,
          },
        }),
      });

      if (!res.ok) {
        const code = maLoiTheoTrangThai(res.status);
        this.logger.error(`Gọi Gemini hỏng, HTTP ${res.status}, mã ${code}`);
        return chuaXacMinhDuoc(code, dauVet);
      }

      const data = (await res.json()) as TraLoiGemini;
      const ungVien = data.candidates?.[0];
      dauVet.finishReason = ungVien?.finishReason ?? null;
      dauVet.tokenVao = data.usageMetadata?.promptTokenCount ?? null;
      dauVet.tokenRa = data.usageMetadata?.candidatesTokenCount ?? null;

      const baoCao = docBaoCao(docJson(ungVien?.content?.parts?.[0]?.text));
      dauVet.baoCao = baoCao;
      if (!baoCao) {
        this.logger.error(
          `Gemini không trả về báo cáo đọc được, finishReason ${ungVien?.finishReason}`,
        );
        return chuaXacMinhDuoc('KET_QUA_KHONG_DOC_DUOC', dauVet);
      }
      return ketLuanTuBaoCao(baoCao, dauVet);
    } catch (loi) {
      const quaHan = (loi as Error).name === 'TimeoutError';
      const code = quaHan ? 'QUA_HAN_CHO' : 'LOI_DICH_VU_AI';
      this.logger.error(`Gọi Gemini hỏng, mã ${code}`, loi as Error);
      return chuaXacMinhDuoc(code, dauVet);
    }
  }
}

function docJson(tho: string | undefined): unknown {
  if (!tho) return null;
  try {
    return JSON.parse(tho);
  } catch {
    return null;
  }
}
