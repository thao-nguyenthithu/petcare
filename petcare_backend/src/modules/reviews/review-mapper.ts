import { MOT_NGAY_MS, ngayThangVn } from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { LOAI_RA_APP } from '../bookings/booking-enums';
import { DanhGiaDb, NGAY_DUOC_PHAN_HOI } from './review-select';

// Tách khỏi service vì hai việc này thuần đọc, không thuộc luồng viết đánh giá

export function raApp(d: DanhGiaDb, kyAnh?: ReadonlyMap<string, string>) {
  const conPhanHoi = Math.max(
    0,
    NGAY_DUOC_PHAN_HOI -
      Math.floor((Date.now() - d.createdAt.getTime()) / MOT_NGAY_MS),
  );
  return {
    id: d.id,
    bookingId: d.booking.id,
    ownerName: d.reviewer.fullName,
    rating: d.rating,
    serviceName: d.booking.service.name,
    serviceType: LOAI_RA_APP[d.booking.service.type],
    createdAtLabel: ngayThangVn(d.createdAt),
    comment: d.comment ?? '',
    photos: d.photos.map((p) => kyAnh?.get(p) ?? p),
    // Mã chip, app tự dịch sang chữ hiển thị
    praiseTags: d.praiseTags,
    pets: d.booking.pets.map((p) => ({
      name: p.pet.name,
      species: p.pet.species.toLowerCase(),
      avatarUrl: p.pet.avatarUrl,
    })),
    reply: d.reply
      ? {
          content: d.reply,
          createdAtLabel: d.replyAt ? ngayThangVn(d.replyAt) : '',
        }
      : null,
    daysLeftToReply: d.reply ? 0 : conPhanHoi,
  };
}

// Tính trên cả bảng chứ không trên trang đang tải, để bộ đếm nói về tất cả
export async function thongKe(prisma: PrismaService, sitterId: string) {
  const rows = await prisma.review.findMany({
    where: { booking: { sitterId } },
    select: {
      rating: true,
      photos: true,
      booking: { select: { service: { select: { type: true } } } },
    },
  });
  const byRating: Record<string, number> = {
    '1': 0,
    '2': 0,
    '3': 0,
    '4': 0,
    '5': 0,
  };
  const byService: Record<string, number> = {
    walking: 0,
    boarding: 0,
    grooming: 0,
  };
  let tongDiem = 0;
  let coAnh = 0;
  for (const r of rows) {
    byRating[String(r.rating)] = (byRating[String(r.rating)] ?? 0) + 1;
    const loai = LOAI_RA_APP[r.booking.service.type];
    byService[loai] = (byService[loai] ?? 0) + 1;
    tongDiem += r.rating;
    if (r.photos.length > 0) coAnh++;
  }
  return {
    ratingAvg: rows.length === 0 ? 0 : tongDiem / rows.length,
    total: rows.length,
    byRating,
    byService,
    withPhotos: coAnh,
  };
}
