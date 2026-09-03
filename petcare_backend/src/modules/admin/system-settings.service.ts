import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
  OnModuleInit,
} from '@nestjs/common';
import { Interval } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';
import {
  GiaTriChon,
  KHOA_THAM_SO,
  KhoaBatTat,
  KhoaChon,
  KhoaSo,
  KhoaThamSo,
  THAM_SO,
  laKhoaThamSo,
} from './tham-so.dinh-nghia';
import { moMoiCuaThoiGian } from '../../common/che-do-demo';

// Khoá chọn nhà cung cấp nhận diện ảnh
export const KHOA_NHA_AI = 'ai.vision.provider';

// Khoá công tắc cổng thanh toán
export const KHOA_BAT_VNPAY = 'payment.vnpay.enabled';

// Khoá công tắc hàng rào vị trí quanh điểm hẹn
export const KHOA_BAT_GEOFENCE = 'checkin.geofence.enabled';

// Nhịp nạp lại cả bảng, để ai sửa thẳng cơ sở dữ liệu vẫn hội tụ
const NHIP_LAM_MOI_MS = 60_000;

const MOT_TRAM = 100;

export type GiaTriThamSo = number | boolean | string;

// Getter đồng bộ chứ không async, đổi sang async là lan ra hàng chục chỗ gọi
@Injectable()
export class SystemSettingsService implements OnModuleInit {
  private readonly logger = new Logger(SystemSettingsService.name);
  private cache = new Map<KhoaThamSo, string>();
  private mocCapNhat: Date | null = null;

  constructor(private readonly prisma: PrismaService) {}

  async onModuleInit() {
    await this.lamMoi();
  }

  @Interval(NHIP_LAM_MOI_MS)
  async lamMoi() {
    try {
      const ds = await this.prisma.systemSetting.findMany({
        select: { key: true, value: true, updatedAt: true },
      });
      const moi = new Map<KhoaThamSo, string>();
      let moc: Date | null = null;
      for (const dong of ds) {
        if (!laKhoaThamSo(dong.key)) continue;
        moi.set(dong.key, dong.value);
        if (!moc || dong.updatedAt > moc) moc = dong.updatedAt;
      }
      this.cache = moi;
      this.mocCapNhat = moc;
    } catch (loi) {
      // Mất kết nối không được làm chết tiến trình, mặc định vẫn chạy được
      this.logger.error(
        'Không nạp được tham số vận hành, tạm dùng giá trị mặc định',
        loi as Error,
      );
    }
  }

  capNhatLuc(): Date | null {
    return this.mocCapNhat;
  }

  // Chuỗi hỏng hoặc ngoài khoảng đều rơi về mặc định, không ném lỗi
  private doc(khoa: KhoaThamSo, tho: string | undefined): GiaTriThamSo {
    const dinhNghia = THAM_SO[khoa];
    if (tho === undefined) return dinhNghia.macDinh;
    if (dinhNghia.kieu === 'chon') {
      const choPhep: readonly string[] = dinhNghia.giaTriChoPhep;
      if (!choPhep.includes(tho)) {
        this.logger.warn(
          `Tham số ${khoa} đang là "${tho}", không có trong danh sách, dùng mặc định`,
        );
        return dinhNghia.macDinh;
      }
      return tho;
    }
    if (dinhNghia.kieu === 'batTat') {
      if (tho !== 'true' && tho !== 'false') {
        this.logger.warn(
          `Công tắc ${khoa} đang là "${tho}", không đọc được, dùng mặc định`,
        );
        return dinhNghia.macDinh;
      }
      return tho === 'true';
    }
    const giaTri = Number(tho);
    if (
      !Number.isFinite(giaTri) ||
      giaTri < dinhNghia.min ||
      giaTri > dinhNghia.max
    ) {
      // Ngoài khoảng là dấu hiệu ai đó sửa thẳng cơ sở dữ liệu
      this.logger.warn(
        `Tham số ${khoa} đang là "${tho}", ngoài khoảng cho phép, dùng mặc định`,
      );
      return dinhNghia.macDinh;
    }
    return giaTri;
  }

  so(khoa: KhoaSo): number {
    return this.doc(khoa, this.cache.get(khoa)) as number;
  }

  // Khoá phần trăm lưu dạng 15, phần tính tiền cần 0.15
  tiLe(khoa: KhoaSo): number {
    return this.so(khoa) / MOT_TRAM;
  }

  bat(khoa: KhoaBatTat): boolean {
    return this.doc(khoa, this.cache.get(khoa)) as boolean;
  }

  chon<K extends KhoaChon>(khoa: K): GiaTriChon<K> {
    return this.doc(khoa, this.cache.get(khoa)) as GiaTriChon<K>;
  }

  // Chỉ khoá công khai, đây là thứ ứng dụng và trang quản trị được đọc
  congKhai(): Record<string, GiaTriThamSo> {
    const ket: Record<string, GiaTriThamSo> = {};
    for (const khoa of KHOA_THAM_SO) {
      if (!THAM_SO[khoa].congKhai) continue;
      ket[khoa] = this.doc(khoa, this.cache.get(khoa));
    }
    // Diễn thử thì ứng dụng cũng phải mở nút, không chỉ máy chủ bỏ chặn
    if (moMoiCuaThoiGian()) ket['checkin.geofence.enabled'] = false;
    return ket;
  }

