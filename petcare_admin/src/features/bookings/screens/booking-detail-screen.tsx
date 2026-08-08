import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useParams } from 'react-router-dom';
import { ChevronRight, CreditCard, PawPrint } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { TextInput } from '@/components/ui/field';
import { ImageViewer } from '@/components/ui/image-viewer';
import { DongThongTin } from '@/components/ui/info-row';
import { useImageViewer, type AnhXem } from '@/components/ui/use-image-viewer';
import { Modal } from '@/components/ui/modal';
import { PageHeader } from '@/components/ui/page-header';
import { SectionCard } from '@/components/ui/section-card';
import { ErrorState } from '@/components/state/error-state';
import { EmptyState } from '@/components/state/empty-state';
import { Skeleton } from '@/components/state/skeleton';
import { TRANG_THAI_HUY_DUOC } from '@/features/bookings/booking-constants';
import { AdminBookingStatusBadge } from '@/features/bookings/components/booking-status-badge';
import { BookingTimeline } from '@/features/bookings/components/booking-timeline';
import { GpsTrackMap } from '@/features/bookings/components/gps-track-map';
import {
  useBookingDetail,
  useCanThiepHuy,
  useTaiTrackCsv,
} from '@/features/bookings/hooks/use-bookings';
import type { BookingDetail } from '@/features/bookings/types';
import { UserAvatar } from '@/features/users/components/user-badges';
import { getErrorMessage } from '@/lib/api/client';
import { formatDateTime, formatMoney, formatPercent } from '@/lib/format';
import { nhanThoiLuong, nhanTuoi } from '@/lib/labels';
import { notify } from '@/lib/toast';
import { PATHS } from '@/routes/paths';

export function BookingDetailScreen() {
  const { t } = useTranslation();
  const { code = '' } = useParams();
  const chiTiet = useBookingDetail(code);
  const huyDon = useCanThiepHuy(code);
  const taiCsv = useTaiTrackCsv(code);
  const [moDialogHuy, setMoDialogHuy] = useState(false);
  const [lyDo, setLyDo] = useState('');

  if (chiTiet.isError) {
    return <ErrorState onRetry={() => void chiTiet.refetch()} />;
  }

  const data = chiTiet.data;
  const choPhepHuy = data ? TRANG_THAI_HUY_DUOC.includes(data.booking.status) : false;
  const coHoiThoai = Boolean(data?.booking.acceptedAt);
  const coLoTrinh = Boolean(data && (data.track.length > 0 || data.gpsReport));

  return (
    <div className="flex flex-col gap-stack pb-block">
      <PageHeader
        backTo={PATHS.bookings}
        crumbs={[{ label: t('man.donDatLich.title'), to: PATHS.bookings }, { label: code }]}
        actions={
          <>
            {coHoiThoai ? (
              <Button variant="ghost" asChild>
                <Link to={`${PATHS.bookings}/${code}/conversation`}>
                  {t('don.hanhDong.xemHoiThoai')}
                </Link>
              </Button>
            ) : (
              <Button variant="ghost" disabled>
                {t('don.hanhDong.xemHoiThoai')}
              </Button>
            )}
            <Button
              variant="secondary"
              disabled={!coLoTrinh || taiCsv.isPending}
              onClick={() =>
                taiCsv.mutate(undefined, {
                  onError: (error) => notify.error(getErrorMessage(error)),
                })
              }
            >
              {t('don.hanhDong.taiLogGps')}
            </Button>
            <Button variant="danger" disabled={!choPhepHuy} onClick={() => setMoDialogHuy(true)}>
              {t('don.hanhDong.canThiepHuy')}
            </Button>
          </>
        }
      />

      {chiTiet.isPending || !data ? (
        <div className="grid grid-cols-[352px_1fr] gap-stack">
          <Skeleton className="h-[660px] w-full rounded-card" />
          <Skeleton className="h-[660px] w-full rounded-card" />
        </div>
      ) : (
        <div className="grid grid-cols-[352px_1fr] items-start gap-stack">
          <div className="flex flex-col gap-stack">
            <ThongTinDonCard data={data} />
            <CacBenCard data={data} />
          </div>

          <div className="flex flex-col gap-stack">
            <SectionCard title={t('don.tienTrinh.tieuDe')} subtitle={t('don.tienTrinh.moTa')}>
              <BookingTimeline data={data} />
            </SectionCard>

            <HanhTrinhGpsCard data={data} />
            {data.booking.noShowProofUrls.length > 0 ? (
              <AnhVangMatCard urls={data.booking.noShowProofUrls} />
            ) : null}
          </div>
        </div>
      )}

      <Modal
        open={moDialogHuy}
        onOpenChange={(open) => {
          setMoDialogHuy(open);
          if (!open) setLyDo('');
        }}
        title={t('don.dialogHuy.tieuDe')}
        description={t('don.dialogHuy.moTa', { code })}
        danger
        confirmLabel={t('don.dialogHuy.nut')}
        confirmDisabled={lyDo.trim().length < 3}
        loading={huyDon.isPending}
        onConfirm={() => {
          huyDon.mutate(lyDo.trim(), {
            onSuccess: () => {
              notify.success(t('don.dialogHuy.daHuy', { code }));
              setMoDialogHuy(false);
              setLyDo('');
            },
            onError: (error) => notify.error(getErrorMessage(error)),
          });
        }}
      >
        <label className="flex flex-col gap-label">
          <span className="text-label-sm uppercase text-text-primary">
            {t('don.dialogHuy.lyDo')}
          </span>
          <TextInput
            value={lyDo}
            onChange={(event) => setLyDo(event.target.value)}
            placeholder={t('don.dialogHuy.lyDoGoiY')}
          />
        </label>
      </Modal>
    </div>
  );
}

