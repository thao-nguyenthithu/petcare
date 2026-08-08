import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { CalendarDays, UserCheck, Users, Wallet } from 'lucide-react';
import { useDashboard, useQueue } from '@/features/dashboard/hooks/use-dashboard';
import { RevenueChart, RevenueLegend } from '@/features/dashboard/components/revenue-chart';
import { ServiceMixChart } from '@/features/dashboard/components/service-mix-chart';
import { RecentBookingsTable } from '@/features/dashboard/components/recent-bookings-table';
import { QueueList } from '@/features/dashboard/components/queue-list';
import { SectionCard } from '@/components/ui/section-card';
import { StatCard, StatCardSkeleton } from '@/components/ui/stat-card';
import { Skeleton } from '@/components/state/skeleton';
import { ErrorState } from '@/components/state/error-state';
import { trangThaiBang } from '@/lib/table-status';
import { useMoneyShort } from '@/lib/use-money-short';
import { PATHS } from '@/routes/paths';

export function DashboardScreen() {
  const { t } = useTranslation();
  const trieu = useMoneyShort();
  const dashboard = useDashboard();
  const queue = useQueue();
  const data = dashboard.data;

  return (
    <div className="flex flex-col gap-block pb-block">
      <div className="grid grid-cols-4 gap-block">
        {dashboard.isPending ? (
          Array.from({ length: 4 }).map((_, index) => <StatCardSkeleton key={index} />)
        ) : dashboard.isError || !data ? (
          <div className="col-span-4 rounded-card border border-neutral-light bg-surface">
            <ErrorState onRetry={() => void dashboard.refetch()} />
          </div>
        ) : (
          <>
            <StatCard
              label={t('dashboard.chiSo.nguoiDung')}
              value={new Intl.NumberFormat('vi-VN').format(data.users.total)}
              icon={Users}
              delta={data.users.delta ?? undefined}
              hint={t('dashboard.chiSo.soVoiThangTruoc')}
            />
            <StatCard
              label={t('dashboard.chiSo.nccHoatDong')}
              value={new Intl.NumberFormat('vi-VN').format(data.sitters.active)}
              icon={UserCheck}
              delta={data.sitters.delta ?? undefined}
              hint={t('dashboard.chiSo.hoSoChoDuyet', { count: data.sitters.pending })}
            />
            <StatCard
              label={t('dashboard.chiSo.donThang')}
              value={new Intl.NumberFormat('vi-VN').format(data.bookings.thisMonth)}
              icon={CalendarDays}
              delta={data.bookings.delta ?? undefined}
              hint={t('dashboard.chiSo.donDangDienRa', { count: data.bookings.ongoing })}
            />
            <StatCard
              label={t('dashboard.chiSo.doanhThuThang')}
              value={trieu(data.revenue.total)}
              icon={Wallet}
              delta={data.revenue.delta ?? undefined}
              hint={t('dashboard.chiSo.hoaHongEscrow', {
                commission: trieu(data.revenue.commission),
                escrow: trieu(data.revenue.escrowHeld),
              })}
            />
          </>
        )}
      </div>

      <div className="grid grid-cols-3 gap-block">
        <SectionCard
          title={t('dashboard.doanhThu12Thang')}
          subtitle={t('dashboard.donViTrieu')}
          action={<RevenueLegend />}
          className="col-span-2"
        >
          {dashboard.isPending ? (
            <Skeleton className="h-[196px] w-full" />
          ) : dashboard.isError || !data ? (
            <ErrorState onRetry={() => void dashboard.refetch()} />
          ) : (
            <RevenueChart data={data.revenueByMonth} />
          )}
        </SectionCard>

        <SectionCard title={t('dashboard.coCauDichVu')} subtitle={t('dashboard.theoSoDonThang')}>
          {dashboard.isPending ? (
            <Skeleton className="h-[148px] w-full" />
          ) : dashboard.isError || !data ? (
            <ErrorState onRetry={() => void dashboard.refetch()} />
          ) : (
            <ServiceMixChart data={data.serviceMix} />
          )}
        </SectionCard>
      </div>

      <div className="grid grid-cols-3 gap-block">
        <SectionCard
          title={t('dashboard.donGanDay')}
          subtitle={t('dashboard.donGanDayPhu')}
          action={
            <Link to={PATHS.bookings} className="text-label text-primary hover:underline">
              {t('dashboard.xemTatCa')}
            </Link>
          }
          className="col-span-2"
          bodyClassName="px-0 pb-0"
        >
          <RecentBookingsTable
            rows={data?.recentBookings ?? []}
            status={trangThaiBang(dashboard)}
            onRetry={() => void dashboard.refetch()}
          />
        </SectionCard>

        <SectionCard title={t('queue.canXuLy')} subtitle={t('queue.canXuLyPhu')}>
          {queue.isPending ? (
            <div className="flex flex-col gap-item">
              {Array.from({ length: 5 }).map((_, index) => (
                <Skeleton key={index} className="h-[33px] w-full" />
              ))}
            </div>
          ) : queue.isError || !queue.data ? (
            <ErrorState onRetry={() => void queue.refetch()} />
          ) : (
            <QueueList items={queue.data.items} />
          )}
        </SectionCard>
      </div>
    </div>
  );
}
