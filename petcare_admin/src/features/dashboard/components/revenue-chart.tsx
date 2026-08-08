import { useTranslation } from 'react-i18next';
import { REVENUE_COLORS } from '@/features/dashboard/chart-colors';
import type { DashboardData } from '@/features/dashboard/types';

const CHIEU_CAO_COT = 172;
const MOT_TRIEU = 1_000_000;

type RevenueChartProps = { data: DashboardData['revenueByMonth'] };

export function RevenueChart({ data }: RevenueChartProps) {
  const { t } = useTranslation();
  const cao = data.map((item) => item.sitterPayout + item.platformFee);
  const lonNhat = Math.max(...cao, 0);

  if (lonNhat === 0) {
    return (
      <div className="flex flex-col justify-end" style={{ height: CHIEU_CAO_COT + 24 }}>
        <p className="pb-block text-center text-body text-text-secondary">
          {t('dashboard.chuaCoDuLieu')}
        </p>
        <div className="border-t border-neutral-light" />
      </div>
    );
  }

  return (
    <div className="flex items-end gap-item" style={{ height: CHIEU_CAO_COT + 24 }}>
      {data.map((item) => {
        const tong = item.sitterPayout + item.platformFee;
        const caoCot = (tong / lonNhat) * CHIEU_CAO_COT;
        const caoHoaHong = tong === 0 ? 0 : (item.platformFee / tong) * caoCot;
        return (
          <div key={item.month} className="flex flex-1 flex-col items-center gap-label">
            <div
              className="flex w-full max-w-[26px] flex-col justify-end overflow-hidden rounded-t-[6px]"
              style={{ height: caoCot }}
              title={t('chung.soTrieu', { value: Math.round(tong / MOT_TRIEU) })}
            >
              <div style={{ flex: 1, backgroundColor: REVENUE_COLORS.sitterPayout }} />
              <div style={{ height: caoHoaHong, backgroundColor: REVENUE_COLORS.platformFee }} />
            </div>
            <span className="text-caption-sm text-text-secondary">T{item.month}</span>
          </div>
        );
      })}
    </div>
  );
}

export function RevenueLegend() {
  const { t } = useTranslation();
  const muc = [
    { color: REVENUE_COLORS.sitterPayout, label: t('dashboard.nccThucNhan') },
    { color: REVENUE_COLORS.platformFee, label: t('dashboard.hoaHongNenTang') },
  ];
  return (
    <div className="flex items-center gap-stack">
      {muc.map((item) => (
        <span key={item.label} className="flex items-center gap-label text-caption-sm">
          <span
            className="h-[10px] w-[10px] rounded-[3px]"
            style={{ backgroundColor: item.color }}
          />
          {item.label}
        </span>
      ))}
    </div>
  );
}
