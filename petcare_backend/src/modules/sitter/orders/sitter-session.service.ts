import {
  BadRequestException,
  ConflictException,
  Injectable,
} from '@nestjs/common';
import { BookingStatus } from 'generated/prisma/enums';
import { MOT_PHUT_MS } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import { SystemSettingsService } from '../../admin/system-settings.service';
import {
  START_WINDOW_MINUTES,
  mocNhaTien,
} from '../../bookings/booking-compensation';
import { kiemTraChuyen } from '../../bookings/booking-state';
import { GpsService } from '../../gps/gps.service';
import { type UploadedImage } from '../../media/image-upload';
import { BookingChatService } from '../../messaging/booking-chat.service';
import { BookingNotifyService } from '../../notifications/booking-notify.service';
import { SitterScoreService } from '../../search/sitter-score.service';
import { DisputeService } from '../../wallet/dispute.service';
import {
  DailyUpdateDto,
  FinishDto,
  HandoverDto,
  IncidentDto,
  LY_DO_SU_CO_CAN_MO_TA,
} from './dto/sitter-order.dto';
import { PetSafetyScanReadService } from './pet-safety-scan-read.service';
import {
  chiDichVu,
  loaiDichVu,
  phaiCoAnhGiuaPhien,
  phaiCoAnhHaiDauPhien,
  phaiDangO,
  phaiHopLeAnhDoDung,
  phaiHopLeAnhSuCo,
  SitterOrderStore,
} from './sitter-order-store.service';
import { moMoiCuaThoiGian } from '../../../common/che-do-demo';

