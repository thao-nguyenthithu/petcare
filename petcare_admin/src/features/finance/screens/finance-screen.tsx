import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { CircleCheck, Clock, Receipt, Users } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { DataTable, type Column } from '@/components/ui/data-table';
import { SectionCard } from '@/components/ui/section-card';
import { StatCard, StatCardSkeleton } from '@/components/ui/stat-card';
import { ErrorState } from '@/components/state/error-state';
import { Skeleton } from '@/components/state/skeleton';
import { RevenueLegend } from '@/features/dashboard/components/revenue-chart';
import { EnumNote } from '@/features/finance/components/enum-note';
import { WithdrawalStatusBadge } from '@/features/finance/components/finance-badges';
import { TopSittersList } from '@/features/finance/components/top-sitters-list';
import { WeeklyRevenueChart } from '@/features/finance/components/weekly-revenue-chart';
import { WithdrawalDialog } from '@/features/finance/components/withdrawal-dialog';
import { financeApi } from '@/features/finance/api/finance-api';
import { trangThaiBang } from '@/lib/table-status';
import { useCsvExport } from '@/lib/use-csv-export';
import { useFinanceSummary, useWithdrawals } from '@/features/finance/hooks/use-finance';
import type { WithdrawalRow } from '@/features/finance/types';
import { formatDate, formatMoney, formatPercent, formatTime } from '@/lib/format';
import { useListPaging } from '@/lib/use-list-paging';
import { useMoneyShort } from '@/lib/use-money-short';

const LIMIT = 10;

