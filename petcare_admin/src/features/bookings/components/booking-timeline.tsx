import { useTranslation } from 'react-i18next';
import { Activity, Check } from 'lucide-react';
import { GIO_MO_CHI_DUONG } from '@/features/bookings/booking-constants';
import type { BookingDetail } from '@/features/bookings/types';
import { formatDateTime, formatTime } from '@/lib/format';
import { cn } from '@/lib/utils';

type Moc = {
  key: string;
  title: string;
  detail: string | null;
  at: string | null;
};

export function BookingTimeline({ data }: { data: BookingDetail }) {
  const { t } = useTranslation();
  const b = data.booking;
  const payment = data.payment;
  const chuNuoiDiLai = b.serviceType === 'BOARDING';
  const mocMoChiDuong = tinhMocMoChiDuong(b.scheduledAt, GIO_MO_CHI_DUONG, b.acceptedAt);

  const moc: Moc[] = [
    {
      key: 'created',
      title: t('don.tienTrinh.datCho'),
      detail: t('don.tienTrinh.datChoPhu'),
      at: b.createdAt,
    },
    {
      key: 'paid',
      title: t('don.tienTrinh.traTien'),
      detail: t('don.tienTrinh.traTienPhu'),
      at: b.paidAt,
    },
    {
      key: 'accepted',
      title: t('don.tienTrinh.nhanDon'),
      detail: b.acceptDeadlineAt
        ? t('don.tienTrinh.nhanDonPhuHan', { value: formatDateTime(b.acceptDeadlineAt) })
        : t('don.tienTrinh.nhanDonPhu'),
      at: b.acceptedAt,
    },
    {
      key: 'departed',
      title: chuNuoiDiLai ? t('don.tienTrinh.chuNuoiXuatPhat') : t('don.tienTrinh.xuatPhat'),
      detail: t(chuNuoiDiLai ? 'don.tienTrinh.chuNuoiXuatPhatPhu' : 'don.tienTrinh.xuatPhatPhu', {
        value: formatDateTime(mocMoChiDuong),
        gio: GIO_MO_CHI_DUONG,
      }),
      at: b.departedAt,
    },
    {
      key: 'arrived',
      title: chuNuoiDiLai ? t('don.tienTrinh.toiNhaNguoiCham') : t('don.tienTrinh.toiNoi'),
      detail:
        b.arriveDistanceM === null
          ? t('don.tienTrinh.toiNoiPhu')
          : t('don.tienTrinh.toiNoiPhuLech', { met: b.arriveDistanceM }),
      at: b.arrivedAt,
    },
    {
      key: 'started',
      title: t('don.tienTrinh.batDau'),
      detail: t('don.tienTrinh.batDauPhu'),
      at: b.startedAt,
    },
    {
      key: 'ended',
      title: t('don.tienTrinh.baoXong'),
      detail: t('don.tienTrinh.baoXongPhu'),
      at: b.endedAt,
    },
    {
      key: 'completed',
      title: t('don.tienTrinh.chuNuoiXacNhan'),
      detail: t('don.tienTrinh.chuNuoiXacNhanPhu'),
      at: b.completedAt,
    },
    {
      key: 'released',
      title: t('don.tienTrinh.nhaEscrow'),
      detail: t('don.tienTrinh.nhaEscrowPhu'),
      at: payment?.releasedAt ?? null,
    },
  ];

  const mocPhu: Moc[] = [];
  if (b.lateReportedAt) {
    mocPhu.push({
      key: 'late',
      title: t('don.tienTrinh.baoTre'),
      detail:
        b.lateMinutes === null
          ? null
          : t('don.tienTrinh.baoTrePhu', { phut: b.lateMinutes }),
      at: b.lateReportedAt,
    });
  }
  if (b.gearReportedAt) {
    mocPhu.push({
      key: 'gear',
      title: t('don.tienTrinh.baoThieuDungCu'),
      detail: t('don.tienTrinh.baoThieuDungCuPhu'),
      at: b.gearReportedAt,
    });
  }
  if (b.ownerArrivedAt) {
    mocPhu.push({
      key: 'ownerArrived',
      title: t('don.tienTrinh.chuNuoiCoMat'),
      detail: t('don.tienTrinh.chuNuoiCoMatPhu'),
      at: b.ownerArrivedAt,
    });
  }

  const danhSach = chenTheoThoiGian(moc, mocPhu);
  const chiSoDangChay = danhSach.reduce((last, item, index) => (item.at ? index : last), -1);

  return (
    <ol className="flex flex-col">
      {danhSach.map((item, index) => {
        const daXayRa = Boolean(item.at);
        const dangChay = index === chiSoDangChay;
        const laCuoi = index === danhSach.length - 1;
        const Icon = dangChay ? Activity : Check;

        return (
          <li key={item.key} className="flex gap-item">
            <div className="flex flex-col items-center">
              <span
                className={cn(
                  'flex h-[22px] w-[22px] shrink-0 items-center justify-center rounded-full',
                  dangChay && 'bg-card-mint text-primary',
                  daXayRa && !dangChay && 'bg-primary/12 text-primary',
                  !daXayRa && 'bg-neutral-light text-text-secondary',
                )}
              >
                <Icon className="h-3 w-3" strokeWidth={2.2} />
              </span>
              {!laCuoi ? (
                <span
                  className={cn('w-[2px] flex-1', daXayRa ? 'bg-primary/25' : 'bg-neutral-light')}
                />
              ) : null}
            </div>

            <div className={cn('min-w-0 pb-stack', laCuoi && 'pb-0')}>
              <p className={cn('text-label', !daXayRa && 'text-text-secondary')}>{item.title}</p>
              <p className="mt-text text-caption-sm text-text-secondary">
                {item.at ? formatTime(item.at) : t('don.tienTrinh.chuaXayRa')}
                {item.detail ? ` · ${item.detail}` : ''}
              </p>
            </div>
          </li>
        );
      })}
    </ol>
  );
}

function tinhMocMoChiDuong(scheduledAt: string, gio: number, acceptedAt: string | null): string {
  const moc = new Date(scheduledAt).getTime() - gio * 3_600_000;
  if (!acceptedAt) return new Date(moc).toISOString();
  return new Date(Math.max(moc, new Date(acceptedAt).getTime())).toISOString();
}

function chenTheoThoiGian(chinh: Moc[], phu: Moc[]): Moc[] {
  if (phu.length === 0) return chinh;
  const ketQua = [...chinh];
  phu.forEach((item) => {
    const viTri = ketQua.findIndex(
      (goc) => goc.at !== null && item.at !== null && goc.at > item.at,
    );
    if (viTri === -1) ketQua.push(item);
    else ketQua.splice(viTri, 0, item);
  });
  return ketQua;
}
