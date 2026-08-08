import { ConflictException } from '@nestjs/common';
import { SystemSettingsService } from '../src/modules/admin/system-settings.service';
import { WalletLedgerService } from '../src/modules/wallet/wallet-ledger.service';
import { WithdrawalService } from '../src/modules/wallet/withdrawal.service';
import { PrismaService } from '../src/prisma/prisma.service';

type BanGhi = Record<string, any>;
type Nen = { nhan: string; hoanTac: Array<() => void> };

// Khoảng hở giữa đọc và ghi, đủ để hai lượt chen vào nhau như hai kết nối thật
const nhip = () => new Promise((tiep) => setTimeout(tiep, 0));

// Bộ giả theo lối READ COMMITTED: increment cộng vào giá trị hiện hành, đè tuyệt đối thì mất dòng
class DbGia {
  vi = new Map<string, BanGhi>();
  soSach: BanGhi[] = [];
  khoan = new Map<string, BanGhi>();
  don = new Map<string, BanGhi>();
  lenhRut: BanGhi[] = [];
  taiKhoan: BanGhi | null = null;
  soLuotTran = 0;
  noiDoiSoDu: string[] = [];
  noiGhiSoSach: string[] = [];

  themVi(sitterId: string, soDu: number) {
    this.vi.set(sitterId, { id: `vi-${sitterId}`, sitterId, balance: soDu });
  }

  soDu(sitterId: string): number {
    return (this.vi.get(sitterId)?.balance as number) ?? 0;
  }

  goc(): PrismaService {
    const c = this.client({ nhan: 'goc', hoanTac: [] }) as BanGhi;
    c.$transaction = (viec: (db: unknown) => Promise<unknown>) =>
      this.chayTran(viec);
    return c as unknown as PrismaService;
  }

  private async chayTran(viec: (db: unknown) => Promise<unknown>) {
    this.soLuotTran += 1;
    const nen: Nen = { nhan: 'tx', hoanTac: [] };
    try {
      return await viec(this.client(nen));
    } catch (loi) {
      for (const lui of nen.hoanTac.reverse()) lui();
      throw loi;
    }
  }

  private client(nen: Nen) {
    return {
      wallet: {
        upsert: (arg: BanGhi) => this.upsertVi(nen, arg),
        update: (arg: BanGhi) => this.deSoDu(nen, arg),
      },
      walletTransaction: { create: (arg: BanGhi) => this.themDongSo(nen, arg) },
      payment: {
        findFirst: (arg: BanGhi) => this.timKhoan(arg),
        updateMany: (arg: BanGhi) => this.doiKhoan(nen, arg),
      },
      booking: {
        findUnique: (arg: BanGhi) =>
          Promise.resolve(this.don.get(arg.where.id as string) ?? null),
      },
      withdrawal: {
        create: (arg: BanGhi) => this.themLenhRut(nen, arg),
        count: () => Promise.resolve(this.lenhRut.length),
      },
      sitter: {
        findUnique: () =>
          Promise.resolve({
            id: 'ncc-1',
            userId: 'u-1',
            hiddenUntil: null,
            hiddenCount: 0,
            bannedAt: null,
          }),
      },
      bankAccount: { findUnique: () => Promise.resolve(this.taiKhoan) },
    };
  }

  private async upsertVi(nen: Nen, arg: BanGhi) {
    const sitterId = arg.where.sitterId as string;
    await nhip();
    const hang = this.vi.get(sitterId);
    if (!hang) {
      const moi = {
        id: `vi-${sitterId}`,
        sitterId,
        balance: Number(arg.create.balance ?? 0),
      };
      this.vi.set(sitterId, moi);
      nen.hoanTac.push(() => this.vi.delete(sitterId));
      this.noiDoiSoDu.push(nen.nhan);
      return { ...moi };
    }
    const doi = arg.update?.balance;
    if (doi && typeof doi === 'object') {
      const buoc = Number(doi.increment);
      hang.balance += buoc;
      nen.hoanTac.push(() => {
        hang.balance -= buoc;
      });
      this.noiDoiSoDu.push(nen.nhan);
    }
    return { ...hang };
  }

  private async deSoDu(nen: Nen, arg: BanGhi) {
    await nhip();
    const hang = [...this.vi.values()].find((v) => v.id === arg.where.id);
    if (!hang) throw new Error('Không thấy ví');
    const cu = hang.balance as number;
    hang.balance = Number(arg.data.balance);
    nen.hoanTac.push(() => {
      hang.balance = cu;
    });
    this.noiDoiSoDu.push(nen.nhan);
    return { ...hang };
  }

  private async themDongSo(nen: Nen, arg: BanGhi) {
    await nhip();
    const dong: BanGhi = { id: `gd-${this.soSach.length + 1}`, ...arg.data };
    this.soSach.push(dong);
    nen.hoanTac.push(() => {
      this.soSach = this.soSach.filter((d) => d !== dong);
    });
    this.noiGhiSoSach.push(nen.nhan);
    return dong;
  }

