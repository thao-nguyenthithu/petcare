import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { Image as ImageIcon, MapPin, MessageSquare, Navigation } from 'lucide-react';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { ImageViewer } from '@/components/ui/image-viewer';
import { useImageViewer, type AnhXem } from '@/components/ui/use-image-viewer';
import { SectionCard } from '@/components/ui/section-card';
import { HAN_PHAN_DOI_HOURS, tinhTrangHanDap } from '@/features/disputes/dispute-constants';
import { moTaHanDap } from '@/features/disputes/dispute-labels';
import type { DisputeDetail } from '@/features/disputes/types';
import { formatDate, formatDateTime, formatMoney, formatTime } from '@/lib/format';
import { cn } from '@/lib/utils';
import { PATHS } from '@/routes/paths';

function PhotoGrid({
  urls,
  nhan,
  onXem,
  className,
}: {
  urls: string[];
  nhan: string;
  onXem: (url: string) => void;
  className?: string;
}) {
  if (urls.length === 0) return null;
  return (
    <div
      className={cn('grid gap-label', className)}
      style={{ gridTemplateColumns: `repeat(${urls.length}, minmax(0, 1fr))` }}
    >
      {urls.map((url) => (
        <button
          key={url}
          type="button"
          aria-label={nhan}
          onClick={() => onXem(url)}
          className="flex h-[84px] items-center justify-center overflow-hidden rounded-card bg-neutral-light/60"
        >
          <img src={url} alt="" className="h-full w-full object-cover" />
        </button>
      ))}
    </div>
  );
}

function OThongTin({ label, value }: { label: string; value: string | null }) {
  return (
    <div className="min-w-0">
      <p className="text-label-sm uppercase text-text-secondary">{label}</p>
      <p className="mt-text break-words text-label">{value ?? <KhongCoDuLieu />}</p>
    </div>
  );
}

export function ReporterCard({ data }: { data: DisputeDetail }) {
  const { t } = useTranslation();
  const { dispute, reporter, sitter, booking } = data;
  const xem = useImageViewer();
  const anh: AnhXem[] = dispute.evidenceUrls.map((url) => ({
    url,
    nhan: t('khieuNai.hoSo.anhNguoiBaoCao'),
  }));

  return (
    <SectionCard
      title={t('khieuNai.hoSo.noiDungPhanAnh')}
      subtitle={t('khieuNai.hoSo.noiDungPhanAnhMoTa')}
    >
      <div className="grid grid-cols-4 gap-item">
        <OThongTin label={t('khieuNai.hoSo.nguoiKhieuNai')} value={reporter.fullName} />
        <OThongTin label={t('khieuNai.hoSo.nguoiCham')} value={sitter.fullName} />
        <OThongTin label={t('khieuNai.hoSo.donLienQuan')} value={booking.code} />
        <OThongTin
          label={t('khieuNai.hoSo.hanNguoiChamDap')}
          value={
            dispute.replyDeadline
              ? `${t('khieuNai.hoSo.soGioHan', { soGio: HAN_PHAN_DOI_HOURS })}, ${moTaHanDap(
                  t,
                  dispute.replyDeadline,
                  dispute.sitterReplyAt,
                )}`
              : moTaHanDap(t, null, dispute.sitterReplyAt)
          }
        />
      </div>

      <div className="my-item h-px bg-neutral-light" />

      <p className="text-label font-normal">{dispute.description}</p>

      {dispute.evidenceUrls.length > 0 ? (
        <>
          <p className="mt-item text-caption-sm text-text-secondary">
            {t('khieuNai.hoSo.anhDinhKem', { soAnh: dispute.evidenceUrls.length })}
          </p>
          <PhotoGrid
            urls={dispute.evidenceUrls}
            nhan={t('xemAnh.moAnh')}
            onXem={(url) => xem.mo(anh.findIndex((item) => item.url === url))}
            className="mt-label"
          />
          <ImageViewer anh={anh} moTai={xem.moTai} onDong={xem.dong} />
        </>
      ) : null}
    </SectionCard>
  );
}

