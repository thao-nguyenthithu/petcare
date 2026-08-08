import { Injectable } from '@nestjs/common';
import { PaymentStatus } from '../../../../generated/prisma/enums';
import { MOT_NGAY_MS, ngayThangVn } from '../../../common/thoi-gian-vn';
import { soDong } from '../../../common/tien';
import { PrismaService } from '../../../prisma/prisma.service';
import { SystemSettingsService } from '../system-settings.service';
import { KyDoanhThuDto } from './dto/ky-doanh-thu.dto';

const NGAY_MOI_KY = 30;
const SO_TOP_NGUOI_CHAM = 5;

// SUM trên cột Int trả bigint, phải qua soDong trước khi tính hay trả ra API
type DongTuan = {
  label: string;
  sitterPayout: bigint | null;
  platformFee: bigint | null;
};

type DongTop = { sitterId: string; name: string; amount: bigint | null };

type Khoang = { tu: Date; den: Date };

// Kỳ trước bằng 0 thì trả null: 0 đọc thành "không đổi", thật ra là chưa có gì để so
function lechPhanTram(nay: number, truoc: number): number | null {
  if (truoc <= 0) return null;
  return Math.round(((nay - truoc) / truoc) * 100);
}

@Injectable()
export class AdminFinanceSummaryService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  private khoangKy(loc: KyDoanhThuDto): { nay: Khoang; truoc: Khoang } {
    const den = loc.to ? new Date(loc.to) : new Date();
    const tu = loc.from
      ? new Date(loc.from)
      : new Date(den.getTime() - NGAY_MOI_KY * MOT_NGAY_MS);
    const doDai = Math.max(0, den.getTime() - tu.getTime());
    return {
      nay: { tu, den },
      truoc: { tu: new Date(tu.getTime() - doDai), den: tu },
    };
  }

  async tongQuan(loc: KyDoanhThuDto) {
    const { nay, truoc } = this.khoangKy(loc);

    const [donNay, donTruoc, khoanNay, khoanTruoc, theoTuan, topNcc] =
      await Promise.all([
        this.gopDon(nay),
        this.gopDon(truoc),
        this.gopKhoan(nay),
        this.gopKhoan(truoc),
        this.doanhThuTheoTuan(nay),
        this.topNguoiCham(nay),
      ]);

    const soNay = this.raChiSo(donNay, khoanNay);
    const soTruoc = this.raChiSo(donTruoc, khoanTruoc);

    return {
      ...soNay,
      commissionRate: this.thamSo.so('platform.fee.percent'),
      deltas: {
        totalOrderValue: lechPhanTram(
          soNay.totalOrderValue,
          soTruoc.totalOrderValue,
        ),
        commission: lechPhanTram(soNay.commission, soTruoc.commission),
        escrowHeld: lechPhanTram(soNay.escrowHeld, soTruoc.escrowHeld),
        releasedToWallet: lechPhanTram(
          soNay.releasedToWallet,
          soTruoc.releasedToWallet,
        ),
      },
      byWeek: theoTuan.map((t) => ({
        label: t.label,
        sitterPayout: soDong(t.sitterPayout),
        platformFee: soDong(t.platformFee),
      })),
      topSitters: topNcc.map((n) => ({
        sitterId: n.sitterId,
        name: n.name,
        amount: soDong(n.amount),
      })),
      topPeriodLabel: `${ngayThangVn(nay.tu)} - ${ngayThangVn(nay.den)}`,
    };
  }

  // Neo cả hai vế vào paidAt để bốn thẻ cùng nói về một tập giao dịch
  private gopDon(k: Khoang) {
    return this.prisma.booking.aggregate({
      where: { paidAt: { gte: k.tu, lte: k.den } },
      _sum: { totalPrice: true, platformFee: true },
      _count: true,
    });
  }

  private gopKhoan(k: Khoang) {
    return this.prisma.payment.groupBy({
      by: ['status'],
      where: {
        paidAt: { gte: k.tu, lte: k.den },
        status: { in: [PaymentStatus.HELD, PaymentStatus.RELEASED] },
      },
      _sum: { amount: true },
      _count: true,
    });
  }

  private raChiSo(
    don: {
      _sum: { totalPrice: number | null; platformFee: number | null };
      _count: number;
    },
    khoan: Array<{
      status: PaymentStatus;
      _sum: { amount: number | null };
      _count: number;
    }>,
  ) {
    const giu = khoan.find((k) => k.status === PaymentStatus.HELD);
    const daNha = khoan.find((k) => k.status === PaymentStatus.RELEASED);
    return {
      totalOrderValue: don._sum.totalPrice ?? 0,
      commission: don._sum.platformFee ?? 0,
      escrowHeld: giu?._sum.amount ?? 0,
      releasedToWallet: daNha?._sum.amount ?? 0,
      paidBookings: don._count,
      escrowBookings: giu?._count ?? 0,
    };
  }

  // Gộp tuần ở database chứ không kéo cả tập đơn về Node rồi tự cộng
  private doanhThuTheoTuan(k: Khoang) {
    return this.prisma.$queryRaw<DongTuan[]>`
      SELECT to_char(tuan, 'DD/MM') AS label,
             "sitterPayout",
             "platformFee"
      FROM (
        SELECT date_trunc('week', b."paidAt" AT TIME ZONE 'Asia/Ho_Chi_Minh') AS tuan,
               SUM(COALESCE(b."sitterPayout", COALESCE(b."totalPrice", 0) - COALESCE(b."platformFee", 0))) AS "sitterPayout",
               SUM(COALESCE(b."platformFee", 0)) AS "platformFee"
        FROM "Booking" b
        WHERE b."paidAt" >= ${k.tu} AND b."paidAt" <= ${k.den}
        GROUP BY 1
      ) t
      ORDER BY tuan`;
  }

  // Nối tên ngay trong câu truy vấn, tách ra là thêm một lượt đi về database
  private topNguoiCham(k: Khoang) {
    return this.prisma.$queryRaw<DongTop[]>`
      SELECT s.id AS "sitterId",
             u."fullName" AS name,
             SUM(COALESCE(b."sitterPayout", COALESCE(b."totalPrice", 0) - COALESCE(b."platformFee", 0))) AS amount
      FROM "Booking" b
      JOIN "Sitter" s ON s.id = b."sitterId"
      JOIN "User" u ON u.id = s."userId"
      WHERE b."paidAt" >= ${k.tu} AND b."paidAt" <= ${k.den}
      GROUP BY s.id, u."fullName"
      ORDER BY amount DESC
      LIMIT ${SO_TOP_NGUOI_CHAM}`;
  }
}
