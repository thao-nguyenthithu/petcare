import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { Copy, ExternalLink, Eye } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { CountTabs } from '@/components/ui/count-tabs';
import { DataTable, type Column } from '@/components/ui/data-table';
import { FilterSelect } from '@/components/ui/filter-select';
import { IconButton } from '@/components/ui/icon-button';
import { SearchField } from '@/components/ui/search-field';
import { EnumNote } from '@/features/finance/components/enum-note';
import { GatewayBadge, PaymentStatusBadge } from '@/features/finance/components/finance-badges';
import { MoneyPill } from '@/features/finance/components/money-pill';
import { PaymentRawDialog } from '@/features/finance/components/payment-raw-dialog';
import {
  MA_NGAN_HANG,
  THU_TU_TAB_GIAO_DICH,
  TRANG_THAI_THEO_TAB_GIAO_DICH,
} from '@/features/finance/finance-constants';
import { financeApi } from '@/features/finance/api/finance-api';
import { useCsvExport } from '@/lib/use-csv-export';
import { DateRangeFilter } from '@/components/ui/date-range-filter';
import { useListPaging } from '@/lib/use-list-paging';
import { useDateRange } from '@/lib/use-date-range';
import { usePaymentTabCounts, usePayments } from '@/features/finance/hooks/use-finance';
import type {
  PaymentGateway,
  PaymentListQuery,
  PaymentRow,
  PaymentTabKey,
} from '@/features/finance/types';
import { UserAvatar } from '@/features/users/components/user-badges';
import { formatDate, formatTime } from '@/lib/format';
import { dungTabs } from '@/lib/tab-list';
import { trangThaiBang } from '@/lib/table-status';
import { notify } from '@/lib/toast';
import { PATHS } from '@/routes/paths';

const LIMIT = 10;

