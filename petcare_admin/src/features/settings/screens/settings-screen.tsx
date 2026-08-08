import { useSearchParams } from 'react-router-dom';
import { AdminAccountCard } from '@/features/settings/components/admin-account-card';
import { AuditLogSummaryCard } from '@/features/settings/components/audit-log-summary-card';
import { AuditLogTable } from '@/features/settings/components/audit-log-table';
import { OperatingParamsCard } from '@/features/settings/components/operating-params-card';
import { SettingsTabs, type SettingsTabKey } from '@/features/settings/components/settings-tabs';

export function SettingsScreen() {
  const [searchParams, setSearchParams] = useSearchParams();
  const tab: SettingsTabKey = searchParams.get('tab') === 'nhat-ky' ? 'nhatKy' : 'chung';

  const doiTab = (key: SettingsTabKey) => {
    setSearchParams(key === 'nhatKy' ? { tab: 'nhat-ky' } : {}, { replace: true });
  };

  return (
    <div className="flex flex-col gap-stack pb-block">
      <SettingsTabs value={tab} onChange={doiTab} />
      {tab === 'chung' ? <TabCauHinh onXemNhatKy={() => doiTab('nhatKy')} /> : <AuditLogTable />}
    </div>
  );
}

function TabCauHinh({ onXemNhatKy }: { onXemNhatKy: () => void }) {
  return (
    <div className="flex gap-group">
      <div className="flex min-w-0 flex-1 flex-col gap-group">
        <OperatingParamsCard />
        <AdminAccountCard />
      </div>
      <div className="w-[396px] shrink-0">
        <AuditLogSummaryCard onXemTatCa={onXemNhatKy} />
      </div>
    </div>
  );
}
