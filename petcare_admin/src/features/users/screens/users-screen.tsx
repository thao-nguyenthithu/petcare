import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { Eye, Lock, LockOpen } from 'lucide-react';
import { CountTabs, type CountTab } from '@/components/ui/count-tabs';
import { DataTable, type Column } from '@/components/ui/data-table';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { FilterSelect } from '@/components/ui/filter-select';
import { IconButton } from '@/components/ui/icon-button';
import { SearchField } from '@/components/ui/search-field';
import { Button } from '@/components/ui/button';
import { useCurrentAdmin } from '@/features/auth/hooks/use-current-admin';
import { LockUserDialog } from '@/features/users/components/lock-user-dialog';
import {
  UserAvatar,
  UserRoleBadge,
  UserStatusBadge,
} from '@/features/users/components/user-badges';
import { usersApi } from '@/features/users/api/users-api';
import { useProvinces, useUserTabCounts, useUsers } from '@/features/users/hooks/use-users';
import type { UserListQuery, UserRow, UserRole, UserTabKey } from '@/features/users/types';
import { formatDate } from '@/lib/format';
import { DateRangeFilter } from '@/components/ui/date-range-filter';
import { trangThaiBang } from '@/lib/table-status';
import { useCsvExport } from '@/lib/use-csv-export';
import { useDateRange } from '@/lib/use-date-range';
import { useListPaging } from '@/lib/use-list-paging';
import { PATHS } from '@/routes/paths';

const LIMIT = 8;
const LECH_VN_MS = 7 * 3600_000;

function ngayVn(moc: number): string {
  return new Date(moc + LECH_VN_MS).toISOString().slice(0, 10);
}

const DIEU_KIEN_TAB: Record<UserTabKey, Pick<UserListQuery, 'role' | 'active'>> = {
  all: {},
  owner: { role: 'OWNER' },
  provider: { role: 'PROVIDER' },
  locked: { active: false },
};

