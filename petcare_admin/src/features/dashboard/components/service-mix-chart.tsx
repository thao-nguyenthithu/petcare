import { useTranslation } from 'react-i18next';
import { SERVICE_MIX_COLORS, SERVICE_TYPES } from '@/features/dashboard/chart-colors';
import type { DashboardData } from '@/features/dashboard/types';

const KICH_THUOC = 148;
const DAY_VANH = 20;
const BAN_KINH = (KICH_THUOC - DAY_VANH) / 2;
const CHU_VI = 2 * Math.PI * BAN_KINH;

type ServiceMixChartProps = { data: DashboardData['serviceMix'] };

export function ServiceMixChart({ data }: ServiceMixChartProps) {
  const { t } = useTranslation();

  const lat = SERVICE_TYPES.map((type) => data.find((item) => item.type === type)).filter(
    (item) => item !== undefined,
  );
  const tong = lat.reduce((sum, item) => sum + item.count, 0);

  if (tong === 0) {
    return (
      <p className="py-block text-center text-body text-text-secondary">
        {t('dashboard.chuaCoDuLieu')}
      </p>
    );
  }

  const latCoOffset = lat.map((item, index) => ({
    ...item,
    phan: item.count / tong,
    daVe: lat.slice(0, index).reduce((sum, truoc) => sum + truoc.count, 0) / tong,
  }));

  return (
    <div className="flex items-center gap-group">
      <div className="relative shrink-0" style={{ width: KICH_THUOC, height: KICH_THUOC }}>
        <svg width={KICH_THUOC} height={KICH_THUOC} viewBox={`0 0 ${KICH_THUOC} ${KICH_THUOC}`}>
          <g transform={`rotate(-90 ${KICH_THUOC / 2} ${KICH_THUOC / 2})`}>
            {latCoOffset.map((item) => {
              const dash = item.phan * CHU_VI;
              const offset = -item.daVe * CHU_VI;
              return (
                <circle
                  key={item.type}
                  cx={KICH_THUOC / 2}
                  cy={KICH_THUOC / 2}
                  r={BAN_KINH}
                  fill="none"
                  stroke={SERVICE_MIX_COLORS[item.type]}
                  strokeWidth={DAY_VANH}
                  strokeDasharray={`${dash} ${CHU_VI - dash}`}
                  strokeDashoffset={offset}
                />
              );
            })}
          </g>
        </svg>
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span className="text-h2">{new Intl.NumberFormat('vi-VN').format(tong)}</span>
          <span className="text-caption-sm text-text-secondary">{t('dashboard.don')}</span>
        </div>
      </div>

      <ul className="flex min-w-0 flex-col gap-item">
        {lat.map((item) => (
          <li key={item.type} className="flex items-start gap-label">
            <span
              className="mt-[5px] h-[10px] w-[10px] shrink-0 rounded-[3px]"
              style={{ backgroundColor: SERVICE_MIX_COLORS[item.type] }}
            />
            <div className="min-w-0">
              <p className="truncate text-label">{t(`dashboard.dichVu.${item.type}`)}</p>
              <p className="truncate text-caption-sm text-text-secondary">
                {t('dashboard.donVaPhanTram', {
                  count: item.count,
                  percent: new Intl.NumberFormat('vi-VN').format(item.percent),
                })}
              </p>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
