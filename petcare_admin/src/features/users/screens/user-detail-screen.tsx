import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useParams } from 'react-router-dom';
import {
  CalendarDays,
  Flag,
  Mail,
  MapPin,
  Phone,
  type LucideIcon,
} from 'lucide-react';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { ImageViewer } from '@/components/ui/image-viewer';
import { useImageViewer, type AnhXem } from '@/components/ui/use-image-viewer';
import { AdminBookingStatusBadge } from '@/features/bookings/components/booking-status-badge';
import { LockUserDialog } from '@/features/users/components/lock-user-dialog';
import { NotifyUserDialog } from '@/features/users/components/notify-user-dialog';
import {
  UserAvatar,
  UserRoleBadge,
  UserStatusBadge,
} from '@/features/users/components/user-badges';
import { useUserDetail } from '@/features/users/hooks/use-users';
import type { UserActivityKind, UserDetail } from '@/features/users/types';
import { Button } from '@/components/ui/button';
import { PageHeader } from '@/components/ui/page-header';
import { SectionCard } from '@/components/ui/section-card';
import { StatCard, StatCardSkeleton } from '@/components/ui/stat-card';
import { EmptyState } from '@/components/state/empty-state';
import { Skeleton } from '@/components/state/skeleton';
import { ErrorState } from '@/components/state/error-state';
import { formatDate, formatDateTime, formatMoney } from '@/lib/format';
import { useMoneyShort } from '@/lib/use-money-short';
import { PATHS } from '@/routes/paths';

const ICON_HOAT_DONG: Record<UserActivityKind, LucideIcon> = {
  BOOKING: CalendarDays,
  DISPUTE: Flag,
};

const ICON_HOAT_DONG_MAC_DINH = CalendarDays;

