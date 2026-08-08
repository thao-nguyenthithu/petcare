import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Modal } from '@/components/ui/modal';
import { TextInput } from '@/components/ui/field';
import { RunningBookingNotice } from '@/features/users/components/running-booking-notice';
import { useSetUserActive, useUserDetail } from '@/features/users/hooks/use-users';
import type { UserRow } from '@/features/users/types';
import { getErrorMessage } from '@/lib/api/client';
import { notify } from '@/lib/toast';

type LockUserDialogProps = {
  target: Pick<UserRow, 'id' | 'fullName' | 'isActive' | 'role'> | null;
  onClose: () => void;
};

export function LockUserDialog({ target, onClose }: LockUserDialogProps) {
  const { t } = useTranslation();
  const [reason, setReason] = useState('');
  const doiTrangThai = useSetUserActive();

  const dangKhoa = target?.isActive === true;
  const canKiem = Boolean(target) && dangKhoa;
  const chiTiet = useUserDetail(target?.id ?? '', canKiem);
  const chuaBietSoDon = canKiem && (chiTiet.isPending || chiTiet.isFetching);

  const dong = () => {
    setReason('');
    onClose();
  };

  const xacNhan = () => {
    if (!target) return;
    doiTrangThai.mutate(
      { id: target.id, isActive: !target.isActive, reason: reason.trim() },
      {
        onSuccess: () => {
          notify.success(dangKhoa ? t('nguoiDung.dialog.daKhoa') : t('nguoiDung.dialog.daMoKhoa'));
          dong();
        },
        onError: (error) => notify.error(getErrorMessage(error)),
      },
    );
  };

  return (
    <Modal
      open={Boolean(target)}
      onOpenChange={(open) => {
        if (!open) dong();
      }}
      title={dangKhoa ? t('nguoiDung.dialog.khoaTieuDe') : t('nguoiDung.dialog.moKhoaTieuDe')}
      description={
        dangKhoa
          ? // Nêu rõ hệ quả: hồ sơ người chăm của tài khoản này cũng ngừng nhận đơn
            target?.role === 'PROVIDER'
            ? t('nguoiDung.dialog.khoaMoTaNcc', { name: target?.fullName })
            : t('nguoiDung.dialog.khoaMoTa', { name: target?.fullName })
          : t('nguoiDung.dialog.moKhoaMoTa', { name: target?.fullName })
      }
      confirmLabel={dangKhoa ? t('nguoiDung.dialog.khoaNut') : t('nguoiDung.dialog.moKhoaNut')}
      danger={dangKhoa}
      confirmDisabled={reason.trim().length < 3 || chuaBietSoDon}
      loading={doiTrangThai.isPending}
      onConfirm={xacNhan}
    >
      {canKiem ? (
        <RunningBookingNotice
          isPending={chuaBietSoDon}
          isError={chiTiet.isError}
          count={chiTiet.data?.stats.runningBookingCount}
        />
      ) : null}
      <label className="flex flex-col gap-label">
        <span className="text-label-sm uppercase text-text-primary">
          {t('nguoiDung.dialog.lyDo')}
        </span>
        <TextInput
          value={reason}
          onChange={(event) => setReason(event.target.value)}
          placeholder={t('nguoiDung.dialog.lyDoGoiY')}
        />
      </label>
    </Modal>
  );
}
