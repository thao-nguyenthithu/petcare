import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CycleUnit } from 'generated/prisma/enums';
import { PrismaService } from '../../prisma/prisma.service';
import { SupabaseService } from '../media/supabase.service';
import { CreateDoseDto } from './dto/create-dose.dto';
import { CreatePreventionDto } from './dto/create-prevention.dto';
import { UpdateDoseDto } from './dto/update-dose.dto';
import { PetsCommon, type UploadedImage } from './pets.shared';

// Ảnh phiếu tối đa mỗi lần ghi
const MAX_DOSE_PHOTOS = 5;

// Mã hạng mục tự đặt tên
const MA_HANG_MUC_KHAC = 'khac';

// Danh mục dựng sẵn
const MAX_HANG_MUC_MOI_BE = 30;
const MAX_LAN_MOI_HANG_MUC = 100;

// Sổ phòng bệnh của bé
@Injectable()
export class PreventionsService extends PetsCommon {
  constructor(prisma: PrismaService, supabase: SupabaseService) {
    super(prisma, supabase);
  }

  // POST /pets/:id/preventions tạo hạng mục
  async create(userId: string, id: string, dto: CreatePreventionDto) {
    await this.timCuaToi(userId, id);
    const tenTuNhap = dto.customName?.trim();
    if (dto.code === MA_HANG_MUC_KHAC && !tenTuNhap) {
      throw new BadRequestException({
        code: 'THIEU_TEN_HANG_MUC',
        message: 'Hạng mục tự nhập phải có tên',
      });
    }
    const soHangMuc = await this.prisma.preventionRecord.count({
      where: { petId: id },
    });
    if (soHangMuc >= MAX_HANG_MUC_MOI_BE) {
      throw new BadRequestException({
        code: 'VUOT_GIOI_HAN_HANG_MUC',
        message: `Mỗi bé chỉ giữ tối đa ${MAX_HANG_MUC_MOI_BE} hạng mục`,
      });
    }
    if (dto.code !== MA_HANG_MUC_KHAC) {
      const daCo = await this.prisma.preventionRecord.findFirst({
        where: { petId: id, code: dto.code },
        select: { id: true },
      });
      if (daCo) {
        throw new BadRequestException({
          code: 'HANG_MUC_DA_CO',
          message: 'Hạng mục này đã có trong sổ phòng bệnh của bé',
        });
      }
    }
    await this.prisma.preventionRecord.create({
      data: {
        petId: id,
        code: dto.code,
        customName: dto.code === MA_HANG_MUC_KHAC ? tenTuNhap : null,
        form: dto.form,
        isPeriodic: dto.isPeriodic ?? false,
        suggestedCycleValue: dto.suggestedCycleValue ?? null,
        suggestedCycleUnit: dto.suggestedCycleUnit ?? null,
      },
    });
    return this.layHoSo(userId, id);
  }

  // DELETE /pets/:id/preventions/:recordId xoá cả hạng mục kèm mọi lần đã ghi
  async remove(userId: string, id: string, recordId: string) {
    await this.timHangMuc(userId, id, recordId);
    const anh = await this.prisma.preventionDosePhoto.findMany({
      where: { dose: { recordId } },
      select: { url: true },
    });
    await this.xoaFileTheoUrl(anh.map((a) => a.url));
    await this.prisma.preventionRecord.delete({ where: { id: recordId } });
    return this.layHoSo(userId, id);
  }

  // POST .../doses ghi một lần đã làm
  async createDose(
    userId: string,
    id: string,
    recordId: string,
    dto: CreateDoseDto,
  ) {
    await this.timHangMuc(userId, id, recordId);
    this.kiemTraChuKy(dto.cycleValue, dto.cycleUnit);
    const soLan = await this.prisma.preventionDose.count({
      where: { recordId },
    });
    if (soLan >= MAX_LAN_MOI_HANG_MUC) {
      throw new BadRequestException({
        code: 'VUOT_GIOI_HAN_LAN_GHI',
        message: `Mỗi hạng mục chỉ giữ tối đa ${MAX_LAN_MOI_HANG_MUC} lần ghi`,
      });
    }
    await this.prisma.preventionDose.create({
      data: {
        recordId,
        doneAt: new Date(dto.doneAt),
        cycleValue: dto.cycleValue ?? null,
        cycleUnit: dto.cycleUnit ?? null,
        place: dto.place?.trim() || null,
      },
    });
    return this.layHoSo(userId, id);
  }

