import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { EmptyState } from '@/components/state/empty-state';
import { ErrorState } from '@/components/state/error-state';
import { TableSkeleton } from '@/components/state/skeleton';
import { Pagination } from '@/components/ui/pagination';
import type { TrangThaiBang } from '@/lib/table-status';
import { cn } from '@/lib/utils';

const MIN_FLEX_WIDTH = 170;
const TABLE_CONTENT_WIDTH = 1104;

export type Column<T> = {
  key: string;
  header: string;
  width?: number;
  align?: 'left' | 'center' | 'right';
  cell: (row: T) => ReactNode;
  isAction?: boolean;
};

type DataTableProps<T> = {
  columns: Array<Column<T>>;
  rows: T[];
  rowKey: (row: T) => string;
  status: TrangThaiBang;
  toolbar?: ReactNode;
  toolbarActions?: ReactNode;
  onRowClick?: (row: T) => void;
  rowClassName?: (row: T) => string | undefined;
  onRetry?: () => void;
  errorMessage?: string;
  emptyMessage?: string;
  isFiltered?: boolean;
  onClearFilter?: () => void;
  pagination?: {
    page: number;
    pageSize: number;
    total: number;
    onPageChange: (page: number) => void;
  };
  className?: string;
};

function warnColumnWidths<T>(columns: Array<Column<T>>) {
  if (!import.meta.env.DEV) return;
  const hasFlex = columns.some((column) => column.width === undefined);
  if (!hasFlex) return;
  const fixed = columns.reduce((sum, column) => sum + (column.width ?? 0), 0);
  if (TABLE_CONTENT_WIDTH - fixed < MIN_FLEX_WIDTH) {
    console.warn(
      `DataTable: cột cố định chiếm ${fixed}px, cột co giãn còn dưới ${MIN_FLEX_WIDTH}px`,
    );
  }
}

const ALIGN_CLASS = {
  left: 'text-left',
  center: 'text-center',
  right: 'text-right',
} as const;

export function DataTable<T>({
  columns,
  rows,
  rowKey,
  status,
  toolbar,
  toolbarActions,
  onRowClick,
  rowClassName,
  onRetry,
  errorMessage,
  emptyMessage,
  isFiltered = false,
  onClearFilter,
  pagination,
  className,
}: DataTableProps<T>) {
  const { t } = useTranslation();
  warnColumnWidths(columns);

  const showBody = status === 'success' && rows.length > 0;
  const showState = status !== 'success' || rows.length === 0;

  return (
    <div className={cn('rounded-card border border-neutral-light bg-surface', className)}>
      {toolbar || toolbarActions ? (
        <div className="flex flex-wrap items-center justify-between gap-item border-b border-neutral-light p-card">
          <div className="flex flex-wrap items-center gap-item">{toolbar}</div>
          <div className="flex items-center gap-label">{toolbarActions}</div>
        </div>
      ) : null}

      <div className="overflow-x-auto">
        <table className="w-full table-fixed border-collapse">
          <colgroup>
            {columns.map((column) => (
              <col key={column.key} style={column.width ? { width: column.width } : undefined} />
            ))}
          </colgroup>
          <thead>
            <tr className="bg-card-mint/50">
              {columns.map((column) => (
                <th
                  key={column.key}
                  className={cn(
                    'px-card py-item text-label-sm text-text-secondary',
                    ALIGN_CLASS[column.align ?? 'left'],
                  )}
                >
                  {column.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {status === 'loading' ? <TableSkeleton columns={columns.length} /> : null}

            {showBody
              ? rows.map((row) => (
                  <tr
                    key={rowKey(row)}
                    onClick={onRowClick ? () => onRowClick(row) : undefined}
                    className={cn(
                      'border-t border-neutral-light',
                      onRowClick && 'cursor-pointer hover:bg-card-mint/40',
                      rowClassName?.(row),
                    )}
                  >
                    {columns.map((column) => (
                      <td
                        key={column.key}
                        onClick={column.isAction ? (event) => event.stopPropagation() : undefined}
                        className={cn(
                          'truncate px-card py-item text-label font-normal',
                          ALIGN_CLASS[column.align ?? 'left'],
                        )}
                      >
                        {column.cell(row)}
                      </td>
                    ))}
                  </tr>
                ))
              : null}

            {showState && status !== 'loading' ? (
              <tr>
                <td colSpan={columns.length}>
                  {status === 'error' ? (
                    <ErrorState message={errorMessage} onRetry={onRetry} />
                  ) : isFiltered ? (
                    <EmptyState
                      variant="no-match"
                      message={t('chung.khongKhopBoLoc')}
                      onAction={onClearFilter}
                    />
                  ) : (
                    <EmptyState message={emptyMessage ?? t('chung.chuaCoDuLieu')} />
                  )}
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>

      {pagination && showBody ? (
        <div className="border-t border-neutral-light p-card">
          <Pagination {...pagination} />
        </div>
      ) : null}
    </div>
  );
}
