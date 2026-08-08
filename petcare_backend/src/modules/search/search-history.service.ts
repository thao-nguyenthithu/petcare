import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class SearchHistoryService {
  constructor(private readonly prisma: PrismaService) {}

  private static readonly TOI_DA = 8;

  async danhSach(userId: string) {
    const ds = await this.prisma.searchHistory.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: SearchHistoryService.TOI_DA,
      select: { keyword: true },
    });
    return { items: ds.map((e) => e.keyword) };
  }

  async them(userId: string, keyword: string) {
    await this.prisma.searchHistory.upsert({
      where: { userId_keyword: { userId, keyword } },
      create: { userId, keyword },
      update: { createdAt: new Date() },
    });
    await this.donBotCu(userId);
    return this.danhSach(userId);
  }

  async xoaHet(userId: string) {
    await this.prisma.searchHistory.deleteMany({ where: { userId } });
    return { items: [] as string[] };
  }

  private async donBotCu(userId: string) {
    const giuLai = await this.prisma.searchHistory.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: SearchHistoryService.TOI_DA,
      select: { id: true },
    });
    await this.prisma.searchHistory.deleteMany({
      where: { userId, id: { notIn: giuLai.map((e) => e.id) } },
    });
  }
}
