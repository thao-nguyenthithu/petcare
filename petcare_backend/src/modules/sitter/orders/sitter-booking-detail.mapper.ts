import {
  ARRIVE_GEOFENCE_METERS,
  DEPART_WINDOW_MINUTES,
  GEAR_WAIT,
  NO_SHOW_WAIT,
} from '../../bookings/booking-compensation';
import { MOT_PHUT_MS } from '../../../common/thoi-gian-vn';
import { THAM_SO } from '../../admin/tham-so.dinh-nghia';
import { BookingStatus } from 'generated/prisma/enums';
import {
  LOAI_RA_APP,
  TRANG_THAI_HUY,
  benHuyRaApp,
} from '../../bookings/booking-enums';
import { LoaiDichVuDto } from '../../bookings/dto/create-booking.dto';
import { kmHienThi } from '../../gps/gps-quang-duong';

import { hanNhanDonCua, maTrangThaiHieuLuc } from '../../bookings/booking-time';
import {
  DonChiTiet,
  DongDon,
  DongGiaLuu,
  GIO_MO_DIA_CHI,
  PHUT_MO_NUT_BAT_DAU,
} from './sitter-booking-select';
import { SitterPenaltyService } from '../../bookings/sitter-penalty.service';

type KyAnh = (duong: string) => string;

const GIU_NGUYEN: KyAnh = (duong) => duong;

export function anhCuaDon(d: DonChiTiet): string[] {
  return [
    ...d.sessionPhotos.map((a) => a.photoUrl),
    ...d.boardingUpdates.flatMap((u) => u.photoUrls),
    ...d.noShowProofUrls,
  ];
}

function soDem(bd: unknown): number {
  const o = bd as { nights?: number } | null;
  return typeof o?.nights === 'number' ? o.nights : 0;
}

function dongGia(bd: unknown): DongGiaLuu[] {
  const o = bd as { lines?: DongGiaLuu[] } | null;
  return Array.isArray(o?.lines) ? o.lines : [];
}

function thucNhan(d: {
  sitterPayout: number | null;
  totalPrice: number | null;
  platformFee: number | null;
}): number {
  if (d.sitterPayout != null) return d.sitterPayout;
  return Math.max(0, (d.totalPrice ?? 0) - (d.platformFee ?? 0));
}

function phanTramNenTang(d: {
  totalPrice: number | null;
  platformFeePercent: number | null;
}): number {
  return d.platformFeePercent ?? THAM_SO['platform.fee.percent'].macDinh;
}

export function raDong(d: DongDon) {
  const loai = LOAI_RA_APP[d.service.type];
  const tong = d.totalPrice ?? 0;
  return {
    id: d.id,
    code: d.code,
    status: maTrangThaiHieuLuc(d),
    serviceType: loai,
    serviceName: d.service.name,
    ownerName: d.owner.fullName,
    ownerAvatar: d.owner.avatarUrl,
    ownerArea: d.address?.ward ?? d.address?.province ?? null,
    pets: d.pets.map((e) => ({
      name: e.pet.name,
      species: e.pet.species === 'CAT' ? 'cat' : 'dog',
    })),
    startAt: d.scheduledAt,
    endAt: d.scheduledEndAt,
    durationMinutes: d.durationMinutes,
    nights: loai === 'boarding' ? soDem(d.priceBreakdown) : null,
    totalPrice: tong,
    sitterAmount: thucNhan(d),
    respondDeadline: hanNhan(d),
  };
}

function hanNhan(d: {
  status: BookingStatus;
  scheduledAt: Date;
  createdAt: Date;
  paidAt: Date | null;
}): Date | null {
  return d.status === 'PENDING' ? hanNhanDonCua(d) : null;
}

