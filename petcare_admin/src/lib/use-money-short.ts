import { useTranslation } from 'react-i18next';
import { formatMoney } from '@/lib/format';

const NF = new Intl.NumberFormat('vi-VN', { maximumFractionDigits: 2 });

export function useMoneyShort() {
  const { t } = useTranslation();
  return (value: number): string => {
    if (Math.abs(value) >= 1_000_000) return t('chung.soTrieu', { value: NF.format(value / 1e6) });
    if (Math.abs(value) >= 1_000) return t('chung.soNghin', { value: NF.format(value / 1e3) });
    return formatMoney(value);
  };
}
