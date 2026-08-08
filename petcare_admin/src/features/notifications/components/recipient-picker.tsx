import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from '@tanstack/react-query';
import { Check } from 'lucide-react';
import { SearchField } from '@/components/ui/search-field';
import { EmptyState } from '@/components/state/empty-state';
import { ErrorState } from '@/components/state/error-state';
import { Skeleton } from '@/components/state/skeleton';
import { usersApi } from '@/features/users/api/users-api';
import type { UserRow } from '@/features/users/types';
import { cn } from '@/lib/utils';

const SO_GOI_Y = 5;
const TU_KHOA_TOI_THIEU = 2;

type RecipientPickerProps = {
  value: string | null;
  onChange: (id: string | null, ten: string | null) => void;
};

export function RecipientPicker({ value, onChange }: RecipientPickerProps) {
  const { t } = useTranslation();
  const [tuKhoa, setTuKhoa] = useState('');
  const duTuKhoa = tuKhoa.trim().length >= TU_KHOA_TOI_THIEU;

  const goiY = useQuery({
    queryKey: ['admin', 'notifications', 'recipient', tuKhoa],
    queryFn: () =>
      usersApi.getUsers({ q: tuKhoa.trim(), active: true, limit: SO_GOI_Y }),
    enabled: duTuKhoa,
    staleTime: 30_000,
  });

  const chon = (nguoi: UserRow) => {
    onChange(nguoi.id === value ? null : nguoi.id, nguoi.fullName);
  };

  return (
    <div className="flex flex-col gap-label">
      <SearchField
        value={tuKhoa}
        onChange={setTuKhoa}
        placeholder={t('thongBao.truong.timNguoiNhan')}
      />
      {!duTuKhoa ? (
        <p className="text-caption-sm text-text-secondary">
          {t('thongBao.truong.goiYTimNguoiNhan')}
        </p>
      ) : goiY.isPending ? (
        <Skeleton className="h-[52px] w-full" />
      ) : goiY.isError ? (
        <ErrorState onRetry={() => void goiY.refetch()} />
      ) : (goiY.data?.items ?? []).length === 0 ? (
        <EmptyState message={t('thongBao.truong.khongThayNguoiNhan')} />
      ) : (
        <ul className="flex flex-col gap-text">
          {(goiY.data?.items ?? []).map((nguoi) => (
            <li key={nguoi.id}>
              <button
                type="button"
                onClick={() => chon(nguoi)}
                className={cn(
                  'flex w-full items-center justify-between gap-item rounded-card border px-item py-label text-left',
                  nguoi.id === value
                    ? 'border-primary bg-card-mint'
                    : 'border-neutral-light hover:bg-card-mint',
                )}
              >
                <span className="min-w-0">
                  <span className="block truncate text-label">{nguoi.fullName}</span>
                  <span className="block truncate text-caption-sm text-text-secondary">
                    {nguoi.email}
                  </span>
                </span>
                {nguoi.id === value ? (
                  <Check className="h-4 w-4 shrink-0 text-primary" strokeWidth={2} />
                ) : null}
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
