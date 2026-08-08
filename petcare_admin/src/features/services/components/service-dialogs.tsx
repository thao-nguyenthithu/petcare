import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { TextInput } from '@/components/ui/field';
import { Modal } from '@/components/ui/modal';
import {
  useSetSitterServiceEnabled,
  useUpdateService,
} from '@/features/services/hooks/use-services';
import { DO_DAI_TEN_TOI_THIEU, DO_DAI_LY_DO_TOI_THIEU } from '@/features/services/service-constants';
import type { ServiceRow, SitterServiceRow } from '@/features/services/types';
import { getErrorMessage } from '@/lib/api/client';
import { notify } from '@/lib/toast';

export function SuaDichVuDialog({ row, onClose }: { row: ServiceRow | null; onClose: () => void }) {
  const { t } = useTranslation();
  const capNhat = useUpdateService();
  const [ten, setTen] = useState('');
  const [moTa, setMoTa] = useState('');
  const [loaiDangMo, setLoaiDangMo] = useState<string | null>(null);

  if (row && row.type !== loaiDangMo) {
    setLoaiDangMo(row.type);
    setTen(row.name ?? t(`dashboard.dichVu.${row.type}`));
    setMoTa(row.description ?? '');
  }

  const dong = () => {
    setLoaiDangMo(null);
    onClose();
  };

  const xacNhan = () => {
    if (!row) return;
    capNhat.mutate(
      { type: row.type, input: { name: ten.trim(), description: moTa.trim() } },
      {
        onSuccess: () => {
          notify.success(t('dichVu.dialogSua.daLuu'));
          dong();
        },
        onError: (error) => notify.error(getErrorMessage(error)),
      },
    );
  };

  return (
    <Modal
      open={Boolean(row)}
      onOpenChange={(open) => {
        if (!open) dong();
      }}
      title={t('dichVu.dialogSua.tieuDe')}
      description={t('dichVu.dialogSua.moTa')}
      confirmLabel={t('dichVu.dialogSua.nut')}
      confirmDisabled={ten.trim().length < DO_DAI_TEN_TOI_THIEU}
      loading={capNhat.isPending}
      onConfirm={xacNhan}
    >
      <div className="flex flex-col gap-stack">
        <label className="flex flex-col gap-label">
          <span className="text-label-sm uppercase text-text-primary">
            {t('dichVu.dialogSua.ten')}
          </span>
          <TextInput value={ten} onChange={(event) => setTen(event.target.value)} />
        </label>
        <label className="flex flex-col gap-label">
          <span className="text-label-sm uppercase text-text-primary">
            {t('dichVu.dialogSua.moTaTruong')}
          </span>
          <TextInput
            value={moTa}
            placeholder={t('dichVu.dialogSua.moTaGoiY')}
            onChange={(event) => setMoTa(event.target.value)}
          />
        </label>
        <p className="text-caption-sm text-text-secondary">{t('dichVu.dialogSua.khongDoiGia')}</p>
      </div>
    </Modal>
  );
}

export function KhoaCauHinhDialog({
  row,
  onClose,
}: {
  row: SitterServiceRow | null;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const [lyDo, setLyDo] = useState('');
  const doiTrangThai = useSetSitterServiceEnabled();
  const dangKhoa = row?.enabled === true;

  const dong = () => {
    setLyDo('');
    onClose();
  };

  const xacNhan = () => {
    if (!row) return;
    doiTrangThai.mutate(
      { id: row.id, enabled: !row.enabled, reason: lyDo.trim() },
      {
        onSuccess: () => {
          notify.success(dangKhoa ? t('dichVu.dialogKhoa.daKhoa') : t('dichVu.dialogKhoa.daMo'));
          dong();
        },
        onError: (error) => notify.error(getErrorMessage(error)),
      },
    );
  };

  return (
    <Modal
      open={Boolean(row)}
      onOpenChange={(open) => {
        if (!open) dong();
      }}
      title={dangKhoa ? t('dichVu.dialogKhoa.tieuDe') : t('dichVu.dialogKhoa.tieuDeMo')}
      description={
        dangKhoa
          ? t('dichVu.dialogKhoa.moTa', { name: row?.sitterName })
          : t('dichVu.dialogKhoa.moTaMo', { name: row?.sitterName })
      }
      confirmLabel={dangKhoa ? t('dichVu.dialogKhoa.nut') : t('dichVu.dialogKhoa.nutMo')}
      danger={dangKhoa}
      confirmDisabled={lyDo.trim().length < DO_DAI_LY_DO_TOI_THIEU}
      loading={doiTrangThai.isPending}
      onConfirm={xacNhan}
    >
      <label className="flex flex-col gap-label">
        <span className="text-label-sm uppercase text-text-primary">
          {t('nguoiDung.dialog.lyDo')}
        </span>
        <TextInput
          value={lyDo}
          onChange={(event) => setLyDo(event.target.value)}
          placeholder={t('nguoiDung.dialog.lyDoGoiY')}
        />
      </label>
    </Modal>
  );
}
