import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ExternalLink, MapPin, Navigation } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { ImageViewer } from '@/components/ui/image-viewer';
import { DongThongTin } from '@/components/ui/info-row';
import { Modal } from '@/components/ui/modal';
import { SectionCard } from '@/components/ui/section-card';
import { ServiceAreaMap } from '@/components/ui/service-area-map';
import { useImageViewer, type AnhXem } from '@/components/ui/use-image-viewer';
import { SitterStateBadge } from '@/features/sitters/components/sitter-badges';
import type { SitterDetail } from '@/features/sitters/types';
import { useOperatingSettings } from '@/features/settings/hooks/use-settings';
import { UserAvatar } from '@/features/users/components/user-badges';
import { formatDate, formatDateTime } from '@/lib/format';
import { duongBanDoOsm, duongChiDuong } from '@/lib/map-links';

const CAO_BAN_DO_LON = 420;

export function HoSoCard({ data }: { data: SitterDetail }) {
  const { t } = useTranslation();
  const s = data.sitter;
  const u = data.user;
  const xem = useImageViewer();
  const anh: AnhXem[] = u.avatarUrl ? [{ url: u.avatarUrl, nhan: u.fullName }] : [];

  return (
    <SectionCard title={t('hoSoNcc.card.hoSo')} action={<SitterStateBadge row={s} />}>
      <div className="mb-stack flex items-center gap-item">
        {u.avatarUrl ? (
          <button type="button" aria-label={t('xemAnh.moAnh')} onClick={() => xem.mo(0)}>
            <UserAvatar name={u.fullName} url={u.avatarUrl} size={44} />
          </button>
        ) : (
          <UserAvatar name={u.fullName} url={null} size={44} />
        )}
        <div className="min-w-0">
          <p className="truncate text-label">{u.fullName}</p>
          <p className="truncate text-caption-sm text-text-secondary">{u.email}</p>
        </div>
      </div>

      <ul className="flex flex-col gap-item">
        <DongThongTin label={t('hoSoNcc.truong.hoTen')} value={s.legalName} />
        <DongThongTin
          label={t('hoSoNcc.truong.gioiTinh')}
          value={s.gender ? t(`hoSoNcc.gioiTinh.${s.gender}`) : null}
        />
        <DongThongTin
          label={t('hoSoNcc.truong.ngaySinh')}
          value={s.dateOfBirth ? formatDate(s.dateOfBirth) : null}
        />
        <DongThongTin label={t('hoSoNcc.truong.soDinhDanh')} value={s.nationalId} />
        <DongThongTin label={t('hoSoNcc.truong.noiCap')} value={s.idIssuedPlace} />
        <DongThongTin
          label={t('hoSoNcc.truong.ngayCap')}
          value={s.idIssuedDate ? formatDate(s.idIssuedDate) : null}
        />
        <DongThongTin label={t('hoSoNcc.truong.dienThoai')} value={u.phone} />
        <DongThongTin label={t('hoSoNcc.truong.thuongTru')} value={s.addressDetail} />
        <DongThongTin
          label={t('hoSoNcc.truong.nopHoSo')}
          value={s.submittedAt ? formatDateTime(s.submittedAt) : null}
        />
        <DongThongTin label={t('hoSoNcc.truong.taiKhoanGoc')} value={formatDate(u.createdAt)} />
        {s.lastSupplementRequestAt ? (
          <DongThongTin
            label={t('hoSoNcc.truong.daNhanBoSung')}
            value={formatDateTime(s.lastSupplementRequestAt)}
          />
        ) : null}
      </ul>

      <ImageViewer anh={anh} moTai={xem.moTai} onDong={xem.dong} />
    </SectionCard>
  );
}

export function GiayToCard({ data }: { data: SitterDetail }) {
  const { t } = useTranslation();
  const xem = useImageViewer();
  const [daDoiChieu, setDaDoiChieu] = useState<Record<string, boolean>>({});
  const o = [
    { key: 'front', label: t('hoSoNcc.giayTo.matTruoc'), url: data.documents.frontUrl },
    { key: 'back', label: t('hoSoNcc.giayTo.matSau'), url: data.documents.backUrl },
  ];
  const anhCoThat: AnhXem[] = o
    .filter((item) => item.url)
    .map((item) => ({ url: item.url as string, nhan: item.label }));

  return (
    <SectionCard title={t('hoSoNcc.card.giayTo')} subtitle={t('hoSoNcc.giayTo.moTa')}>
      <div className="grid grid-cols-2 gap-item">
        {o.map((item) => (
          <div key={item.key} className="flex flex-col gap-label">
            <span className="text-caption-sm text-text-secondary">{item.label}</span>
            <div className="flex h-[104px] items-center justify-center overflow-hidden rounded-card border border-neutral-light bg-neutral-light/50">
              {item.url ? (
                <button
                  type="button"
                  aria-label={t('xemAnh.moAnh')}
                  onClick={() =>
                    xem.mo(anhCoThat.findIndex((a) => a.url === item.url))
                  }
                  className="h-full w-full"
                >
                  <img
                    src={item.url}
                    alt={item.label}
                    className="h-full w-full object-contain"
                  />
                </button>
              ) : (
                <span className="px-item text-center text-caption-sm text-text-secondary">
                  {t('hoSoNcc.giayTo.thieu')}
                </span>
              )}
            </div>
            <label className="flex cursor-pointer items-center gap-label text-caption-sm text-text-secondary">
              <input
                type="checkbox"
                disabled={!item.url}
                checked={Boolean(daDoiChieu[item.key])}
                onChange={(event) =>
                  setDaDoiChieu((cu) => ({ ...cu, [item.key]: event.target.checked }))
                }
                className="h-4 w-4 rounded-[4px] accent-primary disabled:opacity-40"
              />
              {t('hoSoNcc.giayTo.daDoiChieu')}
            </label>
          </div>
        ))}
      </div>
      <p className="mt-item text-caption-sm text-text-secondary">{t('hoSoNcc.giayTo.riengTu')}</p>

      <ImageViewer anh={anhCoThat} moTai={xem.moTai} onDong={xem.dong} />
    </SectionCard>
  );
}

