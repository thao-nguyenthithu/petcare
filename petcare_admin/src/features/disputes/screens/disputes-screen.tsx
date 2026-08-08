import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { Clock, Eye, Images, MessageSquare, ShieldAlert } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { CountTabs } from '@/components/ui/count-tabs';
import { DataTable, type Column } from '@/components/ui/data-table';
import { FilterSelect } from '@/components/ui/filter-select';
import { IconButton } from '@/components/ui/icon-button';
import { SearchField } from '@/components/ui/search-field';
import { disputesApi } from '@/features/disputes/api/disputes-api';
import {
  ConclusionDeadlineBadge,
  DisputeStatusBadge,
  ReplyDeadlineBadge,
} from '@/features/disputes/components/dispute-badges';
import {
  THU_TU_TAB,
  tinhTrangHanKetLuan,
  tinhTrangHienThi,
} from '@/features/disputes/dispute-constants';
import {
  useDisputeTabCounts,
  useDisputes,
  useHanKetLuanNgay,
} from '@/features/disputes/hooks/use-disputes';
import type {
  AdminDisputeRow,
  DisputeListQuery,
  DisputeStatus,
  DisputeTabKey,
} from '@/features/disputes/types';
import type { ServiceType } from '@/features/dashboard/chart-colors';
import { UserAvatar } from '@/features/users/components/user-badges';
import { formatDate } from '@/lib/format';
import { dungTabs } from '@/lib/tab-list';
import { trangThaiBang } from '@/lib/table-status';
import { useCsvExport } from '@/lib/use-csv-export';
import { DateRangeFilter } from '@/components/ui/date-range-filter';
import { useListPaging } from '@/lib/use-list-paging';
import { useDateRange } from '@/lib/use-date-range';
import { PATHS } from '@/routes/paths';

const LIMIT = 10;

