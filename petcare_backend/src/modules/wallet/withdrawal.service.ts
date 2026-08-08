import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { dauNgayVn, homNayVn } from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { layNccCuaToi } from '../sitter/orders/sitter-guard';
import { BankAccountDto, WithdrawDto } from './dto/wallet.dto';
import { PHI_CHUYEN } from './wallet.constants';
import { SystemSettingsService } from '../admin/system-settings.service';
import { WalletLedgerService } from './wallet-ledger.service';

@Injectable()
export class WithdrawalService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: WalletLedgerService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  async taiKhoan(userId: string) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const [tk, daRut] = await Promise.all([
      this.prisma.bankAccount.findUnique({ where: { sitterId: ncc.id } }),
      this.demLenhTrongNgay(ncc.id),
    ]);
    const soLanMoiNgay = this.thamSo.so('withdraw.per_day');
    return (
      tk && {
        ...this.raTaiKhoan(tk),
        soLuotConLai: Math.max(0, soLanMoiNgay - daRut),
        soLuotMoiNgay: soLanMoiNgay,
      }
    );
  }

  private async demLenhTrongNgay(sitterId: string): Promise<number> {
    return this.prisma.withdrawal.count({
      where: { sitterId, createdAt: { gte: dauNgayVn(homNayVn()) } },
    });
  }

  async luuTaiKhoan(userId: string, dto: BankAccountDto) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const tk = await this.prisma.bankAccount.upsert({
      where: { sitterId: ncc.id },
      create: {
        sitterId: ncc.id,
        bankName: dto.bankName,
        accountNumber: dto.accountNumber,
        accountHolder: dto.accountHolder.toUpperCase(),
      },
      update: {
        bankName: dto.bankName,
        accountNumber: dto.accountNumber,
        accountHolder: dto.accountHolder.toUpperCase(),
        verified: false,
      },
    });
    return this.raTaiKhoan(tk);
  }

  async danhSachLenh(userId: string) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const ds = await this.prisma.withdrawal.findMany({
      where: { sitterId: ncc.id },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });
    return ds.map((l) => ({
      id: l.id,
      soTien: l.amount,
      phi: l.fee,
      trangThai: l.status,
      tenNganHang: l.bankName,
      bonSoCuoi: l.accountNumber.slice(-4),
      maThamChieu: l.reference,
      taoLuc: l.createdAt.toISOString(),
      xongLuc: l.doneAt?.toISOString() ?? null,
    }));
  }

  async rut(userId: string, dto: WithdrawDto) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const soTien = dto.amount;
    const mucToiThieu = this.thamSo.so('withdraw.min');
    if (soTien < mucToiThieu) {
      throw new BadRequestException({
        code: 'DUOI_MUC_RUT_TOI_THIEU',
        message: `Số tiền rút tối thiểu là ${mucToiThieu.toLocaleString('vi-VN')}đ`,
      });
    }
    const taiKhoan = await this.prisma.bankAccount.findUnique({
      where: { sitterId: ncc.id },
    });
    if (!taiKhoan) {
      throw new BadRequestException({
        code: 'CHUA_LIEN_KET_NGAN_HANG',
        message: 'Bạn cần thêm tài khoản nhận tiền trước khi rút',
      });
    }
    const daRut = await this.demLenhTrongNgay(ncc.id);
    const soLanMoiNgay = this.thamSo.so('withdraw.per_day');
    if (daRut >= soLanMoiNgay) {
      throw new ConflictException({
        code: 'VUOT_SO_LAN_RUT_NGAY',
        message: `Mỗi ngày chỉ rút được ${soLanMoiNgay} lần, bạn thử lại vào ngày mai`,
      });
    }
    return this.prisma.$transaction(async (tx) => {
      const lenh = await tx.withdrawal.create({
        data: {
          sitterId: ncc.id,
          amount: soTien,
          fee: PHI_CHUYEN,
          bankName: taiKhoan.bankName,
          accountNumber: taiKhoan.accountNumber,
          accountHolder: taiKhoan.accountHolder,
        },
      });
      const gd = await this.ledger.ghi(
        ncc.id,
        {
          loai: 'RUT_RA',
          tieuDe: `Rút về ${taiKhoan.bankName} · ${taiKhoan.accountNumber.slice(-4)}`,
          soTien: -soTien,
          withdrawalId: lenh.id,
        },
        tx,
      );
      return {
        id: lenh.id,
        maGiaoDich: gd.code,
        soTien,
        phi: PHI_CHUYEN,
        thucNhan: soTien - PHI_CHUYEN,
        trangThai: lenh.status,
        soDuConLai: gd.balanceAfter,
      };
    });
  }

  async danhDauThatBai(withdrawalId: string, lyDo: string) {
    const lenh = await this.prisma.withdrawal.findUnique({
      where: { id: withdrawalId },
    });
    if (!lenh) throw new NotFoundException('Không tìm thấy lệnh rút');
    if (lenh.status !== 'PENDING' && lenh.status !== 'SENT') {
      throw new ConflictException('Lệnh rút đã chốt, không đổi được nữa');
    }
    await this.prisma.$transaction(async (tx) => {
      await tx.withdrawal.update({
        where: { id: lenh.id },
        data: { status: 'REJECTED', rejectReason: lyDo },
      });
      await this.ledger.ghi(
        lenh.sitterId,
        {
          loai: 'DIEU_CHINH',
          tieuDe: 'Hoàn lại lệnh rút không thành công',
          soTien: lenh.amount,
          withdrawalId: lenh.id,
        },
        tx,
      );
    });
    return { id: lenh.id, status: 'REJECTED' };
  }

  private raTaiKhoan(tk: {
    bankName: string;
    accountNumber: string;
    accountHolder: string;
    verified: boolean;
  }) {
    return {
      tenNganHang: tk.bankName,
      bonSoCuoi: tk.accountNumber.slice(-4),
      tenChuTaiKhoan: tk.accountHolder,
      daXacThuc: tk.verified,
    };
  }
}
