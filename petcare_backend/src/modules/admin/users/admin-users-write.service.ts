import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { UserRole } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { NhatKyQuanTriService } from '../chung/nhat-ky-quan-tri.service';
import { TRANG_THAI_DANG_CHAY } from './admin-users.trang-thai';

@Injectable()
export class AdminUsersWriteService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly nhatKy: NhatKyQuanTriService,
  ) {}

  private loiVuaDoiNoiKhac() {
    return new ConflictException({
      code: 'TRANG_THAI_KHONG_HOP_LE',
      message: 'Trạng thái vừa được đổi ở nơi khác, tải lại rồi thử tiếp',
    });
  }

  // Đếm cả hai vai vì một tài khoản vừa đặt đơn vừa nhận đơn được
  private demDonDangChay(userId: string) {
    return this.prisma.booking.count({
      where: {
        status: { in: TRANG_THAI_DANG_CHAY },
        OR: [{ ownerId: userId }, { sitter: { userId } }],
      },
    });
  }

  async datTrangThai(
    id: string,
    isActive: boolean,
    reason: string,
    adminId: string,
  ) {
    if (id === adminId) {
      throw new BadRequestException({
        code: 'KHONG_TU_KHOA_CHINH_MINH',
        message: 'Không khoá được tài khoản đang đăng nhập',
      });
    }
    const [user, donDangChay] = await Promise.all([
      this.prisma.user.findUnique({
        where: { id },
        select: { email: true, role: true, isActive: true },
      }),
      this.demDonDangChay(id),
    ]);
    if (!user) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_NGUOI_DUNG',
        message: 'Không tìm thấy người dùng này',
      });
    }
    // Chỉ có một tài khoản quản trị, khoá nhầm là mất luôn đường vào hệ thống
    if (user.role === UserRole.ADMIN) {
      throw new BadRequestException({
        code: 'KHONG_KHOA_TAI_KHOAN_QUAN_TRI',
        message: 'Không khoá được tài khoản quản trị',
      });
    }
    if (user.isActive === isActive) {
      return { id, isActive, runningBookingCount: donDangChay };
    }

    await this.prisma.$transaction(async (db) => {
      // Kẹp trạng thái cũ vào where, không thì hai lượt cùng lúc ghi hai dòng nhật ký giống hệt
      const doi = await db.user.updateMany({
        where: { id, isActive: !isActive },
        data: { isActive },
      });
      if (doi.count === 0) throw this.loiVuaDoiNoiKhac();
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: isActive ? 'MO_KHOA_TAI_KHOAN' : 'KHOA_TAI_KHOAN',
          targetType: 'USER',
          targetId: id,
          targetCode: user.email,
          reason,
          oldValue: String(user.isActive),
          // Số đơn đang chạy lúc khoá, để sau này truy được vì sao đơn treo
          newValue: `${isActive}|donDangChay=${donDangChay}`,
        },
        db,
      );
    });
    return { id, isActive, runningBookingCount: donDangChay };
  }

  // Ẩn hồ sơ bé chứ không xoá: BookingPet của đơn cũ vẫn phải trỏ được tới bé
  async datTrangThaiThuCung(
    id: string,
    isActive: boolean,
    reason: string,
    adminId: string,
  ) {
    const pet = await this.prisma.pet.findUnique({
      where: { id },
      select: { name: true, isActive: true },
    });
    if (!pet) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_THU_CUNG',
        message: 'Không tìm thấy hồ sơ thú cưng này',
      });
    }
    if (pet.isActive === isActive) {
      return { id, isActive };
    }

    await this.prisma.$transaction(async (db) => {
      const doi = await db.pet.updateMany({
        where: { id, isActive: !isActive },
        data: { isActive },
      });
      if (doi.count === 0) throw this.loiVuaDoiNoiKhac();
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: isActive ? 'HIEN_HO_SO_THU_CUNG' : 'AN_HO_SO_THU_CUNG',
          targetType: 'PET',
          targetId: id,
          targetCode: pet.name,
          reason,
          oldValue: String(pet.isActive),
          newValue: String(isActive),
        },
        db,
      );
    });
    return { id, isActive };
  }
}
