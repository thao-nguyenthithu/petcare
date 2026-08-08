import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { AlertTriangle, BellRing, Check, Info, X } from 'lucide-react';
import { buttonVariants } from '@/components/ui/button-variants';
import { Badge } from '@/components/ui/badge';
import { DataTable, type Column } from '@/components/ui/data-table';
import { SectionCard } from '@/components/ui/section-card';
import {
  GHI_CHU_PHONG_BENH,
  LOAI_THONG_BAO,
} from '@/features/notifications/notification-types';
import type { NotificationTypeRow } from '@/features/notifications/types';
import { PATHS } from '@/routes/paths';
import { cn } from '@/lib/utils';

export function NotificationTypesScreen() {
  const { t } = useTranslation();
  const chuaCoTrigger = LOAI_THONG_BAO.filter((row) => !row.hasTrigger);

  const columns: Array<Column<NotificationTypeRow>> = [
    {
      key: 'type',
      header: t('thongBao.loai.cot.loai'),
      width: 168,
      cell: (row) => (
        <span className="inline-block max-w-full truncate rounded-[7px] bg-neutral-light/70 px-label py-text text-label-sm text-text-primary">
          {t(`thongBao.tenLoai.${row.type}`, { defaultValue: row.type })}
        </span>
      ),
    },
    {
      key: 'event',
      header: t('thongBao.loai.cot.suKien'),
      cell: (row) => (
        <p
          className={cn(
            'whitespace-normal text-label font-normal',
            !row.hasTrigger && 'text-text-secondary',
          )}
        >
          {t(`thongBao.loai.suKien.${row.type}`)}
        </p>
      ),
    },
    {
      key: 'audience',
      header: t('thongBao.loai.cot.nguoiNhan'),
      width: 116,
      cell: (row) => (
        <span className="text-label font-normal">{t(`thongBao.nguoiNhan.${row.audience}`)}</span>
      ),
    },
    {
      key: 'openTarget',
      header: t('thongBao.loai.cot.moMan'),
      width: 210,
      cell: (row) => (
        <span className="text-caption-sm text-text-secondary">
          {t(`thongBao.loai.moMan.${row.type}`)}
        </span>
      ),
    },
    {
      key: 'inApp',
      header: t('thongBao.loai.cot.inApp'),
      width: 84,
      align: 'center',
      cell: (row) => <DauKenh bat={row.inApp} mo={!row.hasTrigger} />,
    },
    {
      key: 'push',
      header: t('thongBao.loai.cot.push'),
      width: 84,
      align: 'center',
      cell: (row) => <DauKenh bat={row.push} mo={!row.hasTrigger} />,
    },
    {
      key: 'hasTrigger',
      header: t('thongBao.loai.cot.tinhTrang'),
      width: 116,
      align: 'center',
      cell: (row) => (
        <Badge tone={row.hasTrigger ? 'success' : 'pending'}>
          {row.hasTrigger ? t('thongBao.loai.daCo') : t('thongBao.loai.chuaCo')}
        </Badge>
      ),
    },
  ];

  return (
    <div className="flex flex-col gap-group pb-block">
      <DataTable
        columns={columns}
        rows={LOAI_THONG_BAO}
        rowKey={(row) => row.type}
        status="success"
        toolbar={
          <div className="min-w-0">
            <h2 className="text-h3">{t('thongBao.loai.tieuDe')}</h2>
            <p className="mt-text text-caption-sm text-text-secondary">{t('thongBao.loai.moTa')}</p>
          </div>
        }
      />

      <div className="grid grid-cols-3 gap-group">
        <SectionCard
          title={t('thongBao.phongBenh.tieuDe')}
          subtitle={t('thongBao.phongBenh.moTa')}
          bodyClassName="flex flex-col gap-item"
        >
          {GHI_CHU_PHONG_BENH.map((item) => (
            <div key={item.ma} className="flex items-start justify-between gap-item">
              <div className="min-w-0">
                <p className="text-label">{t(`thongBao.phongBenh.muc.${item.ma}.nhan`)}</p>
                <p className="mt-text text-caption-sm text-text-secondary">
                  {t(`thongBao.phongBenh.muc.${item.ma}.mo`)}
                </p>
              </div>
              <span className="shrink-0 rounded-card border border-neutral-light bg-canvas px-item py-label text-label-sm text-text-secondary">
                {t(`thongBao.phongBenh.muc.${item.ma}.giaTri`)}
              </span>
            </div>
          ))}
        </SectionCard>

        <SectionCard
          title={t('thongBao.chuaTrigger.tieuDe', { so: chuaCoTrigger.length })}
          subtitle={t('thongBao.chuaTrigger.moTa')}
          bodyClassName="flex flex-col gap-item"
        >
          {chuaCoTrigger.map((row) => (
            <div
              key={row.type}
              className="flex items-start gap-item rounded-card bg-honey/15 p-card"
            >
              <AlertTriangle className="mt-[1px] h-4 w-4 shrink-0 text-honey" strokeWidth={1.8} />
              <div className="min-w-0">
                <p className="text-label text-honey">{t(`thongBao.tenLoai.${row.type}`)}</p>
                <p className="mt-text text-caption-sm text-honey/90">
                  {t(`thongBao.chuaTrigger.ly.${row.type}`)}
                </p>
              </div>
            </div>
          ))}
        </SectionCard>

        <SectionCard
          title={t('thongBao.guiTay.tieuDe')}
          subtitle={t('thongBao.guiTay.moTa')}
          bodyClassName="flex flex-col gap-item"
        >
          <div className="flex items-start gap-item rounded-card bg-card-mint p-card">
            <BellRing className="mt-[1px] h-4 w-4 shrink-0 text-primary" strokeWidth={1.8} />
            <p className="text-caption-sm text-text-primary">{t('thongBao.guiTay.chiNoiDung')}</p>
          </div>
          <ul className="flex flex-col gap-label">
            {['dinhNghia', 'khongTrigger', 'khongTargetId'].map((key) => (
              <li
                key={key}
                className="flex items-start gap-label text-caption-sm text-text-secondary"
              >
                <Info className="mt-[1px] h-[14px] w-[14px] shrink-0" strokeWidth={1.8} />
                {t(`thongBao.guiTay.y.${key}`)}
              </li>
            ))}
          </ul>
          <Link
            to={PATHS.broadcast}
            className={cn(buttonVariants({ variant: 'secondary', size: 'sm' }), 'mt-auto w-full')}
          >
            {t('thongBao.guiTay.nut')}
          </Link>
        </SectionCard>
      </div>

      <p className="flex items-start gap-item rounded-card bg-canvas p-card text-caption-sm text-text-secondary">
        <Info className="mt-[1px] h-4 w-4 shrink-0" strokeWidth={1.8} />
        {t('thongBao.ghiChuModel')}
      </p>
    </div>
  );
}

function DauKenh({ bat, mo }: { bat: boolean; mo: boolean }) {
  const Icon = bat ? Check : X;
  return (
    <span
      className={cn(
        'inline-flex h-6 w-6 items-center justify-center rounded-full',
        bat ? 'bg-primary/12 text-primary' : 'bg-neutral-light text-text-secondary',
        mo && 'opacity-40',
      )}
    >
      <Icon className="h-[14px] w-[14px]" strokeWidth={2} />
    </span>
  );
}
