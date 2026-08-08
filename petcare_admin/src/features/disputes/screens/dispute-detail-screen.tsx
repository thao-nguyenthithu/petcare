import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';
import { ShieldAlert } from 'lucide-react';
import { ErrorState } from '@/components/state/error-state';
import { Skeleton } from '@/components/state/skeleton';
import { PageHeader } from '@/components/ui/page-header';
import {
  ConclusionDeadlineBadge,
  DisputeStatusBadge,
  ReplyDeadlineBadge,
} from '@/features/disputes/components/dispute-badges';
import {
  ReporterCard,
  SitterReplyCard,
  SystemEvidenceCard,
  ViolationHistoryCard,
} from '@/features/disputes/components/dispute-cards';
import {
  ResolutionCard,
  ResolvedSummaryCard,
} from '@/features/disputes/components/resolution-card';
import { tinhTrangHanKetLuan, tinhTrangHienThi } from '@/features/disputes/dispute-constants';
import {
  useDisputeDetail,
  useHanKetLuanNgay,
  useResolveDispute,
} from '@/features/disputes/hooks/use-disputes';
import { getErrorMessage } from '@/lib/api/client';
import { notify } from '@/lib/toast';
import { PATHS } from '@/routes/paths';

export function DisputeDetailScreen() {
  const { t } = useTranslation();
  const { code = '' } = useParams();
  const navigate = useNavigate();
  const hoSo = useDisputeDetail(code);
  const ketLuan = useResolveDispute();
  const hanKetLuanNgay = useHanKetLuanNgay();

  if (hoSo.isError) {
    return <ErrorState onRetry={() => void hoSo.refetch()} />;
  }

  const data = hoSo.data;
  const daKetLuan = data?.dispute.status === 'RESOLVED';
  const hanKetLuan =
    data && hanKetLuanNgay !== null ? tinhTrangHanKetLuan(data.dispute, hanKetLuanNgay) : null;
  const nhacHan = hanKetLuan?.kieu === 'canhBao' || hanKetLuan?.kieu === 'quaHan';

  return (
    <div className="flex flex-col gap-stack pb-block">
      <PageHeader
        backTo={PATHS.disputes}
        crumbs={[{ label: t('man.khieuNai.title'), to: PATHS.disputes }, { label: code }]}
        actions={
          data ? (
            <>
              <ReplyDeadlineBadge
                replyDeadline={data.dispute.replyDeadline}
                sitterReplyAt={data.dispute.sitterReplyAt}
              />
              <ConclusionDeadlineBadge row={data.dispute} hanNgay={hanKetLuanNgay} />
              <DisputeStatusBadge view={tinhTrangHienThi(data.dispute)} />
            </>
          ) : null
        }
      />

      {nhacHan ? (
        <p className="flex items-start gap-label rounded-card bg-error/[0.08] p-card text-caption-sm text-error">
          <ShieldAlert className="mt-[1px] h-4 w-4 shrink-0" strokeWidth={1.8} />
          {hanKetLuan?.kieu === 'quaHan'
            ? t('khieuNai.hoSo.nhacQuaHan', {
                soNgay: hanKetLuan.soNgay,
                hanNgay: hanKetLuanNgay,
              })
            : t('khieuNai.hoSo.nhacSapHetHan', {
                soNgay: hanKetLuan?.kieu === 'canhBao' ? hanKetLuan.soNgayConLai : 1,
                hanNgay: hanKetLuanNgay,
              })}
        </p>
      ) : null}

      {hoSo.isPending || !data ? (
        <div className="grid grid-cols-[1fr_360px] gap-stack">
          <Skeleton className="h-[720px] w-full rounded-card" />
          <Skeleton className="h-[720px] w-full rounded-card" />
        </div>
      ) : (
        <div className="grid grid-cols-[1fr_360px] items-start gap-stack">
          <div className="flex flex-col gap-stack">
            <ReporterCard data={data} />
            <SitterReplyCard data={data} />
            <SystemEvidenceCard data={data} />
          </div>

          <div className="flex flex-col gap-stack">
            {daKetLuan ? (
              <ResolvedSummaryCard data={data} />
            ) : (
              <ResolutionCard
                data={data}
                dangGui={ketLuan.isPending}
                onResolve={(input) =>
                  ketLuan.mutate(input, {
                    onSuccess: () => {
                      notify.success(t('khieuNai.hoSo.daGhiKetLuan'));
                      void navigate(PATHS.disputes);
                    },
                    onError: (error) =>
                      notify.error(
                        getErrorMessage(error, t('khieuNai.hoSo.loiGhiKetLuan')),
                      ),
                  })
                }
              />
            )}
            <ViolationHistoryCard data={data} />
          </div>
        </div>
      )}
    </div>
  );
}