function ThongTinDonCard({ data }: { data: BookingDetail }) {
  const { t } = useTranslation();
  const b = data.booking;
  const payment = data.payment;
  const tyLeHoaHong =
    b.totalPrice !== null && b.totalPrice > 0 && b.platformFee !== null
      ? (b.platformFee / b.totalPrice) * 100
      : null;
  const dongHoaHong =
    b.platformFee === null
      ? null
      : tyLeHoaHong === null
        ? formatMoney(b.platformFee)
        : `${formatMoney(b.platformFee)} (${formatPercent(tyLeHoaHong, 0)})`;

  return (
    <SectionCard
      title={t('don.thongTin.tieuDe')}
      subtitle={t('don.thongTin.taoLuc', { value: formatDateTime(b.createdAt) })}
      action={<AdminBookingStatusBadge status={b.status} />}
    >
      <ul className="flex flex-col gap-item">
        <DongThongTin label={t('don.thongTin.dichVu')} value={b.serviceName} />
        <DongThongTin
          label={t('don.thongTin.thoiLuong')}
          value={nhanThoiLuong(t, b.durationMinutes)}
        />
        <DongThongTin label={t('don.thongTin.lichHen')} value={formatDateTime(b.scheduledAt)} />
        <DongThongTin label={t('don.thongTin.diemDon')} value={b.addressText} />
        <DongThongTin
          label={t('don.thongTin.giaDichVu')}
          value={b.totalPrice === null ? null : formatMoney(b.totalPrice)}
        />
        {b.cancellationFee !== null ? (
          <DongThongTin
            label={t('don.thongTin.phiHuy')}
            value={formatMoney(b.cancellationFee)}
          />
        ) : null}
        <DongThongTin label={t('don.thongTin.hoaHong')} value={dongHoaHong} />
        <DongThongTin
          label={t('don.thongTin.nccThucNhan')}
          value={b.sitterPayout === null ? null : formatMoney(b.sitterPayout)}
        />
      </ul>

      <div className="mt-stack flex items-start gap-item border-t border-neutral-light pt-stack">
        <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-card bg-card-mint">
          <CreditCard className="h-4 w-4 text-primary" strokeWidth={1.8} />
        </span>
        <div className="min-w-0">
          <p className="text-label">
            {payment ? t(`don.thanhToan.${payment.status}`) : t('don.thanhToan.chuaCo')}
          </p>
          {payment ? (
            <p className="mt-text text-caption-sm text-text-secondary">
              {[
                t('don.thanhToan.maGiaoDich', { value: payment.txnRef }),
                payment.gatewayTxnNo
                  ? t('don.thanhToan.maCong', { value: payment.gatewayTxnNo })
                  : null,
                payment.bankCode,
                payment.releasedAt
                  ? t('don.thanhToan.daNha', { value: formatDateTime(payment.releasedAt) })
                  : b.escrowReleaseAt
                    ? t('don.thanhToan.duKienNha', {
                        value: formatDateTime(b.escrowReleaseAt),
                      })
                    : payment.expiresAt
                      ? t('don.thanhToan.hetHan', { value: formatDateTime(payment.expiresAt) })
                      : null,
              ]
                .filter(Boolean)
                .join(' · ')}
            </p>
          ) : null}
        </div>
      </div>
    </SectionCard>
  );
}

function BenLienQuan({
  id,
  name,
  avatarUrl,
  role,
  info,
}: {
  id: string;
  name: string;
  avatarUrl: string | null;
  role: string;
  info: string;
}) {
  return (
    <li>
      <Link
        to={`${PATHS.users}/${id}`}
        className="flex items-center gap-item rounded-card px-text py-text transition-colors hover:bg-neutral-light/60"
      >
        <UserAvatar name={name} url={avatarUrl} size={38} />
        <div className="min-w-0 flex-1">
          <p className="truncate text-label">{name}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {role} · {info}
          </p>
        </div>
        <ChevronRight
          className="h-[18px] w-[18px] shrink-0 text-text-secondary"
          strokeWidth={1.8}
        />
      </Link>
    </li>
  );
}

