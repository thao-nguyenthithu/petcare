import { OnWorkerEvent, Processor, WorkerHost } from '@nestjs/bullmq';
import { Inject, Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { Prisma } from '../../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { truLuotChupLai, type MaKetQuaAi } from '../../ai/ai-ket-luan';
import {
  AI_VISION_SERVICE,
  type IAiVisionService,
} from '../../ai/interfaces/ai-vision.interface';
import { AnhKyService } from '../../media/anh-ky.service';
import {
  CHECKIN_SCAN_QUEUE,
  VIEC_QUET_LO,
  type ViecQuetLo,
} from './checkin-scan.constants';
import { CheckinScanGateway } from './checkin-scan.gateway';
import { PetSafetyScanReadService } from './pet-safety-scan-read.service';

// Chấm nền vì 3 tới 5 lượt gọi nối tiếp là quá lâu cho một yêu cầu HTTP ngoài đường
@Processor(CHECKIN_SCAN_QUEUE)
export class CheckinScanProcessor extends WorkerHost {
  private readonly logger = new Logger(CheckinScanProcessor.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly scan: PetSafetyScanReadService,
    private readonly gateway: CheckinScanGateway,
    @Inject(AI_VISION_SERVICE) private readonly ai: IAiVisionService,
    private readonly kyAnh: AnhKyService,
  ) {
    super();
  }

  async process(job: Job<ViecQuetLo>) {
    if (job.name !== VIEC_QUET_LO) return;
    const { batchId, bookingId } = job.data;
    const dsCho = await this.prisma.petSafetyScan.findMany({
      where: { batchId, trangThai: null },
      select: { id: true, photoUrl: true },
    });
    const ky = await this.kyAnh.kyLo(dsCho.map((d) => d.photoUrl));
    await Promise.all(
      dsCho.map((d) => this.quetMot(d.id, ky.get(d.photoUrl) ?? d.photoUrl)),
    );
    await this.prisma.checkinScanBatch.update({
      where: { id: batchId },
      data: { trangThai: 'DONE', xongLuc: new Date() },
    });
    const bao = await this.scan.baoCaoTheoDon(bookingId);
    this.gateway.banKetQua(bookingId, { batchId, ...bao });
  }

  private async quetMot(id: string, photoUrl: string) {
    try {
      const ket = await this.ai.verifyPetSafety(photoUrl);
      const code = ket.code as MaKetQuaAi;
      await this.prisma.petSafetyScan.update({
        where: { id },
        data: {
          trangThai: ket.trangThai,
          code,
          confidence: ket.confidence,
          tinhLuot: truLuotChupLai(code),
          rawResponse: ket.rawResponse as Prisma.InputJsonValue,
          ketLuanLuc: new Date(),
        },
      });
    } catch (loi) {
      this.logger.error(`Không chốt được dòng quét ${id}`, loi as Error);
    }
  }

  @OnWorkerEvent('failed')
  onFailed(job: Job<ViecQuetLo>, error: Error) {
    this.logger.error(
      `Không quét xong lô ${job.data.batchId}: ${error.message}`,
    );
  }
}
