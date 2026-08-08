import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { History, KeyRound } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { SectionCard } from '@/components/ui/section-card';
import { useAdminAccount } from '@/features/settings/hooks/use-settings';
import { formatDate, formatDateTime } from '@/lib/format';
import { PATHS } from '@/routes/paths';

export function AdminAccountCard() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { data: taiKhoan } = useAdminAccount();

  const tenHienThi = taiKhoan?.hoTen || t('chung.quanTriVien');
  const chuCaiDau = tenHienThi.trim().charAt(0).toUpperCase();

  return (
    <SectionCard
      title={t('caiDat.taiKhoan.tieuDe')}
      subtitle={t('caiDat.taiKhoan.moTa')}
      bodyClassName="flex flex-col"
    >
      <div className="flex items-center gap-item pb-block">
        {taiKhoan?.avatarUrl ? (
          <img
            src={taiKhoan.avatarUrl}
            alt={tenHienThi}
            // Ảnh Google/Facebook trả 403 khi kèm Referer lạ
            referrerPolicy="no-referrer"
            className="h-11 w-11 rounded-card object-cover"
          />
        ) : (
          <span className="flex h-11 w-11 items-center justify-center rounded-card bg-card-mint text-label text-primary">
            {chuCaiDau}
          </span>
        )}
        <div className="min-w-0">
          <p className="truncate text-label">{tenHienThi}</p>
          <p className="mt-text truncate text-caption-sm text-text-secondary">
            {taiKhoan ? `${taiKhoan.email} · ${t('caiDat.taiKhoan.vaiTro')}` : ''}
          </p>
        </div>
      </div>

      <DongThongTin
        icon={KeyRound}
        label={t('caiDat.taiKhoan.matKhau')}
        value={
          taiKhoan
            ? taiKhoan.doiMatKhauLuc
              ? t('caiDat.taiKhoan.doiGanNhat', {
                  date: formatDate(taiKhoan.doiMatKhauLuc),
                })
              : t('caiDat.taiKhoan.chuaDoiLanNao', { date: formatDate(taiKhoan.taoLuc) })
            : null
        }
        action={
          <Button
            variant="ghost"
            size="sm"
            onClick={() => void navigate(PATHS.forgotPassword)}
          >
            {t('caiDat.taiKhoan.doiMatKhau')}
          </Button>
        }
      />

      <DongThongTin
        icon={History}
        label={t('caiDat.taiKhoan.nhatKyCuaToi')}
        value={
          taiKhoan
            ? taiKhoan.thaoTacGanNhatLuc
              ? t('caiDat.taiKhoan.soThaoTac', {
                  so: taiKhoan.soThaoTacDaGhi,
                  time: formatDateTime(taiKhoan.thaoTacGanNhatLuc),
                })
              : t('caiDat.taiKhoan.chuaCoThaoTac')
            : null
        }
      />
    </SectionCard>
  );
}

function DongThongTin({
  icon: Icon,
  label,
  value,
  action,
}: {
  icon: typeof KeyRound;
  label: string;
  value: string | null;
  action?: ReactNode;
}) {
  return (
    <div className="flex items-center justify-between gap-item border-t border-neutral-light py-item">
      <div className="flex min-w-0 items-center gap-item">
        <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-card bg-canvas text-text-secondary">
          <Icon className="h-[18px] w-[18px]" strokeWidth={1.8} />
        </span>
        <div className="min-w-0">
          <p className="truncate text-label">{label}</p>
          <p className="mt-text truncate text-caption-sm text-text-secondary">
            {value ?? <KhongCoDuLieu />}
          </p>
        </div>
      </div>
      {action}
    </div>
  );
}
