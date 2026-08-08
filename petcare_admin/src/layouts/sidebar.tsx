import { useTranslation } from 'react-i18next';
import { NavLink } from 'react-router-dom';
import { NAV_GROUPS } from '@/layouts/nav-items';
import { PATHS } from '@/routes/paths';
import { cn } from '@/lib/utils';

export function Sidebar() {
  const { t } = useTranslation();

  return (
    <aside className="flex h-full w-sidebar shrink-0 flex-col overflow-hidden bg-primary">
      <div className="flex h-topbar items-center gap-item px-block">
        <img
          src="/app_icon.png"
          alt={t('chung.tenSanPham')}
          className="h-9 w-9 shrink-0 rounded-card bg-surface object-contain"
        />
        <div className="min-w-0">
          <p className="truncate text-label text-text-white">{t('chung.tenSanPham')}</p>
          <p className="truncate text-caption-sm text-text-white/70">{t('chung.bangQuanTri')}</p>
        </div>
      </div>

      <nav className="scrollbar-hidden flex-1 overflow-y-auto px-item pb-group">
        {NAV_GROUPS.map((group) => (
          <div key={group.titleKey} className="mb-block">
            <p className="px-item pb-label text-caption-sm uppercase text-text-white/60">
              {t(group.titleKey)}
            </p>
            <ul className="flex flex-col gap-text">
              {group.items.map((item) => (
                <li key={item.path}>
                  <NavLink
                    to={item.path}
                    end={item.path === PATHS.dashboard}
                    className={({ isActive }) =>
                      cn(
                        'flex items-center gap-item rounded-card px-item py-label text-label transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-text-white/60',
                        isActive
                          ? 'bg-surface text-primary'
                          : 'text-text-white/75 hover:bg-text-white/10 hover:text-text-white',
                      )
                    }
                  >
                    <item.icon className="h-[18px] w-[18px] shrink-0" strokeWidth={1.8} />
                    <span className="truncate">{t(`man.${item.key}.title`)}</span>
                  </NavLink>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </nav>
    </aside>
  );
}
