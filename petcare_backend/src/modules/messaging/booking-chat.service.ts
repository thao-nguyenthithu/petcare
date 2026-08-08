import { Injectable } from '@nestjs/common';
import { tienVn as tien } from '../../common/dinh-dang-tien';
import { gioVn } from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { SystemMessageService } from './system-message.service';

// Hai bản chữ theo vai

@Injectable()
export class BookingChatService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly system: SystemMessageService,
  ) {}

  private async ten(bookingId: string) {
    const don = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: {
        owner: { select: { fullName: true } },
        sitter: { select: { user: { select: { fullName: true } } } },
      },
    });
    return {
      chuNuoi: don?.owner.fullName ?? 'Chủ nuôi',
      nguoiCham: don?.sitter?.user.fullName ?? 'Người chăm',
    };
  }

  async daNhanDon(bookingId: string, luc = new Date()) {
    const { nguoiCham } = await this.ten(bookingId);
    await this.system.ghi(bookingId, {
      text: `${nguoiCham} đã nhận đơn · ${gioVn(luc)}`,
      textSitter: `Bạn đã nhận đơn · ${gioVn(luc)}`,
    });
  }

  async daXuatPhat(bookingId: string, luc = new Date()) {
    const { nguoiCham } = await this.ten(bookingId);
    await this.system.ghi(bookingId, {
      text: `${nguoiCham} đã xuất phát lúc ${gioVn(luc)}`,
      textSitter: `Bạn đã xuất phát lúc ${gioVn(luc)}`,
      actionLabelSitter: 'Xem chỉ đường',
    });
  }

  async baoMuon(bookingId: string, soPhut: number, eta: Date | null) {
    const { nguoiCham } = await this.ten(bookingId);
    const duKien = eta ? ` · dự kiến tới ${gioVn(eta)}` : '';
    await this.system.ghi(bookingId, {
      text: `${nguoiCham} báo đến muộn khoảng ${soPhut} phút${duKien}`,
      textSitter: `Bạn đã báo đến muộn khoảng ${soPhut} phút${duKien}`,
      canGap: true,
    });
  }

  async daToiNoi(
    bookingId: string,
    khoangCachM: number | null,
    luc = new Date(),
  ) {
    const { chuNuoi, nguoiCham } = await this.ten(bookingId);
    const cach = khoangCachM != null ? `, cách ${khoangCachM} m` : '';
    await this.system.ghi(bookingId, {
      text: `${nguoiCham} đã tới điểm hẹn lúc ${gioVn(luc)}${cach}`,
      textSitter: `Bạn đã tới điểm hẹn${cach ? `, cách nhà ${chuNuoi}${cach.slice(1)}` : ''} · ${gioVn(luc)}`,
    });
  }

  async daBatDau(bookingId: string, coGps: boolean, luc = new Date()) {
    await this.system.ghi(bookingId, {
      text: `Dịch vụ bắt đầu lúc ${gioVn(luc)}`,
      textSitter: `Bạn đã bắt đầu dịch vụ lúc ${gioVn(luc)}${coGps ? ' · vị trí đang chia sẻ cho chủ nuôi' : ''}`,
      actionLabel: coGps ? 'Xem vị trí trực tiếp' : undefined,
    });
  }

  async anhMoi(
    bookingId: string,
    anh: string[],
    ghiChu: string | null,
    tongSoAnh: number,
  ) {
    const hienThi = anh.slice(0, 3);
    await this.system.ghi(bookingId, {
      text: ghiChu ?? 'Có ảnh mới từ người chăm',
      images: hienThi,
      soAnhThem:
        tongSoAnh > hienThi.length ? tongSoAnh - hienThi.length : undefined,
      caption: ghiChu ?? undefined,
      actionLabel: `Xem tất cả ${tongSoAnh} ảnh trong nhật ký`,
      actionLabelSitter: `Xem tất cả ${tongSoAnh} ảnh trong nhật ký`,
    });
  }

  async choXacNhan(bookingId: string, soGioHan: number, luc = new Date()) {
    const { chuNuoi, nguoiCham } = await this.ten(bookingId);
    await this.system.ghi(bookingId, {
      text: `Đơn hoàn thành lúc ${gioVn(luc)} · chờ bạn xác nhận, hết ${soGioHan} giờ hệ thống tự chốt`,
      textSitter: `Bạn đã báo hoàn thành lúc ${gioVn(luc)} · chờ ${chuNuoi} xác nhận, hết ${soGioHan} giờ hệ thống tự chốt`,
      actionLabel: 'Xác nhận hoàn thành',
      canGap: true,
    });
    return nguoiCham;
  }

  async daXacNhanHoanThanh(
    bookingId: string,
    khoanNccNhan: number,
    soGioNha: number,
  ) {
    const { chuNuoi, nguoiCham } = await this.ten(bookingId);
    await this.system.ghi(bookingId, {
      text: `Bạn đã xác nhận hoàn thành · ${tien(khoanNccNhan)} nền tảng đang giữ, chuyển cho ${nguoiCham} sau ${soGioNha} giờ`,
      textSitter: `${chuNuoi} đã xác nhận hoàn thành · ${tien(khoanNccNhan)} vào ví bạn sau ${soGioNha} giờ kể từ khi kết thúc`,
      actionLabelSitter: 'Xem ví',
    });
  }

  async nccHuyDon(bookingId: string) {
    const { nguoiCham } = await this.ten(bookingId);
    await this.system.ghi(bookingId, {
      text: `${nguoiCham} đã huỷ đơn · tiền được hoàn về nguồn bạn đã thanh toán`,
      textSitter:
        'Bạn đã huỷ đơn · lịch của bạn đã được trả lại, lần huỷ này tính vào tỷ lệ huỷ',
      canGap: true,
    });
  }

  async nccKhongTheTiepNhan(bookingId: string, choSoat: boolean) {
    const { nguoiCham } = await this.ten(bookingId);
    const veNcc = choSoat
      ? ' · lần này ghi ở thể chờ đội hỗ trợ soát'
      : ' · lần huỷ này tính vào tỷ lệ huỷ và kèm một cảnh cáo';
    await this.system.ghi(bookingId, {
      text: `${nguoiCham} gặp sự cố trên đường nên không tiếp nhận được đơn · bạn không mất phí, tiền được hoàn về nguồn bạn đã thanh toán`,
      textSitter: `Bạn đã báo không thể tiếp nhận đơn${veNcc}`,
      canGap: true,
    });
  }

  async huyViThieuDungCu(
    bookingId: string,
    phiHuy: number,
    nccNhan: number,
    hoanLai: number,
  ) {
    await this.system.ghi(bookingId, {
      text: `Đơn huỷ vì thiếu rọ mõm hoặc dây xích · phí huỷ ${tien(phiHuy)}, hoàn ${tien(hoanLai)} về nguồn bạn đã thanh toán`,
      textSitter: `Đơn huỷ vì chủ nuôi không đủ dụng cụ · bạn nhận ${tien(nccNhan)} từ phí huỷ, đơn không tính vào tỷ lệ huỷ`,
      canGap: true,
    });
  }

  async heThongHuyViKhongAiBatDau(bookingId: string) {
    await this.system.ghi(bookingId, {
      text: 'Đơn đã huỷ vì quá giờ hẹn mà chưa bắt đầu · bạn không mất phí, tiền được hoàn về nguồn bạn đã thanh toán',
      textSitter:
        'Đơn đã huỷ vì quá giờ hẹn mà chưa bắt đầu · không bên nào bị tính phí, đơn không tính vào tỷ lệ huỷ của bạn',
      canGap: true,
    });
  }

  async heThongHuyQuaHan(bookingId: string) {
    await this.system.ghi(bookingId, {
      text: 'Đơn đã huỷ vì hết hạn chờ người chăm nhận · tiền được hoàn về nguồn bạn đã thanh toán',
      textSitter:
        'Đơn đã huỷ vì bạn không trả lời trong hạn · lịch của bạn đã được trả lại',
      canGap: true,
    });
  }

  // Không ai bấm huỷ nên phải nói rõ hệ thống làm và nói luôn tiền đi đâu
  async heThongHuyViNccBan(bookingId: string) {
    await this.system.ghi(bookingId, {
      text: 'Đơn đã huỷ vì người chăm nhận đơn khác trùng khung giờ · tiền được hoàn về nguồn bạn đã thanh toán',
      textSitter:
        'Đơn đã tự huỷ vì bạn nhận đơn khác trùng khung giờ · đơn này không tính vào tỷ lệ huỷ',
      canGap: true,
    });
  }

  // Hai vai đọc cùng dòng thời gian nên phải nói rõ ai có lỗi
  async heThongHuyViNccChuaToi(bookingId: string) {
    const { nguoiCham } = await this.ten(bookingId);
    await this.system.ghi(bookingId, {
      text: `Đơn đã huỷ vì ${nguoiCham} không tới điểm đón · bạn không mất phí, tiền được hoàn về nguồn bạn đã thanh toán`,
      textSitter:
        'Đơn đã huỷ vì bạn chưa tới điểm đón sau giờ hẹn · lần huỷ này được tính cho bạn',
      canGap: true,
    });
  }

  async chuNuoiHuyDon(
    bookingId: string,
    phiHuy: number | null,
    nccNhan: number,
  ) {
    const { chuNuoi } = await this.ten(bookingId);
    const veChuNuoi = phiHuy
      ? ` · bạn chịu phí huỷ ${tien(phiHuy)}`
      : ' · bạn được hoàn đủ số đã trả';
    const veNcc = phiHuy ? ` · bạn được ${tien(nccNhan)} phí huỷ` : '';
    await this.system.ghi(bookingId, {
      text: `Bạn đã huỷ đơn${veChuNuoi}`,
      textSitter: `${chuNuoi} đã huỷ đơn${veNcc}`,
      canGap: true,
    });
  }

  async baoVangMat(bookingId: string, khoanNccNhan: number, soGioGiu: number) {
    const { chuNuoi, nguoiCham } = await this.ten(bookingId);
    await this.system.ghi(bookingId, {
      text: `${nguoiCham} đã báo bạn vắng mặt · đơn kết thúc, ${tien(khoanNccNhan)} tạm giữ ${soGioGiu} giờ để bạn phản đối`,
      textSitter: `Bạn đã báo ${chuNuoi} vắng mặt · đơn kết thúc, ${tien(khoanNccNhan)} tạm giữ ${soGioGiu} giờ chờ chủ nuôi phản đối`,
      canGap: true,
    });
  }

  async baoThieuDungCu(bookingId: string, soPhutCho: number) {
    const { nguoiCham } = await this.ten(bookingId);
    await this.system.ghi(bookingId, {
      text: `${nguoiCham} báo thiếu rọ mõm hoặc dây xích · bổ sung trong ${soPhutCho} phút, quá hạn đơn bị huỷ`,
      textSitter: `Bạn đã báo thiếu rọ mõm hoặc dây xích · chờ chủ nuôi bổ sung trong ${soPhutCho} phút`,
      canGap: true,
    });
  }

  async baoSuCo(bookingId: string) {
    const { chuNuoi } = await this.ten(bookingId);
    await this.system.ghi(bookingId, {
      text: 'Bạn đã báo sự cố · thanh toán tạm giữ tới khi đội hỗ trợ có kết luận',
      textSitter: `${chuNuoi} đã báo sự cố · thanh toán tạm giữ tới khi đội hỗ trợ có kết luận`,
      canGap: true,
    });
  }

  async chuNuoiDaXuatPhat(bookingId: string, chieuDonVe: boolean) {
    const { chuNuoi } = await this.ten(bookingId);
    const viec = chieuDonVe ? 'đón bé về' : 'mang bé tới';
    await this.system.ghi(bookingId, {
      text: `Bạn đã xuất phát ${viec}`,
      textSitter: `${chuNuoi} đang trên đường ${viec}`,
    });
  }

  async chuNuoiKetThucSom(
    bookingId: string,
    soDemMoi: number,
    hoanLai: number,
  ) {
    const { chuNuoi } = await this.ten(bookingId);
    await this.system.ghi(bookingId, {
      text: `Bạn đã chốt kết thúc sớm · kỳ còn ${soDemMoi} đêm, hoàn ${tien(hoanLai)} về nguồn đã thanh toán`,
      textSitter: `${chuNuoi} đã chốt kết thúc sớm · kỳ còn ${soDemMoi} đêm, các đêm bị cắt trong 7 ngày tới vẫn tính nửa tiền cho bạn`,
      canGap: true,
    });
  }
}
