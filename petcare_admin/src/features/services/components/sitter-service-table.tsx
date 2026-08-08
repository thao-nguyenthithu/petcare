import { useTranslation } from 'react-i18next';
import { Check, Lock, LockOpen, Minus } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { DataTable, type Column } from '@/components/ui/data-table';
import { IconButton } from '@/components/ui/icon-button';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { FilterSelect } from '@/components/ui/filter-select';
import { SearchField } from '@/components/ui/search-field';
import type { ServiceType } from '@/features/dashboard/chart-colors';
import { tomTatBangGia } from '@/features/services/pricing-summary';
import { LIMIT_CAU_HINH } from '@/features/services/service-constants';
import type { SitterServiceRow } from '@/features/services/types';
import { formatDate } from '@/lib/format';

export function SitterServiceTable({
  rows,
  total,
  page,
  onPageChange,
  dangTai,
  loi,
  onRetry,
  keyword,
  onKeyword,
  loaiDichVu,
  onLoaiDichVu,
  dangBat,
  onDangBat,
  onXoaBoLoc,
  onKhoa,
}: {
  rows: SitterServiceRow[];
  total: number;
  page: number;
  onPageChange: (page: number) => void;
  dangTai: boolean;
  loi: boolean;
  onRetry: () => void;
  keyword: string;
  onKeyword: (value: string) => void;
  loaiDichVu: ServiceType | null;
  onLoaiDichVu: (value: ServiceType | null) => void;
  dangBat: 'true' | 'false' | null;
  onDangBat: (value: 'true' | 'false' | null) => void;
  onXoaBoLoc: () => void;
  onKhoa: (row: SitterServiceRow) => void;
}) {
  const { t } = useTranslation();

  const columns: Array<Column<SitterServiceRow>> = [
    {
      key: 'sitter',
      header: t('dichVu.cot.nguoiCham'),
      width: 176,
      cell: (row) => <span className="text-label">{row.sitterName}</span>,
    },
    {
      key: 'type',
      header: t('dichVu.cot.loai'),
      width: 138,
      cell: (row) => (
        <span className="text-label font-normal">{t(`dashboard.dichVu.${row.type}`)}</span>
      ),
    },
    {
      key: 'enabled',
      header: t('dichVu.cot.trangThai'),
      width: 116,
      cell: (row) =>
        row.enabled ? (
          <Badge tone="success" icon={Check}>
            {t('dichVu.loc.dangBat')}
          </Badge>
        ) : (
          <Badge tone="neutral" icon={Minus}>
            {t('dichVu.loc.dangTat')}
          </Badge>
        ),
    },
    {
      key: 'petKind',
      header: t('dichVu.cot.loaiThuCung'),
      width: 116,
      cell: (row) => (
        <span className="text-label font-normal">{t(`dichVu.loaiThuCung.${row.petKind}`)}</span>
      ),
    },
    {
      key: 'pricing',
      header: t('dichVu.cot.bangGia'),
      cell: (row) => {
        const tom = tomTatBangGia(t, row.pricing);
        return tom ? (
          <p className="whitespace-normal text-caption-sm text-text-secondary">{tom}</p>
        ) : (
          <KhongCoDuLieu />
        );
      },
    },
    {
      key: 'maxPets',
      header: t('dichVu.cot.soBeToiDa'),
      width: 108,
      align: 'right',
      cell: (row) =>
        row.pricing.maxPets === null ? (
          <KhongCoDuLieu />
        ) : (
          <span className="text-label font-normal">{row.pricing.maxPets}</span>
        ),
    },
    {
      key: 'updatedAt',
      header: t('dichVu.cot.capNhat'),
      width: 106,
      cell: (row) => (
        <span className="text-label font-normal text-text-secondary">
          {formatDate(row.updatedAt)}
        </span>
      ),
    },
    {
      key: 'actions',
      header: '',
      width: 60,
      align: 'right',
      isAction: true,
      cell: (row) => (
        <IconButton
          label={row.enabled ? t('dichVu.thaoTac.khoa') : t('dichVu.thaoTac.moKhoa')}
          icon={row.enabled ? Lock : LockOpen}
          onClick={() => onKhoa(row)}
        />
      ),
    },
  ];

  return (
    <div className="flex flex-col gap-item">
      <div>
        <h2 className="text-h3">{t('dichVu.cauHinh.tieuDe')}</h2>
        <p className="mt-text text-caption-sm text-text-secondary">{t('dichVu.cauHinh.moTa')}</p>
      </div>
      <DataTable
        columns={columns}
        rows={rows}
        rowKey={(row) => row.id}
        status={dangTai ? 'loading' : loi ? 'error' : 'success'}
        onRetry={onRetry}
        isFiltered={Boolean(keyword || loaiDichVu || dangBat)}
        onClearFilter={onXoaBoLoc}
        emptyMessage={t('dichVu.chuaCoCauHinh')}
        toolbar={
          <>
            <SearchField
              value={keyword}
              onChange={onKeyword}
              placeholder={t('dichVu.timKiem')}
              className="w-[300px]"
            />
            <FilterSelect
              placeholder={t('don.loc.dichVu')}
              clearLabel={t('don.loc.moiDichVu')}
              value={loaiDichVu}
              onChange={onLoaiDichVu}
              options={[
                { value: 'WALKING', label: t('dashboard.dichVu.WALKING') },
                { value: 'BOARDING', label: t('dashboard.dichVu.BOARDING') },
                { value: 'GROOMING', label: t('dashboard.dichVu.GROOMING') },
              ]}
            />
            <FilterSelect
              placeholder={t('dichVu.loc.trangThai')}
              clearLabel={t('nguoiDung.loc.moiTrangThai')}
              value={dangBat}
              onChange={onDangBat}
              options={[
                { value: 'true', label: t('dichVu.loc.dangBat') },
                { value: 'false', label: t('dichVu.loc.dangTat') },
              ]}
            />
          </>
        }
        pagination={{ page, pageSize: LIMIT_CAU_HINH, total, onPageChange }}
      />
    </div>
  );
}
