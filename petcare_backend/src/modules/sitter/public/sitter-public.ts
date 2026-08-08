import { Prisma } from '../../../../generated/prisma/client';

export function dieuKienNccCongKhai(
  bayGio: Date = new Date(),
): Prisma.SitterWhereInput {
  return {
    status: 'APPROVED',
    AND: [
      { user: { isActive: true } },
      { bannedAt: null },
      { OR: [{ hiddenUntil: null }, { hiddenUntil: { lte: bayGio } }] },
    ],
  };
}

export function dangBiTamAn(
  hiddenUntil: Date | null,
  bayGio: Date = new Date(),
): boolean {
  return hiddenUntil !== null && hiddenUntil > bayGio;
}

export const TRUONG_USER_CONG_KHAI = {
  id: true,
  fullName: true,
  avatarUrl: true,
} as const;