export function UserDetailScreen() {
  const { t } = useTranslation();
  const { id = '' } = useParams();
  const chiTiet = useUserDetail(id);
  const moneyShort = useMoneyShort();
  const [moDialogKhoa, setMoDialogKhoa] = useState(false);
  const [moDialogThongBao, setMoDialogThongBao] = useState(false);

  if (chiTiet.isError) {
    return <ErrorState onRetry={() => void chiTiet.refetch()} />;
  }

  const data = chiTiet.data;

  return (
    <div className="flex flex-col gap-stack pb-block">
      <PageHeader
        backTo={PATHS.users}
        crumbs={[
          { label: t('man.nguoiDung.title'), to: PATHS.users },
          { label: data?.user.fullName ?? '' },
        ]}
        actions={
          data ? (
            <>
              <Button
                variant="ghost"
                disabled={!data.user.isActive}
                title={
                  data.user.isActive ? undefined : t('nguoiDung.chiTiet.daKhoaKhongGuiDuoc')
                }
                onClick={() => setMoDialogThongBao(true)}
              >
                {t('nguoiDung.chiTiet.guiThongBao')}
              </Button>
              <Button variant="danger" onClick={() => setMoDialogKhoa(true)}>
                {data.user.isActive
                  ? t('nguoiDung.chiTiet.khoaTaiKhoan')
                  : t('nguoiDung.chiTiet.moKhoaTaiKhoan')}
              </Button>
            </>
          ) : null
        }
      />

      <div className="grid grid-cols-3 gap-stack">
        <div className="flex flex-col gap-stack">
          {chiTiet.isPending || !data ? (
            <Skeleton className="h-[420px] w-full rounded-card" />
          ) : (
            <>
              <HoSoCard data={data} />
              <ThuCungCard data={data} userId={id} />
              <SoDiaChiCard data={data} />
            </>
          )}
        </div>

        <div className="col-span-2 flex flex-col gap-stack">
          <div className="grid grid-cols-5 gap-stack">
            {chiTiet.isPending || !data ? (
              Array.from({ length: 4 }).map((_, index) => (
                <StatCardSkeleton key={index} className={index === 1 ? 'col-span-2' : undefined} />
              ))
            ) : (
              <>
                <StatCard
                  label={t('nguoiDung.chiSo.tongDon')}
                  value={String(data.stats.bookingCount)}
                  hint={t('nguoiDung.chiSo.donDangMo', { count: data.stats.openBookingCount })}
                />
                <StatCard
                  label={t('nguoiDung.chiSo.daChiTieu')}
                  value={moneyShort(data.stats.totalSpent)}
                  className="col-span-2"
                  hint={
                    data.stats.avgPerBooking === null
                      ? undefined
                      : t('nguoiDung.chiSo.trungBinhMoiDon', {
                          value: formatMoney(data.stats.avgPerBooking),
                        })
                  }
                />
                <StatCard
                  label={t('nguoiDung.chiSo.danhGiaDaGui')}
                  value={String(data.stats.reviewCount)}
                  hint={
                    data.stats.avgRating === null
                      ? undefined
                      : t('nguoiDung.chiSo.diemTrungBinh', {
                          value: data.stats.avgRating.toFixed(1),
                        })
                  }
                />
                <StatCard
                  label={t('nguoiDung.chiSo.baoCaoLienQuan')}
                  value={String(data.stats.disputeCount)}
                  tone="accent"
                  hint={t('nguoiDung.chiSo.daXuLy', { count: data.stats.resolvedDisputeCount })}
                />
              </>
            )}
          </div>

          <SectionCard
            title={t('nguoiDung.chiTiet.lichSuDon')}
            subtitle={
              data
                ? t('nguoiDung.chiTiet.lichSuDonPhu', {
                    total: data.stats.bookingCount,
                    open: data.stats.openBookingCount,
                  })
                : undefined
            }
            action={
              <Link to={PATHS.bookings} className="text-label text-primary hover:underline">
                {t('dashboard.xemTatCa')}
              </Link>
            }
          >
            {chiTiet.isPending || !data ? (
              <Skeleton className="h-40 w-full" />
            ) : data.recentBookings.length === 0 ? (
              <EmptyState message={t('nguoiDung.chiTiet.chuaCoDon')} />
            ) : (
              <table className="w-full table-fixed border-collapse">
                <thead>
                  <tr className="bg-card-mint/50">
                    <th className="w-[132px] px-item py-label text-left text-label-sm text-text-secondary">
                      {t('dashboard.cot.maDon')}
                    </th>
                    <th className="px-item py-label text-left text-label-sm text-text-secondary">
                      {t('dashboard.cot.dichVu')}
                    </th>
                    <th className="w-[168px] px-item py-label text-left text-label-sm text-text-secondary">
                      {t('nguoiDung.cot.nhaCungCap')}
                    </th>
                    <th className="w-[116px] px-item py-label text-right text-label-sm text-text-secondary">
                      {t('dashboard.cot.giaTri')}
                    </th>
                    <th className="w-[152px] px-item py-label text-left text-label-sm text-text-secondary">
                      {t('dashboard.cot.trangThai')}
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {data.recentBookings.map((row) => (
                    <tr key={row.code} className="border-t border-neutral-light">
                      <td className="px-item py-item">
                        <p className="truncate text-label text-primary">{row.code}</p>
                        <p className="truncate text-caption-sm text-text-secondary">
                          {formatDate(row.createdAt)}
                        </p>
                      </td>
                      <td className="px-item py-item">
                        <p className="truncate text-label">
                          {row.serviceName ?? <KhongCoDuLieu />}
                        </p>
                        <p className="truncate text-caption-sm text-text-secondary">
                          {row.petNames}
                        </p>
                      </td>
                      <td className="truncate px-item py-item text-label">
                        {row.sitterName ?? <KhongCoDuLieu />}
                      </td>
                      <td className="px-item py-item text-right text-label">
                        {row.totalPrice === null ? <KhongCoDuLieu /> : formatMoney(row.totalPrice)}
                      </td>
                      <td className="px-item py-item">
                        <AdminBookingStatusBadge status={row.status} />
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </SectionCard>

          <SectionCard
            title={t('nguoiDung.chiTiet.nhatKy')}
            subtitle={t('nguoiDung.chiTiet.nhatKyPhu')}
          >
            {chiTiet.isPending || !data ? (
              <Skeleton className="h-28 w-full" />
            ) : data.activities.length === 0 ? (
              <EmptyState message={t('nguoiDung.chiTiet.chuaCoHoatDong')} />
            ) : (
              <ul className="flex flex-col gap-stack">
                {data.activities.map((item) => {
                  const Icon = ICON_HOAT_DONG[item.kind] ?? ICON_HOAT_DONG_MAC_DINH;
                  return (
                    <li key={`${item.kind}-${item.at}`} className="flex items-start gap-item">
                      <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-card bg-card-mint">
                        <Icon className="h-4 w-4 text-primary" strokeWidth={1.8} />
                      </span>
                      <div className="min-w-0">
                        <p className="truncate text-label">{item.title}</p>
                        <p className="truncate text-caption-sm text-text-secondary">
                          {formatDateTime(item.at)} · {item.detail}
                        </p>
                      </div>
                    </li>
                  );
                })}
              </ul>
            )}
          </SectionCard>
        </div>
      </div>

      <LockUserDialog
        target={moDialogKhoa && data ? data.user : null}
        onClose={() => setMoDialogKhoa(false)}
      />

      {data ? (
        <NotifyUserDialog
          open={moDialogThongBao}
          onClose={() => setMoDialogThongBao(false)}
          userId={data.user.id}
          fullName={data.user.fullName}
        />
      ) : null}
    </div>
  );
}

function HoSoCard({ data }: { data: UserDetail }) {
  const { t } = useTranslation();
  const xem = useImageViewer();
  const anh: AnhXem[] = data.user.avatarUrl
    ? [{ url: data.user.avatarUrl, nhan: data.user.fullName }]
    : [];
  const dong: Array<{ icon: LucideIcon; label: string; value: string | null }> = [
    { icon: Phone, label: t('nguoiDung.hoSo.soDienThoai'), value: data.user.phone },
    { icon: Mail, label: t('nguoiDung.hoSo.email'), value: data.user.email },
    {
      icon: MapPin,
      label: t('nguoiDung.hoSo.diaChiMacDinh'),
      value: data.user.defaultAddress,
    },
    {
      icon: CalendarDays,
      label: t('nguoiDung.hoSo.ngayThamGia'),
      value: formatDate(data.user.createdAt),
    },
  ];

  return (
    <div className="rounded-card border border-neutral-light bg-surface p-block">
      <div className="flex flex-col items-center gap-item">
        {data.user.avatarUrl ? (
          <button type="button" aria-label={t('xemAnh.moAnh')} onClick={() => xem.mo(0)}>
            <UserAvatar name={data.user.fullName} url={data.user.avatarUrl} size={80} />
          </button>
        ) : (
          <UserAvatar name={data.user.fullName} url={null} size={80} />
        )}
        <p className="text-h3">{data.user.fullName}</p>
        <div className="flex items-center gap-label">
          <UserRoleBadge role={data.user.role} isSitter={data.user.isSitter} />
          <UserStatusBadge isActive={data.user.isActive} isVerified={data.user.isVerified} />
        </div>
      </div>

      <ul className="mt-block flex flex-col gap-stack border-t border-neutral-light pt-block">
        {dong.map((item) => (
          <li key={item.label} className="flex items-start gap-item">
            <item.icon
              className="mt-[2px] h-[18px] w-[18px] shrink-0 text-text-secondary"
              strokeWidth={1.8}
            />
            <div className="min-w-0">
              <p className="text-caption-sm text-text-secondary">{item.label}</p>
              <p className="break-words text-label">{item.value ?? <KhongCoDuLieu />}</p>
            </div>
          </li>
        ))}
      </ul>

      <ImageViewer anh={anh} moTai={xem.moTai} onDong={xem.dong} />
    </div>
  );
}

function ThuCungCard({ data, userId }: { data: UserDetail; userId: string }) {
  const { t } = useTranslation();
  const dangHoatDong = data.pets.filter((pet) => pet.isActive).length;

  return (
    <SectionCard
      title={t('nguoiDung.hoSo.thuCung')}
      subtitle={t('nguoiDung.hoSo.hoSoDangHoatDong', { count: dangHoatDong })}
    >
      {data.pets.length === 0 ? (
        <EmptyState message={t('nguoiDung.hoSo.chuaCoBe')} />
      ) : (
        <ul className="flex flex-col gap-item">
          {data.pets.map((pet) => (
            <li
              key={pet.id}
              className="flex items-center gap-item rounded-card border border-neutral-light p-item"
            >
              {pet.avatarUrl ? (
                <img
                  src={pet.avatarUrl}
                  alt={pet.name}
                  className="h-8 w-8 shrink-0 rounded-full object-cover"
                />
              ) : (
                <img src="/paw.svg" alt="" aria-hidden className="h-8 w-8 shrink-0" />
              )}
              <div className="min-w-0 flex-1">
                <p className="truncate text-label">{pet.name}</p>
                <p className="truncate text-caption-sm text-text-secondary">
                  {[pet.breed, pet.ageLabel].filter(Boolean).join(' · ')}
                </p>
              </div>
              <Link
                to={`${PATHS.users}/${userId}/pets`}
                className="shrink-0 text-label text-primary hover:underline"
              >
                {t('nguoiDung.hoSo.chiTiet')}
              </Link>
            </li>
          ))}
        </ul>
      )}
    </SectionCard>
  );
}

function SoDiaChiCard({ data }: { data: UserDetail }) {
  const { t } = useTranslation();

  return (
    <SectionCard
      title={t('nguoiDung.hoSo.soDiaChi')}
      subtitle={t('nguoiDung.hoSo.soDiaChiPhu', { count: data.addresses.length })}
    >
      {data.addresses.length === 0 ? (
        <EmptyState message={t('nguoiDung.hoSo.chuaCoDiaChi')} />
      ) : (
        <ul className="flex flex-col gap-item">
          {data.addresses.map((item) => (
            <li
              key={item.id}
              className="flex items-center gap-item rounded-card border border-neutral-light p-item"
            >
              <MapPin className="h-[18px] w-[18px] shrink-0 text-primary" strokeWidth={1.8} />
              <div className="min-w-0 flex-1">
                <p className="truncate text-label">
                  {item.customLabel ?? t(`nguoiDung.nhanDiaChi.${item.label}`)}
                </p>
                <p className="truncate text-caption-sm text-text-secondary">{item.text}</p>
              </div>
              {item.isDefault ? (
                <span className="shrink-0 text-label text-primary">
                  {t('nguoiDung.hoSo.macDinh')}
                </span>
              ) : null}
            </li>
          ))}
        </ul>
      )}
    </SectionCard>
  );
}
