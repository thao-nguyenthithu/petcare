import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Info } from 'lucide-react';
import { CountTabs, type CountTab } from '@/components/ui/count-tabs';
import type { ServiceType } from '@/features/dashboard/chart-colors';
import { ServiceCatalogTable } from '@/features/services/components/service-catalog-table';
import { ServiceConstraintsTable } from '@/features/services/components/service-constraints-table';
import { KhoaCauHinhDialog, SuaDichVuDialog } from '@/features/services/components/service-dialogs';
import { SitterServiceTable } from '@/features/services/components/sitter-service-table';
import {
  useServiceConstraints,
  useServices,
  useSitterServices,
} from '@/features/services/hooks/use-services';
import { LIMIT_CAU_HINH } from '@/features/services/service-constants';
import type {
  ServiceRow,
  ServicesTabKey,
  SitterServiceQuery,
  SitterServiceRow,
} from '@/features/services/types';

export function ServicesScreen() {
  const { t } = useTranslation();
  const [tab, setTab] = useState<ServicesTabKey>('catalog');

  const dichVu = useServices();
  const rangBuoc = useServiceConstraints();
  const [keyword, setKeyword] = useState('');
  const [loaiDichVu, setLoaiDichVu] = useState<ServiceType | null>(null);
  const [dangBat, setDangBat] = useState<'true' | 'false' | null>(null);
  const [page, setPage] = useState(1);

  const query = useMemo<SitterServiceQuery>(
    () => ({
      q: keyword || undefined,
      type: loaiDichVu ?? undefined,
      enabled: dangBat === null ? undefined : dangBat === 'true',
      page,
      limit: LIMIT_CAU_HINH,
    }),
    [keyword, loaiDichVu, dangBat, page],
  );
  const cauHinh = useSitterServices(query);

  const [dongDangSua, setDongDangSua] = useState<ServiceRow | null>(null);
  const [dongDangKhoa, setDongDangKhoa] = useState<SitterServiceRow | null>(null);

  const tabs: Array<CountTab<ServicesTabKey>> = [
    { key: 'catalog', label: t('dichVu.tab.danhMuc'), count: dichVu.data?.items.length },
    { key: 'sitterServices', label: t('dichVu.tab.cauHinh'), count: cauHinh.data?.total },
    { key: 'constants', label: t('dichVu.tab.hangSo') },
  ];

  return (
    <div className="flex flex-col gap-stack pb-block">
      <CountTabs
        tabs={tabs}
        value={tab}
        onChange={setTab}
        className="rounded-card bg-neutral-light/50 p-text"
      />

      {tab === 'catalog' ? (
        <>
          <ServiceCatalogTable
            rows={dichVu.data?.items ?? []}
            dangTai={dichVu.isPending}
            loi={dichVu.isError}
            onRetry={() => void dichVu.refetch()}
            onSua={setDongDangSua}
          />
          <p className="flex items-start gap-item rounded-card bg-honey/15 p-card text-caption-sm text-honey">
            <Info className="mt-[1px] h-4 w-4 shrink-0" strokeWidth={1.8} />
            {t('dichVu.ghiChuEnum')}
          </p>
        </>
      ) : null}

      {tab === 'sitterServices' ? (
        <SitterServiceTable
          rows={cauHinh.data?.items ?? []}
          total={cauHinh.data?.total ?? 0}
          page={page}
          onPageChange={setPage}
          dangTai={cauHinh.isPending}
          loi={cauHinh.isError}
          onRetry={() => void cauHinh.refetch()}
          keyword={keyword}
          onKeyword={(value) => {
            setKeyword(value);
            setPage(1);
          }}
          loaiDichVu={loaiDichVu}
          onLoaiDichVu={(value) => {
            setLoaiDichVu(value);
            setPage(1);
          }}
          dangBat={dangBat}
          onDangBat={(value) => {
            setDangBat(value);
            setPage(1);
          }}
          onXoaBoLoc={() => {
            setKeyword('');
            setLoaiDichVu(null);
            setDangBat(null);
            setPage(1);
          }}
          onKhoa={setDongDangKhoa}
        />
      ) : null}

      {tab === 'constants' ? (
        <ServiceConstraintsTable
          rows={rangBuoc.data?.items ?? []}
          dangTai={rangBuoc.isPending}
          loi={rangBuoc.isError}
          onRetry={() => void rangBuoc.refetch()}
        />
      ) : null}

      <SuaDichVuDialog row={dongDangSua} onClose={() => setDongDangSua(null)} />
      <KhoaCauHinhDialog row={dongDangKhoa} onClose={() => setDongDangKhoa(null)} />
    </div>
  );
}
