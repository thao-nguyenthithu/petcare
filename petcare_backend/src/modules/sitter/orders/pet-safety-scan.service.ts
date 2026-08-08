import { InjectQueue } from '@nestjs/bullmq';
import {
  BadRequestException,
  ConflictException,
  Injectable,
  PayloadTooLargeException,
} from '@nestjs/common';
import { Queue } from 'bullmq';
import { PrismaService } from '../../../prisma/prisma.service';
import { SystemSettingsService } from '../../admin/system-settings.service';
import {
  HAN_CHO_GOI_AI_MS,
  SO_LUOT_CHUP_MOI_BE,
  SO_LAN_GOI_TOI_DA_MOI_DON,
} from '../../ai/ai.constants';
import { canhDai, doKichThuoc } from '../../media/anh-kich-thuoc';
import { kiemTraAnh, type UploadedImage } from '../../media/image-upload';
import {
  CHECKIN_SCAN_QUEUE,
  VIEC_QUET_LO,
  type ViecQuetLo,
} from './checkin-scan.constants';
import {
  conLai,
  cuaSlot,
  slotDaDat,
  tranAnhMoiLuot,
  duocTuXacNhan,
  type DongQuet,
} from './checkin-scan.dem';
import { PetSafetyScanReadService } from './pet-safety-scan-read.service';
import {
  chiDichVu,
  phaiDangO,
  SitterOrderStore,
  type DonMayTrangThai,
} from './sitter-order-store.service';

const HAN_LO_TREO_MS = HAN_CHO_GOI_AI_MS * 3;

type ToaDo = { lat?: number; lng?: number };

