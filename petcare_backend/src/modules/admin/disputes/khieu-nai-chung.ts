import { Prisma } from '../../../../generated/prisma/client';
import { ReportStatus } from '../../../../generated/prisma/enums';
import { TabKhieuNai } from './dto/loc-khieu-nai.dto';

// Cửa sổ đọc lịch sử vi phạm của một người chăm ở màn hồ sơ, chỉ để hiển thị
export const THANG_DEM_VI_PHAM = 6;

// replyDeadline trống là hồ sơ không có lượt đáp, KHÔNG phải quá hạn (bộ luật mục 7)
export function dieuKienTab(
  tab: TabKhieuNai,
  bayGio: Date,
): Prisma.ViolationReportWhereInput {
  switch (tab) {
    case 'waitingSitter':
      return {
        status: ReportStatus.OPEN,
        replyDeadline: { gt: bayGio },
      };
    case 'waitingSupport':
      return {
        OR: [
          { status: ReportStatus.REVIEWING },
          { status: ReportStatus.OPEN, replyDeadline: null },
          { status: ReportStatus.OPEN, replyDeadline: { lte: bayGio } },
        ],
      };
    default:
      return { status: ReportStatus.RESOLVED };
  }
}