export function VungPhucVuCard({ data }: { data: SitterDetail }) {
  const { t } = useTranslation();
  const s = data.sitter;
  const [moBanDo, setMoBanDo] = useState(false);
  const coToaDo = s.lat !== null && s.lng !== null;
  const thamSo = useOperatingSettings();
  const tran = thamSo.data?.items.find((item) => item.key === 'search.radius_max_km');

  return (
    <SectionCard
      title={t('hoSoNcc.card.vungPhucVu')}
      subtitle={
        typeof tran?.giaTri === 'number'
          ? t('hoSoNcc.vung.tranBanKinh', { km: tran.giaTri })
          : undefined
      }
    >
      <ul className="flex flex-col gap-item">
        <DongThongTin label={t('hoSoNcc.truong.diaChiLamViec')} value={s.serviceAddress} />
        <DongThongTin label={t('hoSoNcc.truong.ghiChuDiaChi')} value={s.serviceAddressNote} />
        <DongThongTin
          label={t('hoSoNcc.truong.banKinh')}
          value={s.serviceRadiusKm ? t('hoSoNcc.vung.km', { km: s.serviceRadiusKm }) : null}
        />
      </ul>

      {coToaDo ? (
        <>
          <button
            type="button"
            aria-label={t('hoSoNcc.vung.moBanDoLon')}
            onClick={() => setMoBanDo(true)}
            className="mt-stack block w-full"
          >
            <ServiceAreaMap
              lat={s.lat as number}
              lng={s.lng as number}
              banKinhKm={s.serviceRadiusKm}
              nhan={t('hoSoNcc.vung.banDoTieuDe')}
            />
          </button>
          <p className="mt-label text-caption-sm text-text-secondary">
            {t('hoSoNcc.vung.bamDeXemLon')}
          </p>
        </>
      ) : (
        <div className="mt-stack flex h-[132px] items-center justify-center gap-label rounded-card bg-neutral-light/50 text-caption-sm text-text-secondary">
          <MapPin className="h-4 w-4" strokeWidth={1.8} />
          {t('hoSoNcc.vung.chuaCoToaDo')}
        </div>
      )}

      <Modal
        open={moBanDo}
        onOpenChange={setMoBanDo}
        title={t('hoSoNcc.vung.banDoTieuDe')}
        description={s.serviceAddress ?? undefined}
        className="w-[min(860px,calc(100vw-48px))]"
      >
        {coToaDo ? (
          <div className="flex flex-col gap-item">
            <ServiceAreaMap
              lat={s.lat as number}
              lng={s.lng as number}
              banKinhKm={s.serviceRadiusKm}
              chieuCao={CAO_BAN_DO_LON}
              tuongTac
              nhan={t('hoSoNcc.vung.banDoTuongTac')}
            />
            <ul className="flex flex-col gap-label">
              <DongThongTin label={t('hoSoNcc.truong.diaChiLamViec')} value={s.serviceAddress} />
              <DongThongTin label={t('hoSoNcc.vung.toaDo')} value={`${s.lat}, ${s.lng}`} />
              <DongThongTin
                label={t('hoSoNcc.truong.banKinh')}
                value={
                  s.serviceRadiusKm ? t('hoSoNcc.vung.km', { km: s.serviceRadiusKm }) : null
                }
              />
            </ul>
            <div className="flex flex-wrap gap-item">
              <Button asChild size="sm">
                <a
                  href={duongChiDuong(s.lat as number, s.lng as number)}
                  target="_blank"
                  rel="noreferrer"
                >
                  <Navigation className="h-4 w-4" strokeWidth={1.8} />
                  {t('hoSoNcc.vung.chiDuong')}
                </a>
              </Button>
              <Button asChild variant="secondary" size="sm">
                <a
                  href={duongBanDoOsm(s.lat as number, s.lng as number)}
                  target="_blank"
                  rel="noreferrer"
                >
                  <ExternalLink className="h-4 w-4" strokeWidth={1.8} />
                  {t('hoSoNcc.vung.moBanDoNgoai')}
                </a>
              </Button>
            </div>
          </div>
        ) : null}
      </Modal>
    </SectionCard>
  );
}
