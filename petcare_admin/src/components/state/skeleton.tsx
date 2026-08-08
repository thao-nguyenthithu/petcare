import { cn } from '@/lib/utils';

export function Skeleton({ className }: { className?: string }) {
  return <div className={cn('animate-pulse rounded bg-neutral-light', className)} />;
}

type TableSkeletonProps = {
  rows?: number;
  columns: number;
};

export function TableSkeleton({ rows = 6, columns }: TableSkeletonProps) {
  return (
    <>
      {Array.from({ length: rows }).map((_, rowIndex) => (
        <tr key={rowIndex} className="border-t border-neutral-light">
          {Array.from({ length: columns }).map((__, colIndex) => (
            <td key={colIndex} className="px-card py-item">
              <Skeleton className="h-4 w-full max-w-40" />
            </td>
          ))}
        </tr>
      ))}
    </>
  );
}