  private async timKhoan(arg: BanGhi) {
    await nhip();
    const k = [...this.khoan.values()].find(
      (x) =>
        x.bookingId === arg.where.bookingId && x.status === arg.where.status,
    );
    return k ? { id: k.id, amount: k.amount } : null;
  }

  private async doiKhoan(nen: Nen, arg: BanGhi) {
    await nhip();
    const k = this.khoan.get(arg.where.id as string);
    if (!k || k.status !== arg.where.status) return { count: 0 };
    const cu = k.status as string;
    k.status = arg.data.status;
    nen.hoanTac.push(() => {
      k.status = cu;
    });
    return { count: 1 };
  }

  private async themLenhRut(nen: Nen, arg: BanGhi) {
    await nhip();
    const lenh: BanGhi = {
      id: `wd-${this.lenhRut.length + 1}`,
      status: 'PENDING',
      ...arg.data,
    };
    this.lenhRut.push(lenh);
    nen.hoanTac.push(() => {
      this.lenhRut = this.lenhRut.filter((l) => l !== lenh);
    });
    return lenh;
  }
}

function tienVao(tieuDe: string, soTien: number) {
  return { loai: 'TIEN_VAO' as const, tieuDe, soTien };
}

// Lối cũ đọc số dư rồi ghi đè, giữ lại để chứng minh bộ giả bắt được lỗi
async function ghiKieuCu(db: BanGhi, sitterId: string, soTien: number) {
  const vi = await db.wallet.upsert({
    where: { sitterId },
    create: { sitterId },
    update: {},
  });
  const soDuSau: number = (vi.balance as number) + soTien;
  await db.wallet.update({ where: { id: vi.id }, data: { balance: soDuSau } });
  return soDuSau;
}

describe('Hai lượt ghi sổ ví cùng lúc trên một ví', () => {
  it('cộng đủ cả hai dòng, không dòng nào biến mất khỏi số dư', async () => {
    const db = new DbGia();
    db.themVi('ncc-1', 0);
    const so = new WalletLedgerService(db.goc());

    await Promise.all([
      so.ghi('ncc-1', tienVao('Đơn A', 300000)),
      so.ghi('ncc-1', tienVao('Đơn B', 200000)),
    ]);

    expect(db.soDu('ncc-1')).toBe(500000);
    expect(db.soSach).toHaveLength(2);
    expect(
      db.soSach.map((d) => d.balanceAfter as number).sort((a, b) => a - b),
    ).toEqual([300000, 500000]);
  });

  it('số dư cuối luôn bằng balanceAfter của dòng sổ mới nhất', async () => {
    const db = new DbGia();
    db.themVi('ncc-1', 1000);
    const so = new WalletLedgerService(db.goc());

    await Promise.all([
      so.ghi('ncc-1', tienVao('Đơn A', 10)),
      so.ghi('ncc-1', tienVao('Đơn B', 20)),
      so.ghi('ncc-1', tienVao('Đơn C', 30)),
    ]);

    const moiNhat = Math.max(...db.soSach.map((d) => d.balanceAfter as number));
    expect(moiNhat).toBe(db.soDu('ncc-1'));
    expect(db.soDu('ncc-1')).toBe(1060);
  });

  it('đối chứng: chính bộ giả này làm lối đọc-rồi-ghi-đè mất một dòng tiền', async () => {
    const db = new DbGia();
    db.themVi('ncc-1', 0);
    const goc = db.goc() as unknown as BanGhi;

    await Promise.all([
      ghiKieuCu(goc, 'ncc-1', 300000),
      ghiKieuCu(goc, 'ncc-1', 200000),
    ]);

    expect(db.soDu('ncc-1')).not.toBe(500000);
  });
});

describe('balanceAfter của các dòng ghi liên tiếp', () => {
  it('bám đúng thứ tự phát sinh, kể cả dòng trừ tiền', async () => {
    const db = new DbGia();
    db.themVi('ncc-1', 0);
    const so = new WalletLedgerService(db.goc());

    await so.ghi('ncc-1', tienVao('Đơn A', 300000));
    await so.ghi('ncc-1', tienVao('Đơn B', 200000));
    await so.ghi('ncc-1', {
      loai: 'RUT_RA',
      tieuDe: 'Rút về VCB',
      soTien: -100000,
    });

    expect(db.soSach.map((d) => d.balanceAfter as number)).toEqual([
      300000, 500000, 400000,
    ]);
    expect(db.soDu('ncc-1')).toBe(400000);
  });
});