  // Hai lượt cho cả màn: bảng tham số, rồi tên quản trị viên theo lô
  async danhSachChoQuanTri() {
    const ds = await this.prisma.systemSetting.findMany({
      select: { key: true, value: true, updatedBy: true, updatedAt: true },
    });
    const theoKhoa = new Map(ds.map((d) => [d.key, d]));
    const idNguoiDoi = [
      ...new Set(
        ds.map((d) => d.updatedBy).filter((id): id is string => id !== null),
      ),
    ];
    const nguoiDoi = idNguoiDoi.length
      ? await this.prisma.user.findMany({
          where: { id: { in: idNguoiDoi } },
          select: { id: true, fullName: true },
        })
      : [];
    const tenTheoId = new Map(nguoiDoi.map((u) => [u.id, u.fullName]));

    const items = KHOA_THAM_SO.map((khoa) => {
      const dinhNghia = THAM_SO[khoa];
      const dong = theoKhoa.get(khoa);
      return {
        key: khoa,
        kieu: dinhNghia.kieu,
        donVi: dinhNghia.kieu === 'so' ? dinhNghia.donVi : null,
        giaTri: this.doc(khoa, dong?.value),
        macDinh: dinhNghia.macDinh,
        min: dinhNghia.kieu === 'so' ? dinhNghia.min : null,
        max: dinhNghia.kieu === 'so' ? dinhNghia.max : null,
        // Màn 15b dựng ô chọn từ đây chứ không tự chép danh sách sang trang quản trị
        luaChon: dinhNghia.kieu === 'chon' ? dinhNghia.giaTriChoPhep : null,
        nguoiDoi: dong?.updatedBy
          ? { id: dong.updatedBy, hoTen: tenTheoId.get(dong.updatedBy) ?? null }
          : null,
        capNhatLuc: dong?.updatedAt ?? null,
      };
    });
    // Lấy mốc từ chính lô vừa đọc chứ không từ cache, cache có thể cũ hơn
    const moc = ds.reduce<Date | null>(
      (max, d) => (!max || d.updatedAt > max ? d.updatedAt : max),
      null,
    );
    return { capNhatLuc: moc, items };
  }

  async dat(
    khoa: string,
    giaTri: GiaTriThamSo,
    adminId: string,
    lyDo?: string,
  ): Promise<{ key: KhoaThamSo; giaTri: GiaTriThamSo; capNhatLuc: Date }> {
    if (!laKhoaThamSo(khoa)) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_THAM_SO',
        message: `Không có tham số nào tên ${khoa}`,
      });
    }
    const dinhNghia = THAM_SO[khoa];
    if (dinhNghia.kieu === 'so') {
      if (typeof giaTri !== 'number' || !Number.isInteger(giaTri)) {
        throw new BadRequestException({
          code: 'GIA_TRI_KHONG_HOP_LE',
          message: `${dinhNghia.nhan} phải là số nguyên`,
        });
      }
      if (giaTri < dinhNghia.min || giaTri > dinhNghia.max) {
        throw new BadRequestException({
          code: 'NGOAI_KHOANG_CHO_PHEP',
          message: `${dinhNghia.nhan} chỉ nhận giá trị từ ${dinhNghia.min} đến ${dinhNghia.max}`,
        });
      }
    } else if (dinhNghia.kieu === 'chon') {
      const choPhep: readonly string[] = dinhNghia.giaTriChoPhep;
      if (typeof giaTri !== 'string' || !choPhep.includes(giaTri)) {
        throw new BadRequestException({
          code: 'GIA_TRI_KHONG_HOP_LE',
          message: `${dinhNghia.nhan} chỉ nhận một trong: ${dinhNghia.giaTriChoPhep.join(', ')}`,
        });
      }
    } else if (typeof giaTri !== 'boolean') {
      throw new BadRequestException({
        code: 'GIA_TRI_KHONG_HOP_LE',
        message: `${dinhNghia.nhan} chỉ nhận bật hoặc tắt`,
      });
    }

    const chuoi = String(giaTri);
    // Bảng chưa có dòng thì giá trị cũ chính là mặc định đang chạy
    const cu = this.cache.get(khoa) ?? String(dinhNghia.macDinh);
    const [dong] = await this.prisma.$transaction([
      this.prisma.systemSetting.upsert({
        where: { key: khoa },
        create: { key: khoa, value: chuoi, updatedBy: adminId },
        update: { value: chuoi, updatedBy: adminId },
        select: { updatedAt: true },
      }),
      this.prisma.adminAuditLog.create({
        data: {
          adminId,
          action: 'CAP_NHAT_THAM_SO',
          targetType: 'SETTING',
          targetId: khoa,
          reason: lyDo ?? null,
          oldValue: cu,
          newValue: chuoi,
        },
        select: { id: true },
      }),
    ]);
    this.cache.set(khoa, chuoi);
    if (!this.mocCapNhat || dong.updatedAt > this.mocCapNhat) {
      this.mocCapNhat = dong.updatedAt;
    }
    return { key: khoa, giaTri, capNhatLuc: dong.updatedAt };
  }

  // Cụm thanh toán đọc qua đây để không phải nhớ tên khoá
  batVnpay(): boolean {
    return this.bat(KHOA_BAT_VNPAY);
  }

  batGeofence(): boolean {
    return this.bat(KHOA_BAT_GEOFENCE);
  }

  nhaAi(): GiaTriChon<typeof KHOA_NHA_AI> {
    return this.chon(KHOA_NHA_AI);
  }
}
