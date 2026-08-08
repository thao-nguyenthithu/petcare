import { useTranslation } from 'react-i18next';
import { Footprints, Home, Pencil, Scissors } from 'lucide-react';
import type { LucideIcon } from 'lucide-react';
import { DataTable, type Column } from '@/components/ui/data-table';
import { IconButton } from '@/components/ui/icon-button';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import type { ServiceType } from '@/features/dashboard/chart-colors';
import type { ServiceRow } from '@/features/services/types';

const ICON_DICH_VU: Record<ServiceType, LucideIcon> = {
  WALKING: Footprints,
  BOARDING: Home,
  GROOMING: Scissors,
};

export function ServiceCatalogTable({
  rows,
  dangTai,
  loi,
  onRetry,
  onSua,
}: {
  rows: ServiceRow[];
  dangTai: boolean;
  loi: boolean;
  onRetry: () => void;
  onSua: (row: ServiceRow) => void;
}) {
  const { t } = useTranslation();

  const columns: Array<Column<ServiceRow>> = [
    {
      key: 'type',
      header: t('dichVu.cot.loai'),
      width: 300,
      cell: (row) => {
        const Icon = ICON_DICH_VU[row.type];
        return (
          <div className="flex min-w-0 items-center gap-item">
            <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-card bg-card-mint">
              <Icon className="h-[18px] w-[18px] text-primary" strokeWidth={1.8} />
            </span>
            <p className="truncate text-label">{row.name ?? t(`dashboard.dichVu.${row.type}`)}</p>
          </div>
        );
      },
    },
    {
      key: 'description',
      header: t('dichVu.cot.moTa'),
      cell: (row) =>
        row.description ? (
          <p className="whitespace-normal text-caption-sm text-text-secondary">
            {row.description}
          </p>
        ) : (
          <KhongCoDuLieu />
        ),
    },
    {
      key: 'sitters',
      header: t('dichVu.cot.nccDangBat'),
      width: 172,
      align: 'right',
      cell: (row) => <span className="text-label font-normal">{row.enabledSitterCount}</span>,
    },
    {
      key: 'actions',
      header: '',
      width: 60,
      align: 'right',
      isAction: true,
      cell: (row) => (
        <IconButton
          label={t('dichVu.thaoTac.sua')}
          icon={Pencil}
          bordered
          onClick={() => onSua(row)}
        />
      ),
    },
  ];

  return (
    <div className="flex flex-col gap-item">
      <div>
        <h2 className="text-h3">{t('dichVu.danhMuc.tieuDe')}</h2>
        <p className="mt-text text-caption-sm text-text-secondary">{t('dichVu.danhMuc.moTa')}</p>
      </div>
      <DataTable
        columns={columns}
        rows={rows}
        rowKey={(row) => row.type}
        status={dangTai ? 'loading' : loi ? 'error' : 'success'}
        onRetry={onRetry}
      />
    </div>
  );
}
