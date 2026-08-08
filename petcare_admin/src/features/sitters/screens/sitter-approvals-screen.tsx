import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { Eye } from 'lucide-react';
import { CountTabs } from '@/components/ui/count-tabs';
import { DataTable, type Column } from '@/components/ui/data-table';
import { IconButton } from '@/components/ui/icon-button';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { FilterSelect } from '@/components/ui/filter-select';
import { SearchField } from '@/components/ui/search-field';
import type { ServiceType } from '@/features/dashboard/chart-colors';
import { GiayToBadge, SitterStateBadge } from '@/features/sitters/components/sitter-badges';
import {
  useSitterProvinces,
  useSitterTabCounts,
  useSitters,
} from '@/features/sitters/hooks/use-sitters';
import { THU_TU_TAB } from '@/features/sitters/sitter-constants';
import type { SitterListQuery, SitterRow, SitterTabKey } from '@/features/sitters/types';
import { UserAvatar } from '@/features/users/components/user-badges';
import { formatDate, formatRelative } from '@/lib/format';
import { dungTabs } from '@/lib/tab-list';
import { trangThaiBang } from '@/lib/table-status';
import { useListPaging } from '@/lib/use-list-paging';
import { PATHS } from '@/routes/paths';

const LIMIT = 8;

export function SitterApprovalsScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [tab, setTab] = useState<SitterTabKey>('pending');
  const [keyword, setKeyword] = useState('');
  const [service, setService] = useState<ServiceType | null>(null);
  const [province, setProvince] = useState<string | null>(null);
  const { page, setPage, doiBoLoc, phanTrang } = useListPaging(LIMIT);

  const counts = useSitterTabCounts();
  const provinces = useSitterProvinces();

  const query = useMemo<SitterListQuery>(
    () => ({
      tab,
      q: keyword || undefined,
      service: service ?? undefined,
      province: province ?? undefined,
      page,
      limit: LIMIT,
    }),
    [tab, keyword, service, province, page],
  );

  const danhSach = useSitters(query);
  const coBoLoc = Boolean(keyword || service || province);

  const xoaBoLoc = () => {
    setKeyword('');
    setService(null);
    setProvince(null);
    setPage(1);
  };

  const tabs = dungTabs(THU_TU_TAB, (key) => t(`hoSoNcc.tab.${key}`), counts.data);

  const chuaDuyet = tab === 'pending' || tab === 'rejected';

  const cotChuaDuyet: Array<Column<SitterRow>> = [
    {
      key: 'residence',
      header: t('hoSoNcc.cot.noiO'),
      width: 260,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.province ?? <KhongCoDuLieu />}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {row.addressDetail ?? <KhongCoDuLieu />}
          </p>
        </div>
      ),
    },
    {
      key: 'waiting',
      header: t('hoSoNcc.cot.daCho'),
      width: 160,
      cell: (row) =>
        row.submittedAt ? (
          <span className="truncate text-label">{formatRelative(row.submittedAt)}</span>
        ) : (
          <KhongCoDuLieu />
        ),
    },
  ];

  const cotDaDuyet: Array<Column<SitterRow>> = [
    {
      key: 'services',
      header: t('hoSoNcc.cot.dichVu'),
      width: 190,
      cell: (row) =>
        row.services.length === 0 ? (
          <KhongCoDuLieu />
        ) : (
          <span className="truncate text-label">
            {row.services.map((type) => t(`dashboard.dichVu.${type}`)).join(', ')}
          </span>
        ),
    },
    {
      key: 'area',
      header: t('hoSoNcc.cot.khuVuc'),
      width: 210,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.province ?? <KhongCoDuLieu />}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {row.serviceAddress ?? <KhongCoDuLieu />}
          </p>
        </div>
      ),
    },
    {
      key: 'rating',
      header: t('hoSoNcc.cot.danhGia'),
      width: 120,
      cell: (row) =>
        row.totalReviews === 0 ? (
          <KhongCoDuLieu />
        ) : (
          <div className="min-w-0">
            <p className="truncate text-label">{row.ratingAvg.toFixed(1)}</p>
            <p className="truncate text-caption-sm text-text-secondary">
              {t('hoSoNcc.soLuot', { count: row.totalReviews })}
            </p>
          </div>
        ),
    },
  ];

  const columns: Array<Column<SitterRow>> = [
    {
      key: 'sitter',
      header: t('hoSoNcc.cot.nguoiCham'),
      cell: (row) => (
        <div className="flex min-w-0 items-center gap-item">
          <UserAvatar name={row.fullName} url={row.avatarUrl} />
          <div className="min-w-0">
            <p className="truncate text-label">{row.fullName}</p>
            <p className="truncate text-caption-sm text-text-secondary">
              {row.approvedAt
                ? t('hoSoNcc.duyetNgay', { date: formatDate(row.approvedAt) })
                : row.submittedAt
                  ? t('hoSoNcc.nopNgay', { date: formatDate(row.submittedAt) })
                  : <KhongCoDuLieu />}
            </p>
          </div>
        </div>
      ),
    },
    ...(chuaDuyet ? cotChuaDuyet : cotDaDuyet),
    {
      key: 'documents',
      header: t('hoSoNcc.cot.giayTo'),
      width: 128,
      cell: (row) => <GiayToBadge hasFront={row.hasFront} hasBack={row.hasBack} />,
    },
    {
      key: 'state',
      header: t('hoSoNcc.cot.trangThai'),
      width: 152,
      cell: (row) => <SitterStateBadge row={row} />,
    },
    {
      key: 'actions',
      header: '',
      width: 64,
      align: 'right',
      isAction: true,
      cell: (row) => (
        <IconButton
          label={t('hoSoNcc.xemHoSo')}
          icon={Eye}
          onClick={() => void navigate(`${PATHS.sitterApprovals}/${row.id}`)}
        />
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
        rowKey={(row) => row.id}
        status={trangThaiBang(danhSach)}
        onRetry={() => void danhSach.refetch()}
        onRowClick={(row) => void navigate(`${PATHS.sitterApprovals}/${row.id}`)}
        isFiltered={coBoLoc}
        onClearFilter={xoaBoLoc}
        emptyMessage={t(`hoSoNcc.rong.${tab}`)}
        toolbar={
          <>
            <SearchField
              value={keyword}
              onChange={(value) => doiBoLoc(() => setKeyword(value))}
              placeholder={t('hoSoNcc.timKiem')}
              className="w-[300px]"
            />
            {chuaDuyet ? null : (
              <FilterSelect
                placeholder={t('hoSoNcc.loc.dichVu')}
                clearLabel={t('hoSoNcc.loc.moiDichVu')}
                value={service}
                onChange={(value) => doiBoLoc(() => setService(value))}
                options={[
                  { value: 'WALKING', label: t('dashboard.dichVu.WALKING') },
                  { value: 'BOARDING', label: t('dashboard.dichVu.BOARDING') },
                  { value: 'GROOMING', label: t('dashboard.dichVu.GROOMING') },
                ]}
              />
            )}
            <FilterSelect
              placeholder={t('hoSoNcc.loc.tinhThanh')}
              clearLabel={t('hoSoNcc.loc.moiTinhThanh')}
              value={province}
              onChange={(value) => doiBoLoc(() => setProvince(value))}
              options={(provinces.data ?? []).map((item) => ({ value: item, label: item }))}
            />
          </>
        }
        pagination={phanTrang(danhSach.data?.total)}
      />

      <p className="text-caption-sm text-text-secondary">{t('hoSoNcc.ghiChu')}</p>
    </div>
  );
}
