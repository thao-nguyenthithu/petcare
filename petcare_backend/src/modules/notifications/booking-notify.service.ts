import { Injectable } from '@nestjs/common';
import type { NotificationType } from 'generated/prisma/enums';
import { tienVn as tien } from '../../common/dinh-dang-tien';
import { PrismaService } from '../../prisma/prisma.service';
import { phanTramPhiHuyCuaDon } from '../bookings/booking-cancel';
import { NotificationsService } from './notifications.service';
import type { KhoaTin, ThamSoTin } from './thong-bao-i18n';

type TinDon = {
  type: NotificationType;
  titleKey: KhoaTin;
  bodyKey: KhoaTin;
  params?: ThamSoTin;
  urgent?: boolean;
};

@Injectable()
export class BookingNotifyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
  ) {}

  private async layDon(bookingId: string) {
    return this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: {
        id: true,
        code: true,
        ownerId: true,
        owner: { select: { fullName: true } },
        sitter: {
          select: { userId: true, user: { select: { fullName: true } } },
        },
        service: { select: { name: true } },
        cancelFeePercent: true,
      },
    });
  }

  async baoChuNuoi(bookingId: string, tin: TinDon) {
    const don = await this.layDon(bookingId);
    if (!don) return;
    await this.notifications.tao({
      userId: don.ownerId,
      type: tin.type,
      role: 'CHU_NUOI',
      titleKey: tin.titleKey,
      bodyKey: tin.bodyKey,
      params: { code: don.code, ...tin.params },
      urgent: tin.urgent,
      targetId: don.id,
    });
  }

  async baoNguoiCham(bookingId: string, tin: TinDon) {
    const don = await this.layDon(bookingId);
    if (!don?.sitter) return;
    await this.notifications.tao({
      userId: don.sitter.userId,
      type: tin.type,
      role: 'NGUOI_CHAM',
      titleKey: tin.titleKey,
      bodyKey: tin.bodyKey,
      params: { code: don.code, ...tin.params },
      urgent: tin.urgent,
      targetId: don.id,
    });
  }

  async chuNuoiBaoMuon(bookingId: string, soPhut: number, donVe: boolean) {
    const don = await this.layDon(bookingId);
    if (!don) return;
    await this.baoNguoiCham(bookingId, {
      type: 'DON_HANG',
      titleKey: 'tbChuNuoiBaoMuonTieuDe',
      bodyKey: donVe
        ? 'tbChuNuoiBaoMuonDonNoiDung'
        : 'tbChuNuoiBaoMuonGiaoNoiDung',
      params: { tenChuNuoi: don.owner.fullName, soPhut },
      urgent: true,
    });
  }

  async donMoi(bookingId: string) {
    const don = await this.layDon(bookingId);
    if (!don?.sitter) return;
    await this.baoNguoiCham(bookingId, {
      type: 'DON_MOI',
      titleKey: 'tbDonMoiTieuDe',
      bodyKey: 'tbDonMoiNoiDung',
      params: { tenDichVu: don.service.name },
      urgent: true,
    });
  }

  async daNhanDon(bookingId: string) {
    const don = await this.layDon(bookingId);
    if (!don) return;
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HANG',
      titleKey: 'tbDaNhanDonTieuDe',
      bodyKey: 'tbDaNhanDonNoiDung',
      params: { tenNcc: don.sitter?.user.fullName ?? 'Người chăm' },
    });
  }

  async tuChoiDon(bookingId: string) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbTuChoiDonTieuDe',
      bodyKey: 'tbTuChoiDonNoiDung',
      urgent: true,
    });
  }

  async daXuatPhat(bookingId: string) {
    const don = await this.layDon(bookingId);
    if (!don) return;
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HANG',
      titleKey: 'tbDaXuatPhatTieuDe',
      bodyKey: 'tbDaXuatPhatNoiDung',
      params: { tenNcc: don.sitter?.user.fullName ?? 'Người chăm' },
    });
  }

  async daToiNoi(bookingId: string) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HANG',
      titleKey: 'tbDaToiNoiTieuDe',
      bodyKey: 'tbDaToiNoiNoiDung',
      urgent: true,
    });
  }

  async sapHetGioGiaoBe(bookingId: string) {
    const don = await this.layDon(bookingId);
    if (!don) return;
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HANG',
      titleKey: 'tbSapHetGioGiaoBeTieuDe',
      bodyKey: 'tbSapHetGioGiaoBeNoiDung',
      params: { phanTramPhi: phanTramPhiHuyCuaDon(don.cancelFeePercent) },
      urgent: true,
    });
  }

  async daBatDau(bookingId: string) {
    const don = await this.layDon(bookingId);
    if (!don) return;
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HANG',
      titleKey: 'tbDaBatDauTieuDe',
      bodyKey: 'tbDaBatDauNoiDung',
      params: { tenDichVu: don.service.name },
    });
  }

  async choXacNhan(bookingId: string, gioGiuTien: number) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HANG',
      titleKey: 'tbChoXacNhanTieuDe',
      bodyKey: 'tbChoXacNhanNoiDung',
      params: { gioGiuTien },
      urgent: true,
    });
  }

  async anhMoi(bookingId: string) {
    await this.baoChuNuoi(bookingId, {
      type: 'BANG_CHUNG',
      titleKey: 'tbAnhMoiTieuDe',
      bodyKey: 'tbAnhMoiNoiDung',
    });
  }

  // Gộp theo hội thoại: người nhận còn một tin chưa đọc của đơn này thì đừng kêu lần nữa
  async tinNhanMoi(bookingId: string, guiBoiChuNuoi: boolean) {
    const don = await this.layDon(bookingId);
    if (!don?.sitter) return;
    const nguoiNhan = guiBoiChuNuoi ? don.sitter.userId : don.ownerId;
    const daCo = await this.prisma.notification.findFirst({
      where: {
        userId: nguoiNhan,
        targetId: bookingId,
        type: 'TIN_NHAN',
        isRead: false,
      },
      select: { id: true },
    });
    if (daCo) return;
    const tin = {
      type: 'TIN_NHAN',
      titleKey: 'tbTinNhanMoiTieuDe',
      bodyKey: 'tbTinNhanMoiNoiDung',
      params: {
        tenNguoiGui: guiBoiChuNuoi
          ? don.owner.fullName
          : don.sitter.user.fullName,
      },
    } as const;
    if (guiBoiChuNuoi) {
      await this.baoNguoiCham(bookingId, tin);
    } else {
      await this.baoChuNuoi(bookingId, tin);
    }
  }

  async nccHuyDon(bookingId: string) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbNccHuyDonTieuDe',
      bodyKey: 'tbNccHuyDonNoiDung',
      urgent: true,
    });
  }

  async nccKhongTheTiepNhan(bookingId: string) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbNccKhongTiepNhanTieuDe',
      bodyKey: 'tbNccKhongTiepNhanNoiDung',
      urgent: true,
    });
  }

  async huyViThieuDungCu(
    bookingId: string,
    phiHuy: number,
    nccNhan: number,
    hoanLai: number,
  ) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbThieuDungCuChuNuoiTieuDe',
      bodyKey: 'tbThieuDungCuChuNuoiNoiDung',
      params: { phiHuy: tien(phiHuy), hoanLai: tien(hoanLai) },
      urgent: true,
    });
    await this.baoNguoiCham(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbThieuDungCuNccTieuDe',
      bodyKey: 'tbThieuDungCuNccNoiDung',
      params: { nccNhan: tien(nccNhan) },
    });
  }

  async chuNuoiVangMat(
    bookingId: string,
    phiHuy: number,
    nccNhan: number,
    soGioPhanDoi: number,
  ) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbVangMatChuNuoiTieuDe',
      bodyKey: 'tbVangMatChuNuoiNoiDung',
      params: { phiHuy: tien(phiHuy), soGioPhanDoi },
      urgent: true,
    });
    await this.baoNguoiCham(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbVangMatNccTieuDe',
      bodyKey: 'tbVangMatNccNoiDung',
      params: { nccNhan: tien(nccNhan), soGioPhanDoi },
    });
  }

  async donHuyViKhongAiBatDau(bookingId: string) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbQuaGioHenTieuDe',
      bodyKey: 'tbQuaGioHenChuNuoiNoiDung',
      urgent: true,
    });
    await this.baoNguoiCham(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbQuaGioHenTieuDe',
      bodyKey: 'tbQuaGioHenNccNoiDung',
    });
  }

  async chuNuoiKetThucSom(bookingId: string, hoanLai: number) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HANG',
      titleKey: 'tbKetThucSomChuNuoiTieuDe',
      bodyKey: 'tbKetThucSomChuNuoiNoiDung',
      params: { hoanLai: tien(hoanLai) },
    });
    await this.baoNguoiCham(bookingId, {
      type: 'DON_HANG',
      titleKey: 'tbKetThucSomNccTieuDe',
      bodyKey: 'tbKetThucSomNccNoiDung',
      urgent: true,
    });
  }

  async chuNuoiHuyDon(bookingId: string) {
    await this.baoNguoiCham(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbChuNuoiHuyDonTieuDe',
      bodyKey: 'tbChuNuoiHuyDonNoiDung',
      urgent: true,
    });
  }

  async donQuaHanNhan(bookingId: string) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbQuaHanNhanChuNuoiTieuDe',
      bodyKey: 'tbQuaHanNhanChuNuoiNoiDung',
      urgent: true,
    });
    await this.baoNguoiCham(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbQuaHanNhanNccTieuDe',
      bodyKey: 'tbQuaHanNhanNccNoiDung',
    });
  }

  async donHuyViNccChuaToi(bookingId: string) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbNccChuaToiChuNuoiTieuDe',
      bodyKey: 'tbNccChuaToiChuNuoiNoiDung',
      urgent: true,
    });
    await this.baoNguoiCham(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbNccChuaToiNccTieuDe',
      bodyKey: 'tbNccChuaToiNccNoiDung',
      urgent: true,
    });
  }

  async donHuyViNccBan(bookingId: string) {
    await this.baoChuNuoi(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbNccBanChuNuoiTieuDe',
      bodyKey: 'tbNccBanChuNuoiNoiDung',
      urgent: true,
    });
    await this.baoNguoiCham(bookingId, {
      type: 'DON_HUY',
      titleKey: 'tbNccBanNccTieuDe',
      bodyKey: 'tbNccBanNccNoiDung',
    });
  }
}
