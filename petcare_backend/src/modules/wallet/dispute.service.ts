import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  HAN_PHAN_DOI_HOURS,
  gioGiuTienCuaDon,
} from '../bookings/booking-compensation';
import { LY_DO_THIEU_DUNG_CU, TRANG_THAI_HUY } from '../bookings/booking-enums';
import { AnhKyService } from '../media/anh-ky.service';
import { BUCKET_ANH_DON } from '../media/anh-duong-dan';
import { AnhTaiLenService } from '../media/anh-tai-len.service';
import { type UploadedImage } from '../media/image-upload';
import { layNccCuaToi } from '../sitter/orders/sitter-guard';
import { CHON_DON_VI, khoanNccNhan, raTheDon } from './wallet-booking.mapper';
import {
  DisputeReplyDto,
  OpenDisputeDto,
  SO_ANH_MO_KHIEU_NAI,
  SO_ANH_PHAN_HOI_KHIEU_NAI,
} from './dto/wallet.dto';

const BUCKET_KHIEU_NAI = BUCKET_ANH_DON;

type HoSoCuaChuNuoi = {
  code: string;
  reporterId: string;
  description: string;
  reasonCode: string | null;
  evidenceUrls: unknown;
  sitterReply: string | null;
  sitterReplyAt: Date | null;
  sitterReplyPhotos: string[];
  resolution: string | null;
  resolutionReason: string | null;
  refundAmount: number | null;
  resolvedAt: Date | null;
  createdAt: Date;
  booking: Parameters<typeof raTheDon>[0] & {
    ownerId: string;
    sitter: { user: { fullName: string } } | null;
  };
};

function laNhanhPhanDoi(don: {
  status: string;
  cancellationReason: string | null;
}): boolean {
  if (don.status === 'CANCELLED_NO_SHOW') return true;
  return (
    don.status === 'CANCELLED_BY_SITTER' &&
    don.cancellationReason === LY_DO_THIEU_DUNG_CU
  );
}