export function raChiTiet(
  d: DonChiTiet,
  soDonChuNuoi: number,
  uyTin: Awaited<ReturnType<SitterPenaltyService['hoSoUyTin']>>,
  kyAnh?: ReadonlyMap<string, string>,
) {
  const loai = LOAI_RA_APP[d.service.type];
  const tong = d.totalPrice ?? 0;
  const hienDiaChi = moDiaChi(d, loai);
  const ky: KyAnh = kyAnh ? (v) => kyAnh.get(v) ?? v : GIU_NGUYEN;
  return {
    ...raDong(d),
    owner: {
      name: d.owner.fullName,
      avatarUrl: d.owner.avatarUrl,
      totalBookings: soDonChuNuoi,
    },
    pets: d.pets.map((e) => ({
      ...e.pet,
      packageCode: e.packageCode,
      packageDurationMinutes: e.durationMinutes,
      packagePrice: e.price,
    })),
    note: d.specialNotes,
    priceLines: dongGia(d.priceBreakdown),
    totalPrice: tong,
    platformFeePercent: phanTramNenTang(d),
    sitterAmount: thucNhan(d),
    pickupArea: khuVuc(d),
    pickupDistanceKm: kmToiDiemDon(d, loai),
    pickupAddress: hienDiaChi ? d.addressText : null,
    pickupLat: hienDiaChi ? d.addressLat : null,
    pickupLng: hienDiaChi ? d.addressLng : null,
    directionsOpenAt: mocMoDiaChi(d, loai),
    departOpenAt: mocLui(d, DEPART_WINDOW_MINUTES),
    startButtonOpenAt: mocLui(d, PHUT_MO_NUT_BAT_DAU),
    geofenceMeters: ARRIVE_GEOFENCE_METERS,
    acceptedAt: d.acceptedAt,
    departedAt: d.departedAt,
    arrivedAt: d.arrivedAt,
    arriveDistanceMeters: d.arriveDistanceM,
    ownerArrivedAt: d.ownerArrivedAt,
    startedAt: d.startedAt,
    endedAt: d.endedAt,
    gearCommittedAt: d.gearCommittedAt,
    lateReport: d.lateReportedAt
      ? {
          minutes: d.lateMinutes,
          etaAt: d.etaAt,
          reportedAt: d.lateReportedAt,
        }
      : null,
    noShowOpenAt: mocBaoVangMat(d, loai),
    gearWaitUntil: d.gearReportedAt
      ? new Date(d.gearReportedAt.getTime() + GEAR_WAIT * MOT_PHUT_MS)
      : null,
    autoConfirmAt:
      d.status === 'AWAITING_OWNER_CONFIRM' ? d.escrowReleaseAt : null,
    session: khoiPhien(d, ky),
    grooming: loai === 'grooming' ? khoiGrooming(d, ky) : null,
    boarding: loai === 'boarding' ? khoiTrongGiu(d, ky) : null,
    cancellation: thongTinHuy(d, ky),
    reputation: uyTin,
  };
}

function kmToiDiemDon(d: DonChiTiet, loai: LoaiDichVuDto): number | null {
  if (loai === 'boarding') return 0;
  return d.pickupDistanceKm;
}

function khuVuc(d: DonChiTiet): string | null {
  const phan = (d.addressText ?? '')
    .split(',')
    .map((e) => e.trim())
    .filter((e) => e.length > 0);
  return phan.length <= 1 ? null : phan.slice(1).join(', ');
}

function moDiaChi(d: DonChiTiet, loai: LoaiDichVuDto): boolean {
  if (loai === 'boarding') return false;
  if (d.status !== 'CONFIRMED' && !dangLamViec(d.status)) return false;
  return Date.now() >= mocLui(d, GIO_MO_DIA_CHI * 60).getTime();
}

function dangLamViec(tt: BookingStatus): boolean {
  return (
    tt === 'IN_PROGRESS' ||
    tt === 'AWAITING_OWNER_CONFIRM' ||
    tt === 'COMPLETED'
  );
}

function mocMoDiaChi(d: DonChiTiet, loai: LoaiDichVuDto): Date | null {
  if (loai === 'boarding' || TRANG_THAI_HUY.includes(d.status)) return null;
  return moDiaChi(d, loai) ? null : mocLui(d, GIO_MO_DIA_CHI * 60);
}

function mocLui(d: { scheduledAt: Date }, phut: number): Date {
  return new Date(d.scheduledAt.getTime() - phut * MOT_PHUT_MS);
}

function mocBaoVangMat(d: DonChiTiet, loai: LoaiDichVuDto): Date | null {
  if (loai === 'boarding') {
    return d.ownerArrivedAt
      ? null
      : new Date(d.scheduledAt.getTime() + NO_SHOW_WAIT * MOT_PHUT_MS);
  }
  if (!d.arrivedAt) return null;
  return new Date(d.arrivedAt.getTime() + NO_SHOW_WAIT * MOT_PHUT_MS);
}

