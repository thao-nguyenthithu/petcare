import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { DataTable, type Column } from '@/components/ui/data-table';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { FilterSelect } from '@/components/ui/filter-select';
import { AuditLogIcon } from '@/features/settings/components/audit-log-icon';
import { useAuditLogFilters, useAuditLogs } from '@/features/settings/hooks/use-settings';
import type { AuditLogQuery, AuditLogRow } from '@/features/settings/types';
import { formatDateTime } from '@/lib/format';
import { trangThaiBang } from '@/lib/table-status';
import { useListPaging } from '@/lib/use-list-paging';

const LIMIT = 10;

export function AuditLogTable() {
  const { t } = useTranslation();
  const [action, setAction] = useState<string | null>(null);
  const [targetType, setTargetType] = useState<string | null>(null);
  const { page, setPage, phanTrang } = useListPaging(LIMIT);
  const boLoc = useAuditLogFilters();

  const query = useMemo<AuditLogQuery>(
    () => ({
      action: action ?? undefined,
      targetType: targetType ?? undefined,
      page,
      limit: LIMIT,
    }),
    [action, targetType, page],
  );
  const nhatKy = useAuditLogs(query);

  const columns: Array<Column<AuditLogRow>> = [
    {
      key: 'action',
      header: t('caiDat.nhatKy.cot.hanhDong'),
      width: 232,
      cell: (row) => (
        <div className="flex min-w-0 items-center gap-item">
          <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-card bg-card-mint text-primary">
            <AuditLogIcon action={row.action} className="h-4 w-4" />
          </span>
          <span className="truncate text-label">
            {t(`caiDat.hanhDong.${row.action}`, { defaultValue: row.action })}
          </span>
        </div>
      ),
    },
    {
      key: 'targetType',
      header: t('caiDat.nhatKy.cot.loaiDoiTuong'),
      width: 132,
      cell: (row) => (
        <span className="inline-block max-w-full truncate rounded-[7px] bg-neutral-light/70 px-label py-text text-label-sm">
          {t(`caiDat.loaiDoiTuong.${row.targetType}`, { defaultValue: row.targetType })}
        </span>
      ),
    },
    {
      key: 'targetCode',
      header: t('caiDat.nhatKy.cot.doiTuong'),
      width: 196,
      cell: (row) =>
        row.targetCode ? (
          <span className="text-label font-normal">{row.targetCode}</span>
        ) : (
          <KhongCoDuLieu />
        ),
    },
    {
      key: 'change',
      header: t('caiDat.nhatKy.cot.thayDoi'),
      width: 214,
      cell: (row) =>
        row.oldValue || row.newValue ? (
          <span className="text-caption-sm text-text-secondary">
            {row.oldValue ?? t('chung.khongCoDuLieu')} → {row.newValue ?? t('chung.khongCoDuLieu')}
          </span>
        ) : (
          <KhongCoDuLieu />
        ),
    },
    {
      key: 'reason',
      header: t('caiDat.nhatKy.cot.lyDo'),
      cell: (row) =>
        row.reason ? (
          <p className="whitespace-normal text-caption-sm text-text-secondary">{row.reason}</p>
        ) : (
          <KhongCoDuLieu />
        ),
    },
    {
      key: 'createdAt',
      header: t('caiDat.nhatKy.cot.thoiDiem'),
      width: 152,
      cell: (row) => (
        <span className="text-label font-normal text-text-secondary">
          {formatDateTime(row.createdAt)}
        </span>
      ),
    },
  ];

  const dangLoc = Boolean(action || targetType);

  return (
    <DataTable
      columns={columns}
      rows={nhatKy.data?.items ?? []}
      rowKey={(row) => row.id}
      status={trangThaiBang(nhatKy)}
      onRetry={() => void nhatKy.refetch()}
      isFiltered={dangLoc}
      onClearFilter={() => {
        setAction(null);
        setTargetType(null);
        setPage(1);
      }}
      emptyMessage={t('caiDat.nhatKy.chuaCo')}
      toolbar={
        <>
          <FilterSelect
            placeholder={t('caiDat.nhatKy.locHanhDong')}
            clearLabel={t('caiDat.nhatKy.moiHanhDong')}
            value={action}
            onChange={(value) => {
              setAction(value);
              setPage(1);
            }}
            options={(boLoc.data?.actions ?? []).map((value) => ({
              value,
              label: t(`caiDat.hanhDong.${value}`, { defaultValue: value }),
            }))}
          />
          <FilterSelect
            placeholder={t('caiDat.nhatKy.locDoiTuong')}
            clearLabel={t('caiDat.nhatKy.moiDoiTuong')}
            value={targetType}
            onChange={(value) => {
              setTargetType(value);
              setPage(1);
            }}
            options={(boLoc.data?.targetTypes ?? []).map((value) => ({
              value,
              label: t(`caiDat.loaiDoiTuong.${value}`, { defaultValue: value }),
            }))}
          />
        </>
      }
      toolbarActions={
        <span className="text-caption-sm text-text-secondary">{t('caiDat.nhatKy.giuLai')}</span>
      }
      pagination={phanTrang(nhatKy.data?.total)}
    />
  );
}
