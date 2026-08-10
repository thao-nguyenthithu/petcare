import { kmHienThi } from '../gps/gps-quang-duong';
import { DIEM_MOI_LAN_GUI } from '../gps/gps.constants';
import {
  DonXetHuy,
  hanHuyMienPhiAt,
  hetAnHanDatGapAt,
  laDatGap,
  phanTramPhiHuyCuaDon,
  phiHuyCuaDon,
  xetMienPhi,
} from './booking-cancel';
import { LOAI_RA_APP, TRANG_THAI_HUY, benHuyRaApp } from './booking-enums';
import { hanNhanDonCua, maTrangThaiHieuLuc } from './booking-time';
import { LoaiDichVuDto } from './dto/create-booking.dto';
import { khoangCachKm } from '../../common/khoang-cach';
import { khuVucHaiCap } from '../../common/khu-vuc';
import {
  DonChiTiet,
  DongGiaLuu,
  TRANG_THAI_HUY_DUOC,
} from './owner-booking-select';

type KyAnh = (duong: string) => string;

// Mọi ảnh chủ nuôi được xem của một đơn, để ký một lượt trước khi dựng payload
export function anhChuNuoiXemDuoc(d: DonChiTiet): string[] {
  return [
    ...d.sessionPhotos.map((a) => a.photoUrl),
    ...d.boardingUpdates.flatMap((u) => u.photoUrls),
    ...(d.review?.photos ?? []),
    ...d.noShowProofUrls,
  ];
}

export function raChiTiet(d: DonChiTiet, kyAnh?: ReadonlyMap<string, string>) {
  const loai = LOAI_RA_APP[d.service.type];
  const dem = soDem(d);
  const ky: KyAnh = kyAnh ? (v) => kyAnh.get(v) ?? v : (v) => v;
  const anh = khoiAnh(d, loai, ky);
  return {
    photos: anh,
    result: ketQuaPhien(d, loai, anh.total),
    myReview: baiDanhGia(d, ky),
    id: d.id,
    code: d.code,
    status: maTrangThaiHieuLuc(d),
    serviceType: loai,
    serviceName: d.service.name,
    durationMinutes: d.durationMinutes,
    nights: loai === 'boarding' ? dem : null,
    startAt: d.scheduledAt,
    endAt: d.scheduledEndAt,
    deadlineAt: hanCua(d),
    acceptedAt: d.acceptedAt,
    departedAt: d.departedAt,
    arrivedAt: d.arrivedAt,
    startedAt: d.startedAt,
    endedAt: d.endedAt,
    note: d.specialNotes,
    walkDistanceKm: kmDaDi(d, loai),
    session: khoiPhien(d, loai),
    sitter: {
      id: d.sitter.id,
      fullName: d.sitter.user.fullName,
      avatarUrl: d.sitter.user.avatarUrl,
      ratingAvg: d.sitter.ratingAvg,
      totalReviews: d.sitter.totalReviews,
    },
    pets: d.pets.map((e) => ({
      ...e.pet,
      packageCode: e.packageCode,
      packageDurationMinutes: e.durationMinutes,
      packagePrice: e.price,
    })),
    address: {
      text: d.addressText,
      lat: d.addressLat,
      lng: d.addressLng,
    },
    sitterPlace: choNguoiCham(d, loai),
    priceLines: dongTien(d),
    totalPrice: d.totalPrice ?? 0,
    cancelPolicy: chinhSachHuy(d, loai, dem),
    cancellation: thongTinHuy(d, kyAnh),
    dispute: khoiKhieuNai(d),
  };
}

// Hồ sơ mới nhất của đơn, đủ để màn đơn mở thẳng màn hồ sơ mà không cần tra mã
function khoiKhieuNai(d: DonChiTiet) {
  const hs = d.reports[0];
  if (!hs) return null;
  return {
    code: hs.code,
    open: hs.resolvedAt === null,
    byOwner: hs.reporterId === d.ownerId,
  };
}

function kmDaDi(d: DonChiTiet, loai: LoaiDichVuDto): number | null {
  if (loai !== 'walking' || !d.gpsReport) return null;
  return kmHienThi(d.gpsReport.totalWaypoints, d.gpsReport.totalDistanceM);
}

function anhTheoPha(
  d: DonChiTiet,
  pha: 'CHECK_IN' | 'IN_PROGRESS' | 'CHECK_OUT',
  ky: KyAnh,
): string[] {
  return d.sessionPhotos
    .filter((a) => a.phase === pha && !a.anhDoDung)
    .map((a) => ky(a.photoUrl));
}

// Grooming tách trước và sau; hai dịch vụ kia gom thành một dải nhật ký theo thời gian
function khoiAnh(d: DonChiTiet, loai: LoaiDichVuDto, ky: KyAnh) {
  const nhanBe = anhTheoPha(d, 'CHECK_IN', ky);
  const traBe = anhTheoPha(d, 'CHECK_OUT', ky);
  const giuaPhien = anhTheoPha(d, 'IN_PROGRESS', ky);
  const hangNgay = d.boardingUpdates.flatMap((u) => u.photoUrls.map(ky));
  if (loai === 'grooming') {
    const log = giuaPhien;
    return {
      before: nhanBe,
      after: traBe,
      log,
      total: nhanBe.length + traBe.length + log.length,
    };
  }
  const log =
    loai === 'boarding'
      ? [...nhanBe, ...hangNgay, ...traBe]
      : [...nhanBe, ...giuaPhien, ...traBe];
  return { before: [], after: [], log, total: log.length };
}

