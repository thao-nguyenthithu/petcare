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


export function raChiTiet(d: DonChiTiet, kyAnh?: ReadonlyMap<string, string>) {
  const loai = LOAI_RA_APP[d.service.type];
  const dem = soDem(d);
  return {
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
  };
}

function kmDaDi(d: DonChiTiet, loai: LoaiDichVuDto): number | null {
  if (loai !== 'walking' || !d.gpsReport) return null;
  return kmHienThi(d.gpsReport.totalWaypoints, d.gpsReport.totalDistanceM);
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
