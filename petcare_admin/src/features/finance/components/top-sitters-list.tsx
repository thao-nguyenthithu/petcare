import { UserAvatar } from '@/features/users/components/user-badges';
import type { FinanceSummary } from '@/features/finance/types';
import { useMoneyShort } from '@/lib/use-money-short';

export function TopSittersList({ data }: { data: FinanceSummary['topSitters'] }) {
  const trieu = useMoneyShort();
  const caoNhat = Math.max(...data.map((item) => item.amount), 0);

  return (
    <ul className="flex flex-col gap-item">
      {data.map((item) => (
        <li key={item.sitterId} className="flex flex-col gap-label">
          <div className="flex items-center gap-item">
            <UserAvatar name={item.name} size={32} />
            <p className="min-w-0 flex-1 truncate text-label">{item.name}</p>
            <span className="shrink-0 text-label">{trieu(item.amount)}</span>
          </div>
          <div className="h-[6px] w-full overflow-hidden rounded-card bg-neutral-light">
            <div
              className="h-full rounded-card bg-primary"
              style={{ width: caoNhat === 0 ? 0 : `${(item.amount / caoNhat) * 100}%` }}
            />
          </div>
        </li>
      ))}
    </ul>
  );
}
