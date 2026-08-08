import { Injectable } from '@nestjs/common';
import { ServiceType } from '../../../../generated/prisma/enums';
import { soDong } from '../../../common/tien';
import { PrismaService } from '../../../prisma/prisma.service';
import {
  dauThangVn,
  dayKhoaThang,
  haiKy,
  Khoang,
  lechPhanTram,
} from './dashboard-ky';

const SO_THANG_BIEU_DO = 12;
const SO_DON_GAN_DAY = 5;

// Thứ tự lát vành khuyên cố định theo enum, không sắp lại theo số lượng
const THU_TU_DICH_VU = [
  ServiceType.WALKING,
  ServiceType.BOARDING,
  ServiceType.GROOMING,
];

type SoTongQuan = {
  usersTotal: number;
  usersTruoc: number;
  sittersActive: number;
  sittersPending: number;
  bookingsNay: number;
  bookingsTruoc: number;
  bookingsOngoing: number;
  // SUM trên cột Int trả bigint, phải qua soDong trước khi tính hay trả ra API
  revenueNay: bigint;
  revenueTruoc: bigint;
  commissionNay: bigint;
  escrowHeld: bigint;
};

type DongThang = {
  khoa: string;
  sitterPayout: bigint | null;
  platformFee: bigint | null;
};

type DongCoCau = { type: ServiceType; count: number };

type DongDonGanDay = {
  code: string;
  status: string;
  totalPrice: number | null;
  durationMinutes: number | null;
  ownerName: string;
  ownerPhone: string | null;
  serviceName: string;
};

@Injectable()
export class AdminDashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async tongQuan() {
    const bayGio = new Date();
    const { nay, truoc } = haiKy(bayGio);
    const tuBieuDo = dauThangVn(bayGio, -(SO_THANG_BIEU_DO - 1));

    const [so, theoThang, coCau, donGanDay] = await Promise.all([
      this.gopChiSo(nay, truoc),
      this.doanhThuTheoThang(tuBieuDo),
      this.coCauDichVu(nay),
      this.donGanDay(),
    ]);

