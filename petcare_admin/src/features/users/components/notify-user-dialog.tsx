import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Field, TextInput } from '@/components/ui/field';
import { Modal } from '@/components/ui/modal';
import { useBroadcast } from '@/features/notifications/hooks/use-notifications';
import { getErrorMessage } from '@/lib/api/client';
import { notify } from '@/lib/toast';

const TIEU_DE_TOI_THIEU = 6;
const TIEU_DE_TOI_DA = 120;
const NOI_DUNG_TOI_THIEU = 10;
const NOI_DUNG_TOI_DA = 500;

type NotifyUserDialogProps = {
  open: boolean;
  onClose: () => void;
  userId: string;
  fullName: string;
};

export function NotifyUserDialog({
  open,
  onClose,
  userId,
  fullName,
}: NotifyUserDialogProps) {
  const { t } = useTranslation();
  const gui = useBroadcast();
  const [tieuDe, setTieuDe] = useState('');
  const [noiDung, setNoiDung] = useState('');

  const dong = () => {
    setTieuDe('');
    setNoiDung('');
    onClose();
  };

  const dienDu =
    tieuDe.trim().length >= TIEU_DE_TOI_THIEU &&
    noiDung.trim().length >= NOI_DUNG_TOI_THIEU;

  return (
    <Modal
      open={open}
      onOpenChange={(mo) => (mo ? undefined : dong())}
      title={t('nguoiDung.dialogThongBao.tieuDe')}
      description={t('nguoiDung.dialogThongBao.moTa', { name: fullName })}
      confirmLabel={t('nguoiDung.chiTiet.guiThongBao')}
      confirmDisabled={!dienDu}
      loading={gui.isPending}
      onConfirm={() =>
        gui.mutate(
          {
            title: tieuDe.trim(),
            body: noiDung.trim(),
            audienceKind: 'SINGLE_USER',
            audienceValue: userId,
            urgent: false,
          },
          {
            onSuccess: () => {
              notify.success(t('nguoiDung.dialogThongBao.daGui'));
              dong();
            },
            onError: (error) => notify.error(getErrorMessage(error)),
          },
        )
      }
    >
      <div className="flex flex-col gap-stack">
        <Field label={t('nguoiDung.dialogThongBao.truongTieuDe')}>
          <TextInput
            value={tieuDe}
            maxLength={TIEU_DE_TOI_DA}
            placeholder={t('nguoiDung.dialogThongBao.tieuDeGoiY')}
            onChange={(event) => setTieuDe(event.target.value)}
          />
        </Field>
        <Field label={t('nguoiDung.dialogThongBao.truongNoiDung')}>
          <textarea
            value={noiDung}
            maxLength={NOI_DUNG_TOI_DA}
            rows={4}
            placeholder={t('nguoiDung.dialogThongBao.noiDungGoiY')}
            onChange={(event) => setNoiDung(event.target.value)}
            className="w-full resize-none rounded-card border border-neutral bg-surface px-item py-item text-label font-normal text-text-primary placeholder:text-text-secondary focus:border-primary focus:outline-none"
          />
        </Field>
      </div>
    </Modal>
  );
}
