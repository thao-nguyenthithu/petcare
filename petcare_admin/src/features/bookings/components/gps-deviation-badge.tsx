import { useTranslation } from 'react-i18next';
import { AlertTriangle, Check, Clock, Minus, X } from 'lucide-react';
import { Badge, type BadgeTone } from '@/components/ui/badge';
import { tinhNhanDoLech } from '@/features/bookings/gps-deviation';
import type { GpsDeviationLabel, GpsReportRow } from '@/features/bookings/types';

const KIEU: Record<GpsDeviationLabel, { tone: BadgeTone; icon: typeof Check }> = {
  twoThresholds: { tone: 'danger', icon: X },
  ratioOnly: { tone: 'pending', icon: Clock },
  withinError: { tone: 'success', icon: Check },
  trackingOff: { tone: 'danger', icon: AlertTriangle },
  noClaim: { tone: 'neutral', icon: Minus },
};

export function GpsDeviationBadge({ row }: { row: GpsReportRow }) {
  const { t } = useTranslation();
  const nhan = tinhNhanDoLech(row);
  const kieu = KIEU[nhan];
  return (
    <Badge tone={kieu.tone} icon={kieu.icon}>
      {t(`gps.doLech.${nhan}`)}
    </Badge>
  );
}
