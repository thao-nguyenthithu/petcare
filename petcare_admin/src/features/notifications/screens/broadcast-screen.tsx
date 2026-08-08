import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { CalendarX, Copy, Minus } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { DataTable, type Column } from '@/components/ui/data-table';
import { IconButton } from '@/components/ui/icon-button';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { Modal } from '@/components/ui/modal';
import { ComposeCard } from '@/features/notifications/components/compose-card';
import {
  useCampaigns,
  useCancelCampaign,
} from '@/features/notifications/hooks/use-notifications';
import type { CampaignRow } from '@/features/notifications/types';
import { getErrorMessage } from '@/lib/api/client';
import { formatDateTime, formatNumber, formatPercent } from '@/lib/format';
import { trangThaiBang } from '@/lib/table-status';
import { notify } from '@/lib/toast';
import { useListPaging } from '@/lib/use-list-paging';

const LIMIT = 10;

export function BroadcastScreen() {
  const { t } = useTranslation();
  const { page, phanTrang } = useListPaging(LIMIT);
  const luotGui = useCampaigns(page, LIMIT);
  const huyLich = useCancelCampaign();
  const [nguonSoan, setNguonSoan] = useState<CampaignRow | null>(null);
  const [nguonSeq, setNguonSeq] = useState(0);
  const [lanSoanMoi, setLanSoanMoi] = useState(0);
  const [dangHuy, setDangHuy] = useState<CampaignRow | null>(null);

  const chonNguon = (row: CampaignRow) => {
    setNguonSoan(row);
    setNguonSeq((truoc) => truoc + 1);
  };

  const xacNhanHuy = () => {
    if (!dangHuy) return;
    huyLich.mutate(dangHuy.id, {
      onSuccess: () => {
        notify.success(t('thongBao.daHuyLich'));
        setDangHuy(null);
      },
      onError: (error) => notify.error(getErrorMessage(error)),
    });
  };

  const rows = useMemo(() => luotGui.data?.items ?? [], [luotGui.data]);
  const daGui = useMemo(() => rows.filter((row) => row.sentAt !== null), [rows]);

  const columns: Array<Column<CampaignRow>> = [
    {
      key: 'title',
      header: t('thongBao.cot.tieuDe'),
      cell: (row) => (
        <div className="min-w-0">
          <p className="whitespace-normal text-label">{row.title}</p>
          <p className="mt-text text-caption-sm text-text-secondary">
            {row.sentAt
              ? t('thongBao.guiLuc', { time: formatDateTime(row.sentAt) })
              : row.scheduledAt
                ? t('thongBao.henLuc', { time: formatDateTime(row.scheduledAt) })
                : t('thongBao.taoLuc', { time: formatDateTime(row.createdAt) })}
          </p>
        </div>
      ),
    },
    {
      key: 'audience',
      header: t('thongBao.cot.doiTuong'),
      width: 152,
      cell: (row) => (
        <span className="text-label font-normal">
          {t(`thongBao.doiTuong.${row.audienceKind}`)}
          {row.audienceValue ? (
            <span className="block truncate text-caption-sm text-text-secondary">
              {row.audienceValue}
            </span>
          ) : null}
        </span>
      ),
    },
    {
      key: 'recipientCount',
      header: t('thongBao.cot.nguoiNhan'),
      width: 116,
      align: 'right',
      cell: (row) => (
        <span className="text-label">
          {row.sentAt ? formatNumber(row.recipientCount) : <KhongCoDuLieu />}
        </span>
      ),
    },
    {
      key: 'readCount',
      header: t('thongBao.cot.daDoc'),
      width: 112,
      cell: (row) => {
        if (!row.sentAt) {
          return (
            <Badge tone="pending">
              {row.scheduledAt
                ? t('thongBao.trangThai.henGio')
                : t('thongBao.trangThai.dangGui')}
            </Badge>
          );
        }
        const tiLe = row.recipientCount ? (row.readCount / row.recipientCount) * 100 : 0;
        return (
          <Badge tone="neutral" icon={Minus}>
            {formatPercent(tiLe, 0)}
          </Badge>
        );
      },
    },
    {
      key: 'actions',
      header: '',
      width: 96,
      align: 'right',
      isAction: true,
      cell: (row) => {
        const choHen = row.sentAt === null && row.scheduledAt !== null;
        return (
          <div className="flex items-center justify-end gap-text">
            {row.sentAt || choHen ? (
              <IconButton
                label={t('thongBao.thaoTac.soanLai')}
                icon={Copy}
                bordered
                onClick={() => chonNguon(row)}
              />
            ) : null}
            {choHen ? (
              <IconButton
                label={t('thongBao.thaoTac.huyLich')}
                icon={CalendarX}
                tone="danger"
                bordered
                onClick={() => setDangHuy(row)}
              />
            ) : null}
          </div>
        );
      },
    },
  ];

  return (
    <div className="flex gap-group pb-block">
      <div className="flex min-w-0 flex-1 flex-col gap-item">
        <DataTable
          columns={columns}
          rows={rows}
          rowKey={(row) => row.id}
          status={trangThaiBang(luotGui)}
          onRetry={() => void luotGui.refetch()}
          emptyMessage={t('thongBao.chuaCoLuot')}
          pagination={phanTrang(luotGui.data?.total)}
          toolbar={
            <div className="min-w-0">
              <h2 className="text-h3">{t('thongBao.lichSu.tieuDe')}</h2>
              <p className="mt-text text-caption-sm text-text-secondary">
                {t('thongBao.lichSu.moTa')}
              </p>
            </div>
          }
          toolbarActions={
            <Button
              size="sm"
              onClick={() => {
                setNguonSoan(null);
                setLanSoanMoi((truoc) => truoc + 1);
              }}
            >
              {t('thongBao.soanTinMoi')}
            </Button>
          }
        />
      </div>

      <div className="w-[396px] shrink-0">
        <ComposeCard key={lanSoanMoi} nguon={nguonSoan} nguonSeq={nguonSeq} ganNhat={daGui} />
      </div>

      <Modal
        open={dangHuy !== null}
        onOpenChange={(mo) => setDangHuy(mo ? dangHuy : null)}
        title={t('thongBao.huyLich.tieuDe')}
        description={t('thongBao.huyLich.moTa', {
          time: dangHuy?.scheduledAt ? formatDateTime(dangHuy.scheduledAt) : '',
        })}
        confirmLabel={t('thongBao.huyLich.nut')}
        danger
        loading={huyLich.isPending}
        onConfirm={xacNhanHuy}
      >
        <p className="rounded-card bg-canvas p-card text-label">{dangHuy?.title}</p>
      </Modal>
    </div>
  );
}
