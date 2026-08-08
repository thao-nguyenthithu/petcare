import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { SitterStatus } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { THANG_DEM_LAN_TAM_AN } from '../../bookings/sitter-penalty-rules';
import { SitterPenaltyService } from '../../bookings/sitter-penalty.service';
import { GIAY_KY_ANH } from '../../media/anh-duong-dan';
import { SupabaseService } from '../../media/supabase.service';
import { AdminPenaltiesService } from './admin-penalties.service';
import { doiBangGia } from '../services/rang-buoc-dich-vu';
import { dungTrang, KetQuaTrang, kepTrang } from '../chung/phan-trang';
import { chonChieu, chonCot } from '../chung/sap-xep';
import {
  COT_SAP_XEP_NGUOI_CHAM,
  LocNguoiChamDto,
  TabNguoiCham,
} from './dto/loc-nguoi-cham.dto';

const BUCKET_CCCD = 'cccd-imgs';

// Trần mốc kỷ luật màn hồ sơ kéo về, hàng chờ đầy đủ nằm ở màn kỷ luật riêng
const TRAN_MOC_KY_LUAT = 20;

// Suy từ ba cột chứ không lọc thẳng status, vì tạm ẩn và khoá thắng cột đó
function dieuKienTab(tab: TabNguoiCham, bayGio: Date): Prisma.SitterWhereInput {
  const conAn: Prisma.SitterWhereInput = { hiddenUntil: { gt: bayGio } };
  const khongAn: Prisma.SitterWhereInput = {
    OR: [{ hiddenUntil: null }, { hiddenUntil: { lte: bayGio } }],
  };
  if (tab === 'hidden') return { bannedAt: null, ...conAn };
  if (tab === 'pending') {
    return { bannedAt: null, status: SitterStatus.PENDING, ...khongAn };
  }
  if (tab === 'rejected') {
    return { bannedAt: null, status: SitterStatus.REJECTED, ...khongAn };
  }
  return { bannedAt: null, status: SitterStatus.APPROVED, ...khongAn };
}

