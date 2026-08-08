import { useTranslation } from 'react-i18next';
import { Info, Sparkles } from 'lucide-react';
import type { DiemAi } from '@/features/evidence/types';
import { formatPercent } from '@/lib/format';

function khoaKetLuan(diem: DiemAi): string {
  if (diem.aiPassed === true) return 'anh.ai.dat';
  if (diem.aiPassed === null) return 'anh.ai.chuaKetLuan';
  return diem.anhVanXa ? 'anh.ai.tuXacNhan' : 'anh.ai.khongDat';
}

export function AiScorePanel({ diem }: { diem: DiemAi }) {
  const { t } = useTranslation();
  const diemSo = diem.aiConfidenceScore;

  return (
    <div className="flex flex-col gap-item">
      <span className="flex items-center gap-label text-label">
        <Sparkles className="h-[18px] w-[18px] text-honey" strokeWidth={1.8} />
        {diemSo === null
          ? t('anh.ai.chuaCham')
          : t('anh.ai.doTinCay', { value: formatPercent(diemSo * 100, 0) })}
      </span>

      <div className="rounded-card bg-honey/15 p-item">
        <p className="text-label text-honey">
          {diemSo === null ? t('anh.ai.chuaChamMoTa') : t(khoaKetLuan(diem))}
        </p>
        <p className="mt-label flex items-start gap-label text-caption-sm text-honey">
          <Info className="mt-[1px] h-4 w-4 shrink-0" strokeWidth={1.8} />
          {t('anh.ai.cachTraSoat')}
        </p>
      </div>
    </div>
  );
}
