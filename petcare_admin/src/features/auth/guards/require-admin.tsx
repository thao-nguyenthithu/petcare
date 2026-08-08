import { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useCurrentAdmin } from '@/features/auth/hooks/use-current-admin';
import { ErrorState } from '@/components/state/error-state';
import { tokenStorage } from '@/lib/api/token-storage';
import { PATHS } from '@/routes/paths';

export function RequireAdmin() {
  const { t } = useTranslation();
  const location = useLocation();
  const coToken = Boolean(tokenStorage.get());
  const { data, isPending, isError, refetch } = useCurrentAdmin();
  const saiVai = Boolean(data) && data?.role !== 'ADMIN';

  useEffect(() => {
    if (saiVai) tokenStorage.clear();
  }, [saiVai]);

  if (!coToken) return <Navigate to={PATHS.login} replace state={{ from: location.pathname }} />;

  if (isPending) {
    return (
      <div className="flex h-screen items-center justify-center bg-canvas">
        <p className="text-body text-text-secondary">{t('chung.dangTai')}</p>
      </div>
    );
  }

  if (isError) {
    return (
      <div className="flex h-screen items-center justify-center bg-canvas">
        <ErrorState message={t('chung.khongTaiDuocDuLieu')} onRetry={() => void refetch()} />
      </div>
    );
  }

  if (saiVai) return <Navigate to={PATHS.login} replace />;

  return <Outlet />;
}