export function SitterReplyCard({ data }: { data: DisputeDetail }) {
  const { t } = useTranslation();
  const { dispute } = data;
  const daDap = Boolean(dispute.sitterReply && dispute.sitterReplyAt);
  const hanDap = tinhTrangHanDap(dispute);
  const xem = useImageViewer();
  const anh: AnhXem[] = dispute.sitterReplyPhotos.map((url) => ({
    url,
    nhan: t('khieuNai.hoSo.anhNguoiChamGuiKem'),
  }));

  return (
    <SectionCard
      title={t('khieuNai.hoSo.phanHoiNguoiCham')}
      subtitle={t('khieuNai.hoSo.phanHoiNguoiChamMoTa')}
    >
      <div className="mb-item h-px bg-neutral-light" />

      {daDap ? (
        <>
          <p className="text-label font-normal">{dispute.sitterReply}</p>
          <p className="mt-label text-caption-sm text-text-secondary">
            {t('khieuNai.hoSo.dapLuc', { luc: formatDateTime(dispute.sitterReplyAt as string) })}
          </p>
          {dispute.sitterReplyPhotos.length > 0 ? (
            <>
              <p className="mt-item text-caption-sm text-text-secondary">
                {t('khieuNai.hoSo.anhNguoiChamGui', { soAnh: dispute.sitterReplyPhotos.length })}
              </p>
              <PhotoGrid
                urls={dispute.sitterReplyPhotos}
                nhan={t('xemAnh.moAnh')}
                onXem={(url) => xem.mo(anh.findIndex((item) => item.url === url))}
                className="mt-label"
              />
              <ImageViewer anh={anh} moTai={xem.moTai} onDong={xem.dong} />
            </>
          ) : null}
        </>
      ) : (
        <p className="rounded-card bg-neutral-light/50 p-card text-label font-normal text-text-secondary">
          {hanDap.kieu === 'khongCoHan'
            ? t('khieuNai.hoSo.chuaDapKhongCoLuot')
            : hanDap.kieu === 'conHan'
              ? t('khieuNai.hoSo.chuaDapConHan', {
                  han: formatDateTime(dispute.replyDeadline as string),
                })
              : t('khieuNai.hoSo.chuaDapHetHan')}
        </p>
      )}
    </SectionCard>
  );
}

