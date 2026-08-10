import type { BookingStatus, MessageKind } from 'generated/prisma/enums';

export type VaiChat = 'OWNER' | 'PROVIDER';

export type TrangThaiChat =
  | 'sapToi'
  | 'dangDienRa'
  | 'choXacNhan'
  | 'daKetThuc';

export function trangThaiChat(status: BookingStatus): TrangThaiChat {
  switch (status) {
    case 'IN_PROGRESS':
      return 'dangDienRa';
    case 'AWAITING_OWNER_CONFIRM':
      return 'choXacNhan';
    case 'PENDING':
    case 'CONFIRMED':
      return 'sapToi';
    default:
      return 'daKetThuc';
  }
}

export function chatDaKhoa(status: BookingStatus): boolean {
  return trangThaiChat(status) === 'daKetThuc';
}

type DonRutGon = {
  status: BookingStatus;
  scheduledAt: Date;
  scheduledEndAt: Date | null;
  startedAt: Date | null;
  endedAt: Date | null;
  escrowReleaseAt: Date | null;
  durationMinutes: number | null;
};

export function phutConLai(don: DonRutGon, bayGio = new Date()): number | null {
  const trangThai = trangThaiChat(don.status);
  const moc = (() => {
    if (trangThai === 'sapToi') return don.scheduledAt;
    if (trangThai === 'dangDienRa') {
      if (don.scheduledEndAt) return don.scheduledEndAt;
      if (don.startedAt && don.durationMinutes) {
        return new Date(don.startedAt.getTime() + don.durationMinutes * 60_000);
      }
      return null;
    }
    if (trangThai === 'choXacNhan') return don.escrowReleaseAt;
    return null;
  })();
  if (!moc) return null;
  const con = Math.round((moc.getTime() - bayGio.getTime()) / 60_000);
  return con > 0 ? con : null;
}

export type TinDb = {
  id: string;
  senderId: string | null;
  role: string;
  kind: MessageKind;
  text: string;
  textSitter: string | null;
  actionLabel: string | null;
  actionLabelSitter: string | null;
  actionCode: string | null;
  canGap: boolean;
  masked: boolean;
  images: string[];
  soAnhThem: number | null;
  caption: string | null;
  lat: number | null;
  lng: number | null;
  isRead: boolean;
  createdAt: Date;
};

export function tinTheoVai(
  tin: TinDb,
  vai: VaiChat,
  userId: string,
  kyAnh?: ReadonlyMap<string, string>,
) {
  const laNguoiCham = vai === 'PROVIDER';
  return {
    id: tin.id,
    kind: tin.kind,
    role: tin.role,
    fromMe: tin.senderId != null && tin.senderId === userId,
    text: laNguoiCham ? (tin.textSitter ?? tin.text) : tin.text,
    actionLabel: laNguoiCham
      ? (tin.actionLabelSitter ?? tin.actionLabel)
      : tin.actionLabel,
    actionCode: tin.actionCode,
    canGap: tin.canGap,
    masked: tin.masked,
    images: tin.images.map((a) => kyAnh?.get(a) ?? a),
    soAnhThem: tin.soAnhThem,
    caption: tin.caption,
    lat: tin.lat,
    lng: tin.lng,
    isRead: tin.isRead,
    createdAt: tin.createdAt.toISOString(),
  };
}