export function FinanceScreen() {
  const { t } = useTranslation();
  const trieu = useMoneyShort();
  const { page, phanTrang } = useListPaging(LIMIT);
  const [dangXuLy, setDangXuLy] = useState<WithdrawalRow | null>(null);

  const tongHop = useFinanceSummary();
  const lenhRut = useWithdrawals({ page, limit: LIMIT });
  const data = tongHop.data;
  const csv = useCsvExport();

  const xuatFileChuyenKhoan = () =>
    void csv.xuat<WithdrawalRow>({
      tai: (trang, limit) => financeApi.getWithdrawals({ status: 'PENDING', page: trang, limit }),
      tenFile: 'lenh-rut-cho-chuyen.csv',
      tieuDe: [
        t('taiChinh.csv.nganHang'),
        t('taiChinh.csv.soTaiKhoan'),
        t('taiChinh.csv.chuTaiKhoan'),
        t('taiChinh.csv.soTien'),
        t('taiChinh.csv.noiDung'),
        t('taiChinh.csv.nguoiCham'),
        t('taiChinh.csv.taoLuc'),
      ],
      dong: (row) => [
        row.bankName,
        row.accountNumber,
        row.accountHolder,
        row.amount,
        t('taiChinh.csv.noiDungChuyen', { id: row.id }),
        row.sitterName,
        row.createdAt,
      ],
    });

  const columns: Array<Column<WithdrawalRow>> = [
    {
      key: 'sitter',
      header: t('taiChinh.cot.nguoiCham'),
      width: 168,
      cell: (row) => <span className="text-label text-primary">{row.sitterName}</span>,
    },
    {
      key: 'account',
      header: t('taiChinh.cot.taiKhoanNhan'),
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">
            {row.bankName} · {row.accountNumber}
          </p>
          <p className="truncate text-caption-sm text-text-secondary">{row.accountHolder}</p>
        </div>
      ),
    },
    {
      key: 'amount',
      header: t('taiChinh.cot.soTien'),
      width: 132,
      align: 'right',
      cell: (row) => <span className="text-label">{formatMoney(row.amount)}</span>,
    },
    {
      key: 'fee',
      header: t('taiChinh.cot.phiChuyen'),
      width: 104,
      align: 'right',
      cell: (row) => <span className="text-label">{formatMoney(row.fee)}</span>,
    },
    {
      key: 'createdAt',
      header: t('taiChinh.cot.taoLuc'),
      width: 132,
      cell: (row) => (
        <span className="text-label font-normal text-text-secondary">
          {formatDate(row.createdAt).slice(0, 5)} · {formatTime(row.createdAt)}
        </span>
      ),
    },
    {
      key: 'reference',
      header: t('taiChinh.cot.maThamChieu'),
      width: 140,
      cell: (row) => <MaThamChieu row={row} />,
    },
    {
      key: 'status',
      header: t('taiChinh.cot.trangThai'),
      width: 148,
      cell: (row) => <WithdrawalStatusBadge status={row.status} />,
    },
  ];

  return (
    <div className="flex flex-col gap-block pb-block">
      <div className="grid grid-cols-4 gap-block">
        {tongHop.isPending ? (
          Array.from({ length: 4 }).map((_, index) => <StatCardSkeleton key={index} />)
        ) : tongHop.isError || !data ? (
          <div className="col-span-4 rounded-card border border-neutral-light bg-surface">
            <ErrorState onRetry={() => void tongHop.refetch()} />
          </div>
        ) : (
          <>
            <StatCard
              label={t('taiChinh.chiSo.tongGiaTriDon')}
              value={trieu(data.totalOrderValue)}
              icon={Receipt}
              delta={data.deltas.totalOrderValue ?? undefined}
              hint={t('taiChinh.chiSo.donDaTraTien', { count: data.paidBookings })}
            />
            <StatCard
              label={t('taiChinh.chiSo.hoaHongNenTang')}
              value={trieu(data.commission)}
              icon={CircleCheck}
              delta={data.deltas.commission ?? undefined}
              hint={t('taiChinh.chiSo.tyLeNenTang', {
                value: formatPercent(data.commissionRate * 100, 0),
              })}
            />
            <StatCard
              label={t('taiChinh.chiSo.dangGiuEscrow')}
              value={trieu(data.escrowHeld)}
              icon={Users}
              delta={data.deltas.escrowHeld ?? undefined}
              hint={t('taiChinh.chiSo.escrowPhu', { count: data.escrowBookings })}
            />
            <StatCard
              label={t('taiChinh.chiSo.daNhaVaoVi')}
              value={trieu(data.releasedToWallet)}
              icon={Clock}
              delta={data.deltas.releasedToWallet ?? undefined}
              hint={t('taiChinh.chiSo.daNhaPhu')}
            />
          </>
        )}
      </div>

      <div className="grid grid-cols-3 gap-block">
        <SectionCard
          title={t('taiChinh.doanhThuTheoTuan')}
          subtitle={t('dashboard.donViTrieu')}
          action={<RevenueLegend />}
          className="col-span-2"
        >
          {tongHop.isPending ? (
            <Skeleton className="h-[220px] w-full" />
          ) : tongHop.isError || !data ? (
            <ErrorState onRetry={() => void tongHop.refetch()} />
          ) : (
            <WeeklyRevenueChart data={data.byWeek} />
          )}
        </SectionCard>

        <SectionCard
          title={t('taiChinh.topNcc')}
          subtitle={t('taiChinh.topKy', { period: data?.topPeriodLabel ?? '' })}
        >
          {tongHop.isPending ? (
            <div className="flex flex-col gap-item">
              {Array.from({ length: 5 }).map((_, index) => (
                <Skeleton key={index} className="h-[44px] w-full" />
              ))}
            </div>
          ) : tongHop.isError || !data ? (
            <ErrorState onRetry={() => void tongHop.refetch()} />
          ) : (
            <TopSittersList data={data.topSitters} />
          )}
        </SectionCard>
      </div>

      <SectionCard
        title={t('taiChinh.lenhRut')}
        subtitle={t('taiChinh.lenhRutPhu')}
        action={
          <Button
            variant="secondary"
            size="sm"
            onClick={xuatFileChuyenKhoan}
            loading={csv.dangXuat}
          >
            {t('taiChinh.xuatFile')}
          </Button>
        }
        bodyClassName="px-0 pb-0"
      >
        <DataTable
          columns={columns}
          rows={lenhRut.data?.items ?? []}
          rowKey={(row) => row.id}
          status={trangThaiBang(lenhRut)}
          onRetry={() => void lenhRut.refetch()}
          className="rounded-none border-0"
          onRowClick={(row) => setDangXuLy(row)}
          emptyMessage={t('taiChinh.chuaCoLenhRut')}
          pagination={phanTrang(lenhRut.data?.total)}
        />
      </SectionCard>

      <EnumNote>{t('taiChinh.ghiChuEnum')}</EnumNote>

      <WithdrawalDialog row={dangXuLy} onClose={() => setDangXuLy(null)} />
    </div>
  );
}

function MaThamChieu({ row }: { row: WithdrawalRow }) {
  const { t } = useTranslation();
  if (row.reference) {
    return <span className="text-label">{row.reference}</span>;
  }
  return (
    <span className="text-label font-normal text-text-secondary">
      {row.status === 'REJECTED' ? t('taiChinh.hoanSoDu') : t('taiChinh.chuaCoMa')}
    </span>
  );
}