function anhTheoPha(
  d: DonChiTiet,
  pha: 'CHECK_IN' | 'IN_PROGRESS' | 'CHECK_OUT',
  ky: KyAnh,
) {
  return d.sessionPhotos
    .filter((a) => a.phase === pha && !a.anhDoDung)
    .map((a) => ky(a.photoUrl));
}

function anhDoDungTheoPha(
  d: DonChiTiet,
  pha: 'CHECK_IN' | 'CHECK_OUT',
  ky: KyAnh,
) {
  return d.sessionPhotos
    .filter((a) => a.phase === pha && a.anhDoDung)
    .map((a) => ky(a.photoUrl));
}

function kmChot(d: DonChiTiet): number | null {
  const bc = d.gpsReport;
  if (!bc) return null;
  return kmHienThi(bc.totalWaypoints, bc.totalDistanceM);
}

function khoiPhien(d: DonChiTiet, ky: KyAnh) {
  if (!d.startedAt) return null;
  const nhatKy = anhTheoPha(d, 'IN_PROGRESS', ky);
  return {
    startedAt: d.startedAt,
    verifiedAt:
      d.sessionPhotos.find((a) => a.phase === 'CHECK_IN')?.takenAt ?? null,
    distanceKm: kmChot(d),
    endedAt: d.endedAt,
    finishOpenAt: d.scheduledEndAt,
    photos: nhatKy,
    totalPhotos: nhatKy.length,
    sitterNote: d.sitterNote,
  };
}

function khoiGrooming(d: DonChiTiet, ky: KyAnh) {
  return {
    tasks: d.pets.map((e) => ({
      petId: e.pet.id,
      packageCode: e.packageCode,
      durationMinutes: e.durationMinutes,
    })),
    estimatedFinishAt: d.scheduledEndAt,
    startedAt: d.startedAt,
    finishedAt: d.endedAt,
    beforePhotos: anhTheoPha(d, 'CHECK_IN', ky),
    afterPhotos: anhTheoPha(d, 'CHECK_OUT', ky),
  };
}

function khoiTrongGiu(d: DonChiTiet, ky: KyAnh) {
  const dem = soDem(d.priceBreakdown);
  const moiNhat = d.boardingUpdates[0];
  return {
    nights: dem,
    currentNight: demHienTai(d, dem),
    dropOffAt: d.scheduledAt,
    pickUpAt: d.scheduledEndAt,
    receivedAt: d.startedAt,
    ownerArrivedAt: d.ownerArrivedAt,
    finishedAt: d.endedAt,
    handoverNote: d.handoverNote,
    latestUpdate: moiNhat
      ? {
          message: moiNhat.message,
          conditions: moiNhat.conditions,
          photoUrls: moiNhat.photoUrls.map(ky),
          createdAt: moiNhat.createdAt,
        }
      : null,
    updateCount: d.boardingUpdates.length,
    photos: d.boardingUpdates.flatMap((u) => u.photoUrls.map(ky)),
    petPhotosIn: anhTheoPha(d, 'CHECK_IN', ky),
    petPhotosOut: anhTheoPha(d, 'CHECK_OUT', ky),
    itemPhotosIn: anhDoDungTheoPha(d, 'CHECK_IN', ky),
    itemPhotosOut: anhDoDungTheoPha(d, 'CHECK_OUT', ky),
  };
}

function demHienTai(d: DonChiTiet, soDem: number): number | null {
  if (!d.startedAt || soDem < 1) return null;
  const troi = Date.now() - d.startedAt.getTime();
  const dem = Math.floor(troi / (24 * 60 * MOT_PHUT_MS)) + 1;
  return Math.min(Math.max(dem, 1), soDem);
}

function thongTinHuy(d: DonChiTiet, ky: KyAnh) {
  if (!TRANG_THAI_HUY.includes(d.status)) return null;
  return {
    by: benHuyRaApp(d),
    at: d.cancelledAt,
    reason: d.cancellationReason,
    note: d.cancellationNote,
    ownerFee: d.cancellationFee ?? 0,
    sitterPayout: d.sitterPayout ?? 0,
    proofUrls: d.noShowProofUrls.map(ky),
  };
}
