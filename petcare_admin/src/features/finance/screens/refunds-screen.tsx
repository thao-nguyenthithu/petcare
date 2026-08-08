import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Eye, FileCheck } from 'lucide-react';
import { CountTabs } from '@/components/ui/count-tabs';
import { DataTable, type Column } from '@/components/ui/data-table';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { FilterSelect } from '@/components/ui/filter-select';
import { IconButton } from '@/components/ui/icon-button';
import { SearchField } from '@/components/ui/search-field';
import { EnumNote } from '@/features/finance/components/enum-note';
import { RefundStatusBadge } from '@/features/finance/components/finance-badges';
import { MoneyPill } from '@/features/finance/components/money-pill';
import { RefundDialog, type RefundDialogMode } from '@/features/finance/components/refund-dialog';
import {
  LY_DO_HOAN,
  MA_NGAN_HANG,
  THU_TU_TAB_HOAN,
  TRANG_THAI_THEO_TAB_HOAN,
} from '@/features/finance/finance-constants';
import { useRefundTabCounts, useRefunds } from '@/features/finance/hooks/use-finance';
import type {
  RefundListQuery,
  RefundReason,
  RefundRow,
  RefundTabKey,
} from '@/features/finance/types';
import { UserAvatar } from '@/features/users/components/user-badges';
import { formatRelative } from '@/lib/format';
import { DateRangeFilter } from '@/components/ui/date-range-filter';
import { dungTabs } from '@/lib/tab-list';
import { trangThaiBang } from '@/lib/table-status';
import { useListPaging } from '@/lib/use-list-paging';
import { useDateRange } from '@/lib/use-date-range';

const LIMIT = 10;