// Có bài rồi thì màn đơn hiện lại bài đó thay cho lời mời chấm sao
function baiDanhGia(d: DonChiTiet, ky: KyAnh) {
  const bai = d.review;
  if (!bai) return null;
  return {
    rating: bai.rating,
    comment: bai.comment,
    photos: bai.photos.map(ky),
    praiseTags: bai.praiseTags,
    reply: bai.reply,
    replyAt: bai.replyAt,
    createdAt: bai.createdAt,
  };
}

// Dải số liệu chốt chỉ có nghĩa khi phiên đã khép lại
function ketQuaPhien(d: DonChiTiet, loai: LoaiDichVuDto, soAnh: number) {
  if (d.status !== 'AWAITING_OWNER_CONFIRM' && d.status !== 'COMPLETED') {
    return null;
  }
  return {
    durationMinutes: phutDaLam(d),
    distanceKm: kmDaDi(d, loai),
    photoCount: soAnh,
  };
}

function phutDaLam(d: DonChiTiet): number {
  const bc = d.gpsReport;
  if (bc && bc.durationMinutes > 0) return bc.durationMinutes;
  if (!d.startedAt) return 0;
  const ket = d.endedAt ?? new Date();
  const phut = Math.round((ket.getTime() - d.startedAt.getTime()) / 60000);
  return phut > 0 ? phut : 0;
}

function khoiPhien(d: DonChiTiet, loai: LoaiDichVuDto) {
  const bc = d.gpsReport;
  if (loai !== 'walking' || !bc || bc.totalWaypoints < 1) return null;
  const giayMoiDiem = (bc.durationMinutes * 60) / bc.totalWaypoints;
  return {
    distanceKm: kmDaDi(d, loai),
    durationMinutes: bc.durationMinutes,
    updateEverySeconds: Math.max(1, Math.round(giayMoiDiem * DIEM_MOI_LAN_GUI)),
  };
}

function choNguoiCham(d: DonChiTiet, loai: LoaiDichVuDto) {
  if (loai !== 'boarding') return null;
  const daNhan = d.status !== 'PENDING';
  const day = d.sitter.serviceAddress;
  return {
    area: khuVucHaiCap(day),
    address: daNhan ? day : null,
    lat: daNhan ? d.sitter.lat : null,
    lng: daNhan ? d.sitter.lng : null,
    distanceKm: khoangCachToiNcc(d),
  };
}

function khoangCachToiNcc(d: DonChiTiet): number | null {
  const { lat, lng } = d.sitter;
  if (lat === null || lng === null) return null;
  if (d.addressLat === null || d.addressLng === null) return null;
  return (
    Math.round(khoangCachKm(d.addressLat, d.addressLng, lat, lng) * 10) / 10
  );
}

function hanCua(d: DonChiTiet): Date | null {
  if (d.status === 'PENDING') return hanNhanDonCua(d);
  if (d.status === 'AWAITING_OWNER_CONFIRM') return d.escrowReleaseAt;
  return null;
}

export function soDem(d: DonChiTiet): number {
  const bd = d.priceBreakdown as { nights?: number } | null;
  return typeof bd?.nights === 'number' ? bd.nights : 0;
}

function dongTien(d: DonChiTiet): DongGiaLuu[] {
  const bd = d.priceBreakdown as { lines?: DongGiaLuu[] } | null;
  return Array.isArray(bd?.lines) ? bd.lines : [];
}

export function donXetHuy(d: DonChiTiet): DonXetHuy {
  return {
    loai: LOAI_RA_APP[d.service.type],
    batDau: d.scheduledAt,
    soDem: soDem(d),
    tongTien: d.totalPrice ?? 0,
    dangCho: d.status === 'PENDING',
    taoLuc: d.createdAt,
    acceptedAt: d.acceptedAt,
    arrivedAt: d.arrivedAt,
    departedAt: d.departedAt,
  };
}

function chinhSachHuy(d: DonChiTiet, loai: LoaiDichVuDto, soDem: number) {
  const xetHuy = donXetHuy(d);
  const han = hanHuyMienPhiAt(loai, d.scheduledAt, soDem);
  const conCua = TRANG_THAI_HUY_DUOC.includes(d.status) && !d.departedAt;
  const xet = xetMienPhi(xetHuy, Date.now());
  const phi =
    !conCua || xet.mienPhi
      ? 0
      : phiHuyCuaDon(
          loai,
          d.totalPrice ?? 0,
          soDem,
          phanTramPhiHuyCuaDon(d.cancelFeePercent),
          d.scheduledAt,
        );
  return {
    hanHuyMienPhiAt: han,
    laDatGap: laDatGap(d.createdAt, han),
    hetAnHanDatGapAt: hetAnHanDatGapAt(xetHuy, han),
    mienPhi: xet.mienPhi,
    doNguoiCham: xet.doNguoiCham,
    coTheHuy: conCua,
    phiHuyDuKien: phi,
    tienHoanDuKien: (d.totalPrice ?? 0) - phi,
  };
}

function thongTinHuy(d: DonChiTiet, ky?: ReadonlyMap<string, string>) {
  if (!TRANG_THAI_HUY.includes(d.status)) return null;
  return {
    by: benHuyRaApp(d),
    at: d.cancelledAt,
    reason: d.cancellationReason,
    note: d.cancellationNote,
    fee: d.cancellationFee ?? 0,
    proofUrls: d.noShowProofUrls.map((u) => ky?.get(u) ?? u),
  };
}
