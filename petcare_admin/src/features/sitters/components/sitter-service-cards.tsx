import { useTranslation } from 'react-i18next';
import { Badge } from '@/components/ui/badge';
import { DongThongTin } from '@/components/ui/info-row';
import { SectionCard } from '@/components/ui/section-card';
import { EmptyState } from '@/components/state/empty-state';
import {
  BAC_CAN,
  GOI_GROOMING,
  SO_LAN_TAM_AN_KHOA,
  THANG_DEM_LAN_TAM_AN,
} from '@/features/sitters/sitter-constants';
import type { ServicePricing } from '@/features/services/types';
import type { SitterDetail } from '@/features/sitters/types';
import { formatDate, formatDateTime, formatMoney, formatPercent } from '@/lib/format';

type DongGia = { label: string; value: string };
type Dich = ReturnType<typeof useTranslation>['t'];

function soDuong(gia: number | null): number | null {
  return gia !== null && gia > 0 ? gia : null;
}

function traO(bang: Record<string, number>, khoa: string): number | undefined {
  return bang[khoa];
}

function traBang(
  bang: Record<string, Record<string, number>>,
  khoa: string,
): Record<string, number> {
  return bang[khoa] ?? {};
}

function dongDat(pricing: Extract<ServicePricing, { type: 'WALKING' }>, t: Dich): DongGia[] {
  return Object.entries(pricing.priceByDuration).map(([phut, gia]) => ({
    label: t('hoSoNcc.gia.theoPhut', { phut }),
    value: formatMoney(gia),
  }));
}

function dongTrongGiu(pricing: Extract<ServicePricing, { type: 'BOARDING' }>, t: Dich): DongGia[] {
  const dong: DongGia[] = [];
  const moiDem = soDuong(pricing.pricePerDay);
  if (moiDem !== null) {
    dong.push({ label: t('hoSoNcc.gia.moiDem'), value: formatMoney(moiDem) });
  }
  const sucChua = soDuong(pricing.capacity);
  if (sucChua !== null) {
    dong.push({
      label: t('hoSoNcc.gia.sucChua'),
      value: t('hoSoNcc.gia.soBe', { count: sucChua }),
    });
  }
  return dong;
}

function dongGrooming(pricing: Extract<ServicePricing, { type: 'GROOMING' }>, t: Dich): DongGia[] {
  const dong: DongGia[] = [];
  for (const goi of GOI_GROOMING) {
    const theoBac = traBang(pricing.priceByPackage, goi);
    const phutTheoBac = traBang(pricing.durationByPackage, goi);
    for (const bac of BAC_CAN) {
      const gia = traO(theoBac, bac);
      if (gia === undefined) continue;
      const phut = traO(phutTheoBac, bac);
      dong.push({
        label: t('hoSoNcc.gia.goiVaCan', {
          goi: t(`hoSoNcc.gia.goi.${goi}`),
          can: t(`hoSoNcc.gia.can.${bac}`),
        }),
        value:
          phut === undefined
            ? formatMoney(gia)
            : t('hoSoNcc.gia.giaKemPhut', { gia: formatMoney(gia), phut }),
      });
    }
  }
  return dong;
}

function dongGia(pricing: ServicePricing, t: Dich): DongGia[] {
  const dong =
    pricing.type === 'WALKING'
      ? dongDat(pricing, t)
      : pricing.type === 'BOARDING'
        ? dongTrongGiu(pricing, t)
        : dongGrooming(pricing, t);
  if (pricing.type !== 'GROOMING') {
    const beThem = soDuong(pricing.additionalPetFee);
    if (beThem !== null) {
      dong.push({ label: t('hoSoNcc.gia.beThem'), value: formatMoney(beThem) });
    }
  }
  const toiDaBe = soDuong(pricing.maxPets);
  if (toiDaBe !== null) {
    dong.push({
      label: t('hoSoNcc.gia.toiDaBe'),
      value: t('hoSoNcc.gia.soBe', { count: toiDaBe }),
    });
  }
  return dong;
}