export function UsersScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [tab, setTab] = useState<UserTabKey>('all');
  const [keyword, setKeyword] = useState('');
  const [role, setRole] = useState<UserRole | null>(null);
  const [active, setActive] = useState<'true' | 'false' | null>(null);
  const [province, setProvince] = useState<string | null>(null);
  const { khoangNgay, tuNgay, chon: chonKhoangNgay, xoa: xoaKhoangNgay } = useDateRange(ngayVn);
  const { page, setPage, doiBoLoc, phanTrang } = useListPaging(LIMIT);
  const [dongDangKhoa, setDongDangKhoa] = useState<UserRow | null>(null);

  const { data: admin } = useCurrentAdmin();
  const provinces = useProvinces();
  const counts = useUserTabCounts();

  const query = useMemo<UserListQuery>(
    () => ({
      ...DIEU_KIEN_TAB[tab],
      q: keyword || undefined,
      role: role ?? DIEU_KIEN_TAB[tab].role,
      active: active === null ? DIEU_KIEN_TAB[tab].active : active === 'true',
      province: province ?? undefined,
      from: tuNgay,
      page,
      limit: LIMIT,
    }),
    [tab, keyword, role, active, province, tuNgay, page],
  );

  const danhSach = useUsers(query);
  const coBoLoc = Boolean(keyword || role || active || province || khoangNgay);
  const csv = useCsvExport();

  const xuatCsv = () =>
    void csv.xuat<UserRow>({
      tai: (trang, limit) => usersApi.getUsers({ ...query, page: trang, limit }),
      tenFile: `nguoi-dung-${tab}.csv`,
      tieuDe: [
        t('nguoiDung.csv.hoTen'),
        t('nguoiDung.csv.email'),
        t('nguoiDung.csv.soDienThoai'),
        t('nguoiDung.csv.vaiTro'),
        t('nguoiDung.csv.tinhThanh'),
        t('nguoiDung.csv.trangThai'),
        t('nguoiDung.csv.daXacMinh'),
        t('nguoiDung.csv.soThuCung'),
        t('nguoiDung.csv.soDon'),
        t('nguoiDung.csv.taoLuc'),
      ],
      dong: (row) => [
        row.fullName,
        row.email,
        row.phone,
        row.role,
        row.province,
        row.isActive ? t('nguoiDung.csv.dangHoatDong') : t('nguoiDung.csv.daKhoa'),
        row.isVerified ? t('chung.co') : t('chung.khong'),
        row.petCount,
        row.bookingCount,
        row.createdAt,
      ],
    });

  const xoaBoLoc = () => {
    setKeyword('');
    setRole(null);
    setActive(null);
    setProvince(null);
    xoaKhoangNgay();
    setPage(1);
  };

  const tabs: Array<CountTab<UserTabKey>> = [
    { key: 'all', label: t('nguoiDung.tab.tatCa'), count: counts.data?.all },
    { key: 'owner', label: t('nguoiDung.tab.chuNuoi'), count: counts.data?.owner },
    { key: 'provider', label: t('nguoiDung.tab.nhaCungCap'), count: counts.data?.provider },
    { key: 'locked', label: t('nguoiDung.tab.biKhoa'), count: counts.data?.locked },
  ];

  const columns: Array<Column<UserRow>> = [
    {
      key: 'user',
      header: t('nguoiDung.cot.nguoiDung'),
      cell: (row) => (
        <div className="flex min-w-0 items-center gap-item">
          <UserAvatar name={row.fullName} url={row.avatarUrl} />
          <div className="min-w-0">
            <p className="truncate text-label">{row.fullName}</p>
            <p className="truncate text-caption-sm text-text-secondary">
              {t('nguoiDung.thamGia', { date: formatDate(row.createdAt) })}
            </p>
          </div>
        </div>
      ),
    },
    {
      key: 'contact',
      header: t('nguoiDung.cot.lienHe'),
      width: 200,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.phone ?? <KhongCoDuLieu />}</p>
          <p className="truncate text-caption-sm text-text-secondary">{row.email}</p>
        </div>
      ),
    },
    {
      key: 'role',
      header: t('nguoiDung.cot.vaiTro'),
      width: 148,
      cell: (row) => <UserRoleBadge role={row.role} isSitter={row.isSitter} />,
    },
    {
      key: 'pets',
      header: t('nguoiDung.cot.thuCung'),
      width: 96,
      cell: (row) => <span className="text-label">{row.petCount}</span>,
    },
    {
      key: 'bookings',
      header: t('nguoiDung.cot.soDon'),
      width: 96,
      cell: (row) => <span className="text-label">{row.bookingCount}</span>,
    },
    {
      key: 'status',
      header: t('nguoiDung.cot.trangThai'),
      width: 152,
      cell: (row) => <UserStatusBadge isActive={row.isActive} isVerified={row.isVerified} />,
    },
    {
      key: 'actions',
      header: '',
      width: 100,
      align: 'right',
      isAction: true,
      cell: (row) => (
        <div className="flex items-center justify-end gap-text">
          <IconButton
            label={t('nguoiDung.thaoTac.xemChiTiet')}
            icon={Eye}
            onClick={() => void navigate(`${PATHS.users}/${row.id}`)}
          />
          <IconButton
            label={row.isActive ? t('nguoiDung.thaoTac.khoa') : t('nguoiDung.thaoTac.moKhoa')}
            icon={row.isActive ? Lock : LockOpen}
            disabled={row.id === admin?.id}
            onClick={() => setDongDangKhoa(row)}
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
        rowKey={(row) => row.id}
        status={trangThaiBang(danhSach)}
        onRetry={() => void danhSach.refetch()}
        onRowClick={(row) => void navigate(`${PATHS.users}/${row.id}`)}
        isFiltered={coBoLoc}
        onClearFilter={xoaBoLoc}
        emptyMessage={t('nguoiDung.chuaCoTaiKhoan')}
        toolbar={
          <>
            <SearchField
              value={keyword}
              onChange={(value) => doiBoLoc(() => setKeyword(value))}
              placeholder={t('nguoiDung.timKiem')}
              className="w-[300px]"
            />
            <FilterSelect
              placeholder={t('nguoiDung.loc.vaiTro')}
              clearLabel={t('nguoiDung.loc.moiVaiTro')}
              value={role}
              onChange={(value) => doiBoLoc(() => setRole(value))}
              options={[
                { value: 'OWNER', label: t('nguoiDung.vaiTro.OWNER') },
                { value: 'PROVIDER', label: t('nguoiDung.vaiTro.PROVIDER') },
              ]}
            />
            <FilterSelect
              placeholder={t('nguoiDung.loc.trangThai')}
              clearLabel={t('nguoiDung.loc.moiTrangThai')}
              value={active}
              onChange={(value) => doiBoLoc(() => setActive(value))}
              options={[
                { value: 'true', label: t('nguoiDung.trangThai.hoatDong') },
                { value: 'false', label: t('nguoiDung.trangThai.biKhoa') },
              ]}
            />
            <FilterSelect
              placeholder={t('nguoiDung.loc.tinhThanh')}
              clearLabel={t('nguoiDung.loc.moiTinhThanh')}
              value={province}
              onChange={(value) => doiBoLoc(() => setProvince(value))}
              options={(provinces.data ?? []).map((item) => ({ value: item, label: item }))}
            />
            <DateRangeFilter
              placeholder={t('nguoiDung.loc.ngayTao')}
              value={khoangNgay}
              onChange={(value) => doiBoLoc(() => chonKhoangNgay(value))}
            />
          </>
        }
        toolbarActions={
          <Button variant="secondary" size="sm" onClick={xuatCsv} loading={csv.dangXuat}>
            {t('nguoiDung.xuatCsv')}
          </Button>
        }
        pagination={phanTrang(danhSach.data?.total)}
      />

      <LockUserDialog target={dongDangKhoa} onClose={() => setDongDangKhoa(null)} />
    </div>
  );
}
