import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '../../generated/prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  constructor() {
    const adapter = new PrismaPg({
      connectionString: process.env.DATABASE_URL,
    });
    // DEBUG_PRISMA=1 để in từng câu query kèm thời gian, dùng khi soi hiệu năng
    super({
      adapter,
      log: process.env.DEBUG_PRISMA === '1' ? ['query'] : [],
    });
  }

  async onModuleInit() {
    await this.$connect();
  }
}
