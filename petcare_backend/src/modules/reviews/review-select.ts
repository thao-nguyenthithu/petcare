import { Prisma } from 'generated/prisma/client';

export const NGAY_DUOC_PHAN_HOI = 7;

export const CHON_DANH_GIA = {
  id: true,
  rating: true,
  comment: true,
  photos: true,
  praiseTags: true,
  reply: true,
  replyAt: true,
  createdAt: true,
  reviewer: { select: { fullName: true } },
  booking: {
    select: {
      id: true,
      sitterId: true,
      service: { select: { name: true, type: true } },
      pets: {
        select: {
          pet: { select: { name: true, species: true, avatarUrl: true } },
        },
      },
    },
  },
} satisfies Prisma.ReviewSelect;

export type DanhGiaDb = Prisma.ReviewGetPayload<{
  select: typeof CHON_DANH_GIA;
}>;