@Injectable()
export class DisputeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly anh: AnhTaiLenService,
    private readonly kyAnh: AnhKyService,
  ) {}

  // Chủ nuôi mở khiếu nại cho một đơn của mình
  async mo(
    userId: string,
    bookingId: string,
    dto: OpenDisputeDto,
    files: UploadedImage[] = [],
  ) {
    const don = await this.prisma.booking.findFirst({
      where: { id: bookingId, ownerId: userId },
      select: {
        id: true,
        code: true,
        status: true,
        endedAt: true,
        cancelledAt: true,
        cancellationReason: true,
        escrowReleaseAt: true,
      },
    });
    if (!don) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn này',
      });
    }
    if (laNhanhPhanDoi(don)) {
      const moc = don.cancelledAt;
      if (moc && Date.now() > moc.getTime() + HAN_PHAN_DOI_HOURS * 3_600_000) {
        throw new ConflictException({
          code: 'QUA_HAN_PHAN_DOI',
          message: `Chỉ phản đối trong ${HAN_PHAN_DOI_HOURS} giờ kể từ lúc đơn bị khép vì vắng mặt`,
        });
      }
    } else {
      if (!don.endedAt) {
        throw new ConflictException({
          code: 'DON_CHUA_KET_THUC',
          message: 'Đơn chưa kết thúc nên chưa báo sự cố được',
        });
      }
      const hetHan = don.escrowReleaseAt ?? don.endedAt;
      if (Date.now() > hetHan.getTime()) {
        throw new ConflictException({
          code: 'QUA_HAN_BAO_SU_CO',
          message: `Chỉ báo sự cố trong ${gioGiuTienCuaDon(don)} giờ kể từ lúc đơn kết thúc`,
        });
      }
    }
    this.phaiHopLeAnh(files, SO_ANH_MO_KHIEU_NAI);
    await this.chuaCoHoSoMo(don.id);
    const ma = await this.maHoSoMoi(don.id, don.code);
    const anh = await this.anh.dayLen(BUCKET_KHIEU_NAI, don.id, files);
    const bayGio = new Date();
    const hs = await this.prisma.violationReport.create({
      data: {
        code: ma,
        bookingId: don.id,
        reporterId: userId,
        description: dto.description,
        reasonCode: dto.reason ?? null,
        evidenceUrls: anh,
        replyDeadline: new Date(
          bayGio.getTime() + HAN_PHAN_DOI_HOURS * 3_600_000,
        ),
      },
    });
    return { id: hs.id, code: hs.code, status: hs.status };
  }

  async moBoiNguoiCham(
    userId: string,
    bookingId: string,
    moTa: string,
    anh: string[],
    maLyDo?: string,
  ) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const don = await this.prisma.booking.findFirst({
      where: { id: bookingId, sitterId: ncc.id },
      select: {
        id: true,
        code: true,
        status: true,
        startedAt: true,
        endedAt: true,
        escrowReleaseAt: true,
      },
    });
    if (!don) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn này',
      });
    }
    if (!don.startedAt || TRANG_THAI_HUY.includes(don.status)) {
      throw new ConflictException({
        code: 'PHIEN_CHUA_CHAY',
        message: 'Chỉ báo sự cố khi phiên đã bắt đầu',
      });
    }
    const hetHan = don.endedAt ? (don.escrowReleaseAt ?? don.endedAt) : null;
    if (hetHan && Date.now() > hetHan.getTime()) {
      throw new ConflictException({
        code: 'QUA_HAN_BAO_SU_CO',
        message: `Chỉ báo sự cố trong ${gioGiuTienCuaDon(don)} giờ kể từ lúc đơn kết thúc`,
      });
    }
    await this.chuaCoHoSoMo(don.id);
    const ma = await this.maHoSoMoi(don.id, don.code);
    const hs = await this.prisma.violationReport.create({
      data: {
        code: ma,
        bookingId: don.id,
        reporterId: userId,
        description: moTa,
        reasonCode: maLyDo ?? null,
        evidenceUrls: anh,
      },
    });
    return { id: hs.id, code: hs.code, status: hs.status };
  }

  private phaiHopLeAnh(files: UploadedImage[], tran: number) {
    if ((files?.length ?? 0) > tran) {
      throw new BadRequestException({
        code: 'VUOT_GIOI_HAN_ANH',
        message: `Chỉ gửi tối đa ${tran} ảnh mỗi lượt`,
      });
    }
  }

  private async chuaCoHoSoMo(bookingId: string) {
    const daCo = await this.prisma.violationReport.findFirst({
      where: { bookingId, status: { not: 'RESOLVED' } },
      select: { id: true },
    });
    if (daCo) {
      throw new ConflictException({
        code: 'DA_CO_KHIEU_NAI',
        message: 'Đơn này đang có một khiếu nại chờ xử lý',
      });
    }
  }

  private async maHoSoMoi(bookingId: string, maDon: string) {
    const goc = `KN-${maDon.replace(/^[A-Z]+-/, '')}`;
    const daCo = await this.prisma.violationReport.count({
      where: { bookingId },
    });
    return daCo === 0 ? goc : `${goc}-${daCo + 1}`;
  }

  // Hồ sơ theo mã, đọc được từ CẢ HAI vai của đơn
  async theoMa(userId: string, code: string) {
    const hs = await this.prisma.violationReport.findUnique({
      where: { code },
      include: {
        booking: {
          select: {
            ...CHON_DON_VI,
            ownerId: true,
            sitter: {
              select: { userId: true, user: { select: { fullName: true } } },
            },
          },
        },
      },
    });
    if (!hs) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_KHIEU_NAI',
        message: 'Không tìm thấy hồ sơ khiếu nại',
      });
    }
    const laChuNuoi = hs.booking.ownerId === userId;
    if (!laChuNuoi && hs.booking.sitter?.userId !== userId) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_KHIEU_NAI',
        message: 'Không tìm thấy hồ sơ khiếu nại',
      });
    }
    const ky = await this.kyAnh.kyLo(this.anhCuaHoSo(hs));
    return laChuNuoi ? this.raHoSoChuNuoi(hs, ky) : this.raHoSo(hs, ky);
  }

  async phanHoi(
    userId: string,
    code: string,
    dto: DisputeReplyDto,
    files: UploadedImage[] = [],
  ) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const hs = await this.prisma.violationReport.findUnique({
      where: { code },
      select: {
        id: true,
        status: true,
        reporterId: true,
        sitterReplyAt: true,
        replyDeadline: true,
        bookingId: true,
        booking: { select: { sitterId: true } },
      },
    });
    if (!hs || hs.booking.sitterId !== ncc.id) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_KHIEU_NAI',
        message: 'Không tìm thấy hồ sơ khiếu nại',
      });
    }
    // Hồ sơ do chính người chăm mở không có lượt đáp nào (bộ luật mục 7)
    if (hs.reporterId === userId) {
      throw new ConflictException({
        code: 'HO_SO_TU_MO_KHONG_CO_LUOT_DAP',
        message: 'Hồ sơ do chính bạn mở đã chuyển thẳng cho đội hỗ trợ',
      });
    }
    if (hs.sitterReplyAt) {
      throw new ConflictException({
        code: 'DA_PHAN_HOI',
        message: 'Mỗi khiếu nại chỉ phản hồi được một lần',
      });
    }
    if (hs.replyDeadline && Date.now() > hs.replyDeadline.getTime()) {
      throw new ConflictException({
        code: 'QUA_HAN_PHAN_HOI',
        message: 'Đã quá hạn phản hồi, hồ sơ chuyển sang đội hỗ trợ',
      });
    }
    this.phaiHopLeAnh(files, SO_ANH_PHAN_HOI_KHIEU_NAI);
    const anh = await this.anh.dayLen(BUCKET_KHIEU_NAI, hs.bookingId, files);
    const daSua = await this.prisma.violationReport.update({
      where: { id: hs.id },
      data: {
        sitterReply: dto.content,
        sitterReplyAt: new Date(),
        sitterReplyPhotos: anh,
        status: 'REVIEWING',
      },
      include: {
        booking: {
          select: {
            ...CHON_DON_VI,
            ownerId: true,
            sitter: { select: { userId: true } },
          },
        },
      },
    });
    return this.raHoSo(daSua, await this.kyAnh.kyLo(this.anhCuaHoSo(daSua)));
  }

  async cuaNguoiCham(userId: string) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const ds = await this.prisma.violationReport.findMany({
      where: { booking: { sitterId: ncc.id } },
      orderBy: { createdAt: 'desc' },
      include: {
        booking: {
          select: {
            ...CHON_DON_VI,
            ownerId: true,
            sitter: { select: { userId: true } },
          },
        },
      },
    });
    const ky = await this.kyAnh.kyLo(ds.flatMap((hs) => this.anhCuaHoSo(hs)));
    return ds.map((hs) => this.raHoSo(hs, ky));
  }

  private anhCuaHoSo(hs: {
    evidenceUrls: unknown;
    sitterReplyPhotos: string[];
  }): string[] {
    const phanAnh = Array.isArray(hs.evidenceUrls)
      ? (hs.evidenceUrls as string[])
      : [];
    return [...phanAnh, ...hs.sitterReplyPhotos];
  }

  private raHoSo(
    hs: {
      code: string;
      status: string;
      description: string;
      evidenceUrls: unknown;
      sitterReply: string | null;
      sitterReplyAt: Date | null;
      sitterReplyPhotos: string[];
      replyDeadline: Date | null;
      resolution: string | null;
      resolutionReason: string | null;
      refundAmount: number | null;
      resolvedAt: Date | null;
      createdAt: Date;
      reporterId: string;
      booking: Parameters<typeof raTheDon>[0] & {
        ownerId: string;
        sitterPayout: number | null;
        totalPrice: number | null;
        platformFee: number | null;
      };
    },
    ky?: ReadonlyMap<string, string>,
  ) {
    const thucNhan = khoanNccNhan(hs.booking);
    const tong = hs.booking.totalPrice ?? 0;
    const phiNenTang = hs.booking.platformFee ?? 0;
    const kyMot = (v: string) => ky?.get(v) ?? v;
    const phanAnh = Array.isArray(hs.evidenceUrls)
      ? (hs.evidenceUrls as string[])
      : [];
    return {
      ma: hs.code,
      trangThai: this.trangThaiApp(hs),
      don: raTheDon(hs.booking),
      soTien: thucNhan,
      phanAnh: hs.description,
      anhPhanAnh: phanAnh.map(kyMot),
      thoiDiemPhanAnh: hs.createdAt.toISOString(),
      phanHoiCuaBan: hs.sitterReply,
      anhPhanHoi: hs.sitterReplyPhotos.map(kyMot),
      thoiDiemPhanHoi: hs.sitterReplyAt?.toISOString() ?? null,
      hanPhanHoi: hs.replyDeadline?.toISOString() ?? null,
      ketLuan: hs.resolvedAt && {
        noiDung: hs.resolution,
        lyDo: hs.resolutionReason,
        nguoiXuLy: 'Bộ phận hỗ trợ Smart Pet Care',
        thoiDiem: hs.resolvedAt.toISOString(),
      },
      cacDongTien: [
        { nhan: 'Chủ nuôi đã trả', tien: tong },
        { nhan: 'Phí nền tảng', tien: -phiNenTang },
        { nhan: 'Hoàn cho chủ nuôi', tien: -(tong - phiNenTang - thucNhan) },
      ],
      tongCuoi: { nhan: 'Thực nhận', tien: thucNhan },
    };
  }

  // Bản cho vai chủ nuôi: cắt mọi khoản tiền của người chăm khỏi payload
  private raHoSoChuNuoi(hs: HoSoCuaChuNuoi, ky?: ReadonlyMap<string, string>) {
    const kyMot = (v: string) => ky?.get(v) ?? v;
    const phanAnh = Array.isArray(hs.evidenceUrls)
      ? (hs.evidenceUrls as string[])
      : [];
    const the = raTheDon(hs.booking);
    const banMo = hs.reporterId === hs.booking.ownerId;
    return {
      ma: hs.code,
      trangThai: this.trangThaiChuNuoi(hs, banMo),
      banMo,
      lyDo: hs.reasonCode,
      don: {
        id: the.id,
        code: the.code,
        status: the.status,
        serviceType: the.serviceType,
        serviceName: the.serviceName,
        sitterName: hs.booking.sitter?.user.fullName ?? '',
        pets: the.pets,
        startAt: the.startAt,
        endAt: the.endAt,
        durationMinutes: the.durationMinutes,
        nights: the.nights,
        totalPrice: the.totalPrice,
      },
      phanAnh: hs.description,
      anhPhanAnh: phanAnh.map(kyMot),
      thoiDiemPhanAnh: hs.createdAt.toISOString(),
      phanHoiNguoiCham: hs.sitterReply,
      anhPhanHoiNguoiCham: hs.sitterReplyPhotos.map(kyMot),
      thoiDiemPhanHoi: hs.sitterReplyAt?.toISOString() ?? null,
      ketLuan: hs.resolvedAt && {
        noiDung: hs.resolution,
        lyDo: hs.resolutionReason,
        nguoiXuLy: 'Bộ phận hỗ trợ Smart Pet Care',
        thoiDiem: hs.resolvedAt.toISOString(),
      },
      tienHoan: hs.refundAmount,
    };
  }

  // Hồ sơ do chính người chăm mở thì không có lượt đáp nào (bộ luật mục 7)
  private trangThaiChuNuoi(
    hs: {
      sitterReplyAt: Date | null;
      resolvedAt: Date | null;
      refundAmount: number | null;
    },
    banMo: boolean,
  ) {
    if (!hs.resolvedAt) {
      return banMo && !hs.sitterReplyAt
        ? 'choNguoiChamPhanHoi'
        : 'choHoTroXuLy';
    }
    return (hs.refundAmount ?? 0) > 0 ? 'daHoanMotPhan' : 'khongChapNhan';
  }

  private trangThaiApp(hs: {
    reporterId: string;
    sitterReplyAt: Date | null;
    resolvedAt: Date | null;
    refundAmount: number | null;
    booking: { ownerId: string };
  }) {
    if (!hs.resolvedAt) {
      const choDap = hs.reporterId === hs.booking.ownerId && !hs.sitterReplyAt;
      return choDap ? 'choBanPhanHoi' : 'choHoTroXuLy';
    }
    return (hs.refundAmount ?? 0) > 0 ? 'daHoanMotPhan' : 'khongChapNhan';
  }
}