function AnhVangMatCard({ urls }: { urls: string[] }) {
  const { t } = useTranslation();
  const xem = useImageViewer();
  const anh: AnhXem[] = urls.map((url) => ({ url, nhan: t('don.anhVangMat.tieuDe') }));

  return (
    <SectionCard title={t('don.anhVangMat.tieuDe')} subtitle={t('don.anhVangMat.moTa')}>
      <div className="grid grid-cols-3 gap-item">
        {urls.map((url, viTri) => (
          <button
            key={url}
            type="button"
            aria-label={t('xemAnh.moAnh')}
            onClick={() => xem.mo(viTri)}
            className="h-[128px] overflow-hidden rounded-card bg-neutral-light/60"
          >
            <img src={url} alt="" className="h-full w-full object-cover" />
          </button>
        ))}
      </div>

      <ImageViewer anh={anh} moTai={xem.moTai} onDong={xem.dong} />
    </SectionCard>
  );
}

function CacBenCard({ data }: { data: BookingDetail }) {
  const { t } = useTranslation();
  const nhieuBe = data.pets.length > 1;

  return (
    <SectionCard title={t('don.cacBen.tieuDe')}>
      <ul className="-mx-text flex flex-col gap-label">
        <BenLienQuan
          id={data.owner.id}
          name={data.owner.fullName}
          avatarUrl={data.owner.avatarUrl}
          role={t('nguoiDung.vaiTro.OWNER')}
          info={data.owner.email}
        />

        <BenLienQuan
          id={data.sitter.userId}
          name={data.sitter.fullName}
          avatarUrl={data.sitter.avatarUrl}
          role={t('nguoiDung.vaiTro.PROVIDER')}
          info={data.sitter.email}
        />
      </ul>

      <p className="mt-stack px-text text-label-sm uppercase text-text-secondary">
        {t('don.cacBen.thuCung', { count: data.pets.length })}
      </p>

      <ul className="mt-label flex flex-col gap-label">
        {data.pets.map((pet) => (
          <li
            key={pet.id}
            className="flex items-center gap-item rounded-card border border-neutral-light p-item"
          >
            <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-card bg-card-mint">
              <PawPrint className="h-[18px] w-[18px] text-primary" strokeWidth={1.8} />
            </span>
            <div className="min-w-0 flex-1">
              <p className="truncate text-label">{pet.name}</p>
              <p className="truncate text-caption-sm text-text-secondary">
                {[
                  pet.breed,
                  nhanTuoi(t, pet.birthDate),
                  t('don.canNang', { value: pet.weightKg }),
                ]
                  .filter(Boolean)
                  .join(' · ')}
              </p>
            </div>
            {nhieuBe && pet.price !== null ? (
              <span className="shrink-0 text-label">{formatMoney(pet.price)}</span>
            ) : null}
          </li>
        ))}
      </ul>
    </SectionCard>
  );
}

function HanhTrinhGpsCard({ data }: { data: BookingDetail }) {
  const { t } = useTranslation();
  const report = data.gpsReport;

  const oSo: Array<{ label: string; value: string | null }> = [
    {
      label: t('don.gps.quangDuongServer'),
      value: report ? t('don.gps.km', { value: (report.totalDistanceM / 1000).toFixed(1) }) : null,
    },
    {
      label: t('don.gps.thoiGianPhien'),
      value: report ? t('don.gps.phut', { value: report.durationMinutes }) : null,
    },
    {
      label: t('don.gps.tocDoTrungBinh'),
      value: report ? t('don.gps.kmh', { value: report.avgSpeedKmh }) : null,
    },
    {
      label: t('don.gps.diemNghiNgo'),
      value: report
        ? `${report.suspicionScore ?? t('don.gps.khongDoiChieuDuoc')} · ${
            report.flaggedForReview ? t('don.gps.daGanCo') : t('don.gps.chuaGanCo')
          }`
        : null,
    },
  ];

  return (
    <SectionCard
      title={t('don.gps.tieuDe')}
      subtitle={t('don.gps.moTa')}
      action={
        report?.flaggedForReview ? (
          <Badge tone="danger">{t('don.gps.daGanCo')}</Badge>
        ) : (
          <Badge tone="info">{t('don.gps.dangTruyen')}</Badge>
        )
      }
    >
      {data.track.length === 0 && !report ? (
        <EmptyState message={t('don.gps.chuaCoLoTrinh')} />
      ) : (
        <GpsTrackMap track={data.track} />
      )}

      <div className="mt-stack grid grid-cols-4 gap-item">
        {oSo.map((item) => (
          <div key={item.label} className="rounded-card border border-neutral-light p-item">
            <p className="truncate text-caption-sm text-text-secondary">{item.label}</p>
            <p className="mt-text truncate text-label">{item.value ?? <KhongCoDuLieu />}</p>
          </div>
        ))}
      </div>

      <p className="mt-item text-caption-sm text-text-secondary">
        {data.booking.distanceKm === null
          ? t('don.gps.appChuaKhai')
          : t('don.gps.appKhai', { value: data.booking.distanceKm })}
      </p>

      {data.trackTruncated ? (
        <p className="mt-item rounded-card bg-honey/15 p-item text-caption-sm text-honey">
          {t('don.gps.daCatLoTrinh')}
        </p>
      ) : null}

      {report?.suspicionNote ? (
        <p className="mt-item rounded-card bg-honey/15 p-item text-caption-sm text-honey">
          {report.suspicionNote}
        </p>
      ) : null}
    </SectionCard>
  );
}
