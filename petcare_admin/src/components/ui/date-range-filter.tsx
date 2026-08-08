import { useTranslation } from 'react-i18next';
import { FilterSelect } from '@/components/ui/filter-select';
import type { KhoangNgay } from '@/lib/use-date-range';

type DateRangeFilterProps = {
  value: KhoangNgay | null;
  onChange: (value: KhoangNgay | null) => void;
  placeholder?: string;
};

export function DateRangeFilter({ value, onChange, placeholder }: DateRangeFilterProps) {
  const { t } = useTranslation();

  return (
    <FilterSelect
      placeholder={placeholder ?? t('don.loc.khoangNgay')}
      clearLabel={t('nguoiDung.loc.moiThoiGian')}
      value={value}
      onChange={onChange}
      options={[
        { value: '7', label: t('nguoiDung.loc.bayNgay') },
        { value: '30', label: t('nguoiDung.loc.baMuoiNgay') },
        { value: '90', label: t('nguoiDung.loc.chinMuoiNgay') },
      ]}
    />
  );
}
