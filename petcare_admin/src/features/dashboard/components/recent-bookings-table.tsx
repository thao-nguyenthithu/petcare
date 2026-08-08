import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { AdminBookingStatusBadge } from '@/features/bookings/components/booking-status-badge';
import type { RecentBooking } from '@/features/dashboard/types';
import { DataTable, type Column } from '@/components/ui/data-table';
import { formatMoney } from '@/lib/format';
import { nhanThoiLuong } from '@/lib/labels';
import { PATHS } from '@/routes/paths';

type RecentBookingsTableProps = {
  rows: RecentBooking[];
  status: 'loading' | 'error' | 'success';
  onRetry: () => void;
};

export function RecentBookingsTable({ rows, status, onRetry }: RecentBookingsTableProps) {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const columns: Array<Column<RecentBooking>> = [
    {
      key: 'code',
      header: t('dashboard.cot.maDon'),
      width: 116,
      cell: (row) => <span className="text-label text-primary">{row.code}</span>,
    },
    {
      key: 'owner',
      header: t('dashboard.cot.chuNuoi'),
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.ownerName}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {row.ownerPhone ?? t('chung.khongCoDuLieu')}
          </p>
        </div>
      ),
    },
    {
      key: 'service',
      header: t('dashboard.cot.dichVu'),
      width: 148,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.serviceName}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {nhanThoiLuong(t, row.durationMinutes) ?? ''}
          </p>
        </div>
      ),
    },
    {
      key: 'status',
      header: t('dashboard.cot.trangThai'),
      width: 176,
      cell: (row) => <AdminBookingStatusBadge status={row.status} />,
    },
    {
      key: 'price',
      header: t('dashboard.cot.giaTri'),
      width: 116,
      align: 'right',
      cell: (row) => (
        <span className="text-label">
          {row.totalPrice === null ? t('chung.khongCoDuLieu') : formatMoney(row.totalPrice)}
        </span>
      ),
    },
  ];

  return (
    <DataTable
      columns={columns}
      rows={rows}
      rowKey={(row) => row.code}
      status={status}
      onRetry={onRetry}
      onRowClick={(row) => void navigate(`${PATHS.bookings}/${row.code}`)}
      emptyMessage={t('dashboard.chuaCoDon')}
      className="border-0"
    />
  );
}
