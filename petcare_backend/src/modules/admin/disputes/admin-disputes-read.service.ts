import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { dungTrang, KetQuaTrang, kepTrang } from '../chung/phan-trang';
import { LocKhieuNaiDto } from './dto/loc-khieu-nai.dto';
import { dieuKienTab } from './khieu-nai-chung';

@Injectable()
export class AdminDisputesReadService {
  constructor(private readonly prisma: PrismaService) {}

  private dieuKien(
    loc: LocKhieuNaiDto,
    bayGio: Date,
  ): Prisma.ViolationReportWhereInput {
    const dieu: Prisma.ViolationReportWhereInput = {
      ...(loc.tab ? dieuKienTab(loc.tab, bayGio) : {}),
    };
    if (loc.status) dieu.status = loc.status;
    if (loc.serviceType) dieu.booking = { service: { type: loc.serviceType } };
    if (loc.from || loc.to) {
      dieu.createdAt = {
        ...(loc.from ? { gte: new Date(loc.from) } : {}),
        ...(loc.to ? { lte: new Date(loc.to) } : {}),
      };
    }
    if (loc.q) {
      const tim = { contains: loc.q, mode: Prisma.QueryMode.insensitive };
      // Gộp vào AND để không đè mất nhánh OR của tab
      dieu.AND = [
        {
          OR: [
            { code: tim },
            { booking: { code: tim } },
            { reporter: { fullName: tim } },
            { booking: { sitter: { legalName: tim } } },
            { booking: { sitter: { user: { fullName: tim } } } },
          ],
        },
      ];
    }
    return dieu;
  }

  // Hạn đếm từ lúc mở nên trong nhóm chưa kết luận, mở sớm nhất là gấp nhất
  private thuTu(
    loc: LocKhieuNaiDto,
  ): Prisma.ViolationReportOrderByWithRelationInput[] {
    if (loc.sort === 'moiNhat') return [{ createdAt: 'desc' }];
    const chieu = loc.tab === 'resolved' ? 'desc' : 'asc';
    return [
      { resolvedAt: { sort: 'asc', nulls: 'first' } },
      { createdAt: chieu },
    ];
  }

  async danhSach(loc: LocKhieuNaiDto): Promise<KetQuaTrang<unknown>> {
    const bayGio = new Date();
    const khoang = kepTrang(loc.page, loc.limit);
    const where = this.dieuKien(loc, bayGio);

    const [total, ds] = await Promise.all([
      this.prisma.violationReport.count({ where }),
      this.prisma.violationReport.findMany({
        where,
        orderBy: this.thuTu(loc),
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          code: true,
          description: true,
          status: true,
          replyDeadline: true,
          sitterReplyAt: true,
          refundAmount: true,
          createdAt: true,
          reporterId: true,
          reporter: { select: { fullName: true, avatarUrl: true } },
          booking: {
            select: {
              code: true,
              ownerId: true,
              service: { select: { name: true, type: true } },
              sitter: {
                select: {
                  user: { select: { fullName: true } },
                },
              },
            },
          },
        },
      }),
    ]);

    const items = ds.map((hs) => ({
      code: hs.code,
      bookingCode: hs.booking.code,
      serviceType: hs.booking.service.type,
      serviceName: hs.booking.service.name,
      reporterName: hs.reporter.fullName,
      // Vai suy từ chính đơn, không đọc User.role vì một người vừa là chủ nuôi vừa nhận đơn
      reporterRole: hs.reporterId === hs.booking.ownerId ? 'OWNER' : 'PROVIDER',
      reporterAvatarUrl: hs.reporter.avatarUrl,
      sitterName: hs.booking.sitter.user.fullName,
      description: hs.description,
      createdAt: hs.createdAt,
      replyDeadline: hs.replyDeadline,
      sitterReplyAt: hs.sitterReplyAt,
      status: hs.status,
      refundAmount: hs.refundAmount,
    }));
    return dungTrang(items, total, khoang);
  }

  async demTab() {
    const bayGio = new Date();
    const dem = (tab: Parameters<typeof dieuKienTab>[0]) =>
      this.prisma.violationReport.count({ where: dieuKienTab(tab, bayGio) });
    const [waitingSitter, waitingSupport, resolved] = await Promise.all([
      dem('waitingSitter'),
      dem('waitingSupport'),
      dem('resolved'),
    ]);
    return { waitingSitter, waitingSupport, resolved };
  }
}
