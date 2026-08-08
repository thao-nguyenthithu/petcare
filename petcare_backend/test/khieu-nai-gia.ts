import { NhatKyQuanTriService } from '../src/modules/admin/chung/nhat-ky-quan-tri.service';
import { AdminDisputeResolveService } from '../src/modules/admin/disputes/admin-dispute-resolve.service';
import { SitterPenaltyService } from '../src/modules/bookings/sitter-penalty.service';
import { NotificationsService } from '../src/modules/notifications/notifications.service';
import { WalletLedgerService } from '../src/modules/wallet/wallet-ledger.service';
import { PrismaService } from '../src/prisma/prisma.service';

export type HoSoGia = {
  status: string;
  totalPrice: number;
  platformFeePercent?: number | null;
  // Để null là đơn không còn khoản HELD nào, ví dụ escrow đã nhả trước đó
  khoanGiu?: { id: string } | null;
} | null;

export type ChonGia = {
  // Số dòng violationReport đổi được, 0 là có người chốt xen vào trước
  soDongDoi?: number;
  // Số dòng Payment đổi được, 0 là khoản giữ vừa bị lượt khác lấy mất
  soDongKhoan?: number;
};

export function dungKetLuan(hoSo: HoSoGia, chon: ChonGia = {}) {
  const soDongDoi = chon.soDongDoi ?? 1;
  const soDongKhoan = chon.soDongKhoan ?? 1;
  const nhatKy: Array<Record<string, unknown>> = [];
  const daCapNhat: Array<Record<string, unknown>> = [];
  const dieuKienGhi: Array<Record<string, unknown>> = [];
  const daBao: Array<Record<string, unknown>> = [];
  const goiPhat: Array<{ ten: string; doiSo: unknown[] }> = [];
  const khoanDoi: Array<Record<string, unknown>> = [];
  const luotDocKhoan: number[] = [];
  const donDoi: Array<Record<string, unknown>> = [];
  const dongVi: Array<Record<string, unknown>> = [];
  let soDu = 0;

  const khoanGiu =
    hoSo?.khoanGiu === undefined ? { id: 'pay-1' } : hoSo.khoanGiu;

  const tx = {
    violationReport: {
      findUnique: () =>
        Promise.resolve(
          hoSo && {
            id: 'hs-1',
            code: 'KN-PC001',
            status: hoSo.status,
            booking: {
              id: 'don-1',
              code: 'PC001',
              ownerId: 'user-owner',
              totalPrice: hoSo.totalPrice,
              platformFeePercent: hoSo.platformFeePercent ?? null,
              sitterId: 'ncc-1',
              sitter: { userId: 'user-ncc' },
            },
          },
        ),
      updateMany: (arg: {
        where: Record<string, unknown>;
        data: Record<string, unknown>;
      }) => {
        dieuKienGhi.push(arg.where);
        if (soDongDoi === 0) return Promise.resolve({ count: 0 });
        daCapNhat.push(arg.data);
        return Promise.resolve({ count: soDongDoi });
      },
      // Lối KHÔNG kẹp trạng thái cũ, để gỡ bản vá ra là test đỏ vì phạt hai lần
      update: (arg: { data: Record<string, unknown> }) => {
        daCapNhat.push(arg.data);
        return Promise.resolve({ code: 'KN-PC001', status: 'RESOLVED' });
      },
    },
    payment: {
      findFirst: () => {
        luotDocKhoan.push(1);
        return Promise.resolve(khoanGiu);
      },
      updateMany: (arg: {
        where: Record<string, unknown>;
        data: Record<string, unknown>;
      }) => {
        khoanDoi.push(arg);
        return Promise.resolve({ count: soDongKhoan });
      },
    },
    booking: {
      update: (arg: { data: Record<string, unknown> }) => {
        donDoi.push(arg.data);
        return Promise.resolve({ id: 'don-1' });
      },
    },
    wallet: {
      upsert: (arg: { update: { balance: { increment: number } } }) => {
        soDu += arg.update.balance.increment;
        return Promise.resolve({ id: 'vi-1', balance: soDu });
      },
    },
    walletTransaction: {
      create: (arg: { data: Record<string, unknown> }) => {
        dongVi.push(arg.data);
        return Promise.resolve(arg.data);
      },
    },
    adminAuditLog: {
      create: (arg: { data: Record<string, unknown> }) => {
        nhatKy.push(arg.data);
        return Promise.resolve({ id: 'log-1' });
      },
    },
  };

  // Client trong transaction KHÔNG có $transaction, y như Prisma thật
  const prisma = {
    ...tx,
    $transaction: (lenh: unknown) =>
      typeof lenh === 'function'
        ? (lenh as (db: unknown) => Promise<unknown>)(tx)
        : Promise.resolve(lenh),
  };

  const phat = {
    ghiPhat: (...doiSo: unknown[]) => {
      goiPhat.push({ ten: 'ghiPhat', doiSo });
      return Promise.resolve({ tamAn: false, khoa: false });
    },
    tamAn: (...doiSo: unknown[]) => {
      goiPhat.push({ ten: 'tamAn', doiSo });
      return Promise.resolve({ soNgay: 3, khoa: false });
    },
  };
  const thongBao = {
    tao: (ban: Record<string, unknown>) => {
      daBao.push(ban);
      return Promise.resolve({ id: 'tb-1' });
    },
  };

  const service = new AdminDisputeResolveService(
    prisma as unknown as PrismaService,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
    phat as unknown as SitterPenaltyService,
    thongBao as unknown as NotificationsService,
    new WalletLedgerService(prisma as unknown as PrismaService),
  );
  return {
    service,
    nhatKy,
    daCapNhat,
    dieuKienGhi,
    daBao,
    goiPhat,
    khoanDoi,
    luotDocKhoan,
    donDoi,
    dongVi,
  };
}
