import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { CountTabs } from '@/components/ui/count-tabs';
import { DataTable, type Column } from '@/components/ui/data-table';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { FilterSelect } from '@/components/ui/filter-select';
import { Modal } from '@/components/ui/modal';
import { SearchField } from '@/components/ui/search-field';
import { TextInput } from '@/components/ui/field';
import { THU_TU_TAB, tinhTrangHanSoat } from '@/features/penalties/penalty-constants';
import {
  usePenalties,
  usePenaltyTabCounts,
  useReviewPenalty,
} from '@/features/penalties/hooks/use-penalties';
import { PENALTY_KINDS } from '@/features/penalties/types';
import type {
  PenaltyKind,
  PenaltyListQuery,
  PenaltyRow,
  PenaltyTabKey,
} from '@/features/penalties/types';
import { SO_LAN_TAM_AN_KHOA } from '@/features/sitters/sitter-constants';
import { formatDateTime, formatPercent } from '@/lib/format';
import { getErrorMessage } from '@/lib/api/client';
import { dungTabs } from '@/lib/tab-list';
import { trangThaiBang } from '@/lib/table-status';
import { notify } from '@/lib/toast';
import { useListPaging } from '@/lib/use-list-paging';
import { PATHS } from '@/routes/paths';

const LIMIT = 8;

export function PenaltiesScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [tab, setTab] = useState<PenaltyTabKey>('pendingReview');
  const [keyword, setKeyword] = useState('');
  const [kind, setKind] = useState<PenaltyKind | null>(null);
  const { page, setPage, doiBoLoc, phanTrang } = useListPaging(LIMIT);
  const [dongDangSoat, setDongDangSoat] = useState<PenaltyRow | null>(null);
  const [mienPhat, setMienPhat] = useState(true);
  const [ketLuan, setKetLuan] = useState('');

  const counts = usePenaltyTabCounts();
  const soat = useReviewPenalty();

  const query = useMemo<PenaltyListQuery>(
    () => ({
      tab,
      q: keyword || undefined,
      kind: kind ?? undefined,
      page,
      limit: LIMIT,
    }),
    [tab, keyword, kind, page],
  );

  const danhSach = usePenalties(query);
  const coBoLoc = Boolean(keyword || kind);

  const xoaBoLoc = () => {
    setKeyword('');
    setKind(null);
    setPage(1);
  };

  const dongDialog = () => {
    setDongDangSoat(null);
    setMienPhat(true);
    setKetLuan('');
  };

  const tabs = dungTabs(THU_TU_TAB, (key) => t(`kyLuat.tab.${key}`), counts.data);

  const columns: Array<Column<PenaltyRow>> = [
    {
      key: 'sitter',
      header: t('kyLuat.cot.nguoiCham'),
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.sitterName}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {row.profile.cancelRate === null
              ? t('kyLuat.tyLeHuyChuaDuMau')
              : t('kyLuat.tyLeHuyHienTai', {
                  value: formatPercent(row.profile.cancelRate * 100, 0),
                })}
            {' · '}
            {t('kyLuat.soCanhCao', { count: row.profile.warningCount })}
          </p>
        </div>
      ),
    },
    {
      key: 'kind',
      header: t('kyLuat.cot.loaiGhi'),
      width: 190,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{t(`kyLuat.loai.${row.kind}`)}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {row.reason ?? <KhongCoDuLieu />}
          </p>
        </div>
      ),
    },
    {
      key: 'booking',
      header: t('kyLuat.cot.donLienQuan'),
      width: 160,
      cell: (row) =>
        row.bookingCode ? (
          <div className="min-w-0">
            <p className="truncate text-label">{row.bookingCode}</p>
            <p className="truncate text-caption-sm text-text-secondary">
              {row.serviceName ?? <KhongCoDuLieu />}
            </p>
          </div>
        ) : (
          <KhongCoDuLieu />
        ),
    },
    {
      key: 'status',
      header: t('kyLuat.cot.trangThai'),
      width: 140,
      cell: (row) => (
        <Badge
          tone={
            row.status === 'WAIVED' ? 'success' : row.status === 'ACTIVE' ? 'danger' : 'pending'
          }
        >
          {t(`kyLuat.trangThai.${row.status}`)}
        </Badge>
      ),
    },
    {
      key: 'deadline',
      header: t('kyLuat.cot.hanSoat'),
      width: 168,
      cell: (row) => <HanSoat row={row} />,
    },
    {
      key: 'effect',
      header: t('kyLuat.cot.heQua'),
      width: 176,
      cell: (row) => (
        <span className="truncate text-caption-sm text-text-secondary">
          {t('kyLuat.lanTamAn', {
            lan: row.profile.hiddenTimesInWindow,
            nguong: SO_LAN_TAM_AN_KHOA,
          })}
        </span>
      ),
    },
    {
      key: 'actions',
      header: '',
      width: 112,
      align: 'right',
      isAction: true,
      cell: (row) =>
        row.status === 'PENDING_REVIEW' ? (
          <Button size="sm" variant="secondary" onClick={() => setDongDangSoat(row)}>
            {t('kyLuat.hanhDong.soat')}
          </Button>
        ) : (
          <Button
            size="sm"
            variant="ghost"
            onClick={() => void navigate(`${PATHS.sitterApprovals}/${row.sitterId}`)}
          >
            {t('kyLuat.hanhDong.xemHoSo')}
          </Button>
        ),
    },
  ];

  return (
    <div className="flex flex-col gap-stack pb-block">
      <CountTabs
        tabs={tabs}
        value={tab}
        onChange={(key) => doiBoLoc(() => setTab(key))}
        className="rounded-card bg-neutral-light/50 p-text"
      />

      <DataTable
        columns={columns}
        rows={danhSach.data?.items ?? []}
        rowKey={(row) => row.id}
        status={trangThaiBang(danhSach)}
        onRetry={() => void danhSach.refetch()}
        isFiltered={coBoLoc}
        onClearFilter={xoaBoLoc}
        emptyMessage={t(`kyLuat.rong.${tab}`)}
        toolbar={
          <>
            <SearchField
              value={keyword}
              onChange={(value) => doiBoLoc(() => setKeyword(value))}
              placeholder={t('kyLuat.timKiem')}
              className="w-[300px]"
            />
            <FilterSelect
              placeholder={t('kyLuat.loc.loaiGhi')}
              clearLabel={t('kyLuat.loc.moiLoaiGhi')}
              value={kind}
              onChange={(value) => doiBoLoc(() => setKind(value))}
              options={PENALTY_KINDS.map((kind) => ({
                value: kind,
                label: t(`kyLuat.loai.${kind}`),
              }))}
            />
          </>
        }
        pagination={phanTrang(danhSach.data?.total)}
      />

      <p className="text-caption-sm text-text-secondary">{t('kyLuat.ghiChu')}</p>

      <Modal
        open={dongDangSoat !== null}
        onOpenChange={(open) => (open ? undefined : dongDialog())}
        title={t('kyLuat.dialogSoat.tieuDe')}
        description={
          dongDangSoat
            ? t('kyLuat.dialogSoat.moTa', {
                ten: dongDangSoat.sitterName,
                lyDo: dongDangSoat.reason ?? t('chung.khongCoDuLieu'),
              })
            : undefined
        }
        confirmLabel={t('kyLuat.dialogSoat.nut')}
        confirmDisabled={ketLuan.trim().length < 3}
        loading={soat.isPending}
        onConfirm={() => {
          if (!dongDangSoat) return;
          soat.mutate(
            { id: dongDangSoat.id, waived: mienPhat, note: ketLuan.trim() },
            {
              onSuccess: () => {
                notify.success(mienPhat ? t('kyLuat.daMien') : t('kyLuat.daGiuPhat'));
                dongDialog();
              },
              onError: (error) => notify.error(getErrorMessage(error)),
            },
          );
        }}
      >
        <div className="flex flex-col gap-label">
          <ChonKetLuan
            chon={mienPhat}
            onChange={setMienPhat}
            value
            title={t('kyLuat.dialogSoat.mien')}
            desc={t('kyLuat.dialogSoat.mienMoTa')}
          />
          <ChonKetLuan
            chon={!mienPhat}
            onChange={(value) => setMienPhat(!value)}
            value
            title={t('kyLuat.dialogSoat.giu')}
            desc={t('kyLuat.dialogSoat.giuMoTa')}
          />
          <label className="mt-item flex flex-col gap-label">
            <span className="text-label-sm uppercase text-text-primary">
              {t('kyLuat.dialogSoat.ketLuan')}
            </span>
            <TextInput
              value={ketLuan}
              onChange={(event) => setKetLuan(event.target.value)}
              placeholder={t('kyLuat.dialogSoat.ketLuanGoiY')}
            />
          </label>
        </div>
      </Modal>
    </div>
  );
}

