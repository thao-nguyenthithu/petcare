import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

// cả app dùng chung 1 PrismaService nói chuyện với DB
@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
