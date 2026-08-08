import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { CountTabs, type CountTab } from '@/components/ui/count-tabs';
import { PATHS } from '@/routes/paths';

export type SettingsTabKey = 'chung' | 'gioiHan' | 'nhatKy';

type SettingsTabsProps = {
  value: SettingsTabKey;
  onChange: (key: SettingsTabKey) => void;
};

export function SettingsTabs({ value, onChange }: SettingsTabsProps) {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const tabs: Array<CountTab<SettingsTabKey>> = [
    { key: 'chung', label: t('caiDat.tab.chung') },
    { key: 'gioiHan', label: t('caiDat.tab.gioiHan') },
    { key: 'nhatKy', label: t('caiDat.tab.nhatKy') },
  ];

  return (
    <CountTabs
      tabs={tabs}
      value={value}
      onChange={(key) => {
        if (key === 'gioiHan') {
          void navigate(PATHS.limits);
          return;
        }
        if (value === 'gioiHan') {
          void navigate(key === 'nhatKy' ? `${PATHS.settings}?tab=nhat-ky` : PATHS.settings);
          return;
        }
        onChange(key);
      }}
      className="rounded-card bg-neutral-light/50 p-text"
    />
  );
}
