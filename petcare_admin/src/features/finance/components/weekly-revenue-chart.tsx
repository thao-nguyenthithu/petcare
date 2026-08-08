import { useTranslation } from 'react-i18next';
import { REVENUE_COLORS } from '@/features/dashboard/chart-colors';
import type { FinanceSummary } from '@/features/finance/types';

const CHIEU_CAO_COT = 196;
const MOT_TRIEU = 1_000_000;

export function WeeklyRevenueChart({ data }: { data: FinanceSummary['byWeek'] }) {
  const { t } = useTranslation();
  const lonNhat = Math.max(...data.map((item) => item.sitterPayout + item.platformFee), 0);

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
    <div className="flex items-end gap-stack" style={{ height: CHIEU_CAO_COT + 24 }}>
      {data.map((item) => {
        const tong = item.sitterPayout + item.platformFee;
        const caoCot = (tong / lonNhat) * CHIEU_CAO_COT;
        const caoHoaHong = tong === 0 ? 0 : (item.platformFee / tong) * caoCot;
        return (
          <div key={item.label} className="flex flex-1 flex-col items-center gap-label">
            <div
              className="flex w-full max-w-[34px] flex-col justify-end overflow-hidden rounded-t-[6px]"
              style={{ height: caoCot }}
              title={t('chung.soTrieu', { value: Math.round(tong / MOT_TRIEU) })}
            >
              <div style={{ flex: 1, backgroundColor: REVENUE_COLORS.sitterPayout }} />
              <div style={{ height: caoHoaHong, backgroundColor: REVENUE_COLORS.platformFee }} />
            </div>
            <span className="text-caption-sm text-text-secondary">{item.label}</span>
          </div>
        );
      })}
    </div>
  );
}
