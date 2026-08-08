import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { WithdrawalStatus } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { WalletLedgerService } from '../../wallet/wallet-ledger.service';
import type { HanhDongNhatKy } from '../chung/hanh-dong-nhat-ky';
import { NhatKyQuanTriService } from '../chung/nhat-ky-quan-tri.service';
import { dungTrang, kepTrang } from '../chung/phan-trang';
import {
  ChuyenLenhRut,
  DoiLenhRutDto,
  LocLenhRutDto,
} from './dto/loc-lenh-rut.dto';

// Trạng thái phải đang đứng ở đây thì lối chuyển mới hợp lệ
const TRANG_THAI_TRUOC: Record<ChuyenLenhRut, WithdrawalStatus> = {
  SENT: WithdrawalStatus.PENDING,
  DONE: WithdrawalStatus.SENT,
  REJECTED: WithdrawalStatus.PENDING,
};

const MA_NHAT_KY: Record<ChuyenLenhRut, HanhDongNhatKy> = {
  SENT: 'CHUYEN_TIEN_RUT',
  DONE: 'HOAN_TAT_LENH_RUT',
  REJECTED: 'TU_CHOI_LENH_RUT',
};

@Injectable()
export class AdminWithdrawalsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly nhatKy: NhatKyQuanTriService,
    private readonly soVi: WalletLedgerService,
  ) {}

  private dieuKien(loc: LocLenhRutDto): Prisma.WithdrawalWhereInput {
    const dieu: Prisma.WithdrawalWhereInput = {};
    if (loc.status) dieu.status = loc.status;
    if (loc.from || loc.to) {
      dieu.createdAt = {
        ...(loc.from ? { gte: new Date(loc.from) } : {}),
        ...(loc.to ? { lte: new Date(loc.to) } : {}),
      };
    }
    if (loc.q) {
      const tim = { contains: loc.q, mode: Prisma.QueryMode.insensitive };
      dieu.OR = [
        { accountHolder: tim },
        { accountNumber: tim },
        { reference: tim },
        { sitter: { legalName: tim } },
        { sitter: { user: { fullName: tim } } },
      ];
    }
    return dieu;
  }

  async danhSach(loc: LocLenhRutDto) {
    const khoang = kepTrang(loc.page, loc.limit);
    const where = this.dieuKien(loc);

    const [total, ds] = await Promise.all([
      this.prisma.withdrawal.count({ where }),
      this.prisma.withdrawal.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          id: true,
          sitterId: true,
          amount: true,
          fee: true,
          status: true,
          bankName: true,
          accountNumber: true,
          accountHolder: true,
          reference: true,
          rejectReason: true,
          createdAt: true,
          sentAt: true,
          doneAt: true,
          sitter: { select: { user: { select: { fullName: true } } } },
        },
      }),
    ]);

    const items = ds.map((l) => ({
      id: l.id,
      sitterId: l.sitterId,
      sitterName: l.sitter.user.fullName,
      bankName: l.bankName,
      accountNumber: l.accountNumber,
      accountHolder: l.accountHolder,
      amount: l.amount,
      fee: l.fee,
      status: l.status,
      reference: l.reference,
      rejectReason: l.rejectReason,
      createdAt: l.createdAt,
      sentAt: l.sentAt,
      doneAt: l.doneAt,
    }));
    return dungTrang(items, total, khoang);
  }

  async doiTrangThai(id: string, dto: DoiLenhRutDto, adminId: string) {
    const lenh = await this.prisma.withdrawal.findUnique({
      where: { id },
      select: { id: true, sitterId: true, amount: true, status: true },
    });
    if (!lenh) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_LENH_RUT',
        message: 'Không tìm thấy lệnh rút này',
      });
    }
    this.kiemLoiChuyen(lenh.status, dto);

    const bayGio = new Date();
    await this.prisma.$transaction(async (db) => {
      // Kẹp trạng thái cũ vào where để hai lượt bấm cùng lúc không cùng chạy qua
      const doi = await db.withdrawal.updateMany({
        where: { id: lenh.id, status: lenh.status },
        data: this.duLieuDoi(dto, bayGio),
      });
      if (doi.count === 0) throw this.loiTrangThai(lenh.status);
      if (dto.status === 'REJECTED') {
        await this.soVi.ghi(
          lenh.sitterId,
          {
            loai: 'DIEU_CHINH',
            tieuDe: 'Hoàn lại lệnh rút bị từ chối',
            soTien: lenh.amount,
            withdrawalId: lenh.id,
          },
          db,
        );
      }
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: MA_NHAT_KY[dto.status],
          targetType: 'WITHDRAWAL',
          targetId: lenh.id,
          reason: dto.rejectReason ?? null,
          oldValue: lenh.status,
          newValue: dto.status,
        },
        db,
      );
    });
    return { id: lenh.id, status: dto.status };
  }

  private duLieuDoi(
    dto: DoiLenhRutDto,
    bayGio: Date,
  ): Prisma.WithdrawalUpdateManyMutationInput {
    if (dto.status === 'SENT') {
      return {
        status: WithdrawalStatus.SENT,
        reference: dto.reference,
        sentAt: bayGio,
      };
    }
    if (dto.status === 'DONE') {
      return { status: WithdrawalStatus.DONE, doneAt: bayGio };
    }
    return {
      status: WithdrawalStatus.REJECTED,
      rejectReason: dto.rejectReason,
    };
  }

  private kiemLoiChuyen(dangO: WithdrawalStatus, dto: DoiLenhRutDto) {
    if (TRANG_THAI_TRUOC[dto.status] !== dangO) throw this.loiTrangThai(dangO);
    if (dto.status === 'SENT' && !dto.reference) {
      throw new BadRequestException({
        code: 'THIEU_MA_THAM_CHIEU',
        message: 'Phải nhập mã tham chiếu của lượt chuyển khoản',
      });
    }
    if (dto.status === 'REJECTED' && !dto.rejectReason) {
      throw new BadRequestException({
        code: 'THIEU_LY_DO_TU_CHOI',
        message: 'Phải ghi lý do từ chối lệnh rút',
      });
    }
  }

  private loiTrangThai(dangO: WithdrawalStatus) {
    return new ConflictException({
      code: 'TRANG_THAI_KHONG_HOP_LE',
      message: `Lệnh rút đang ở ${dangO}, không đi tiếp bằng lối này được`,
    });
  }
}