@Injectable()
export class PetSafetyScanService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly store: SitterOrderStore,
    private readonly thamSo: SystemSettingsService,
    @InjectQueue(CHECKIN_SCAN_QUEUE) private readonly hangDoi: Queue,
    private readonly doc: PetSafetyScanReadService,
  ) {}

  private choPhepQuet(don: DonMayTrangThai) {
    phaiDangO(don, ['CONFIRMED']);
    chiDichVu(don, 'walking');
    if (!don.arrivedAt) {
      throw new ConflictException({
        code: 'CHUA_TOI_DIEM_DON',
        message: 'Cần báo đã tới điểm đón trước khi gửi ảnh',
      });
    }
  }

  private doAnh(file: UploadedImage): number {
    const kt = doKichThuoc(file.buffer!);
    if (!kt) {
      throw new BadRequestException({
        code: 'KHONG_DOC_DUOC_KICH_THUOC_ANH',
        message: 'Không đọc được kích thước ảnh. Hãy chụp lại bằng máy ảnh.',
      });
    }
    return canhDai(kt);
  }

  private docSlot(tho: string | undefined, soFile: number): number[] {
    const ds = (tho ?? '')
      .split(',')
      .map((s) => Number(s.trim()))
      .filter((n) => Number.isInteger(n));
    if (ds.length !== soFile) {
      throw new BadRequestException({
        code: 'SAI_DANH_SACH_SLOT',
        message: 'Danh sách chỗ chụp không khớp số ảnh gửi lên',
      });
    }
    return ds;
  }

  private async chanLoDangChay(bookingId: string) {
    const hanChet = new Date(Date.now() - HAN_LO_TREO_MS);
    const dangChay = await this.prisma.checkinScanBatch.findFirst({
      where: {
        bookingId,
        trangThai: 'PROCESSING',
        taoLuc: { gt: hanChet },
      },
      select: { id: true },
    });
    if (dangChay) {
      throw new ConflictException({
        code: 'DANG_QUET_LO_TRUOC',
        message: 'Lô ảnh trước đang được chấm, hãy đợi kết quả',
      });
    }
    await this.prisma.checkinScanBatch.updateMany({
      where: { bookingId, trangThai: 'PROCESSING', taoLuc: { lte: hanChet } },
      data: { trangThai: 'DONE', xongLuc: new Date() },
    });
    await this.chotDongTreo(bookingId);
  }

  private async chotDongTreo(bookingId: string) {
    await this.prisma.petSafetyScan.updateMany({
      where: { bookingId, trangThai: null },
      data: {
        trangThai: 'CHUA_XAC_MINH_DUOC',
        code: 'LOI_DICH_VU_AI',
        tinhLuot: false,
        ketLuanLuc: new Date(),
      },
    });
  }

  async nhanLo(
    userId: string,
    bookingId: string,
    files: UploadedImage[],
    slotTho: string | undefined,
    viTri: ToaDo,
  ) {
    const { don } = await this.store.timDon(userId, bookingId);
    this.choPhepQuet(don);
    const soBe = don._count.pets;
    if (!files?.length) {
      throw new BadRequestException({
        code: 'THIEU_ANH',
        message: 'Cần gửi ảnh của cả đàn và từng bé',
      });
    }
    if (files.length > tranAnhMoiLuot(soBe)) {
      throw new PayloadTooLargeException({
        code: 'VUOT_TRAN_ANH_MOI_LUOT',
        message: `Mỗi lượt gửi tối đa ${tranAnhMoiLuot(soBe)} ảnh`,
      });
    }
    const slots = this.docSlot(slotTho, files.length);
    const canhDaiTheoFile = files.map((file) => {
      kiemTraAnh(file);
      return this.doAnh(file);
    });

    await this.chanLoDangChay(don.id);
    const [ds, daXacNhan] = await Promise.all([
      this.doc.docQuet(don.id),
      this.doc.docXacNhan(don.id),
    ]);
    const canQuet = this.kiemTraLo(ds, daXacNhan, slots, soBe);

    const urls = await this.store.dayAnhLenStorage(don.id, files);
    const anhCaDan = slots.indexOf(0) >= 0 ? urls[slots.indexOf(0)] : null;
    const nhaAi = this.thamSo.nhaAi();
    let batch: { id: string; taoLuc: Date };
    try {
      batch = await this.prisma.checkinScanBatch.create({
        data: {
          bookingId: don.id,
          anhCaDanUrl: anhCaDan,
          scans: {
            create: canQuet.map((slot) => ({
              bookingId: don.id,
              slotIndex: slot,
              soLan: cuaSlot(ds, slot).length + 1,
              photoUrl: urls[slots.indexOf(slot)],
              canhDaiPx: canhDaiTheoFile[slots.indexOf(slot)],
              lat: viTri.lat ?? null,
              lng: viTri.lng ?? null,
              provider: nhaAi,
            })),
          },
        },
        select: { id: true, taoLuc: true },
      });
    } catch {
      throw new ConflictException({
        code: 'DANG_QUET_LO_TRUOC',
        message: 'Một lô ảnh của đơn này đang được chấm, hãy đợi kết quả',
      });
    }

    await this.hangDoi.add(
      VIEC_QUET_LO,
      { batchId: batch.id, bookingId: don.id } satisfies ViecQuetLo,
      { attempts: 1, removeOnComplete: true },
    );
    return {
      batchId: batch.id,
      trangThai: 'PROCESSING',
      soTamQuet: canQuet.length,
      taoLuc: batch.taoLuc,
    };
  }

  private kiemTraLo(
    ds: DongQuet[],
    daXacNhan: ReadonlySet<number>,
    slots: number[],
    soBe: number,
  ): number[] {
    if (new Set(slots).size !== slots.length) {
      throw new BadRequestException({
        code: 'TRUNG_SLOT_TRONG_LO',
        message: 'Mỗi chỗ chụp chỉ được một ảnh trong một lượt gửi',
      });
    }
    for (const slot of slots) {
      if (slot < 0 || slot > soBe) {
        throw new BadRequestException({
          code: 'SLOT_KHONG_HOP_LE',
          message: `Chỗ chụp phải nằm trong khoảng 0 tới ${soBe}`,
        });
      }
      if (slot >= 1 && slotDaDat(ds, slot)) {
        throw new ConflictException({
          code: 'SLOT_DA_DAT',
          message: `Bé ${slot} đã qua kiểm, không chụp đè lên`,
        });
      }
    }
    const canQuet = slots.filter((s) => s >= 1);
    if (!ds.length) {
      const duCaDan = slots.includes(0) && canQuet.length === soBe;
      if (!duCaDan) {
        throw new BadRequestException({
          code: 'THIEU_ANH_LO_DAU',
          message: `Lô đầu cần một ảnh cả đàn và mỗi bé một ảnh, tổng ${soBe + 1} ảnh`,
        });
      }
    }
    if (!canQuet.length) {
      throw new BadRequestException({
        code: 'THIEU_ANH_BE',
        message: 'Lô này không có ảnh bé nào để quét',
      });
    }
    for (const slot of canQuet) {
      if (conLai(ds, slot) === 0) {
        throw new ConflictException({
          code: 'HET_LUOT_CHUP_LAI',
          message: `Bé ${slot} đã dùng hết ${SO_LUOT_CHUP_MOI_BE} lượt chụp, hãy tự xác nhận`,
        });
      }
      if (daXacNhan.has(slot)) {
        throw new ConflictException({
          code: 'SLOT_DA_TU_XAC_NHAN',
          message: `Bé ${slot} đã được bạn tự xác nhận`,
        });
      }
    }
    if (ds.length + canQuet.length > SO_LAN_GOI_TOI_DA_MOI_DON) {
      throw new ConflictException({
        code: 'HET_LUOT_QUET_CUA_DON',
        message: `Đơn này chỉ được quét tối đa ${SO_LAN_GOI_TOI_DA_MOI_DON} lượt`,
      });
    }
    return canQuet;
  }

  async tuXacNhan(
    userId: string,
    bookingId: string,
    slotIndex: number,
    viTri: ToaDo,
  ) {
    const { don } = await this.store.timDon(userId, bookingId);
    this.choPhepQuet(don);
    if (slotIndex < 1 || slotIndex > don._count.pets) {
      throw new BadRequestException({
        code: 'SLOT_KHONG_HOP_LE',
        message: 'Chỗ chụp không thuộc đơn',
      });
    }
    const ds = await this.doc.docQuet(don.id);
    const conQuota = ds.length < SO_LAN_GOI_TOI_DA_MOI_DON;
    if (!duocTuXacNhan(ds, slotIndex, conQuota)) {
      throw new ConflictException({
        code: 'CHUA_DUOC_TU_XAC_NHAN',
        message: 'Bé này chưa tới bước tự xác nhận, hãy chụp lại',
      });
    }
    const ban = await this.prisma.checkinSlotXacNhan.upsert({
      where: { bookingId_slotIndex: { bookingId: don.id, slotIndex } },
      create: {
        bookingId: don.id,
        slotIndex,
        boiUserId: userId,
        lat: viTri.lat ?? null,
        lng: viTri.lng ?? null,
      },
      update: {},
      select: { luc: true, boiUserId: true },
    });
    const daXacNhan = await this.doc.docXacNhan(don.id);
    return {
      slotIndex,
      xacNhanLuc: ban.luc,
      boiUserId: ban.boiUserId,
      ...(await this.doc.dungBaoCao(ds, daXacNhan, don._count.pets)),
    };
  }

  async duocVaoRoom(userId: string, bookingId: string): Promise<boolean> {
    try {
      await this.store.timDon(userId, bookingId);
      return true;
    } catch {
      return false;
    }
  }
}
