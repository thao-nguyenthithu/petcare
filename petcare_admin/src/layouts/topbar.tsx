import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useLocation, useNavigate } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';
import { LogOut } from 'lucide-react';
import { QueueBell } from '@/features/dashboard/components/queue-bell';
import { useDashboard } from '@/features/dashboard/hooks/use-dashboard';
import { formatDate, formatTime } from '@/lib/format';
import { SearchField } from '@/components/ui/search-field';
import { LanguageSwitch } from '@/components/ui/language-switch';
import { getNavKey } from '@/layouts/nav-items';
import { useCurrentAdmin } from '@/features/auth/hooks/use-current-admin';
import { tokenStorage } from '@/lib/api/token-storage';
import { PATHS } from '@/routes/paths';

export function Topbar() {
  const { t } = useTranslation();
  const { pathname } = useLocation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { data: admin } = useCurrentAdmin();
  const [keyword, setKeyword] = useState('');

  const navKey = getNavKey(pathname);
  const title = navKey ? t(`man.${navKey}.title`) : t('chung.bangQuanTri');

  const laTongQuan = pathname === PATHS.dashboard;
  const { dataUpdatedAt } = useDashboard(laTongQuan);
  const moTaTongQuan =
    dataUpdatedAt > 0
      ? t('man.tongQuan.desc', {
          time: formatTime(dataUpdatedAt),
          date: formatDate(dataUpdatedAt),
        })
      : t('man.tongQuan.descChoTai');

  const description = laTongQuan
    ? moTaTongQuan
    : navKey
      ? t(`man.${navKey}.desc`)
      : t('chung.tenSanPham');

  const dangXuat = () => {
    tokenStorage.clear();
    queryClient.clear();
    void navigate(PATHS.login, { replace: true });
  };

  const tenHienThi = admin?.fullName || t('chung.quanTriVien');
  const chuCaiDau = tenHienThi.trim().charAt(0).toUpperCase();

  return (
    <header className="flex h-topbar shrink-0 items-center justify-between gap-group border-b border-neutral-light bg-surface px-section">
      <div className="min-w-0">
        <h1 className="truncate text-h3">{title}</h1>
        <p className="truncate text-caption-sm text-text-secondary">{description}</p>
      </div>

      <div className="flex items-center gap-item">
        <SearchField
          value={keyword}
          onChange={setKeyword}
          placeholder={t('chung.timNhanh')}
          className="w-64"
        />

        <QueueBell />

        <LanguageSwitch />

        <div className="flex h-[42px] items-center gap-label rounded-card border border-neutral pl-label pr-label">
          {admin?.avatarUrl ? (
            <img
              src={admin.avatarUrl}
              alt={tenHienThi}
              // Ảnh Google/Facebook trả 403 khi kèm Referer lạ
              referrerPolicy="no-referrer"
              className="h-8 w-8 rounded-card object-cover"
            />
          ) : (
            <span className="flex h-8 w-8 items-center justify-center rounded-card bg-card-mint text-label-sm text-primary">
              {chuCaiDau}
            </span>
          )}
          <span className="max-w-40 truncate text-label">{tenHienThi}</span>
          <button
            type="button"
            onClick={dangXuat}
            aria-label={t('chung.dangXuat')}
            className="text-text-secondary hover:text-error"
          >
            <LogOut className="h-[18px] w-[18px]" strokeWidth={1.8} />
          </button>
        </div>
      </div>
    </header>
  );
}
