import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useParams } from 'react-router-dom';
import { Check, Clock, EyeOff, ImageIcon } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { ImageViewer } from '@/components/ui/image-viewer';
import { useImageViewer, type AnhXem } from '@/components/ui/use-image-viewer';
import { PageHeader } from '@/components/ui/page-header';
import { SearchField } from '@/components/ui/search-field';
import { SectionCard } from '@/components/ui/section-card';
import { TextInput } from '@/components/ui/field';
import { Modal } from '@/components/ui/modal';
import { Skeleton } from '@/components/state/skeleton';
import { EmptyState } from '@/components/state/empty-state';
import { ErrorState } from '@/components/state/error-state';
import {
  usePetPreventions,
  useSetPetActive,
  useUserDetail,
  useUserPets,
} from '@/features/users/hooks/use-users';
import type { PetDetail } from '@/features/users/types';
import { formatDate } from '@/lib/format';
import { nhanTuoi } from '@/lib/labels';
import { getErrorMessage } from '@/lib/api/client';
import { notify } from '@/lib/toast';
import { cn } from '@/lib/utils';
import { PATHS } from '@/routes/paths';

function PetBadge({ pet }: { pet: PetDetail }) {
  const { t } = useTranslation();
  if (!pet.isActive) {
    return (
      <Badge tone="neutral" icon={EyeOff}>
        {t('thuCung.badge.daAn')}
      </Badge>
    );
  }
  if (pet.preventionCount === 0) {
    return (
      <Badge tone="pending" icon={Clock}>
        {t('thuCung.badge.thieuSoTiem')}
      </Badge>
    );
  }
  return (
    <Badge tone="success" icon={Check}>
      {t('thuCung.badge.dangHoatDong')}
    </Badge>
  );
}

