import { useTranslation } from 'react-i18next';
import { AlertTriangle, Check, Clock, LifeBuoy, X } from 'lucide-react';
import { Badge, type BadgeTone } from '@/components/ui/badge';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import {
  NGUONG_SAP_HET_HAN_GIO,
  tinhTrangHanDap,
  tinhTrangHanKetLuan,
} from '@/features/disputes/dispute-constants';
import type { AdminDisputeRow, DisputeViewStatus } from '@/features/disputes/types';

const KIEU_TINH_TRANG: Record<
  DisputeViewStatus,
  { tone: BadgeTone; icon: typeof Clock | typeof Check }
> = {
  waitingSitter: { tone: 'pending', icon: Clock },
  waitingSupport: { tone: 'info', icon: LifeBuoy },
  refunded: { tone: 'success', icon: Check },
  rejected: { tone: 'neutral', icon: X },
};

export function DisputeStatusBadge({ view }: { view: DisputeViewStatus }) {
  const { t } = useTranslation();
  const kieu = KIEU_TINH_TRANG[view];
  return (
    <Badge tone={kieu.tone} icon={kieu.icon}>
      {t(`khieuNai.tinhTrang.${view}`)}
    </Badge>
  );
}

export function ReplyDeadlineBadge({
  replyDeadline,
  sitterReplyAt,
}: {
  replyDeadline: string | null;
  sitterReplyAt: string | null;
}) {
  const { t } = useTranslation();
  const tinhTrang = tinhTrangHanDap({ replyDeadline, sitterReplyAt });

  if (tinhTrang.kieu === 'khongCoHan') {
    return (
      <span className="text-caption-sm text-text-secondary">
        {t('khieuNai.hanDap.khongCo')}
      </span>
    );
  }
  if (tinhTrang.kieu === 'daDap') {
    return (
      <Badge tone="neutral" icon={Check}>
        {t('khieuNai.hanDap.daDap')}
      </Badge>
    );
  }
  if (tinhTrang.kieu === 'hetHan') {
    return (
      <Badge tone="danger" icon={AlertTriangle}>
        {t('khieuNai.hanDap.hetHan')}
      </Badge>
    );
  }
  const sapHet = tinhTrang.soGio <= NGUONG_SAP_HET_HAN_GIO;
  return (
    <Badge tone={sapHet ? 'danger' : 'pending'} icon={sapHet ? AlertTriangle : Clock}>
      {t('khieuNai.hanDap.conHan', { soGio: tinhTrang.soGio })}
    </Badge>
  );
}

export function ConclusionDeadlineBadge({
  row,
  hanNgay,
}: {
  row: Pick<AdminDisputeRow, 'status' | 'createdAt'>;
  hanNgay: number | null;
}) {
  const { t } = useTranslation();
  if (hanNgay === null) return <KhongCoDuLieu />;
  const tinhTrang = tinhTrangHanKetLuan(row, hanNgay);

  if (tinhTrang.kieu === 'daKetLuan') {
    return <KhongCoDuLieu />;
  }
  if (tinhTrang.kieu === 'quaHan') {
    return (
      <Badge tone="danger" icon={AlertTriangle}>
        {t('khieuNai.hanKetLuan.quaHan', { soNgay: tinhTrang.soNgay })}
      </Badge>
    );
  }
  const canhBao = tinhTrang.kieu === 'canhBao';
  return (
    <Badge tone={canhBao ? 'danger' : 'pending'} icon={canhBao ? AlertTriangle : Clock}>
      {t('khieuNai.hanKetLuan.conHan', { soNgay: tinhTrang.soNgayConLai })}
    </Badge>
  );
}