export function DisputesScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [tab, setTab] = useState<DisputeTabKey>('waitingSitter');
  const [keyword, setKeyword] = useState('');
  const [status, setStatus] = useState<DisputeStatus | null>(null);
  const [serviceType, setServiceType] = useState<ServiceType | null>(null);
  const { khoangNgay, tuNgay, chon: chonKhoangNgay, xoa: xoaKhoangNgay } = useDateRange();
  const { page, setPage, doiBoLoc, phanTrang } = useListPaging(LIMIT);

  const counts = useDisputeTabCounts();
  const hanKetLuanNgay = useHanKetLuanNgay();

  const query = useMemo<DisputeListQuery>(
    () => ({
      q: keyword || undefined,
      tab,
      status: status ?? undefined,
      serviceType: serviceType ?? undefined,
      from: tuNgay,
      sort: 'hanKetLuan',
      page,
      limit: LIMIT,
    }),
    [tab, keyword, status, serviceType, tuNgay, page],
  );

  const danhSach = useDisputes(query);
  const coBoLoc = Boolean(keyword || status || serviceType || khoangNgay);
  const csv = useCsvExport();

  const xuatCsv = () =>
    void csv.xuat<AdminDisputeRow>({
      tai: (trang, limit) => disputesApi.getDisputes({ ...query, page: trang, limit }),
      tenFile: `khieu-nai-${tab}.csv`,
      tieuDe: [
        t('khieuNai.csv.ma'),
        t('khieuNai.csv.maDon'),
        t('khieuNai.csv.nguoiKhieuNai'),
        t('khieuNai.csv.vaiTro'),
        t('khieuNai.csv.nguoiCham'),
        t('khieuNai.csv.dichVu'),
        t('khieuNai.csv.moLuc'),
        t('khieuNai.csv.hanDap'),
        t('khieuNai.csv.dapLuc'),
        t('khieuNai.csv.trangThai'),
        t('khieuNai.csv.tienHoan'),
      ],
      dong: (row) => [
        row.code,
        row.bookingCode,
        row.reporterName,
        t(`khieuNai.vaiTro.${row.reporterRole}`),
        row.sitterName,
        row.serviceName,
        row.createdAt,
        row.replyDeadline,
        row.sitterReplyAt,
        row.status,
        row.refundAmount,
      ],
    });

  const xoaBoLoc = () => {
    setKeyword('');
    setStatus(null);
    setServiceType(null);
    xoaKhoangNgay();
    setPage(1);
  };

  const moHoSo = (row: AdminDisputeRow) => void navigate(`${PATHS.disputes}/${row.code}`);

  const tabs = dungTabs(THU_TU_TAB, (key) => t(`khieuNai.tab.${key}`), counts.data);

  const columns: Array<Column<AdminDisputeRow>> = [
    {
      key: 'code',
      header: t('khieuNai.cot.ma'),
      width: 122,
      cell: (row) => <span className="text-label text-primary">{row.code}</span>,
    },
    {
      key: 'reporter',
      header: t('khieuNai.cot.nguoiKhieuNai'),
      cell: (row) => (
        <div className="flex min-w-0 items-center gap-label">
          <UserAvatar name={row.reporterName} url={row.reporterAvatarUrl} />
          <div className="min-w-0">
            <p className="truncate text-label">{row.reporterName}</p>
            <p className="truncate text-caption-sm text-text-secondary">
              {t(`khieuNai.vaiTro.${row.reporterRole}`)} · {formatDate(row.createdAt).slice(0, 5)}
            </p>
          </div>
        </div>
      ),
    },
    {
      key: 'sitter',
      header: t('khieuNai.cot.nguoiCham'),
      width: 150,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.sitterName}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {t('khieuNai.vaiTro.PROVIDER')}
          </p>
        </div>
      ),
    },
    {
      key: 'description',
      header: t('khieuNai.cot.noiDung'),
      width: 158,
      cell: (row) => (
        <p className="line-clamp-2 whitespace-normal text-label font-normal">{row.description}</p>
      ),
    },
    {
      key: 'deadline',
      header: t('khieuNai.cot.hanDap'),
      width: 104,
      cell: (row) => (
        <ReplyDeadlineBadge replyDeadline={row.replyDeadline} sitterReplyAt={row.sitterReplyAt} />
      ),
    },
    {
      key: 'conclusionDeadline',
      header: t('khieuNai.cot.hanKetLuan'),
      width: 118,
      cell: (row) => <ConclusionDeadlineBadge row={row} hanNgay={hanKetLuanNgay} />,
    },
    {
      key: 'status',
      header: t('khieuNai.cot.trangThai'),
      width: 128,
      cell: (row) => <DisputeStatusBadge view={tinhTrangHienThi(row)} />,
    },
    {
      key: 'actions',
      header: '',
      width: 96,
      align: 'right',
      isAction: true,
      cell: (row) => (
        <div className="flex items-center justify-end gap-text">
          <IconButton label={t('khieuNai.thaoTac.moHoSo')} icon={Eye} onClick={() => moHoSo(row)} />
          <IconButton
            label={t('khieuNai.thaoTac.xemAnh')}
            icon={Images}
            onClick={() => void navigate(`${PATHS.evidence}/${row.bookingCode}`)}
          />
          <IconButton
            label={t('khieuNai.thaoTac.xemHoiThoai')}
            icon={MessageSquare}
            onClick={() => void navigate(`${PATHS.bookings}/${row.bookingCode}/conversation`)}
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
        onRowClick={moHoSo}
        rowClassName={(row) =>
          hanKetLuanNgay !== null &&
          tinhTrangHanKetLuan(row, hanKetLuanNgay).kieu === 'quaHan'
            ? 'bg-error/[0.06]'
            : undefined
        }
        isFiltered={coBoLoc}
        onClearFilter={xoaBoLoc}
        emptyMessage={t('khieuNai.chuaCoKhieuNai')}
        toolbar={
          <>
            <SearchField
              value={keyword}
              onChange={(value) => doiBoLoc(() => setKeyword(value))}
              placeholder={t('khieuNai.timKiem')}
              className="w-[292px]"
            />
            <FilterSelect
              placeholder={t('khieuNai.loc.trangThai')}
              clearLabel={t('khieuNai.loc.moiTrangThai')}
              value={status}
              onChange={(value) => doiBoLoc(() => setStatus(value))}
              options={[
                { value: 'OPEN', label: t('khieuNai.status.OPEN') },
                { value: 'REVIEWING', label: t('khieuNai.status.REVIEWING') },
                { value: 'RESOLVED', label: t('khieuNai.status.RESOLVED') },
              ]}
            />
            <FilterSelect
              placeholder={t('khieuNai.loc.dichVu')}
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
            {t('khieuNai.xuatCsv')}
          </Button>
        }
        pagination={phanTrang(danhSach.data?.total)}
      />

      <p className="rounded-card bg-neutral-light/50 p-card text-caption-sm text-text-secondary">
        {t('khieuNai.ghiChuEnum')}
      </p>

      <p className="flex items-start gap-label rounded-card bg-honey/15 p-card text-caption-sm text-honey">
        <ShieldAlert className="mt-[1px] h-4 w-4 shrink-0" strokeWidth={1.8} />
        {t('khieuNai.ghiChuGiuTien')}
      </p>

      {hanKetLuanNgay !== null ? (
        <p className="flex items-start gap-label rounded-card bg-neutral-light/50 p-card text-caption-sm text-text-secondary">
          <Clock className="mt-[1px] h-4 w-4 shrink-0" strokeWidth={1.8} />
          {t('khieuNai.ghiChuHanKetLuan', { soNgay: hanKetLuanNgay })}
        </p>
      ) : null}
    </div>
  );
}
