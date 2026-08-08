import { useTranslation } from 'react-i18next';
import { DataTable, type Column } from '@/components/ui/data-table';
import { danhSachRangBuoc } from '@/features/services/pricing-summary';
import type { ServiceConstraintRow } from '@/features/services/types';

export function ServiceConstraintsTable({
  rows,
  dangTai,
  loi,
  onRetry,
}: {
  rows: ServiceConstraintRow[];
  dangTai: boolean;
  loi: boolean;
  onRetry: () => void;
}) {
  const { t } = useTranslation();

  const columns: Array<Column<ServiceConstraintRow>> = [
    {
      key: 'name',
      header: t('dichVu.cot.hangSo'),
      width: 300,
      cell: (row) => (
        <span className="text-label">
          {t(`dichVu.rangBuoc.${row.code}.ten`, { defaultValue: row.code })}
        </span>
      ),
    },
    {
      key: 'value',
      header: t('dichVu.cot.giaTri'),
      width: 300,
      cell: (row) => (
        <span className="text-label font-normal">
          {t(`dichVu.rangBuoc.${row.code}.giaTri`, {
            defaultValue: '{{list}}',
            list: danhSachRangBuoc(t, row.numbers, row.keys),
            min: row.numbers[0],
            max: row.numbers[1],
            step: row.numbers[2],
          })}
        </span>
      ),
    },
    {
      key: 'effect',
      header: t('dichVu.cot.anhHuong'),
      cell: (row) => (
        <p className="whitespace-normal text-caption-sm text-text-secondary">
          {t(`dichVu.rangBuoc.${row.code}.anhHuong`, { defaultValue: '' })}
        </p>
      ),
    },
  ];

  return (
    <div className="flex flex-col gap-item">
      <div>
        <h2 className="text-h3">{t('dichVu.hangSo.tieuDe')}</h2>
        <p className="mt-text text-caption-sm text-text-secondary">{t('dichVu.hangSo.moTa')}</p>
      </div>
      <DataTable
        columns={columns}
        rows={rows}
        rowKey={(row) => row.code}
        status={dangTai ? 'loading' : loi ? 'error' : 'success'}
        onRetry={onRetry}
      />
    </div>
  );
}
