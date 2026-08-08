import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { Eye, Images } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { CountTabs } from '@/components/ui/count-tabs';
import { DataTable, type Column } from '@/components/ui/data-table';
import { FilterSelect } from '@/components/ui/filter-select';
import { IconButton } from '@/components/ui/icon-button';
import { SearchField } from '@/components/ui/search-field';
import { bookingsApi } from '@/features/bookings/api/bookings-api';
import { AdminBookingStatusBadge } from '@/features/bookings/components/booking-status-badge';
import { THU_TU_TAB } from '@/features/bookings/booking-constants';
import { dungTabs } from '@/lib/tab-list';
import { nhanThoiLuong } from '@/lib/labels';
import { trangThaiBang } from '@/lib/table-status';
import { useCsvExport } from '@/lib/use-csv-export';
import { useBookingTabCounts, useBookings } from '@/features/bookings/hooks/use-bookings';
import type { AdminBookingRow, BookingListQuery, BookingTabKey } from '@/features/bookings/types';
import type { ServiceType } from '@/features/dashboard/chart-colors';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { DateRangeFilter } from '@/components/ui/date-range-filter';
import { useListPaging } from '@/lib/use-list-paging';
import { useDateRange } from '@/lib/use-date-range';
import { formatDate, formatMoney, formatTime } from '@/lib/format';
import { PATHS } from '@/routes/paths';

const LIMIT = 10;