function HanSoat({ row }: { row: PenaltyRow }) {
  const { t } = useTranslation();
  const tinhTrang = tinhTrangHanSoat(row.reviewDeadline);

  if (tinhTrang.kieu === 'khongCo') {
    return <KhongCoDuLieu />;
  }
  if (tinhTrang.kieu === 'quaHan') {
    return <Badge tone="danger">{t('kyLuat.quaHanSoat')}</Badge>;
  }
  return (
    <div className="min-w-0">
      <Badge tone={tinhTrang.sapHet ? 'danger' : 'pending'}>
        {t('kyLuat.conLaiGio', { gio: tinhTrang.soGio })}
      </Badge>
      <p className="mt-text truncate text-caption-sm text-text-secondary">
        {formatDateTime(row.reviewDeadline as string)}
      </p>
    </div>
  );
}

function ChonKetLuan({
  chon,
  onChange,
  value,
  title,
  desc,
}: {
  chon: boolean;
  onChange: (value: boolean) => void;
  value: boolean;
  title: string;
  desc: string;
}) {
  return (
    <button
      type="button"
      onClick={() => onChange(value)}
      className={`flex flex-col rounded-card border p-item text-left ${
        chon ? 'border-primary bg-card-mint' : 'border-neutral-light'
      }`}
    >
      <span className="text-label">{title}</span>
      <span className="mt-text text-caption-sm text-text-secondary">{desc}</span>
    </button>
  );
}