@Injectable()
export class SitterSessionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly store: SitterOrderStore,
    private readonly gps: GpsService,
    private readonly notify: BookingNotifyService,
    private readonly chat: BookingChatService,
    private readonly diem: SitterScoreService,
    private readonly thamSo: SystemSettingsService,
    private readonly scan: PetSafetyScanReadService,
    private readonly khieuNai: DisputeService,
  ) {}

  async batDauPhien(
    userId: string,
    id: string,
    files: UploadedImage[],
    dto: HandoverDto,
    anhDoDung: UploadedImage[] = [],
  ) {
    const { don } = await this.store.timDon(userId, id);
    kiemTraChuyen(don.status, 'IN_PROGRESS');
    const loai = loaiDichVu(don);
    const moLuc =
      don.scheduledAt.getTime() - START_WINDOW_MINUTES * MOT_PHUT_MS;
    if (!moMoiCuaThoiGian() && Date.now() < moLuc) {
      throw new ConflictException({
        code: 'CHUA_TOI_GIO_BAT_DAU',
        message: `Nút bắt đầu mở trước giờ hẹn ${START_WINDOW_MINUTES} phút`,
      });
    }
    if (loai === 'boarding') {
      if (!don.ownerArrivedAt) {
        await this.prisma.booking.update({
          where: { id: don.id },
          data: { ownerArrivedAt: new Date() },
        });
      }
    } else if (!don.arrivedAt) {
      throw new ConflictException({
        code: 'CHUA_TOI_DIEM_DON',
        message: 'Cần báo đã tới điểm đón trước khi nhận bé',
      });
    }
    phaiHopLeAnhDoDung(anhDoDung, loai);
    let urls: string[];
    if (loai === 'walking') {
      await this.scan.chanCheckIn(don);
      urls = await this.scan.luuAnhBangChung(don.id, don._count.pets);
    } else {
      phaiCoAnhHaiDauPhien(files, don._count.pets, loai);
      urls = await this.store.taiAnh(don.id, files, 'CHECK_IN');
    }
    const urlDoDung = await this.store.taiAnh(
      don.id,
      anhDoDung,
      'CHECK_IN',
      true,
    );
    const luc = new Date();
    await this.prisma.booking.update({
      where: { id: don.id },
      data: {
        status: 'IN_PROGRESS',
        startedAt: luc,
        handoverNote: dto.note ?? null,
      },
    });
    await this.notify.daBatDau(don.id);
    await this.chat.daBatDau(don.id, loai === 'walking', luc);
    const ky = await this.store.kyAnh([...urls, ...urlDoDung]);
    return {
      id: don.id,
      status: 'inProgress',
      startedAt: luc,
      photos: urls.map((u) => ky.get(u) ?? u),
      // Tách khỏi mảng ảnh các bé để màn album dựng được hai khối riêng
      itemPhotos: urlDoDung.map((u) => ky.get(u) ?? u),
    };
  }

  async baoSuCo(
    userId: string,
    id: string,
    files: UploadedImage[],
    dto: IncidentDto,
  ) {
    phaiHopLeAnhSuCo(files);
    if (dto.reason === LY_DO_SU_CO_CAN_MO_TA && !dto.description) {
      throw new BadRequestException({
        code: 'THIEU_MO_TA_SU_CO',
        message: 'Chọn lý do khác thì cần mô tả thêm',
      });
    }
    const { don } = await this.store.timDon(userId, id);
    const anh = await this.store.dayAnhLenStorage(don.id, files);
    return this.khieuNai.moBoiNguoiCham(
      userId,
      don.id,
      dto.description ?? '',
      anh,
      dto.reason,
    );
  }

  async capNhatNgay(
    userId: string,
    id: string,
    files: UploadedImage[],
    dto: DailyUpdateDto,
  ) {
    const { don } = await this.store.timDon(userId, id);
    phaiDangO(don, ['IN_PROGRESS']);
    chiDichVu(don, 'boarding');
    phaiCoAnhGiuaPhien(files);
    const urls = await this.store.taiAnh(don.id, files, 'IN_PROGRESS');
    const ban = await this.prisma.boardingUpdate.create({
      data: {
        bookingId: don.id,
        message: dto.message ?? null,
        conditions: dto.conditions ?? [],
        photoUrls: urls,
      },
      select: { id: true, createdAt: true },
    });
    await this.notify.anhMoi(don.id);
    await this.chat.anhMoi(don.id, urls, dto.message ?? null, urls.length);
    return {
      id: ban.id,
      createdAt: ban.createdAt,
      photos: await this.store.kyAnhMang(urls),
    };
  }

  // Ảnh gửi giữa phiên của dắt và grooming
  async guiAnhPhien(userId: string, id: string, files: UploadedImage[]) {
    const { don } = await this.store.timDon(userId, id);
    phaiDangO(don, ['IN_PROGRESS']);
    phaiCoAnhGiuaPhien(files);
    const urls = await this.store.taiAnh(don.id, files, 'IN_PROGRESS');
    await this.notify.anhMoi(don.id);
    const tongAnh = await this.prisma.sessionPhoto.count({
      where: { bookingId: don.id },
    });
    await this.chat.anhMoi(don.id, urls, null, tongAnh);
    return { id: don.id, photos: await this.store.kyAnhMang(urls) };
  }

  async ketThuc(
    userId: string,
    id: string,
    files: UploadedImage[],
    dto: FinishDto,
    anhDoDung: UploadedImage[] = [],
  ) {
    const { don } = await this.store.timDon(userId, id);
    phaiDangO(don, ['IN_PROGRESS']);
    const loai = loaiDichVu(don);
    phaiHopLeAnhDoDung(anhDoDung, loai);
    const den: BookingStatus =
      loai === 'boarding' ? 'COMPLETED' : 'AWAITING_OWNER_CONFIRM';
    kiemTraChuyen(don.status, den);
    phaiCoAnhHaiDauPhien(files, don._count.pets, loai);
    const urls = await this.store.taiAnh(don.id, files, 'CHECK_OUT');
    const urlDoDung = await this.store.taiAnh(
      don.id,
      anhDoDung,
      'CHECK_OUT',
      true,
    );
    const luc = new Date();
    const gioGiuTien = this.thamSo.so('escrow.hours');
    await this.prisma.booking.update({
      where: { id: don.id },
      data: {
        status: den,
        endedAt: luc,
        escrowReleaseAt: mocNhaTien(luc, gioGiuTien),
        completedAt: den === 'COMPLETED' ? luc : null,
        sitterNote: dto.note ?? null,
        distanceKm: dto.distanceKm ?? null,
      },
    });
    if (den === 'COMPLETED' && don.sitterId) {
      await this.diem.tinhLai(don.sitterId);
    }
    if (loai === 'walking') await this.gps.chotBaoCao(don.id);
    if (den === 'AWAITING_OWNER_CONFIRM') {
      await this.notify.choXacNhan(don.id, gioGiuTien);
      await this.chat.choXacNhan(don.id, gioGiuTien, luc);
    }
    const ky = await this.store.kyAnh([...urls, ...urlDoDung]);
    return {
      id: don.id,
      status: den === 'COMPLETED' ? 'completed' : 'awaitingOwnerConfirm',
      endedAt: luc,
      photos: urls.map((u) => ky.get(u) ?? u),
      itemPhotos: urlDoDung.map((u) => ky.get(u) ?? u),
    };
  }
}
