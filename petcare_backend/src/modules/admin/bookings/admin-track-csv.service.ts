import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { MA_DON_HOP_LE, TRAN_DIEM_TRA_SOAT } from './tra-soat-gps';

// Khai bằng mã ký tự chứ không dán BOM thật vào nguồn, dán thì nhìn là dấu nháy rỗng
const BOM = String.fromCharCode(0xfeff);

// Không dấu vì Excel vẫn có máy đọc sai bảng mã dù đã có BOM
const CAU_DA_CAT = `"DA CAT O ${TRAN_DIEM_TRA_SOAT} DIEM DAU, DON NAY CON DIEM CHUA TAI VE"`;

const COT = [
  'thu_tu',
  'lat',
  'lng',
  'gio_may_gui',
  'gio_may_chu_nhan',
  'lech_ms',
  'lo_gui',
  'la_nhieu',
  'vi_tri_gia',
];

@Injectable()
export class AdminTrackCsvService {
  constructor(private readonly prisma: PrismaService) {}

  async csvLoTrinh(code: string) {
    if (!MA_DON_HOP_LE.test(code)) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn này',
      });
    }

    // Hỏi đơn song song để mã sai trả 404 chứ không trả tệp rỗng
    const [don, diem] = await Promise.all([
      this.prisma.booking.findUnique({
        where: { code },
        select: { id: true },
      }),
      this.prisma.locationTrack.findMany({
        where: { booking: { code } },
        orderBy: { clientTs: 'asc' },
        // Lấy dư một điểm để biết tệp có bị cắt hay không mà nói ra
        take: TRAN_DIEM_TRA_SOAT + 1,
        select: {
          latitude: true,
          longitude: true,
          clientTs: true,
          serverTs: true,
          driftMs: true,
          batchSeq: true,
          isNoise: true,
          isMocked: true,
        },
      }),
    ]);
    if (!don) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn này',
      });
    }

    const daCat = diem.length > TRAN_DIEM_TRA_SOAT;
    // Giữ cả điểm nhiễu và cờ vị trí giả, lọc sẵn là vứt đúng phần bằng chứng
    const dong = diem
      .slice(0, TRAN_DIEM_TRA_SOAT)
      .map((d, i) =>
        [
          i + 1,
          d.latitude,
          d.longitude,
          d.clientTs.toISOString(),
          d.serverTs.toISOString(),
          d.driftMs ?? '',
          d.batchSeq ?? '',
          d.isNoise ? 1 : 0,
          d.isMocked ? 1 : 0,
        ].join(','),
      );
    // Tệp rời khỏi hệ thống nên phải tự nói là đã cắt, người mở sau không hỏi được ai
    if (daCat) dong.push(`${CAU_DA_CAT},,,,,,,,`);
    // BOM để Excel đọc đúng tiêu đề tiếng Việt
    const noiDung = BOM + [COT.join(','), ...dong].join('\r\n');
    return { ten: `lo-trinh-${code}.csv`, noiDung, daCat };
  }
}