@Injectable()
export class AdminSittersReadService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly phat: SitterPenaltyService,
    private readonly kyLuat: AdminPenaltiesService,
    private readonly supabase: SupabaseService,
  ) {}

  // Bucket cccd-imgs cố ý KHÔNG công khai, dán path vào thẻ ảnh là bị từ chối
  private async kyAnhGiayTo(front: string | null, back: string | null) {
    const duong = [front, back].filter((p): p is string => Boolean(p));
    if (!duong.length) return { frontUrl: null, backUrl: null };
    // Ký cả hai mặt trong MỘT lượt, đừng gọi hai lần
    const { data } = await this.supabase
      .getClient()
      .storage.from(BUCKET_CCCD)
      .createSignedUrls(duong, GIAY_KY_ANH);
    // Ghép theo THỨ TỰ gửi đi, tra theo path là rỗng nếu kho chuẩn hoá lại chuỗi
    const ky = duong.map((_, i) => data?.[i]?.signedUrl ?? null);
    return {
      frontUrl: front ? ky[0] : null,
      backUrl: back ? (front ? ky[1] : ky[0]) : null,
    };
  }

  private dieuKien(
    loc: LocNguoiChamDto,
    bayGio: Date,
  ): Prisma.SitterWhereInput {
    const dieu: Prisma.SitterWhereInput = {
      ...(loc.tab ? dieuKienTab(loc.tab, bayGio) : {}),
    };
    if (loc.province) dieu.province = loc.province;
    if (loc.service) dieu.services = { some: { type: loc.service } };
    if (loc.q) {
      const tim = { contains: loc.q, mode: Prisma.QueryMode.insensitive };
      // Gộp vào AND để không đè mất nhánh OR của điều kiện tab
      dieu.AND = [
        {
          OR: [
            { legalName: tim },
            { nationalId: tim },
            { user: { fullName: tim } },
            { user: { email: tim } },
          ],
        },
      ];
    }
    return dieu;
  }

  async danhSach(loc: LocNguoiChamDto): Promise<KetQuaTrang<unknown>> {
    const bayGio = new Date();
    const khoang = kepTrang(loc.page, loc.limit);
    const where = this.dieuKien(loc, bayGio);
    const cot = chonCot(COT_SAP_XEP_NGUOI_CHAM, loc.sort, 'createdAt');
    const chieu = chonChieu(loc.dir, 'desc');

    const [total, ds] = await Promise.all([
      this.prisma.sitter.count({ where }),
      this.prisma.sitter.findMany({
        where,
        orderBy: { [cot]: chieu },
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          id: true,
          userId: true,
          legalName: true,
          status: true,
          province: true,
          addressDetail: true,
          serviceAddress: true,
          submittedAt: true,
          approvedAt: true,
          onboardedAt: true,
          ratingAvg: true,
          totalReviews: true,
          hiddenUntil: true,
          hiddenCount: true,
          bannedAt: true,
          cccdFrontPath: true,
          cccdBackPath: true,
          user: { select: { fullName: true, avatarUrl: true } },
          services: { where: { enabled: true }, select: { type: true } },
        },
      }),
    ]);

    const items = ds.map(({ user, services, ...ncc }) => ({
      ...ncc,
      fullName: user.fullName,
      avatarUrl: user.avatarUrl,
      services: services.map((s) => s.type),
      // Ảnh căn cước chỉ trả CÓ hay KHÔNG, đường dẫn chỉ mở ở màn chi tiết
      hasFront: Boolean(ncc.cccdFrontPath),
      hasBack: Boolean(ncc.cccdBackPath),
      cccdFrontPath: undefined,
      cccdBackPath: undefined,
    }));
    return dungTrang(items, total, khoang);
  }

  async demTab() {
    const bayGio = new Date();
    const [pending, active, rejected, hidden, banned] = await Promise.all(
      (['pending', 'active', 'rejected', 'hidden'] as TabNguoiCham[])
        .map((tab) =>
          this.prisma.sitter.count({ where: dieuKienTab(tab, bayGio) }),
        )
        .concat(
          this.prisma.sitter.count({ where: { bannedAt: { not: null } } }),
        ),
    );
    return { pending, active, rejected, hidden, banned };
  }

  // Không có cột riêng cho lần nhắn bổ sung, tra ngược nhật ký theo index targetType+targetId
  private async lanYeuCauBoSung(sitterId: string) {
    const ban = await this.prisma.adminAuditLog.findFirst({
      where: {
        targetType: 'SITTER',
        targetId: sitterId,
        action: 'YEU_CAU_BO_SUNG_HO_SO_NCC',
      },
      orderBy: { createdAt: 'desc' },
      select: { createdAt: true },
    });
    return ban?.createdAt ?? null;
  }

  async chiTiet(id: string) {
    const [ncc, thongKe, lanBoSung] = await Promise.all([
      this.prisma.sitter.findUnique({
        where: { id },
        select: {
          id: true,
          userId: true,
          legalName: true,
          gender: true,
          dateOfBirth: true,
          nationalId: true,
          idIssuedPlace: true,
          idIssuedDate: true,
          province: true,
          addressDetail: true,
          submittedAt: true,
          approvedAt: true,
          onboardedAt: true,
          serviceAddress: true,
          serviceAddressNote: true,
          serviceRadiusKm: true,
          // Chỉ ở chi tiết: danh sách không vẽ bản đồ nên không cần toạ độ
          lat: true,
          lng: true,
          status: true,
          hiddenUntil: true,
          hiddenCount: true,
          bannedAt: true,
          ratingAvg: true,
          totalReviews: true,
          cccdFrontPath: true,
          cccdBackPath: true,
          user: {
            select: {
              fullName: true,
              email: true,
              phone: true,
              createdAt: true,
              avatarUrl: true,
            },
          },
          services: {
            select: {
              type: true,
              enabled: true,
              petKind: true,
              pricing: true,
            },
          },
        },
      }),
      this.thongKe(id),
      this.lanYeuCauBoSung(id),
    ]);
    if (!ncc) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_NCC',
        message: 'Không tìm thấy hồ sơ người chăm này',
      });
    }

    const { user, services, cccdFrontPath, cccdBackPath, ...hoSo } = ncc;
    const documents = await this.kyAnhGiayTo(cccdFrontPath, cccdBackPath);
    return {
      // Cảnh báo ngưỡng khoá phải đọc số mốc TRONG CỬA SỔ, hiddenCount là trọn đời
      sitter: {
        ...hoSo,
        hiddenTimesInWindow: thongKe.hiddenTimesInWindow,
        lastSupplementRequestAt: lanBoSung,
      },
      user,
      documents,
      // Cùng một hình dạng pricing với GET /admin/sitter-services, hai hình dạng cùng tên trường là bẫy cho web
      services: services.map(({ pricing, ...dv }) => ({
        ...dv,
        pricing: doiBangGia(dv.type, pricing),
      })),
      penalties: thongKe.penalties,
      stats: {
        bookingCount: thongKe.bookingCount,
        cancelRate: thongKe.cancelRate,
        runningBookingCount: thongKe.runningBookingCount,
        ratingAvg: ncc.ratingAvg,
        totalReviews: ncc.totalReviews,
      },
    };
  }

  private async thongKe(sitterId: string) {
    const [soDon, dangChay, phat, uyTin, lanAn] = await Promise.all([
      this.prisma.booking.count({
        where: { sitterId, status: { notIn: ['AWAITING_PAYMENT', 'PENDING'] } },
      }),
      this.prisma.booking.count({
        where: {
          sitterId,
          status: {
            in: ['CONFIRMED', 'IN_PROGRESS', 'AWAITING_OWNER_CONFIRM'],
          },
        },
      }),
      this.prisma.sitterPenalty.findMany({
        where: { sitterId },
        orderBy: { createdAt: 'desc' },
        take: TRAN_MOC_KY_LUAT,
        select: {
          id: true,
          kind: true,
          status: true,
          reason: true,
          createdAt: true,
          booking: { select: { code: true } },
        },
      }),
      this.phat.hoSoUyTin(sitterId),
      this.kyLuat.soLanAnTrongCuaSo(sitterId, THANG_DEM_LAN_TAM_AN),
    ]);
    return {
      bookingCount: soDon,
      runningBookingCount: dangChay,
      cancelRate: uyTin.tyLeHuy,
      hiddenTimesInWindow: lanAn,
      penalties: phat.map(({ booking, ...p }) => ({
        ...p,
        bookingCode: booking?.code ?? null,
      })),
    };
  }
}