export function DichVuCard({ data }: { data: SitterDetail }) {
  const { t } = useTranslation();

  return (
    <SectionCard title={t('hoSoNcc.card.dichVu')} subtitle={t('hoSoNcc.gia.moTaThamKhao')}>
      {data.services.length === 0 ? (
        <EmptyState message={t('hoSoNcc.gia.chuaDangKy')} />
      ) : (
        <ul className="flex flex-col gap-item">
          {data.services.map((service) => (
            <li key={service.type} className="rounded-card border border-neutral-light p-item">
              <div className="flex items-center justify-between gap-item">
                <p className="truncate text-label">{t(`dashboard.dichVu.${service.type}`)}</p>
                <div className="flex shrink-0 items-center gap-label">
                  <Badge tone="neutral">{t(`hoSoNcc.loaiThuCung.${service.petKind}`)}</Badge>
                  <Badge tone={service.enabled ? 'success' : 'neutral'}>
                    {t(service.enabled ? 'hoSoNcc.gia.dangBat' : 'hoSoNcc.gia.dangTat')}
                  </Badge>
                </div>
              </div>
              <ul className="mt-label flex flex-col gap-text">
                {dongGia(service.pricing, t).map((item) => (
                  <li key={item.label} className="flex items-baseline justify-between gap-item">
                    <span className="shrink-0 text-caption-sm text-text-secondary">
                      {item.label}
                    </span>
                    <span className="min-w-0 truncate text-label">{item.value}</span>
                  </li>
                ))}
              </ul>
            </li>
          ))}
        </ul>
      )}
    </SectionCard>
  );
}

export function KyLuatCard({ data }: { data: SitterDetail }) {
  const { t } = useTranslation();
  const s = data.sitter;

  return (
    <SectionCard
      title={t('hoSoNcc.card.kyLuat')}
      action={
        <Badge
          tone={
            data.stats.cancelRate !== null && data.stats.cancelRate >= 0.2 ? 'danger' : 'neutral'
          }
        >
          {data.stats.cancelRate === null
            ? t('hoSoNcc.kyLuat.tyLeHuyChuaDuMau')
            : t('hoSoNcc.kyLuat.tyLeHuy', {
                value: formatPercent(data.stats.cancelRate * 100, 0),
              })}
        </Badge>
      }
    >
      <ul className="mb-stack flex flex-col gap-item">
        <DongThongTin
          label={t('hoSoNcc.kyLuat.soLanTamAn', { thang: THANG_DEM_LAN_TAM_AN })}
          value={t('hoSoNcc.kyLuat.lanTrenNguong', {
            lan: s.hiddenTimesInWindow,
            nguong: SO_LAN_TAM_AN_KHOA,
          })}
        />
        <DongThongTin label={t('hoSoNcc.kyLuat.soLanTamAnTronDoi')} value={String(s.hiddenCount)} />
        <DongThongTin
          label={t('hoSoNcc.kyLuat.hetTamAn')}
          value={s.hiddenUntil ? formatDateTime(s.hiddenUntil) : null}
        />
        <DongThongTin
          label={t('hoSoNcc.kyLuat.soDonHoanThanh')}
          value={String(data.stats.bookingCount)}
        />
      </ul>

      {data.penalties.length === 0 ? (
        <EmptyState message={t('hoSoNcc.kyLuat.chuaCoGhi')} />
      ) : (
        <ul className="flex flex-col gap-label">
          {data.penalties.map((item) => (
            <li key={item.id} className="rounded-card border border-neutral-light p-item">
              <div className="flex items-center justify-between gap-item">
                <p className="truncate text-label">{t(`kyLuat.loai.${item.kind}`)}</p>
                <Badge tone={item.status === 'WAIVED' ? 'success' : 'pending'}>
                  {t(`kyLuat.trangThai.${item.status}`)}
                </Badge>
              </div>
              <p className="mt-text text-caption-sm text-text-secondary">
                {[item.reason, item.bookingCode, formatDate(item.createdAt)]
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
