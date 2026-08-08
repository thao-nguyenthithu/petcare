import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { type LyDoHuyNccDto } from '../orders/dto/sitter-order.dto';
import { SitterCancelService } from '../orders/sitter-cancel.service';
import { CancelBookingDto, type LyDoHuy } from './dto/cancel-booking.dto';

const LY_DO_SANG_MA_CHUNG: Record<LyDoHuy, LyDoHuyNccDto> = {
  OM_DOT_XUAT: 'sucKhoeKhongTot',
  BAN_VIEC_GAP: 'banViecDotXuat',
  TRUNG_LICH: 'trungLichDonKhac',
  KHAC: 'khac',
};

@Injectable()
export class SitterScheduleService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly cancel: SitterCancelService,
  ) {}

  async huyDon(userId: string, bookingId: string, dto: CancelBookingDto) {
    const ket = await this.cancel.huyDon(userId, bookingId, {
      reason: LY_DO_SANG_MA_CHUNG[dto.reason],
      note: dto.note?.trim(),
    });
    return { id: ket.id, status: ket.status, canhCao: ket.canhCao };
  }
}