export function UserPetsScreen() {
  const { t } = useTranslation();
  const { id = '' } = useParams();
  const chuNuoi = useUserDetail(id);
  const danhSach = useUserPets(id);
  const doiTrangThai = useSetPetActive();

  const [keyword, setKeyword] = useState('');
  const [petId, setPetId] = useState<string | null>(null);
  const [moDialogAn, setMoDialogAn] = useState(false);
  const [reason, setReason] = useState('');

  const pets = useMemo(() => danhSach.data?.items ?? [], [danhSach.data]);
  const locTheoTen = useMemo(
    () => pets.filter((pet) => pet.name.toLowerCase().includes(keyword.trim().toLowerCase())),
    [pets, keyword],
  );
  const dangChon = pets.find((pet) => pet.id === petId) ?? pets[0] ?? null;

  const anHoSo = () => {
    if (!dangChon) return;
    doiTrangThai.mutate(
      { id: dangChon.id, isActive: !dangChon.isActive, reason: reason.trim() },
      {
        onSuccess: () => {
          notify.success(dangChon.isActive ? t('thuCung.daAn') : t('thuCung.daHien'));
          setMoDialogAn(false);
          setReason('');
        },
        onError: (error) => notify.error(getErrorMessage(error)),
      },
    );
  };

  if (danhSach.isError) return <ErrorState onRetry={() => void danhSach.refetch()} />;

  return (
    <div className="flex flex-col gap-stack pb-block">
      <PageHeader
        backTo={`${PATHS.users}/${id}`}
        crumbs={[
          { label: t('man.nguoiDung.title'), to: PATHS.users },
          { label: chuNuoi.data?.user.fullName ?? '', to: `${PATHS.users}/${id}` },
          { label: t('thuCung.tieuDe') },
        ]}
        actions={
          <Button variant="danger" disabled={!dangChon} onClick={() => setMoDialogAn(true)}>
            {dangChon?.isActive === false ? t('thuCung.hienHoSo') : t('thuCung.anHoSo')}
          </Button>
        }
      />

      <div className="grid grid-cols-3 gap-stack">
        <SectionCard
          title={t('thuCung.danhSach')}
          subtitle={t('thuCung.soBe', { count: pets.length })}
        >
          <SearchField
            value={keyword}
            onChange={setKeyword}
            placeholder={t('thuCung.timTheoTen')}
            debounceMs={0}
            className="mb-item"
          />
          {danhSach.isPending ? (
            <div className="flex flex-col gap-item">
              {Array.from({ length: 5 }).map((_, index) => (
                <Skeleton key={index} className="h-16 w-full rounded-card" />
              ))}
            </div>
          ) : locTheoTen.length === 0 ? (
            <EmptyState
              variant={keyword ? 'no-match' : 'no-data'}
              message={keyword ? t('thuCung.khongKhopTen') : t('thuCung.chuaCoBe')}
              onAction={() => setKeyword('')}
            />
          ) : (
            <ul className="flex flex-col gap-item">
              {locTheoTen.map((pet) => (
                <li key={pet.id}>
                  <button
                    type="button"
                    onClick={() => setPetId(pet.id)}
                    className={cn(
                      'flex w-full items-center gap-item rounded-card border p-item text-left transition-colors',
                      pet.id === dangChon?.id
                        ? 'border-primary bg-card-mint/50'
                        : 'border-neutral-light hover:bg-card-mint/30',
                    )}
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
                        {[
                          pet.breed,
                          pet.gender ? t(`thuCung.gioiTinh.${pet.gender}`) : null,
                          nhanTuoi(t, pet.birthDate),
                          pet.weightKg ? `${pet.weightKg} kg` : null,
                        ]
                          .filter(Boolean)
                          .join(' · ')}
                      </p>
                      <span className="mt-text inline-block">
                        <PetBadge pet={pet} />
                      </span>
                    </div>
                  </button>
                </li>
              ))}
            </ul>
          )}
        </SectionCard>

        <div className="col-span-2 flex flex-col gap-stack">
          {danhSach.isPending ? (
            <Skeleton className="h-[320px] w-full rounded-card" />
          ) : !dangChon ? (
            <div className="rounded-card border border-neutral-light bg-surface">
              <EmptyState message={t('thuCung.chuaCoBe')} />
            </div>
          ) : (
            <>
              <HoSoBe pet={dangChon} />
              <SoPhongBenh petId={dangChon.id} />
            </>
          )}
        </div>
      </div>

      <Modal
        open={moDialogAn}
        onOpenChange={(open) => {
          if (!open) {
            setMoDialogAn(false);
            setReason('');
          }
        }}
        title={dangChon?.isActive ? t('thuCung.dialog.anTieuDe') : t('thuCung.dialog.hienTieuDe')}
        description={
          dangChon?.isActive
            ? t('thuCung.dialog.anMoTa', { name: dangChon?.name })
            : t('thuCung.dialog.hienMoTa', { name: dangChon?.name })
        }
        confirmLabel={dangChon?.isActive ? t('thuCung.anHoSo') : t('thuCung.hienHoSo')}
        danger={dangChon?.isActive}
        confirmDisabled={reason.trim().length < 3}
        loading={doiTrangThai.isPending}
        onConfirm={anHoSo}
      >
        <label className="flex flex-col gap-label">
          <span className="text-label-sm uppercase text-text-primary">
            {t('nguoiDung.dialog.lyDo')}
          </span>
          <TextInput value={reason} onChange={(event) => setReason(event.target.value)} />
        </label>
      </Modal>
    </div>
  );
}