export function SystemEvidenceCard({ data }: { data: DisputeDetail }) {
  const { t } = useTranslation();
  const { systemEvidence, dispute } = data;
  const xem = useImageViewer();
  const anh: AnhXem[] = systemEvidence.photos.map((item) => ({
    url: item.url,
    nhan: formatDateTime(item.takenAt),
  }));

  return (
    <SectionCard
      title={t('khieuNai.hoSo.bangChungHeThong')}
      subtitle={t('khieuNai.hoSo.bangChungHeThongMoTa', { code: dispute.bookingCode })}
    >
      <div className="grid grid-cols-3 gap-item">
        <div className="min-w-0">
          <p className="flex items-center gap-label text-label-sm text-text-secondary">
            <Navigation className="h-[14px] w-[14px]" strokeWidth={1.8} />
            {t('khieuNai.hoSo.logGps')}
          </p>
          {systemEvidence.gps ? (
            <>
              <div className="mt-label flex h-[110px] items-center justify-center rounded-card bg-card-mint">
                <MapPin className="h-6 w-6 text-primary" strokeWidth={1.6} />
              </div>
              <p className="mt-label text-caption-sm text-text-secondary">
                {systemEvidence.gps.distanceFromMeetingM === null
                  ? t('khieuNai.hoSo.chuaGhiDoLech')
                  : t('khieuNai.hoSo.doLechDiemHen', {
                      met: systemEvidence.gps.distanceFromMeetingM,
                    })}
              </p>
              {systemEvidence.gps.note ? (
                <p className="mt-label text-caption-sm text-honey">
                  {systemEvidence.gps.note}
                </p>
              ) : null}
            </>
          ) : (
            <p className="mt-label text-caption-sm text-text-secondary">
              {t('khieuNai.hoSo.khongCoGps')}
            </p>
          )}
        </div>

        <div className="min-w-0">
          <p className="flex items-center gap-label text-label-sm text-text-secondary">
            <ImageIcon className="h-[14px] w-[14px]" strokeWidth={1.8} />
            {t('khieuNai.hoSo.anhNccTaiLen')}
          </p>
          {systemEvidence.photos.length === 0 ? (
            <p className="mt-label text-caption-sm text-text-secondary">
              {t('khieuNai.hoSo.chuaCoAnhHeThong')}
            </p>
          ) : null}
          <div className="mt-label grid grid-cols-2 gap-label">
            {systemEvidence.photos.map((photo, viTri) => (
              <button
                key={photo.url}
                type="button"
                aria-label={t('xemAnh.moAnh')}
                onClick={() => xem.mo(viTri)}
                className="flex flex-col items-center gap-label"
              >
                <span className="h-[110px] w-full overflow-hidden rounded-card bg-neutral-light/60">
                  <img src={photo.url} alt="" className="h-full w-full object-cover" />
                </span>
                <span className="text-caption-sm text-text-secondary">
                  {formatTime(photo.takenAt)}
                </span>
              </button>
            ))}
          </div>
          <ImageViewer anh={anh} moTai={xem.moTai} onDong={xem.dong} />
          <p className="mt-label text-caption-sm text-text-secondary">
            {t('khieuNai.hoSo.chuaCoDiemAi')}
          </p>
        </div>

        <div className="min-w-0">
          <p className="flex items-center gap-label text-label-sm text-text-secondary">
            <MessageSquare className="h-[14px] w-[14px]" strokeWidth={1.8} />
            {t('khieuNai.hoSo.hoiThoaiCuaDon')}
          </p>
          <p className="mt-label text-caption-sm text-text-secondary">
            {t('khieuNai.hoSo.hoiThoaiMoTa')}
          </p>
          <Link
            to={`${PATHS.bookings}/${dispute.bookingCode}/conversation`}
            className="mt-label inline-block text-label text-primary hover:underline"
          >
            {t('khieuNai.hoSo.moHoiThoai')}
          </Link>
        </div>
      </div>
    </SectionCard>
  );
}

export function ViolationHistoryCard({ data }: { data: DisputeDetail }) {
  const { t } = useTranslation();
  const { sitter, sitterHistory } = data;

  return (
    <SectionCard
      title={t('khieuNai.hoSo.lichSuViPham')}
      subtitle={t('khieuNai.hoSo.lichSuViPhamMoTa', {
        ten: sitter.fullName,
        soLan: sitter.violationCount6m,
      })}
    >
      {sitterHistory.length === 0 ? (
        <p className="text-label font-normal text-text-secondary">
          {t('khieuNai.hoSo.chuaCoViPhamCu')}
        </p>
      ) : (
        <ul className="flex flex-col">
          {sitterHistory.map((item, index) => (
            <li
              key={item.code}
              className={cn('py-label', index > 0 && 'border-t border-neutral-light')}
            >
              <p className="text-label">{item.title ?? t('khieuNai.hoSo.khongCoKetLuan')}</p>
              <p className="mt-text text-caption-sm text-text-secondary">
                {[
                  item.code,
                  item.resolvedAt ? formatDate(item.resolvedAt) : null,
                  (item.refundAmount ?? 0) > 0
                    ? t('khieuNai.hoSo.daHoan', {
                        tien: formatMoney(item.refundAmount as number),
                      })
                    : t('khieuNai.hoSo.khongHoan'),
                ]
                  .filter(Boolean)
                  .join(' · ')}
              </p>
            </li>
          ))}
        </ul>
      )}
    </SectionCard>
  );
}