export function PaymentsScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [tab, setTab] = useState<PaymentTabKey>('escrow');
  const [keyword, setKeyword] = useState('');
  const [gateway, setGateway] = useState<PaymentGateway | null>(null);
  const [bankCode, setBankCode] = useState<string | null>(null);
  const { khoangNgay, tuNgay, chon: chonKhoangNgay, xoa: xoaKhoangNgay } = useDateRange();
  const { page, setPage, doiBoLoc, phanTrang } = useListPaging(LIMIT);
  const [dangXemRaw, setDangXemRaw] = useState<PaymentRow | null>(null);

  const counts = usePaymentTabCounts();

  const query = useMemo<PaymentListQuery>(
    () => ({
      status: TRANG_THAI_THEO_TAB_GIAO_DICH[tab],
      q: keyword || undefined,
      gateway: gateway ?? undefined,
      bankCode: bankCode ?? undefined,
      from: tuNgay,
      page,
      limit: LIMIT,
    }),
    [tab, keyword, gateway, bankCode, tuNgay, page],
  );

  const danhSach = usePayments(query);
  const coBoLoc = Boolean(keyword || gateway || bankCode || khoangNgay);
  const csv = useCsvExport();

  const xuatCsv = () =>
    void csv.xuat<PaymentRow>({
      tai: (trang, limit) => financeApi.getPayments({ ...query, page: trang, limit }),
      tenFile: `giao-dich-${tab}.csv`,
      tieuDe: [
        t('thanhToan.csv.maDon'),
        'txnRef',
        'gatewayTxnNo',
        'gatewayPayDate',
        t('thanhToan.csv.chuNuoi'),
        t('thanhToan.csv.nganHang'),
        t('thanhToan.csv.loaiThe'),
        t('thanhToan.csv.soTien'),
        t('thanhToan.csv.cong'),
        t('thanhToan.csv.trangThai'),
        t('thanhToan.csv.traLuc'),
      ],
      dong: (row) => [
        row.bookingCode,
        row.txnRef,
        row.gatewayTxnNo,
        row.gatewayPayDate,
        row.ownerName,
        row.bankCode,
        row.cardType,
        row.amount,
        row.gateway,
        row.status,
        row.paidAt,
      ],
    });

  const xoaBoLoc = () => {
    setKeyword('');
    setGateway(null);
    setBankCode(null);
    xoaKhoangNgay();
    setPage(1);
  };

  const saoChep = (value: string) => {
    void navigator.clipboard
      .writeText(value)
      .then(() => notify.success(t('thanhToan.daSaoChep')))
      .catch(() => notify.error(t('thanhToan.khongSaoChepDuoc')));
  };

  const tabs = dungTabs(THU_TU_TAB_GIAO_DICH, (key) => t(`thanhToan.tab.${key}`), counts.data);

  const columns: Array<Column<PaymentRow>> = [
    {
      key: 'owner',
      header: t('thanhToan.cot.chuNuoi'),
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
      key: 'txnRef',
      header: t('thanhToan.cot.donVaTxnRef'),
      width: 168,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.bookingCode}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {t('thanhToan.truong.maGiaoDich')} {row.txnRef}
          </p>
        </div>
      ),
    },
    {
      key: 'gatewayTxnNo',
      header: t('thanhToan.cot.maCongTraVe'),
      width: 176,
      cell: (row) => <MaCong row={row} />,
    },
    {
      key: 'amount',
      header: t('thanhToan.cot.soTien'),
      width: 148,
      cell: (row) => <MoneyPill value={row.amount} />,
    },
    {
      key: 'paidAt',
      header: t('thanhToan.cot.traLuc'),
      width: 128,
      cell: (row) => <TraLuc row={row} />,
    },
    {
      key: 'status',
      header: t('thanhToan.cot.trangThai'),
      width: 148,
      cell: (row) => (
        <div className="flex flex-col items-start gap-text">
          <PaymentStatusBadge status={row.status} />
          <GatewayBadge gateway={row.gateway} />
        </div>
      ),
    },
    {
      key: 'actions',
      header: '',
      width: 116,
      align: 'right',
      isAction: true,
      cell: (row) => (
        <div className="flex items-center justify-end gap-text">
          <IconButton
            label={t('thanhToan.thaoTac.xemPayload')}
            title={t('thanhToan.thaoTac.xemPayload')}
            onClick={() => setDangXemRaw(row)}
            icon={Eye}
          />
          <IconButton
            label={t('thanhToan.thaoTac.moDon')}
            title={t('thanhToan.thaoTac.moDon')}
            onClick={() => void navigate(`${PATHS.bookings}/${row.bookingCode}`)}
            icon={ExternalLink}
          />
          <IconButton
            label={t('thanhToan.thaoTac.chepTxnRef')}
            title={t('thanhToan.thaoTac.chepTxnRef')}
            onClick={() => saoChep(row.txnRef)}
            icon={Copy}
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
        rowKey={(row) => row.id}
        status={trangThaiBang(danhSach)}
        onRetry={() => void danhSach.refetch()}
        isFiltered={coBoLoc}
        onClearFilter={xoaBoLoc}
        emptyMessage={t('thanhToan.chuaCoGiaoDich')}
        toolbar={
          <>
            <SearchField
              value={keyword}
              onChange={(value) => doiBoLoc(() => setKeyword(value))}
              placeholder={t('thanhToan.timKiem')}
              className="w-[292px]"
            />
            <FilterSelect
              placeholder={t('thanhToan.loc.cong')}
              clearLabel={t('thanhToan.loc.moiCong')}
              value={gateway}
              onChange={(value) => doiBoLoc(() => setGateway(value))}
              options={[
                { value: 'vnpay', label: t('thanhToan.cong.vnpay') },
                { value: 'mock', label: t('thanhToan.cong.mock') },
                { value: 'auto', label: t('thanhToan.cong.auto') },
              ]}
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
        toolbarActions={
          <Button variant="secondary" size="sm" onClick={xuatCsv} loading={csv.dangXuat}>
            {t('thanhToan.xuatCsv')}
          </Button>
        }
        pagination={phanTrang(danhSach.data?.total)}
      />

      <EnumNote>{t('thanhToan.ghiChuEnum')}</EnumNote>

      <PaymentRawDialog row={dangXemRaw} onClose={() => setDangXemRaw(null)} />
    </div>
  );
}

function MaCong({ row }: { row: PaymentRow }) {
  const { t } = useTranslation();
  if (!row.gatewayTxnNo) {
    return (
      <div className="min-w-0">
        <p className="truncate text-label font-normal text-text-secondary">
          {row.status === 'EXPIRED' ? t('thanhToan.khongCoMa') : t('thanhToan.chuaCoMa')}
        </p>
        <p className="truncate text-caption-sm text-text-secondary">
          {row.status === 'EXPIRED' ? t('thanhToan.hetHanGiuCho') : t('thanhToan.chuaQuaCong')}
        </p>
      </div>
    );
  }
  return (
    <div className="min-w-0">
      <p className="truncate text-label">{row.gatewayTxnNo}</p>
      <p className="truncate text-caption-sm text-text-secondary">
        {[row.bankCode, row.cardType].filter(Boolean).join(' · ') || t('thanhToan.congKhongTra')}
      </p>
    </div>
  );
}

function TraLuc({ row }: { row: PaymentRow }) {
  const { t } = useTranslation();
  if (row.paidAt) {
    return (
      <span className="text-label font-normal">
        {formatDate(row.paidAt).slice(0, 5)} {formatTime(row.paidAt)}
      </span>
    );
  }
  return (
    <span className="text-label text-text-secondary">
      {row.status === 'EXPIRED' ? t('thanhToan.quaMuoiPhut') : t('thanhToan.chuaTra')}
    </span>
  );
}