describe('Số dư ví không bao giờ âm', () => {
  it('trừ quá số dư thì chặn bằng VUOT_SO_DU và không để lại dòng sổ nào', async () => {
    const db = new DbGia();
    db.themVi('ncc-1', 50000);
    const so = new WalletLedgerService(db.goc());

    await expect(
      so.ghi('ncc-1', {
        loai: 'RUT_RA',
        tieuDe: 'Rút về VCB',
        soTien: -80000,
      }),
    ).rejects.toMatchObject({ response: { code: 'VUOT_SO_DU' } });
    expect(db.soDu('ncc-1')).toBe(50000);
    expect(db.soSach).toHaveLength(0);
  });

  it('ví chưa tồn tại mà đã trừ tiền thì cũng chặn, không tạo ví âm', async () => {
    const db = new DbGia();
    const so = new WalletLedgerService(db.goc());

    await expect(
      so.ghi('ncc-2', { loai: 'RUT_RA', tieuDe: 'Rút về VCB', soTien: -1000 }),
    ).rejects.toBeInstanceOf(ConflictException);
    expect(db.vi.has('ncc-2')).toBe(false);
  });
});

describe('Mọi lối ghi sổ đều nằm trong một transaction', () => {
  it('gọi bằng client gốc thì tự mở transaction cho cả số dư lẫn dòng sổ', async () => {
    const db = new DbGia();
    db.themVi('ncc-1', 0);
    const so = new WalletLedgerService(db.goc());

    await so.ghi('ncc-1', tienVao('Đơn A', 300000));

    expect(db.soLuotTran).toBe(1);
    expect(db.noiDoiSoDu).toEqual(['tx']);
    expect(db.noiGhiSoSach).toEqual(['tx']);
  });

  it('nhả escrow: đổi trạng thái khoản giữ và cộng ví trong cùng một lượt', async () => {
    const db = dungDonGiuTien();
    const so = new WalletLedgerService(db.goc());

    await expect(so.nhaEscrow('bk-1')).resolves.toBe(true);

    expect(db.soLuotTran).toBe(1);
    expect(db.noiGhiSoSach).toEqual(['tx']);
    expect(db.khoan.get('pm-1')?.status).toBe('RELEASED');
    expect(db.soDu('ncc-1')).toBe(255000);
  });

  it('hai lượt quét cùng lúc chỉ nhả tiền một lần', async () => {
    const db = dungDonGiuTien();
    const so = new WalletLedgerService(db.goc());

    const ket = await Promise.all([so.nhaEscrow('bk-1'), so.nhaEscrow('bk-1')]);

    expect(ket.filter(Boolean)).toHaveLength(1);
    expect(db.soDu('ncc-1')).toBe(255000);
    expect(db.soSach).toHaveLength(1);
  });
});

function dungDonGiuTien() {
  const db = new DbGia();
  db.themVi('ncc-1', 0);
  db.don.set('bk-1', {
    id: 'bk-1',
    code: 'PC001',
    sitterId: 'ncc-1',
    sitterPayout: 255000,
    totalPrice: 300000,
    platformFee: 45000,
    owner: { fullName: 'Chị Lan' },
    reports: [],
  });
  db.khoan.set('pm-1', {
    id: 'pm-1',
    bookingId: 'bk-1',
    status: 'HELD',
    amount: 300000,
  });
  return db;
}

function dungRutTien(soDu: number) {
  const db = new DbGia();
  db.themVi('ncc-1', soDu);
  db.taiKhoan = {
    bankName: 'Vietcombank',
    accountNumber: '0123456789',
    accountHolder: 'NGUYEN VAN A',
    verified: true,
  };
  const goc = db.goc();
  const thamSo = {
    so: (khoa: string) => (khoa === 'withdraw.min' ? 50000 : 2),
  } as unknown as SystemSettingsService;
  const dv = new WithdrawalService(goc, new WalletLedgerService(goc), thamSo);
  return { db, dv };
}

describe('Lệnh rút trừ số dư ngay trong transaction', () => {
  it('một lệnh hợp lệ trừ đúng số dư và trả về số dư còn lại thật', async () => {
    const { db, dv } = dungRutTien(300000);

    const ket = await dv.rut('u-1', { amount: 100000 });

    expect(db.soLuotTran).toBe(1);
    expect(db.soDu('ncc-1')).toBe(200000);
    expect(ket.soDuConLai).toBe(200000);
    expect(db.noiDoiSoDu).toEqual(['tx']);
  });

  it('hai lệnh rút cùng lúc vượt số dư thì chỉ một lệnh đi qua', async () => {
    const { db, dv } = dungRutTien(120000);

    const ket = await Promise.allSettled([
      dv.rut('u-1', { amount: 100000 }),
      dv.rut('u-1', { amount: 100000 }),
    ]);

    expect(ket.filter((k) => k.status === 'fulfilled')).toHaveLength(1);
    const hong = ket.find((k) => k.status === 'rejected');
    expect((hong as PromiseRejectedResult).reason).toMatchObject({
      response: { code: 'VUOT_SO_DU' },
    });
    expect(db.soDu('ncc-1')).toBe(20000);
    expect(db.lenhRut).toHaveLength(1);
    expect(db.soSach).toHaveLength(1);
  });
});