function HoSoBe({ pet }: { pet: PetDetail }) {
  const { t } = useTranslation();
  const xem = useImageViewer();
  const anh: AnhXem[] = [
    ...(pet.avatarUrl ? [{ url: pet.avatarUrl, nhan: pet.name }] : []),
    ...pet.photos.map((item) => ({ url: item.url, nhan: pet.name })),
  ];
  const moTa = [
    t(`thuCung.loai.${pet.species}`),
    pet.breed,
    pet.gender ? t(`thuCung.gioiTinh.${pet.gender}`) : null,
    pet.weightKg ? `${pet.weightKg} kg` : null,
    pet.isNeutered ? t('thuCung.daTrietSan') : null,
  ]
    .filter(Boolean)
    .join(' · ');

  const truong: Array<{ label: string; value: string | null }> = [
    {
      label: t('thuCung.truong.ngaySinh'),
      value: pet.birthDate ? formatDate(pet.birthDate) : null,
    },
    { label: t('thuCung.truong.canNang'), value: pet.weightKg ? `${pet.weightKg} kg` : null },
    {
      label: t('thuCung.truong.dangDieuTri'),
      value: pet.underTreatment ? t('chung.co') : t('chung.khong'),
    },
    { label: t('thuCung.truong.benhMan'), value: pet.chronicDisease },
    { label: t('thuCung.truong.thuocDangDung'), value: pet.medication },
    { label: t('thuCung.truong.ghiChu'), value: pet.careNote },
  ];

  return (
    <SectionCard
      title={pet.name}
      subtitle={moTa}
      action={<PetBadge pet={pet} />}
      bodyClassName="px-block pb-block"
    >
      <div className="grid grid-cols-5 gap-item">
        <div className="col-span-2 row-span-2 flex aspect-square items-center justify-center rounded-card bg-neutral-light/60">
          {pet.avatarUrl ? (
            <button
              type="button"
              aria-label={t('xemAnh.moAnh')}
              onClick={() => xem.mo(0)}
              className="h-full w-full"
            >
              <img
                src={pet.avatarUrl}
                alt={pet.name}
                className="h-full w-full rounded-card object-cover"
              />
            </button>
          ) : (
            <ImageIcon className="h-8 w-8 text-neutral" strokeWidth={1.6} />
          )}
        </div>
        {Array.from({ length: Math.max(6, pet.photos.length) }).map((_, index) => {
          const cuaBe = pet.photos[index];
          const viTri = pet.avatarUrl ? index + 1 : index;
          return (
            <div
              key={cuaBe?.id ?? `giu-cho-${index}`}
              className="flex aspect-square items-center justify-center rounded-card bg-neutral-light/60"
            >
              {cuaBe ? (
                <button
                  type="button"
                  aria-label={t('xemAnh.moAnh')}
                  onClick={() => xem.mo(viTri)}
                  className="h-full w-full"
                >
                  <img
                    src={cuaBe.url}
                    alt=""
                    className="h-full w-full rounded-card object-cover"
                  />
                </button>
              ) : (
                <ImageIcon className="h-5 w-5 text-neutral" strokeWidth={1.6} />
              )}
            </div>
          );
        })}
      </div>

      <ImageViewer anh={anh} moTai={xem.moTai} onDong={xem.dong} />

      <dl className="mt-block grid grid-cols-3 gap-item border-t border-neutral-light pt-block">
        {truong.map((item) => (
          <div key={item.label} className="min-w-0">
            <dt className="text-label-sm uppercase text-text-secondary">{item.label}</dt>
            <dd className="mt-text break-words text-label">
              {item.value ?? <KhongCoDuLieu />}
            </dd>
          </div>
        ))}
      </dl>
    </SectionCard>
  );
}

function SoPhongBenh({ petId }: { petId: string }) {
  const { t } = useTranslation();
  const so = usePetPreventions(petId);
  const mui = (so.data?.items ?? []).flatMap((record) =>
    record.doses.map((dose) => ({ record, dose })),
  );

  return (
    <SectionCard
      title={t('thuCung.soPhongBenh')}
      subtitle={t('thuCung.soMuiDaTiem', { count: mui.length })}
    >
      {so.isPending ? (
        <Skeleton className="h-40 w-full rounded-card" />
      ) : so.isError ? (
        <ErrorState message={t('thuCung.loiSoPhongBenh')} onRetry={() => void so.refetch()} />
      ) : mui.length === 0 ? (
        <EmptyState message={t('thuCung.chuaCoMui')} />
      ) : (
        <table className="w-full table-fixed border-collapse">
          <thead>
            <tr className="bg-card-mint/50">
              <th className="px-item py-label text-left text-label-sm text-text-secondary">
                {t('thuCung.cot.hangMuc')}
              </th>
              <th className="w-[140px] px-item py-label text-left text-label-sm text-text-secondary">
                {t('thuCung.cot.ngayThucHien')}
              </th>
              <th className="w-[200px] px-item py-label text-left text-label-sm text-text-secondary">
                {t('thuCung.cot.coSo')}
              </th>
              <th className="w-[140px] px-item py-label text-left text-label-sm text-text-secondary">
                {t('thuCung.cot.nhacLai')}
              </th>
            </tr>
          </thead>
          <tbody>
            {mui.map(({ record, dose }) => (
              <tr key={dose.id} className="border-t border-neutral-light">
                <td className="px-item py-item">
                  <p className="truncate text-label">
                    {record.customName ??
                      t(`thuCung.hangMuc.${record.code}`, t('thuCung.hangMucLa'))}
                  </p>
                  {record.form ? (
                    <p className="truncate text-caption-sm text-text-secondary">
                      {t(`thuCung.hinhThuc.${record.form}`)}
                    </p>
                  ) : null}
                </td>
                <td className="px-item py-item text-label">{formatDate(dose.doneAt)}</td>
                <td className="truncate px-item py-item text-label">
                  {dose.place ?? <KhongCoDuLieu />}
                </td>
                <td className="px-item py-item text-label">
                  {dose.nextDueAt ? formatDate(dose.nextDueAt) : <KhongCoDuLieu />}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </SectionCard>
  );
}