    return {
      users: {
        total: so.usersTotal,
        delta: lechPhanTram(so.usersTotal, so.usersTruoc),
      },
      sitters: {
        active: so.sittersActive,
        pending: so.sittersPending,
        // Schema không lưu mốc duyệt hồ sơ nên không dựng lại được số của kỳ trước
        delta: null,
      },
      bookings: {
        thisMonth: so.bookingsNay,
        ongoing: so.bookingsOngoing,
        delta: lechPhanTram(so.bookingsNay, so.bookingsTruoc),
      },
      revenue: {
        total: soDong(so.revenueNay),
        commission: soDong(so.commissionNay),
        escrowHeld: soDong(so.escrowHeld),
        delta: lechPhanTram(soDong(so.revenueNay), soDong(so.revenueTruoc)),
      },
      revenueByMonth: this.duMuoiHaiCot(bayGio, theoThang),
      serviceMix: this.duBaLat(coCau),
      recentBookings: donGanDay.map((d) => ({
        code: d.code,
        ownerName: d.ownerName,
        ownerPhone: d.ownerPhone,
        serviceName: d.serviceName,
        durationMinutes: d.durationMinutes,
        status: d.status,
        totalPrice: d.totalPrice,
      })),
    };
  }

  // Mười một con số gộp vào một câu truy vấn, tách ra là thêm mười lượt đi về
  private async gopChiSo(nay: Khoang, truoc: Khoang): Promise<SoTongQuan> {
    const dong = await this.prisma.$queryRaw<SoTongQuan[]>`
      SELECT
        (SELECT count(*) FROM "User")::int AS "usersTotal",
        (SELECT count(*) FROM "User" WHERE "createdAt" < ${truoc.den})::int AS "usersTruoc",
        (SELECT count(*) FROM "Sitter" WHERE "status" = 'APPROVED')::int AS "sittersActive",
        (SELECT count(*) FROM "Sitter" WHERE "status" = 'PENDING')::int AS "sittersPending",
        (SELECT count(*) FROM "Booking"
          WHERE "paidAt" >= ${nay.tu} AND "paidAt" <= ${nay.den})::int AS "bookingsNay",
        (SELECT count(*) FROM "Booking"
          WHERE "paidAt" >= ${truoc.tu} AND "paidAt" < ${truoc.den})::int AS "bookingsTruoc",
        (SELECT count(*) FROM "Booking"
          WHERE "status" = 'IN_PROGRESS')::int AS "bookingsOngoing",
        (SELECT COALESCE(SUM("totalPrice"), 0) FROM "Booking"
          WHERE "paidAt" >= ${nay.tu} AND "paidAt" <= ${nay.den}) AS "revenueNay",
        (SELECT COALESCE(SUM("totalPrice"), 0) FROM "Booking"
          WHERE "paidAt" >= ${truoc.tu} AND "paidAt" < ${truoc.den}) AS "revenueTruoc",
        (SELECT COALESCE(SUM("platformFee"), 0) FROM "Booking"
          WHERE "paidAt" >= ${nay.tu} AND "paidAt" <= ${nay.den}) AS "commissionNay",
        (SELECT COALESCE(SUM("amount"), 0) FROM "Payment"
          WHERE "status" = 'HELD') AS "escrowHeld"`;
    return dong[0];
  }

  // Gộp tháng ở database chứ không kéo cả năm đơn về Node rồi tự cộng
  private doanhThuTheoThang(tu: Date) {
    return this.prisma.$queryRaw<DongThang[]>`
      SELECT to_char(thang, 'YYYY-MM') AS khoa,
             "sitterPayout",
             "platformFee"
      FROM (
        SELECT date_trunc('month', b."paidAt" AT TIME ZONE 'Asia/Ho_Chi_Minh') AS thang,
               SUM(COALESCE(b."sitterPayout", COALESCE(b."totalPrice", 0) - COALESCE(b."platformFee", 0))) AS "sitterPayout",
               SUM(COALESCE(b."platformFee", 0)) AS "platformFee"
        FROM "Booking" b
        WHERE b."paidAt" >= ${tu}
        GROUP BY 1
      ) t`;
  }

  private coCauDichVu(nay: Khoang) {
    return this.prisma.$queryRaw<DongCoCau[]>`
      SELECT s."type" AS type, count(*)::int AS count
      FROM "Booking" b
      JOIN "Service" s ON s.id = b."serviceId"
      WHERE b."paidAt" >= ${nay.tu} AND b."paidAt" <= ${nay.den}
      GROUP BY s."type"`;
  }

  // Nối tên chủ nuôi và dịch vụ ngay trong câu truy vấn: mỗi cấp include là một lượt nữa
  private donGanDay() {
    return this.prisma.$queryRaw<DongDonGanDay[]>`
      SELECT b."code",
             b."status"::text AS status,
             b."totalPrice",
             b."durationMinutes",
             u."fullName" AS "ownerName",
             u."phone" AS "ownerPhone",
             s."name" AS "serviceName"
      FROM "Booking" b
      JOIN "User" u ON u.id = b."ownerId"
      JOIN "Service" s ON s.id = b."serviceId"
      WHERE b."paidAt" IS NOT NULL
      ORDER BY b."paidAt" DESC
      LIMIT ${SO_DON_GAN_DAY}`;
  }

  // Tháng không có đơn vẫn phải giữ chỗ, thiếu cột là trục biểu đồ trượt sang tháng khác
  private duMuoiHaiCot(bayGio: Date, theoThang: DongThang[]) {
    const theoKhoa = new Map(theoThang.map((t) => [t.khoa, t]));
    return dayKhoaThang(bayGio, SO_THANG_BIEU_DO).map((khoa) => {
      const dong = theoKhoa.get(khoa);
      return {
        month: Number(khoa.slice(5, 7)),
        sitterPayout: soDong(dong?.sitterPayout),
        platformFee: soDong(dong?.platformFee),
      };
    });
  }

  private duBaLat(coCau: DongCoCau[]) {
    const theoLoai = new Map(coCau.map((c) => [c.type, c.count]));
    const tong = coCau.reduce((sum, c) => sum + c.count, 0);
    return THU_TU_DICH_VU.map((type) => {
      const count = theoLoai.get(type) ?? 0;
      return {
        type,
        count,
        percent: tong === 0 ? 0 : Math.round((count / tong) * 100),
      };
    });
  }
}
