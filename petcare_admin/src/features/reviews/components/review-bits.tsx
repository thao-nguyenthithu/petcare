import { useTranslation } from 'react-i18next';
import { Check, Clock, Star, X } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { tinhTrangPhanHoi } from '@/features/reviews/review-constants';
import type { AdminReviewRow } from '@/features/reviews/types';
import { formatDate } from '@/lib/format';
import { cn } from '@/lib/utils';

const SO_SAO = 5;

export function RatingStars({ rating, size = 13 }: { rating: number; size?: number }) {
  return (
    <div className="min-w-0">
      <div className="flex items-center gap-text">
        {Array.from({ length: SO_SAO }).map((_, index) => (
          <Star
            key={index}
            style={{ width: size, height: size }}
            strokeWidth={1.8}
            className={cn(
              index < rating ? 'fill-honey text-honey' : 'fill-neutral-light text-neutral',
            )}
          />
        ))}
      </div>
      <p className="mt-text text-caption-sm text-text-secondary">
        {new Intl.NumberFormat('vi-VN', { minimumFractionDigits: 1 }).format(rating)}
      </p>
    </div>
  );
}

export function ReplyBadge({ row }: { row: AdminReviewRow }) {
  const { t } = useTranslation();
  const tinhTrang = tinhTrangPhanHoi(row);

  if (tinhTrang.kieu === 'daDap') {
    return (
      <Badge tone="success" icon={Check}>
        {t('danhGia.phanHoi.daDap', { ngay: formatDate(tinhTrang.luc).slice(0, 5) })}
      </Badge>
    );
  }
  if (tinhTrang.kieu === 'conHan') {
    return (
      <Badge tone="pending" icon={Clock}>
        {t('danhGia.phanHoi.conNgay', { soNgay: tinhTrang.soNgay })}
      </Badge>
    );
  }
  return (
    <Badge tone="neutral" icon={X}>
      {t('danhGia.phanHoi.hetHan')}
    </Badge>
  );
}
