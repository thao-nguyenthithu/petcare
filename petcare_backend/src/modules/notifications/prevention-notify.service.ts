import { Injectable } from '@nestjs/common';
import { NotificationsService } from './notifications.service';

@Injectable()
export class PreventionNotifyService {
  constructor(private readonly notifications: NotificationsService) {}

  async toiHan(
    ownerId: string,
    tenBe: string,
    tenHangMuc: string,
    conMayNgay: number,
  ) {
    await this.notifications.tao({
      userId: ownerId,
      type: 'PHONG_BENH',
      role: 'CHU_NUOI',
      titleKey: 'tbPhongBenhToiHanTieuDe',
      bodyKey:
        conMayNgay <= 1
          ? 'tbPhongBenhNhacCuoiNoiDung'
          : 'tbPhongBenhToiHanNoiDung',
      params: { tenHangMuc, tenBe, conMayNgay },
      urgent: conMayNgay <= 1,
    });
  }
}