export function BookingsScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [tab, setTab] = useState<BookingTabKey>('all');
  const [keyword, setKeyword] = useState('');
  const [serviceType, setServiceType] = useState<ServiceType | null>(null);
  const { khoangNgay, tuNgay, chon: chonKhoangNgay, xoa: xoaKhoangNgay } = useDateRange();
  const { page, setPage, doiBoLoc, phanTrang } = useListPaging(LIMIT);

  const counts = useBookingTabCounts();

  const query = useMemo<BookingListQuery>(
    () => ({
      q: keyword || undefined,
      tab: tab === 'all' ? undefined : tab,
      serviceType: serviceType ?? undefined,
      from: tuNgay,
      page,
      limit: LIMIT,
    }),
    [tab, keyword, serviceType, tuNgay, page],
  );

  const danhSach = useBookings(query);
  const coBoLoc = Boolean(keyword || serviceType || khoangNgay);
  const csv = useCsvExport();

  const xuatCsv = () =>
    void csv.xuat<AdminBookingRow>({
      tai: (trang, limit) => bookingsApi.getBookings({ ...query, page: trang, limit }),
      tenFile: `don-${tab}.csv`,
      tieuDe: [
        t('don.csv.maDon'),
        t('don.csv.chuNuoi'),
        t('don.csv.nguoiCham'),
        t('don.csv.dichVu'),
        t('don.csv.loaiDichVu'),
        t('don.csv.batDau'),
        t('don.csv.ketThuc'),
        t('don.csv.giaTri'),
        t('don.csv.trangThai'),
        t('don.csv.taoLuc'),
      ],
      dong: (row) => [
        row.code,
        row.ownerName,
        row.sitterName,
        row.serviceName,
        row.serviceType,
        row.scheduledAt,
        row.scheduledEndAt,
        row.totalPrice,
        row.status,
        row.createdAt,
      ],
    });

  const xoaBoLoc = () => {
    setKeyword('');
    setServiceType(null);
    xoaKhoangNgay();
    setPage(1);
  };

  const tabs = dungTabs(THU_TU_TAB, (key) => t(`don.tab.${key}`), counts.data);

  const columns: Array<Column<AdminBookingRow>> = [
    {
      key: 'code',
      header: t('don.cot.maDon'),
      width: 112,
      cell: (row) => <span className="text-label text-primary">{row.code}</span>,
    },
    {
      key: 'owner',
      header: t('don.cot.chuNuoi'),
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.ownerName}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {row.petNames.join(', ')}
          </p>
        </div>
      ),
    },
    {
      key: 'sitter',
      header: t('don.cot.nhaCungCap'),
      width: 168,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.sitterName}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {row.sitterRating > 0
              ? t('don.diemSao', { value: row.sitterRating.toFixed(1) })
              : t('don.chuaCoDanhGia')}
          </p>
        </div>
      ),
    },
    {
      key: 'service',
      header: t('don.cot.dichVu'),
      width: 140,
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
      key: 'schedule',
      header: t('don.cot.lichHen'),
      width: 132,
      cell: (row) => <LichHen row={row} />,
    },
    {
      key: 'price',
      header: t('don.cot.giaTri'),
      width: 112,
      align: 'right',
      cell: (row) =>
        row.totalPrice === null ? (
          <KhongCoDuLieu />
        ) : (
          <span className="text-label">{formatMoney(row.totalPrice)}</span>
        ),
    },
    {
      key: 'status',
      header: t('don.cot.trangThai'),
      width: 160,
      cell: (row) => <AdminBookingStatusBadge status={row.status} />,
    },
    {
      key: 'actions',
      header: '',
      width: 84,
      align: 'right',
      isAction: true,
      cell: (row) => (
        <div className="flex items-center justify-end gap-text">
          <IconButton
            label={t('don.thaoTac.xemChiTiet')}
            icon={Eye}
            onClick={() => void navigate(`${PATHS.bookings}/${row.code}`)}
          />
          <IconButton
            label={t('don.thaoTac.xemAnh')}
            icon={Images}
            onClick={() => void navigate(`${PATHS.evidence}/${row.code}`)}
          />
        </div>
      ),
    },
  ];

  return (
    <div className="flex flex-col gap-stack pb-block">
      <CountTabs
        tabs={tabs}
        value={tab}
        onChange={(key) => doiBoLoc(() => setTab(key))}
        className="flex-wrap rounded-card bg-neutral-light/50 p-text"
      />

      <DataTable
        columns={columns}
        rows={danhSach.data?.items ?? []}
        rowKey={(row) => row.code}
        status={trangThaiBang(danhSach)}
        onRetry={() => void danhSach.refetch()}
        onRowClick={(row) => void navigate(`${PATHS.bookings}/${row.code}`)}
        isFiltered={coBoLoc}
        onClearFilter={xoaBoLoc}
        emptyMessage={t('don.chuaCoDon')}
        toolbar={
          <>
            <SearchField
              value={keyword}
              onChange={(value) => doiBoLoc(() => setKeyword(value))}
              placeholder={t('don.timKiem')}
              className="w-[292px]"
            />
            <FilterSelect
              placeholder={t('don.loc.dichVu')}
              clearLabel={t('don.loc.moiDichVu')}
              value={serviceType}
              onChange={(value) => doiBoLoc(() => setServiceType(value))}
              options={[
                { value: 'WALKING', label: t('dashboard.dichVu.WALKING') },
                { value: 'BOARDING', label: t('dashboard.dichVu.BOARDING') },
                { value: 'GROOMING', label: t('dashboard.dichVu.GROOMING') },
              ]}
            />
            <DateRangeFilter
              value={khoangNgay}
              onChange={(value) => doiBoLoc(() => chonKhoangNgay(value))}
            />
          </>
        }
        toolbarActions={
          <Button variant="secondary" size="sm" onClick={xuatCsv} loading={csv.dangXuat}>
            {t('don.xuatCsv')}
          </Button>
        }
        pagination={phanTrang(danhSach.data?.total)}
      />

      <p className="rounded-card bg-neutral-light/50 p-card text-caption-sm text-text-secondary">
        {t('don.ghiChuEnum')}
      </p>
    </div>
  );
}

function LichHen({ row }: { row: AdminBookingRow }) {
  const { t } = useTranslation();
  if (row.serviceType === 'BOARDING') {
    return (
      <div className="min-w-0">
        <p className="truncate text-label">
          {formatDate(row.scheduledAt).slice(0, 5)}
          {row.scheduledEndAt ? ` - ${formatDate(row.scheduledEndAt).slice(0, 5)}` : ''}
        </p>
        <p className="truncate text-caption-sm text-text-secondary">
          {t('don.nhanLuc', { time: formatTime(row.scheduledAt) })}
        </p>
      </div>
    );
  }
  return (
    <div className="min-w-0">
      <p className="truncate text-label">{formatDate(row.scheduledAt)}</p>
      <p className="truncate text-caption-sm text-text-secondary">
        {formatTime(row.scheduledAt)}
        {row.scheduledEndAt ? ` - ${formatTime(row.scheduledEndAt)}` : ''}
      </p>
    </div>
  );
}
