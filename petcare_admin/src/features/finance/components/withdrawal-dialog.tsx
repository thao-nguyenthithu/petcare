import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Field, TextInput } from '@/components/ui/field';
import { Modal } from '@/components/ui/modal';
import { WithdrawalStatusBadge } from '@/features/finance/components/finance-badges';
import { useUpdateWithdrawal } from '@/features/finance/hooks/use-finance';
import type { WithdrawalRow, WithdrawalStatus } from '@/features/finance/types';
import { getErrorMessage } from '@/lib/api/client';
import { formatDateTime, formatMoney } from '@/lib/format';
import { notify } from '@/lib/toast';

type HanhDong = Extract<WithdrawalStatus, 'SENT' | 'DONE' | 'REJECTED'>;

const HANH_DONG_THEO_TRANG_THAI: Record<WithdrawalStatus, HanhDong[]> = {
  PENDING: ['SENT', 'REJECTED'],
  SENT: ['DONE'],
  DONE: [],
  REJECTED: [],
};

export function WithdrawalDialog({
  row,
  onClose,
}: {
  row: WithdrawalRow | null;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const capNhat = useUpdateWithdrawal();
  const [hanhDong, setHanhDong] = useState<HanhDong | null>(null);
  const [maThamChieu, setMaThamChieu] = useState('');
  const [lyDoTuChoi, setLyDoTuChoi] = useState('');

  const chonDuoc = row ? HANH_DONG_THEO_TRANG_THAI[row.status] : [];
  const dangChon = (hanhDong && chonDuoc.includes(hanhDong) ? hanhDong : chonDuoc[0]) ?? null;

  const dong = () => {
    setHanhDong(null);
    setMaThamChieu('');
    setLyDoTuChoi('');
    onClose();
  };

  const thieuDuLieu =
    (dangChon === 'SENT' && !maThamChieu.trim()) || (dangChon === 'REJECTED' && !lyDoTuChoi.trim());

  const xacNhan = () => {
    if (!row || !dangChon) return;
    capNhat.mutate(
      {
        id: row.id,
        status: dangChon,
        reference: dangChon === 'SENT' ? maThamChieu.trim() : undefined,
        rejectReason: dangChon === 'REJECTED' ? lyDoTuChoi.trim() : undefined,
      },
      {
        onSuccess: () => {
          notify.success(t(`taiChinh.dialog.xong.${dangChon}`));
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
      title={t('taiChinh.dialog.tieuDe')}
      description={dangChon ? t(`taiChinh.dialog.moTa.${dangChon}`) : t('taiChinh.dialog.chiXem')}
      confirmLabel={dangChon ? t(`taiChinh.dialog.nut.${dangChon}`) : undefined}
      onConfirm={dangChon ? xacNhan : undefined}
      danger={dangChon === 'REJECTED'}
      confirmDisabled={thieuDuLieu}
      loading={capNhat.isPending}
    >
      {row ? (
        <div className="flex flex-col gap-stack">
          <dl className="flex flex-col gap-item rounded-card bg-card-mint/50 p-card">
            <ThongTin nhan={t('taiChinh.cot.nguoiCham')} giaTri={row.sitterName} />
            <ThongTin
              nhan={t('taiChinh.cot.taiKhoanNhan')}
              giaTri={`${row.bankName} · ${row.accountNumber}`}
              phu={row.accountHolder}
            />
            <ThongTin nhan={t('taiChinh.cot.soTien')} giaTri={formatMoney(row.amount)} />
            <ThongTin nhan={t('taiChinh.cot.phiChuyen')} giaTri={formatMoney(row.fee)} />
            <ThongTin nhan={t('taiChinh.cot.taoLuc')} giaTri={formatDateTime(row.createdAt)} />
            <div className="flex items-center justify-between gap-item">
              <dt className="text-caption-sm text-text-secondary">{t('taiChinh.cot.trangThai')}</dt>
              <dd>
                <WithdrawalStatusBadge status={row.status} />
              </dd>
            </div>
            {row.reference ? (
              <ThongTin nhan={t('taiChinh.cot.maThamChieu')} giaTri={row.reference} />
            ) : null}
            {row.rejectReason ? (
              <ThongTin nhan={t('taiChinh.dialog.lyDo')} giaTri={row.rejectReason} />
            ) : null}
          </dl>

          {chonDuoc.length > 1 ? (
            <div className="flex items-center gap-label rounded-card bg-neutral-light/50 p-text">
              {chonDuoc.map((key) => (
                <button
                  key={key}
                  type="button"
                  onClick={() => setHanhDong(key)}
                  className={
                    key === dangChon
                      ? 'flex-1 rounded-card bg-surface px-stack py-label text-label font-bold text-primary shadow-card'
                      : 'flex-1 rounded-card px-stack py-label text-label text-text-secondary hover:text-text-primary'
                  }
                >
                  {t(`taiChinh.dialog.nut.${key}`)}
                </button>
              ))}
            </div>
          ) : null}

          {dangChon === 'SENT' ? (
            <Field label={t('taiChinh.dialog.maThamChieu')} hint={t('taiChinh.dialog.maGoiY')}>
              <TextInput
                value={maThamChieu}
                onChange={(event) => setMaThamChieu(event.target.value)}
                placeholder={t('taiChinh.dialog.maGoiYNhap')}
              />
            </Field>
          ) : null}

          {dangChon === 'REJECTED' ? (
            <Field label={t('taiChinh.dialog.lyDo')} hint={t('taiChinh.dialog.lyDoGoiY')}>
              <TextInput
                value={lyDoTuChoi}
                onChange={(event) => setLyDoTuChoi(event.target.value)}
                placeholder={t('taiChinh.dialog.lyDoGoiYNhap')}
              />
            </Field>
          ) : null}
        </div>
      ) : null}
    </Modal>
  );
}

function ThongTin({ nhan, giaTri, phu }: { nhan: string; giaTri: string; phu?: string }) {
  return (
    <div className="flex items-start justify-between gap-item">
      <dt className="shrink-0 text-caption-sm text-text-secondary">{nhan}</dt>
      <dd className="min-w-0 text-right">
        <p className="truncate text-label">{giaTri}</p>
        {phu ? <p className="truncate text-caption-sm text-text-secondary">{phu}</p> : null}
      </dd>
    </div>
  );
}
