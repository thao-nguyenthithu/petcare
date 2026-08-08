import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { Check, Eye, Flag, Gauge, ShieldAlert, X } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { CountTabs } from '@/components/ui/count-tabs';
import { DataTable, type Column } from '@/components/ui/data-table';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { TextInput } from '@/components/ui/field';
import { FilterSelect } from '@/components/ui/filter-select';
import { IconButton } from '@/components/ui/icon-button';
import { Modal } from '@/components/ui/modal';
import { SearchField } from '@/components/ui/search-field';
import { bookingsApi } from '@/features/bookings/api/bookings-api';
import { NGUONG_LECH_TY_LE } from '@/features/bookings/booking-constants';
import { GpsDeviationBadge } from '@/features/bookings/components/gps-deviation-badge';
import {
  useGpsReports,
  useGpsTabCounts,
  useReviewGpsReport,
} from '@/features/bookings/hooks/use-bookings';
import type { GpsReportListQuery, GpsReportRow, GpsTabKey } from '@/features/bookings/types';
import { UserAvatar } from '@/features/users/components/user-badges';
import { getErrorMessage } from '@/lib/api/client';
import { formatDateTime } from '@/lib/format';
import { DateRangeFilter } from '@/components/ui/date-range-filter';
import { useCsvExport } from '@/lib/use-csv-export';
import { useDateRange } from '@/lib/use-date-range';
import { useListPaging } from '@/lib/use-list-paging';
import { dungTabs } from '@/lib/tab-list';
import { trangThaiBang } from '@/lib/table-status';
import { notify } from '@/lib/toast';
import { PATHS } from '@/routes/paths';

const LIMIT = 10;

