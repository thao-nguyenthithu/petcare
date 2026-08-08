import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { BookingStatus, UserRole } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { dauNgayVn, MOT_NGAY_MS } from '../../../common/thoi-gian-vn';
import { dungTrang, KetQuaTrang, kepTrang } from '../chung/phan-trang';
import { chonChieu, chonCot } from '../chung/sap-xep';
import {
  COT_SAP_XEP_NGUOI_DUNG,
  LocNguoiDungDto,
} from './dto/loc-nguoi-dung.dto';

export type DongNguoiDung = {
  id: string;
  fullName: string;
  email: string;
  phone: string | null;
  role: UserRole;
  avatarUrl: string | null;
  isActive: boolean;
  isVerified: boolean;
  createdAt: Date;
  petCount: number;
  bookingCount: number;
  province: string | null;
  // Cột role KHÔNG nói được vai này: người chăm vẫn đặt đơn như chủ nuôi (bộ luật mục 1)
  isSitter: boolean;
};

// Khoá hồ sơ vĩnh viễn là mất vai người chăm, chờ duyệt thì chưa có vai đó
const LA_NGUOI_CHAM: Prisma.SitterWhereInput = {
  status: 'APPROVED',
  bannedAt: null,
};

// Đơn chưa trả tiền chưa ai nhìn thấy nên không tính là đơn của người dùng
const BO_KHOI_SO_DON = { not: BookingStatus.AWAITING_PAYMENT };

@Injectable()
export class AdminUsersReadService {
  constructor(private readonly prisma: PrismaService) {}

  private dieuKien(loc: LocNguoiDungDto): Prisma.UserWhereInput {
    const dieu: Prisma.UserWhereInput = {};
    // Tab Người chăm lọc theo hồ sơ chứ không theo cột role, cột đó không ai ghi PROVIDER
    if (loc.role === UserRole.PROVIDER) dieu.sitter = { is: LA_NGUOI_CHAM };
    else if (loc.role === UserRole.OWNER) {
      dieu.role = UserRole.OWNER;
      dieu.sitter = { isNot: LA_NGUOI_CHAM };
    } else if (loc.role) dieu.role = loc.role;
    if (loc.active !== undefined) dieu.isActive = loc.active;
    if (loc.province) {
      dieu.addresses = { some: { isDefault: true, province: loc.province } };
    }
    if (loc.from || loc.to) {
      dieu.createdAt = {
        ...(loc.from ? { gte: dauNgayVn(loc.from) } : {}),
        // Đến hết ngày `to` theo giờ VN, nên lấy mốc đầu ngày hôm sau
        ...(loc.to
          ? { lt: new Date(dauNgayVn(loc.to).getTime() + MOT_NGAY_MS) }
          : {}),
      };
    }
    if (loc.q) {
      const tim = { contains: loc.q, mode: Prisma.QueryMode.insensitive };
      dieu.OR = [{ fullName: tim }, { email: tim }, { phone: tim }];
    }
    return dieu;
  }

  async danhSach(loc: LocNguoiDungDto): Promise<KetQuaTrang<DongNguoiDung>> {
    const khoang = kepTrang(loc.page, loc.limit);
    const where = this.dieuKien(loc);
    const cot = chonCot(COT_SAP_XEP_NGUOI_DUNG, loc.sort, 'createdAt');
    const chieu = chonChieu(loc.dir, cot === 'createdAt' ? 'desc' : 'asc');

    const [total, ds] = await Promise.all([
      this.prisma.user.count({ where }),
      this.prisma.user.findMany({
        where,
        orderBy: { [cot]: chieu },
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          id: true,
          fullName: true,
          email: true,
          phone: true,
          role: true,
          avatarUrl: true,
          isActive: true,
          isVerified: true,
          createdAt: true,
          addresses: {
            where: { isDefault: true },
            select: { province: true },
            take: 1,
          },
          sitter: { select: { status: true, bannedAt: true } },
          _count: {
            select: {
              pets: { where: { isActive: true } },
              bookingsAsOwner: { where: { status: BO_KHOI_SO_DON } },
            },
          },
        },
      }),
    ]);

    const items = ds.map((u) => ({
      id: u.id,
      fullName: u.fullName,
      email: u.email,
      phone: u.phone,
      role: u.role,
      avatarUrl: u.avatarUrl,
      isActive: u.isActive,
      isVerified: u.isVerified,
      createdAt: u.createdAt,
      petCount: u._count.pets,
      bookingCount: u._count.bookingsAsOwner,
      province: u.addresses[0]?.province ?? null,
      isSitter: u.sitter?.status === 'APPROVED' && u.sitter.bannedAt === null,
    }));
    return dungTrang(items, total, khoang);
  }

  // Đếm trên TOÀN hệ thống, không theo bộ lọc đang chọn
  async demTab() {
    const [tatCa, nguoiCham, chuNuoi, locked] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({ where: { sitter: { is: LA_NGUOI_CHAM } } }),
      this.prisma.user.count({
        where: { role: UserRole.OWNER, sitter: { isNot: LA_NGUOI_CHAM } },
      }),
      this.prisma.user.count({ where: { isActive: false } }),
    ]);
    return { all: tatCa, owner: chuNuoi, provider: nguoiCham, locked };
  }

  // Danh mục tỉnh dựng từ chính địa chỉ đang có, không nhúng danh sách cứng
  async danhSachTinh(): Promise<string[]> {
    const ds = await this.prisma.address.findMany({
      where: { isDefault: true },
      distinct: ['province'],
      select: { province: true },
      orderBy: { province: 'asc' },
    });
    return ds.map((d) => d.province);
  }
}
