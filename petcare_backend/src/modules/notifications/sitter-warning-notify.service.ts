import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { SystemSettingsService } from '../admin/system-settings.service';
import { NotificationsService } from './notifications.service';

// Thông báo chứ không phải hình phạt
@Injectable()
export class SitterWarningNotifyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  private async userCua(sitterId: string) {
    const ncc = await this.prisma.sitter.findUnique({
      where: { id: sitterId },
      select: { userId: true },
    });
    return ncc?.userId ?? null;
  }

  async sapBiAn(sitterId: string, soCanhCao: number) {
    const userId = await this.userCua(sitterId);
    if (!userId) return;
    const conLai = this.thamSo.so('penalty.warnings_to_hide') - soCanhCao;
    await this.notifications.tao({
      userId,
      type: 'HO_SO',
      role: 'NGUOI_CHAM',
      titleKey: 'tbHoSoSapBiAnTieuDe',
      bodyKey: 'tbHoSoSapBiAnNoiDung',
      params: { soCanhCao, conLai },
      urgent: true,
    });
  }

  async daBiAn(sitterId: string, soNgay: number, khoa: boolean) {
    const userId = await this.userCua(sitterId);
    if (!userId) return;
    await this.notifications.tao({
      userId,
      type: 'HO_SO',
      role: 'NGUOI_CHAM',
      titleKey: khoa ? 'tbHoSoBiKhoaTieuDe' : 'tbHoSoTamAnTieuDe',
      bodyKey: khoa ? 'tbHoSoBiKhoaNoiDung' : 'tbHoSoTamAnNoiDung',
      params: { soNgay },
      urgent: true,
    });
  }
}