  // PUT .../doses/:doseId sửa một lần đã ghi
  async updateDose(
    userId: string,
    id: string,
    recordId: string,
    doseId: string,
    dto: UpdateDoseDto,
  ) {
    await this.timLan(userId, id, recordId, doseId);
    this.kiemTraChuKy(dto.cycleValue, dto.cycleUnit);
    await this.prisma.preventionDose.update({
      where: { id: doseId },
      data: {
        ...(dto.doneAt === undefined ? {} : { doneAt: new Date(dto.doneAt) }),
        ...(dto.cycleValue === undefined
          ? {}
          : { cycleValue: dto.cycleValue ?? null }),
        ...(dto.cycleUnit === undefined
          ? {}
          : { cycleUnit: dto.cycleUnit ?? null }),
        ...(dto.place === undefined
          ? {}
          : { place: dto.place?.trim() || null }),
      },
    });
    return this.layHoSo(userId, id);
  }

  // DELETE .../doses/:doseId xoá riêng một lần, hạng mục vẫn còn
  async removeDose(
    userId: string,
    id: string,
    recordId: string,
    doseId: string,
  ) {
    await this.timLan(userId, id, recordId, doseId);
    const anh = await this.prisma.preventionDosePhoto.findMany({
      where: { doseId },
      select: { url: true },
    });
    await this.xoaFileTheoUrl(anh.map((a) => a.url));
    await this.prisma.preventionDose.delete({ where: { id: doseId } });
    return this.layHoSo(userId, id);
  }

  // POST .../doses/:doseId/photos thêm ảnh phiếu hoặc hoá đơn
  async addDosePhotos(
    userId: string,
    id: string,
    recordId: string,
    doseId: string,
    files: UploadedImage[],
  ) {
    await this.timLan(userId, id, recordId, doseId);
    this.kiemTraCoAnh(files);
    const dangCo = await this.prisma.preventionDosePhoto.count({
      where: { doseId },
    });
    this.kiemTraGioiHanAnh(dangCo, files.length, MAX_DOSE_PHOTOS);
    const urls = await this.taiLenNhieu(files, 'preventions');
    if (urls.length) {
      await this.prisma.preventionDosePhoto.createMany({
        data: urls.map((url) => ({ doseId, url })),
      });
    }
    return this.layHoSo(userId, id);
  }

  // DELETE .../doses/:doseId/photos xoá ảnh phiếu
  async deleteDosePhotos(
    userId: string,
    id: string,
    recordId: string,
    doseId: string,
    ids: string[],
  ) {
    await this.timLan(userId, id, recordId, doseId);
    const rows = await this.prisma.preventionDosePhoto.findMany({
      where: { id: { in: ids }, doseId },
      select: { id: true, url: true },
    });
    await this.xoaFileTheoUrl(rows.map((r) => r.url));
    await this.prisma.preventionDosePhoto.deleteMany({
      where: { id: { in: rows.map((r) => r.id) }, doseId },
    });
    return this.layHoSo(userId, id);
  }

  private async timHangMuc(userId: string, id: string, recordId: string) {
    await this.timCuaToi(userId, id);
    const muc = await this.prisma.preventionRecord.findFirst({
      where: { id: recordId, petId: id },
      select: { id: true },
    });
    if (!muc) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_HANG_MUC',
        message: 'Không tìm thấy hạng mục phòng bệnh',
      });
    }
    return muc;
  }

  private async timLan(
    userId: string,
    id: string,
    recordId: string,
    doseId: string,
  ) {
    await this.timHangMuc(userId, id, recordId);
    const lan = await this.prisma.preventionDose.findFirst({
      where: { id: doseId, recordId },
      select: { id: true },
    });
    if (!lan) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_LAN_GHI',
        message: 'Không tìm thấy lần đã ghi',
      });
    }
    return lan;
  }

  // Đặt nhắc lại thì phải có đủ cả số và đơn vị
  private kiemTraChuKy(so?: number, donVi?: CycleUnit) {
    if ((so == null) !== (donVi == null)) {
      throw new BadRequestException({
        code: 'CHU_KY_KHONG_DAY_DU',
        message: 'Chu kỳ nhắc lại phải có cả số và đơn vị',
      });
    }
  }
}
