import { useTranslation } from 'react-i18next';
import { Copy } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Modal } from '@/components/ui/modal';
import { ErrorState } from '@/components/state/error-state';
import { Skeleton } from '@/components/state/skeleton';
import { PaymentStatusBadge } from '@/features/finance/components/finance-badges';
import { usePaymentRaw } from '@/features/finance/hooks/use-finance';
import type { PaymentRow } from '@/features/finance/types';
import { formatDateTime, formatMoney } from '@/lib/format';
import { notify } from '@/lib/toast';

export function PaymentRawDialog({
  row,
  onClose,
}: {
  row: PaymentRow | null;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const raw = usePaymentRaw(row?.txnRef ?? null);

  const sao = (value: string) => {
    void navigator.clipboard
      .writeText(value)
      .then(() => notify.success(t('thanhToan.daSaoChep')))
      .catch(() => notify.error(t('thanhToan.khongSaoChepDuoc')));
  };

  return (
    <Modal
      open={Boolean(row)}
      onOpenChange={(open) => {
        if (!open) onClose();
      }}
      title={t('thanhToan.dialogRaw.tieuDe')}
      description={t('thanhToan.dialogRaw.moTa')}
      className="w-[min(680px,calc(100vw-48px))]"
    >
      {row ? (
        <div className="flex flex-col gap-stack">
          <dl className="flex flex-col gap-item rounded-card bg-card-mint/50 p-card">
            <Dong
              nhan={t('thanhToan.cot.donVaTxnRef')}
              giaTri={`${row.bookingCode} · ${row.txnRef}`}
            />
            <Dong
              nhan={t('thanhToan.truong.gatewayTxnNo')}
              giaTri={row.gatewayTxnNo ?? t('thanhToan.chuaQuaCong')}
            />
            <Dong
              nhan={t('thanhToan.truong.gatewayPayDate')}
              giaTri={row.gatewayPayDate ?? t('thanhToan.chuaQuaCong')}
            />
            <Dong
              nhan={t('thanhToan.truong.bankCode')}
              giaTri={
                row.bankCode
                  ? `${row.bankCode} · ${row.cardType ?? ''}`.trim()
                  : t('thanhToan.congKhongTra')
              }
            />
            <Dong
              nhan={t('thanhToan.truong.responseCode')}
              giaTri={row.responseCode ?? t('thanhToan.chuaQuaCong')}
            />
            <Dong nhan={t('thanhToan.cot.soTien')} giaTri={formatMoney(row.amount)} />
            <Dong
              nhan={t('thanhToan.cot.traLuc')}
              giaTri={row.paidAt ? formatDateTime(row.paidAt) : t('thanhToan.chuaTra')}
            />
            <div className="flex items-center justify-between gap-item">
              <dt className="text-caption-sm text-text-secondary">
                {t('thanhToan.cot.trangThai')}
              </dt>
              <dd>
                <PaymentStatusBadge status={row.status} />
              </dd>
            </div>
          </dl>

          <div className="flex flex-col gap-label">
            <div className="flex items-center justify-between gap-item">
              <span className="text-label-sm uppercase tracking-[0.02em]">
                {t('thanhToan.dialogRaw.payload')}
              </span>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => sao(raw.data ?? '')}
                disabled={!raw.data}
              >
                <Copy className="h-4 w-4" strokeWidth={1.8} />
                {t('thanhToan.saoChep')}
              </Button>
            </div>
            {raw.isPending ? <Skeleton className="h-[120px] w-full" /> : null}
            {raw.isError ? <ErrorState onRetry={() => void raw.refetch()} /> : null}
            {!raw.isPending && !raw.isError ? (
              <pre className="max-h-[240px] overflow-auto whitespace-pre-wrap break-all rounded-card border border-neutral-light bg-neutral-light/40 p-card text-caption-sm">
                {raw.data ?? t('thanhToan.dialogRaw.chuaCoPayload')}
              </pre>
            ) : null}
          </div>
        </div>
      ) : null}
    </Modal>
  );
}

function Dong({ nhan, giaTri }: { nhan: string; giaTri: string }) {
  return (
    <div className="flex items-start justify-between gap-item">
      <dt className="shrink-0 text-caption-sm text-text-secondary">{nhan}</dt>
      <dd className="min-w-0 truncate text-label">{giaTri}</dd>
    </div>
  );
}
