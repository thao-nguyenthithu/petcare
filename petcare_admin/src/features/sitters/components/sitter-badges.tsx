import { useTranslation } from 'react-i18next';
import { Ban, Check, Clock, EyeOff, X } from 'lucide-react';
import { Badge, type BadgeTone } from '@/components/ui/badge';
import { trangThaiCuaNcc } from '@/features/sitters/sitter-constants';
import type { SitterRow, SitterState } from '@/features/sitters/types';

const KIEU: Record<SitterState, { tone: BadgeTone; icon: typeof Check }> = {
  pending: { tone: 'pending', icon: Clock },
  active: { tone: 'success', icon: Check },
  rejected: { tone: 'danger', icon: X },
  hidden: { tone: 'neutral', icon: EyeOff },
  banned: { tone: 'danger', icon: Ban },
};

export function SitterStateBadge({
  row,
}: {
  row: Pick<SitterRow, 'status' | 'hiddenUntil' | 'bannedAt'>;
}) {
  const { t } = useTranslation();
  const trangThai = trangThaiCuaNcc(row);
  const kieu = KIEU[trangThai];
  return (
    <Badge tone={kieu.tone} icon={kieu.icon}>
      {t(`hoSoNcc.trangThai.${trangThai}`)}
    </Badge>
  );
}

export function GiayToBadge({ hasFront, hasBack }: { hasFront: boolean; hasBack: boolean }) {
  const { t } = useTranslation();
  const so = Number(hasFront) + Number(hasBack);
  return (
    <Badge tone={so === 2 ? 'success' : 'pending'} icon={so === 2 ? Check : Clock}>
      {t('hoSoNcc.giayTo.dem', { so })}
    </Badge>
  );
}
