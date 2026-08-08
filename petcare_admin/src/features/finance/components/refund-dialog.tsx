import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Field, TextInput } from '@/components/ui/field';
import { Modal } from '@/components/ui/modal';
import { RefundStatusBadge } from '@/features/finance/components/finance-badges';
import { DO_DAI_MA_HOAN_TOI_THIEU } from '@/features/finance/finance-constants';
import { useMarkRefundManual } from '@/features/finance/hooks/use-finance';
import type { RefundRow } from '@/features/finance/types';
import { getErrorMessage } from '@/lib/api/client';
import { formatDateTime, formatMoney } from '@/lib/format';
import { notify } from '@/lib/toast';

export type RefundDialogMode = 'view' | 'manual';

export function RefundDialog({
  row,
  mode,
  onClose,
}: {
  row: RefundRow | null;
  mode: RefundDialogMode;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const danhDau = useMarkRefundManual();
  const [maThamChieu, setMaThamChieu] = useState('');
  const [ghiChu, setGhiChu] = useState('');

  const maQuaNgan = maThamChieu.trim().length < DO_DAI_MA_HOAN_TOI_THIEU;
  const hienLoi = maThamChieu.length > 0 && maQuaNgan;

  const dong = () => {
    setMaThamChieu('');
    setGhiChu('');
    onClose();
  };

  const xacNhan = () => {
    if (!row || maQuaNgan) return;
    danhDau.mutate(
      { txnRef: row.txnRef, reference: maThamChieu.trim(), note: ghiChu.trim() || undefined },
      {
        onSuccess: () => {
          notify.success(t('hoanTien.daDanhDauTay'));
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
      title={t(`hoanTien.dialog.tieuDe.${mode}`)}
      description={t(`hoanTien.dialog.moTa.${mode}`)}
      confirmLabel={mode === 'manual' ? t('hoanTien.dialog.nut.manual') : undefined}
      onConfirm={mode === 'manual' ? xacNhan : undefined}
      confirmDisabled={mode === 'manual' && maQuaNgan}
      loading={danhDau.isPending}
    >
      {row ? (
        <div className="flex flex-col gap-stack">
          <dl className="flex flex-col gap-item rounded-card bg-card-mint/50 p-card">
            <Dong
              nhan={t('hoanTien.truong.chuNuoi')}
              giaTri={`${row.ownerName} · ${row.ownerPhone}`}
            />
            <Dong nhan={t('hoanTien.truong.maDon')} giaTri={row.bookingCode} />
            <Dong nhan={t('thanhToan.truong.maGiaoDich')} giaTri={row.txnRef} />
            <Dong
              nhan={t('thanhToan.truong.gatewayTxnNo')}
              giaTri={row.gatewayTxnNo ?? t('hoanTien.thieuDuLieu')}
              thieu={!row.gatewayTxnNo}
            />
            <Dong
              nhan={t('thanhToan.truong.gatewayPayDate')}
              giaTri={row.gatewayPayDate ?? t('hoanTien.thieuDuLieu')}
              thieu={!row.gatewayPayDate}
            />
            <Dong
              nhan={t('hoanTien.truong.nganHang')}
              giaTri={row.bankCode ?? t('hoanTien.congKhongTraNganHang')}
            />
            <Dong nhan={t('hoanTien.cot.soTienHoan')} giaTri={formatMoney(row.amount)} />
            <Dong nhan={t('hoanTien.truong.daTra')} giaTri={formatMoney(row.paymentAmount)} />
            <Dong nhan={t('hoanTien.cot.lyDo')} giaTri={t(`hoanTien.lyDo.${row.reason}`)} />
            {row.cancelReasonText ? (
              <Dong nhan={t('hoanTien.truong.lyDoHuy')} giaTri={row.cancelReasonText} />
            ) : null}
            <Dong nhan={t('hoanTien.truong.choTu')} giaTri={formatDateTime(row.requestedAt)} />
            <div className="flex items-center justify-between gap-item">
              <dt className="text-caption-sm text-text-secondary">{t('hoanTien.cot.trangThai')}</dt>
              <dd>
                <RefundStatusBadge status={row.status} />
              </dd>
            </div>
          </dl>

          {row.status === 'REFUNDED' ? <ChotHoan row={row} /> : null}

          <p className="rounded-card bg-neutral-light/50 p-card text-caption-sm text-text-secondary">
            {row.bankCode
              ? t('hoanTien.nguonNhan', { bank: row.bankCode })
              : t('hoanTien.nguonNhanKhongRo')}
          </p>

          {mode === 'manual' ? (
            <>
              <Field
                label={t('hoanTien.truong.maHoanTay')}
                hint={t('hoanTien.dialog.maGoiY')}
                error={
                  hienLoi ? t('hoanTien.maQuaNgan', { count: DO_DAI_MA_HOAN_TOI_THIEU }) : undefined
                }
              >
                <TextInput
                  value={maThamChieu}
                  hasError={hienLoi}
                  onChange={(event) => setMaThamChieu(event.target.value)}
                  placeholder={t('hoanTien.dialog.maGoiYNhap')}
                />
              </Field>
              <Field label={t('hoanTien.truong.ghiChu')} hint={t('hoanTien.dialog.ghiChuGoiY')}>
                <TextInput
                  value={ghiChu}
                  onChange={(event) => setGhiChu(event.target.value)}
                  placeholder={t('hoanTien.dialog.ghiChuGoiYNhap')}
                />
              </Field>
            </>
          ) : null}
        </div>
      ) : null}
    </Modal>
  );
}

function ChotHoan({ row }: { row: RefundRow }) {
  const { t } = useTranslation();
  return (
    <dl className="flex flex-col gap-item rounded-card border border-neutral-light p-card">
      <Dong
        nhan={t('hoanTien.truong.maHoanTay')}
        giaTri={row.refundReference ?? t('chung.khongCoDuLieu')}
      />
      <Dong nhan={t('hoanTien.truong.ghiChu')} giaTri={row.refundNote ?? t('chung.khongCoDuLieu')} />
      <Dong
        nhan={t('hoanTien.truong.hoanLuc')}
        giaTri={row.refundedAt ? formatDateTime(row.refundedAt) : t('chung.khongCoDuLieu')}
      />
    </dl>
  );
}

function Dong({ nhan, giaTri, thieu = false }: { nhan: string; giaTri: string; thieu?: boolean }) {
  return (
    <div className="flex items-start justify-between gap-item">
      <dt className="shrink-0 text-caption-sm text-text-secondary">{nhan}</dt>
      <dd
        className={thieu ? 'min-w-0 truncate text-label text-error' : 'min-w-0 truncate text-label'}
      >
        {giaTri}
      </dd>
    </div>
  );
}