export function GpsFlaggedScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [tab, setTab] = useState<GpsTabKey>('flagged');
  const [keyword, setKeyword] = useState('');
  const [mucDiem, setMucDiem] = useState<'0.5' | '0.7' | '0.9' | null>(null);
  const [trangThai, setTrangThai] = useState<'flagged' | 'noFlag' | null>(null);
  const { khoangNgay, tuNgay, chon: chonKhoangNgay, xoa: xoaKhoangNgay } = useDateRange();
  const { page, setPage, doiBoLoc, phanTrang } = useListPaging(LIMIT);
  const [dangSoat, setDangSoat] = useState<{ row: GpsReportRow; cleared: boolean } | null>(null);
  const [ghiChu, setGhiChu] = useState('');

  const counts = useGpsTabCounts();
  const soat = useReviewGpsReport();

  const query = useMemo<GpsReportListQuery>(
    () => ({
      tab,
      q: keyword || undefined,
      flagged: trangThai === null ? undefined : trangThai === 'flagged',
      minScore: mucDiem ? Number(mucDiem) : undefined,
      from: tuNgay,
      page,
      limit: LIMIT,
    }),
    [tab, keyword, trangThai, mucDiem, tuNgay, page],
  );

  const danhSach = useGpsReports(query);
  const coBoLoc = Boolean(keyword || mucDiem || trangThai || khoangNgay);
  const csv = useCsvExport();

  const xuatCsv = () =>
    void csv.xuat<GpsReportRow>({
      tai: (trang, limit) => bookingsApi.getGpsReports({ ...query, page: trang, limit }),
      tenFile: `lo-trinh-${tab}.csv`,
      tieuDe: [
        t('gps.csv.maDon'),
        t('gps.csv.nguoiCham'),
        t('gps.csv.diemNghiNgo'),
        t('gps.csv.quangDuongServerM'),
        t('gps.csv.appKhaiKm'),
        t('gps.csv.waypoint'),
        t('gps.csv.tocDoTb'),
        t('gps.csv.viTriGia'),
        t('gps.csv.co'),
        t('gps.csv.soatLuc'),
        t('gps.csv.ghiChuSoat'),
      ],
      dong: (row) => [
        row.bookingCode,
        row.sitterName,
        row.suspicionScore,
        row.totalDistanceM,
        row.claimedDistanceKm,
        row.totalWaypoints,
        row.avgSpeedKmh,
        row.mockedCount,
        row.flaggedForReview ? t('gps.dangGanCo') : t('gps.khongCoCo'),
        row.reviewedAt,
        row.suspicionNote,
      ],
    });

  const xoaBoLoc = () => {
    setKeyword('');
    setMucDiem(null);
    setTrangThai(null);
    xoaKhoangNgay();
    setPage(1);
  };

  const dongDialog = () => {
    setDangSoat(null);
    setGhiChu('');
  };

  const xacNhanSoat = () => {
    if (!dangSoat) return;
    soat.mutate(
      { bookingCode: dangSoat.row.bookingCode, cleared: dangSoat.cleared, note: ghiChu.trim() },
      {
        onSuccess: () => {
          notify.success(dangSoat.cleared ? t('gps.daGoCo') : t('gps.daGiuCo'));
          dongDialog();
        },
        onError: (error) => notify.error(getErrorMessage(error)),
      },
    );
  };

  const tabs = dungTabs(
    ['flagged', 'reviewed', 'noClaim', 'all'] as GpsTabKey[],
    (key) => t(`gps.tab.${key}`),
    counts.data,
  );

  const columns: Array<Column<GpsReportRow>> = [
    {
      key: 'sitter',
      header: t('gps.cot.nguoiCham'),
      cell: (row) => (
        <div className="flex min-w-0 items-center gap-item">
          <UserAvatar name={row.sitterName} />
          <div className="min-w-0">
            <p className="truncate text-label">{row.sitterName}</p>
            <p className="truncate text-caption-sm text-text-secondary">{row.bookingCode}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'score',
      header: t('gps.cot.diemNghiNgo'),
      width: 140,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">
            {row.suspicionScore === null ? (
              <KhongCoDuLieu />
            ) : (
              new Intl.NumberFormat('vi-VN', { minimumFractionDigits: 2 }).format(
                row.suspicionScore,
              )
            )}
          </p>
          <p className="truncate text-caption-sm text-text-secondary">
            {row.suspicionScore === null
              ? t('gps.khongDoiChieuDuoc')
              : t('gps.nguong', { value: NGUONG_LECH_TY_LE.toFixed(2).replace('.', ',') })}
          </p>
        </div>
      ),
    },
    {
      key: 'distance',
      header: t('gps.cot.quangDuong'),
      width: 150,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">
            {t('gps.serverKm', { value: (row.totalDistanceM / 1000).toFixed(1) })}
          </p>
          <p className="truncate text-caption-sm text-text-secondary">
            {row.claimedDistanceKm === null
              ? t('gps.appChuaKhaiKm')
              : t('gps.appKhaiKm', { value: row.claimedDistanceKm.toFixed(1) })}
          </p>
        </div>
      ),
    },
    {
      key: 'deviation',
      header: t('gps.cot.doLech'),
      width: 170,
      cell: (row) => (
        <div className="flex flex-col items-start gap-text">
          <GpsDeviationBadge row={row} />
          {row.mockedCount > 0 ? (
            <Badge tone="danger" icon={ShieldAlert}>
              {t('gps.viTriGia', { so: row.mockedCount })}
            </Badge>
          ) : null}
          {row.speedFlag ? (
            <Badge tone="pending" icon={Gauge}>
              {t('gps.nghiDiXe')}
            </Badge>
          ) : null}
        </div>
      ),
    },
    {
      key: 'waypoints',
      header: t('gps.cot.waypoint'),
      width: 110,
      cell: (row) => <span className="text-label">{row.totalWaypoints}</span>,
    },
    {
      key: 'status',
      header: t('gps.cot.trangThai'),
      width: 170,
      cell: (row) => (
        <div className="flex flex-col items-start gap-text">
          {row.flaggedForReview ? (
            <Badge tone="pending" icon={Flag}>
              {t('gps.dangGanCo')}
            </Badge>
          ) : (
            <Badge tone="success" icon={Check}>
              {t('gps.khongCoCo')}
            </Badge>
          )}
          <span className="truncate text-caption-sm text-text-secondary">
            {row.reviewedAt
              ? t('gps.daSoatLuc', { time: formatDateTime(row.reviewedAt) })
              : t('gps.chuaAiSoat')}
          </span>
        </div>
      ),
    },
    {
      key: 'actions',
      header: '',
      width: 120,
      align: 'right',
      isAction: true,
      cell: (row) => (
        <div className="flex items-center justify-end gap-text">
          <IconButton
            label={t('don.thaoTac.xemChiTiet')}
            icon={Eye}
            onClick={() => void navigate(`${PATHS.bookings}/${row.bookingCode}`)}
          />
          <IconButton
            label={t('gps.thaoTac.goCo')}
            icon={Check}
            disabled={!row.flaggedForReview}
            onClick={() => setDangSoat({ row, cleared: true })}
          />
          <IconButton
            label={t('gps.thaoTac.giuCo')}
            icon={X}
            tone="danger"
            disabled={!row.flaggedForReview}
            onClick={() => setDangSoat({ row, cleared: false })}
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
        className="rounded-card bg-neutral-light/50 p-text"
      />

      <DataTable
        columns={columns}
        rows={danhSach.data?.items ?? []}
        rowKey={(row) => row.bookingCode}
        status={trangThaiBang(danhSach)}
        onRetry={() => void danhSach.refetch()}
        onRowClick={(row) => void navigate(`${PATHS.bookings}/${row.bookingCode}`)}
        isFiltered={coBoLoc}
        onClearFilter={xoaBoLoc}
        emptyMessage={t('gps.chuaCoPhien')}
        toolbar={
          <>
            <SearchField
              value={keyword}
              onChange={(value) => doiBoLoc(() => setKeyword(value))}
              placeholder={t('gps.timKiem')}
              className="w-[300px]"
            />
            <FilterSelect
              placeholder={t('gps.loc.mucDiem')}
              clearLabel={t('gps.loc.moiMucDiem')}
              value={mucDiem}
              onChange={(value) => doiBoLoc(() => setMucDiem(value))}
              options={[
                { value: '0.5', label: t('gps.loc.tu05') },
                { value: '0.7', label: t('gps.loc.tu07') },
                { value: '0.9', label: t('gps.loc.tu09') },
              ]}
            />
            <FilterSelect
              placeholder={t('nguoiDung.loc.trangThai')}
              clearLabel={t('nguoiDung.loc.moiTrangThai')}
              value={trangThai}
              onChange={(value) => doiBoLoc(() => setTrangThai(value))}
              options={[
                { value: 'flagged', label: t('gps.dangGanCo') },
                { value: 'noFlag', label: t('gps.khongCoCo') },
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
            {t('gps.xuatCsv')}
          </Button>
        }
        pagination={phanTrang(danhSach.data?.total)}
      />

      <p className="rounded-card bg-honey/15 p-card text-caption-sm text-honey">
        {t('gps.ghiChuNguon')}
      </p>

      {mucDiem ? (
        <p className="rounded-card bg-honey/15 p-card text-caption-sm text-honey">
          {t('gps.locDiemBoQuaChuaKhai')}
        </p>
      ) : null}

      <p className="rounded-card bg-card-mint p-card text-caption-sm text-text-secondary">
        {t('gps.khongTuPhat')}
      </p>

      <Modal
        open={Boolean(dangSoat)}
        onOpenChange={(open) => {
          if (!open) dongDialog();
        }}
        title={dangSoat?.cleared ? t('gps.dialog.goCoTieuDe') : t('gps.dialog.giuCoTieuDe')}
        description={
          dangSoat?.cleared
            ? t('gps.dialog.goCoMoTa', { code: dangSoat?.row.bookingCode })
            : t('gps.dialog.giuCoMoTa', { code: dangSoat?.row.bookingCode })
        }
        confirmLabel={dangSoat?.cleared ? t('gps.dialog.goCoNut') : t('gps.dialog.giuCoNut')}
        danger={dangSoat?.cleared === false}
        confirmDisabled={ghiChu.trim().length < 3}
        loading={soat.isPending}
        onConfirm={xacNhanSoat}
      >
        <label className="flex flex-col gap-label">
          <span className="text-label-sm uppercase text-text-primary">
            {t('gps.dialog.ghiChu')}
          </span>
          <TextInput
            value={ghiChu}
            onChange={(event) => setGhiChu(event.target.value)}
            placeholder={t('gps.dialog.ghiChuGoiY')}
          />
        </label>
      </Modal>
    </div>
  );
}