export function RefundsScreen() {
  const { t } = useTranslation();

  const [tab, setTab] = useState<RefundTabKey>('refunding');
  const [keyword, setKeyword] = useState('');
  const [lyDo, setLyDo] = useState<RefundReason | null>(null);
  const [bankCode, setBankCode] = useState<string | null>(null);
  const { khoangNgay, tuNgay, chon: chonKhoangNgay, xoa: xoaKhoangNgay } = useDateRange();
  const { page, setPage, doiBoLoc, phanTrang } = useListPaging(LIMIT);
  const [dangMo, setDangMo] = useState<{ row: RefundRow; mode: RefundDialogMode } | null>(null);

  const counts = useRefundTabCounts();

  const query = useMemo<RefundListQuery>(
    () => ({
      status: TRANG_THAI_THEO_TAB_HOAN[tab],
      q: keyword || undefined,
      reason: lyDo ?? undefined,
      bankCode: bankCode ?? undefined,
      from: tuNgay,
      page,
      limit: LIMIT,
    }),
    [tab, keyword, lyDo, bankCode, tuNgay, page],
  );

  const danhSach = useRefunds(query);
  const coBoLoc = Boolean(keyword || lyDo || bankCode || khoangNgay);

  const xoaBoLoc = () => {
    setKeyword('');
    setLyDo(null);
    setBankCode(null);
    xoaKhoangNgay();
    setPage(1);
  };

  const tabs = dungTabs(THU_TU_TAB_HOAN, (key) => t(`hoanTien.tab.${key}`), counts.data);

  const columns: Array<Column<RefundRow>> = [
    {
      key: 'owner',
      header: t('hoanTien.cot.chuNuoi'),
      cell: (row) => (
        <div className="flex min-w-0 items-center gap-item">
          <UserAvatar name={row.ownerName} size={32} />
          <div className="min-w-0">
            <p className="truncate text-label">{row.ownerName}</p>
            <p className="truncate text-caption-sm text-text-secondary">{row.ownerPhone}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'transaction',
      header: t('hoanTien.cot.donVaGiaoDich'),
      width: 176,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.bookingCode}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            txn {row.gatewayTxnNo ?? t('hoanTien.thieuMaCong')} ·{' '}
            {row.bankCode ?? t('hoanTien.khongRoNganHang')}
          </p>
        </div>
      ),
    },
    {
      key: 'reason',
      header: t('hoanTien.cot.lyDo'),
      width: 188,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{t(`hoanTien.lyDo.${row.reason}`)}</p>
          {row.cancelReasonText ? (
            <p className="truncate text-caption-sm text-text-secondary">{row.cancelReasonText}</p>
          ) : (
            <KhongCoDuLieu />
          )}
        </div>
      ),
    },
    {
      key: 'amount',
      header: t('hoanTien.cot.soTienHoan'),
      width: 156,
      cell: (row) => (
        <div className="min-w-0">
          <MoneyPill value={row.amount} />
          <p className="mt-text truncate text-caption-sm text-text-secondary">
            {row.amount === row.paymentAmount
              ? t('hoanTien.hoanToanPhan')
              : t('hoanTien.hoanMotPhan')}
          </p>
        </div>
      ),
    },
    {
      key: 'waiting',
      header: t('hoanTien.cot.choTu'),
      width: 108,
      cell: (row) => (
        <span className="text-label font-normal">{formatRelative(row.requestedAt)}</span>
      ),
    },
    {
      key: 'status',
      header: t('hoanTien.cot.trangThai'),
      width: 140,
      cell: (row) => <RefundStatusBadge status={row.status} />,
    },
    {
      key: 'actions',
      header: '',
      width: 88,
      align: 'right',
      isAction: true,
      cell: (row) => (
        <div className="flex items-center justify-end gap-text">
          <IconButton
            label={t('hoanTien.thaoTac.xemGiaoDich')}
            title={t('hoanTien.thaoTac.xemGiaoDich')}
            icon={Eye}
            onClick={() => setDangMo({ row, mode: 'view' })}
          />
          {row.status === 'REFUNDING' ? (
            <IconButton
              label={t('hoanTien.thaoTac.danhDauTay')}
              title={t('hoanTien.thaoTac.danhDauTay')}
              icon={FileCheck}
              onClick={() => setDangMo({ row, mode: 'manual' })}
            />
          ) : null}
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
        rowKey={(row) => row.txnRef}
        status={trangThaiBang(danhSach)}
        onRetry={() => void danhSach.refetch()}
        isFiltered={coBoLoc}
        onClearFilter={xoaBoLoc}
        emptyMessage={t('hoanTien.chuaCoLenh')}
        toolbar={
          <>
            <SearchField
              value={keyword}
              onChange={(value) => doiBoLoc(() => setKeyword(value))}
              placeholder={t('hoanTien.timKiem')}
              className="w-[292px]"
            />
            <FilterSelect
              placeholder={t('hoanTien.loc.lyDo')}
              clearLabel={t('hoanTien.loc.moiLyDo')}
              value={lyDo}
              onChange={(value) => doiBoLoc(() => setLyDo(value))}
              options={LY_DO_HOAN.map((value) => ({
                value,
                label: t(`hoanTien.lyDo.${value}`),
              }))}
            />
            <FilterSelect
              placeholder={t('thanhToan.loc.nganHang')}
              clearLabel={t('thanhToan.loc.moiNganHang')}
              value={bankCode}
              onChange={(value) => doiBoLoc(() => setBankCode(value))}
              options={MA_NGAN_HANG.map((code) => ({ value: code, label: code }))}
            />
            <DateRangeFilter
              value={khoangNgay}
              onChange={(value) => doiBoLoc(() => chonKhoangNgay(value))}
            />
          </>
        }
        pagination={phanTrang(danhSach.data?.total)}
      />

      <EnumNote>{t('hoanTien.ghiChuNguon')}</EnumNote>

      <RefundDialog
        row={dangMo?.row ?? null}
        mode={dangMo?.mode ?? 'view'}
        onClose={() => setDangMo(null)}
      />
    </div>
  );
}
