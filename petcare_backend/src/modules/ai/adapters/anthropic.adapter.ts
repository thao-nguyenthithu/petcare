import Anthropic from '@anthropic-ai/sdk';
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
  MO_TA_CONG_CU,
  PROMPT_HE_THONG,
  PROMPT_NGUOI_DUNG,
  SCHEMA_ANTHROPIC,
  TEN_CONG_CU,
} from '../ai-prompt';
import { HAN_CHO_GOI_AI_MS } from '../ai.constants';
import {
  AiVerifyResult,
  IAiVisionService,
} from '../interfaces/ai-vision.interface';

const MODEL = 'claude-sonnet-5';

const TRAN_TOKEN_TRA_VE = 512;

const SO_LAN_THU_LAI = 1;

@Injectable()
export class AnthropicAdapter implements IAiVisionService {
  private readonly logger = new Logger(AnthropicAdapter.name);
  private client: Anthropic | null = null;

  constructor(
    private readonly config: ConfigService,
    private readonly loader: AiImageLoader,
  ) {}

  coKhoa(): boolean {
    return Boolean(this.config.get<string>('ai.anthropicApiKey'));
  }

  private layClient(): Anthropic | null {
    if (this.client) return this.client;
    const apiKey = this.config.get<string>('ai.anthropicApiKey');
    if (!apiKey) return null;
    this.client = new Anthropic({
      apiKey,
      timeout: HAN_CHO_GOI_AI_MS,
      maxRetries: SO_LAN_THU_LAI,
    });
    return this.client;
  }

  async verifyPetSafety(imageUrl: string): Promise<AiVerifyResult> {
    const client = this.layClient();
    if (!client) {
      this.logger.error(
        'Thiếu ANTHROPIC_API_KEY trong khi Anthropic đang là nhà cung cấp đang chọn',
      );
      return chuaXacMinhDuoc('THIEU_KHOA_API');
    }
    const anh = await this.loader.tai(imageUrl);
    if (!anh.ok) return chuaXacMinhDuoc(anh.code);

    try {
      const res = await client.messages.create({
        model: MODEL,
        max_tokens: TRAN_TOKEN_TRA_VE,
        temperature: 0,
        system: PROMPT_HE_THONG,
        tools: [
          {
            name: TEN_CONG_CU,
            description: MO_TA_CONG_CU,
            input_schema: SCHEMA_ANTHROPIC,
          },
        ],
        tool_choice: { type: 'tool', name: TEN_CONG_CU },
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'image',
                source: {
                  type: 'base64',
                  media_type: anh.anh.contentType,
                  data: anh.anh.base64,
                },
              },
              { type: 'text', text: PROMPT_NGUOI_DUNG },
            ],
          },
        ],
      });

      const khoi = res.content.find((c) => c.type === 'tool_use');
      const baoCao = docBaoCao(khoi?.type === 'tool_use' ? khoi.input : null);
      const dauVet = {
        nhaCungCap: 'anthropic',
        model: MODEL,
        stopReason: res.stop_reason,
        tokenVao: res.usage.input_tokens,
        tokenRa: res.usage.output_tokens,
        baoCao,
      };
      if (!baoCao) {
        this.logger.error(
          `Anthropic không trả về báo cáo đọc được, stop_reason ${res.stop_reason}`,
        );
        return chuaXacMinhDuoc('KET_QUA_KHONG_DOC_DUOC', dauVet);
      }
      return ketLuanTuBaoCao(baoCao, dauVet);
    } catch (loi) {
      const status = (loi as { status?: number }).status;
      const code = maLoiTheoTrangThai(status);
      this.logger.error(`Gọi Anthropic hỏng, mã ${code}`, loi as Error);
      return chuaXacMinhDuoc(code, { nhaCungCap: 'anthropic', model: MODEL });
    }
  }
}
