import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Eye, Info } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { CountTabs } from '@/components/ui/count-tabs';
import { DataTable, type Column } from '@/components/ui/data-table';
import { FilterSelect } from '@/components/ui/filter-select';
import { IconButton } from '@/components/ui/icon-button';
import { ImageViewer } from '@/components/ui/image-viewer';
import { useImageViewer, type AnhXem } from '@/components/ui/use-image-viewer';
import { Modal } from '@/components/ui/modal';
import { SearchField } from '@/components/ui/search-field';
import type { ServiceType } from '@/features/dashboard/chart-colors';
import { RatingStars, ReplyBadge } from '@/features/reviews/components/review-bits';
import { SAO_THAP_TOI_DA, THU_TU_TAB } from '@/features/reviews/review-constants';
import { reviewsApi } from '@/features/reviews/api/reviews-api';
import { useReviewTabCounts, useReviews } from '@/features/reviews/hooks/use-reviews';
import type { AdminReviewRow, ReviewListQuery, ReviewTabKey } from '@/features/reviews/types';
import { UserAvatar } from '@/features/users/components/user-badges';
import { formatDate, formatDateTime } from '@/lib/format';
import { nhanThoiLuong } from '@/lib/labels';
import { dungTabs } from '@/lib/tab-list';
import { trangThaiBang } from '@/lib/table-status';
import { useCsvExport } from '@/lib/use-csv-export';
import { DateRangeFilter } from '@/components/ui/date-range-filter';
import { useListPaging } from '@/lib/use-list-paging';
import { useDateRange } from '@/lib/use-date-range';

const LIMIT = 10;

const LOC_THEO_TAB: Record<ReviewTabKey, Partial<ReviewListQuery>> = {
  all: {},
  lowRating: { ratingTo: SAO_THAP_TOI_DA },
  hasPhotos: { hasPhotos: true },
  noReply: { replied: false },
};

export function ReviewsScreen() {
  const { t } = useTranslation();

  const [tab, setTab] = useState<ReviewTabKey>('all');
  const [keyword, setKeyword] = useState('');
  const [soSao, setSoSao] = useState<'1' | '2' | '3' | '4' | '5' | null>(null);
  const [serviceType, setServiceType] = useState<ServiceType | null>(null);
  const { khoangNgay, tuNgay, chon: chonKhoangNgay, xoa: xoaKhoangNgay } = useDateRange();
  const { page, setPage, doiBoLoc, phanTrang } = useListPaging(LIMIT);
  const [dangXem, setDangXem] = useState<AdminReviewRow | null>(null);

  const counts = useReviewTabCounts();

  const query = useMemo<ReviewListQuery>(
    () => ({
      q: keyword || undefined,
      ...LOC_THEO_TAB[tab],
      ...(soSao ? { ratingFrom: Number(soSao), ratingTo: Number(soSao) } : {}),
      serviceType: serviceType ?? undefined,
      from: tuNgay,
      page,
      limit: LIMIT,
    }),
    [tab, keyword, soSao, serviceType, tuNgay, page],
  );

  const csv = useCsvExport();

  const xuatCsv = () =>
    void csv.xuat<AdminReviewRow>({
      tai: (trang, limit) => reviewsApi.getReviews({ ...query, page: trang, limit }),
      tenFile: `danh-gia-${tab}.csv`,
      tieuDe: [
        t('danhGia.csv.maDon'),
        t('danhGia.csv.nguoiDanhGia'),
        t('danhGia.csv.nguoiCham'),
        t('danhGia.csv.dichVu'),
        t('danhGia.csv.soSao'),
        t('danhGia.csv.soAnh'),
        t('danhGia.csv.daDap'),
        t('danhGia.csv.danhGiaLuc'),
        t('danhGia.csv.hanDap'),
        t('danhGia.csv.dapLuc'),
      ],
      dong: (row) => [
        row.bookingCode,
        row.reviewerName,
        row.sitterName,
        row.serviceName,
        row.rating,
        row.photos.length,
        row.reply ? t('chung.co') : t('chung.khong'),
        row.createdAt,
        row.replyDeadline,
        row.replyAt,
      ],
    });

  const danhSach = useReviews(query);
  const rows = danhSach.data?.items ?? [];

  const coBoLoc = Boolean(keyword || soSao || serviceType || khoangNgay);

  const xoaBoLoc = () => {
    setKeyword('');
    setSoSao(null);
    setServiceType(null);
    xoaKhoangNgay();
    setPage(1);
  };

  const tabs = dungTabs(THU_TU_TAB, (key) => t(`danhGia.tab.${key}`), counts.data);

  const columns: Array<Column<AdminReviewRow>> = [
    {
      key: 'reviewer',
      header: t('danhGia.cot.nguoiDanhGia'),
      width: 200,
      cell: (row) => (
        <div className="flex min-w-0 items-center gap-label">
          <UserAvatar name={row.reviewerName} url={row.reviewerAvatar} />
          <div className="min-w-0">
            <p className="truncate text-label">{row.reviewerName}</p>
            <p className="truncate text-caption-sm text-text-secondary">
              {formatDate(row.createdAt)}
            </p>
          </div>
        </div>
      ),
    },
    {
      key: 'sitter',
      header: t('danhGia.cot.nguoiCham'),
      width: 168,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.sitterName}</p>
          <p className="truncate text-caption-sm text-text-secondary">{row.bookingCode}</p>
        </div>
      ),
    },
    {
      key: 'service',
      header: t('danhGia.cot.dichVu'),
      width: 124,
      cell: (row) => (
        <div className="min-w-0">
          <p className="truncate text-label">{row.serviceName}</p>
          <p className="truncate text-caption-sm text-text-secondary">
            {nhanThoiLuong(t, row.durationMinutes) ?? ''}
          </p>
        </div>
      ),
    },
    {
      key: 'rating',
      header: t('danhGia.cot.diem'),
      width: 96,
      cell: (row) => <RatingStars rating={row.rating} />,
    },
    {
      key: 'comment',
      header: t('danhGia.cot.noiDung'),
      cell: (row) => (
        <p className="line-clamp-3 whitespace-normal text-label font-normal">
          {row.comment}
          {row.photos.length > 0 ? (
            <span className="text-text-secondary">
              {' · '}
              {t('danhGia.soAnh', { soAnh: row.photos.length })}
            </span>
          ) : null}
        </p>
      ),
    },
    {
      key: 'reply',
      header: t('danhGia.cot.phanHoi'),
      width: 124,
      cell: (row) => <ReplyBadge row={row} />,
    },
    {
      key: 'actions',
      header: '',
      width: 76,
      align: 'right',
      isAction: true,
      cell: (row) => (
        <IconButton
          label={t('danhGia.thaoTac.xemChiTiet')}
          icon={Eye}
          onClick={() => setDangXem(row)}
        />
      ),
    },
  ];

  return (
    <div className="flex flex-col gap-stack pb-block">
      <CountTabs
        tabs={tabs}
        value={tab}
        onChange={(key) => doiBoLoc(() => setTab(key))}
        className="flex-wrap rounded-card bg-neutral-light/50 p-text"
      />

      <DataTable
        columns={columns}
        rows={rows}
        rowKey={(row) => row.id}
        status={trangThaiBang(danhSach)}
        onRetry={() => void danhSach.refetch()}
        onRowClick={(row) => setDangXem(row)}
        isFiltered={coBoLoc}
        onClearFilter={xoaBoLoc}
        emptyMessage={t('danhGia.chuaCoDanhGia')}
        toolbar={
          <>
            <SearchField
              value={keyword}
              onChange={(value) => doiBoLoc(() => setKeyword(value))}
              placeholder={t('danhGia.timKiem')}
              className="w-[292px]"
            />
            <FilterSelect
              placeholder={t('danhGia.loc.soSao')}
              clearLabel={t('danhGia.loc.moiSoSao')}
              value={soSao}
              onChange={(value) => doiBoLoc(() => setSoSao(value))}
              options={[
                { value: '5', label: t('danhGia.loc.nSao', { soSao: 5 }) },
                { value: '4', label: t('danhGia.loc.nSao', { soSao: 4 }) },
                { value: '3', label: t('danhGia.loc.nSao', { soSao: 3 }) },
                { value: '2', label: t('danhGia.loc.nSao', { soSao: 2 }) },
                { value: '1', label: t('danhGia.loc.nSao', { soSao: 1 }) },
              ]}
            />
            <FilterSelect
              placeholder={t('khieuNai.loc.dichVu')}
              clearLabel={t('don.loc.moiDichVu')}
              value={serviceType}
              onChange={(value) => doiBoLoc(() => setServiceType(value))}
              options={[
                { value: 'WALKING', label: t('dashboard.dichVu.WALKING') },
                { value: 'BOARDING', label: t('dashboard.dichVu.BOARDING') },
                { value: 'GROOMING', label: t('dashboard.dichVu.GROOMING') },
              ]}
            />
            <DateRangeFilter
              value={khoangNgay}
              onChange={(value) => doiBoLoc(() => chonKhoangNgay(value))}
            />
          </>
        }
        toolbarActions={
          <Button variant="secondary" size="sm" onClick={xuatCsv} loading={csv.dangXuat}>
            {t('danhGia.xuatCsv')}
          </Button>
        }
        pagination={phanTrang(danhSach.data?.total)}
      />

      <p className="flex items-start gap-label rounded-card bg-neutral-light/50 p-card text-caption-sm text-text-secondary">
        <Info className="mt-[1px] h-4 w-4 shrink-0" strokeWidth={1.8} />
        {danhSach.data?.avgRating != null
          ? `${t('danhGia.diemTrungBinh', {
              diem: danhSach.data.avgRating.toFixed(1).replace('.', ','),
              soLuong: danhSach.data.total,
            })} ${t('danhGia.ghiChuThieuModel')}`
          : t('danhGia.ghiChuThieuModel')}
      </p>

      <ChiTietDanhGiaModal row={dangXem} onDong={() => setDangXem(null)} />
    </div>
  );
}

function ChiTietDanhGiaModal({ row, onDong }: { row: AdminReviewRow | null; onDong: () => void }) {
  const { t } = useTranslation();
  const xem = useImageViewer();
  if (!row) return null;

  const anh: AnhXem[] = row.photos.map((url) => ({ url, nhan: row.reviewerName }));

  return (
    <Modal
      open
      onOpenChange={(open) => {
        if (!open) onDong();
      }}
      title={t('danhGia.chiTiet.tieuDe')}
      description={t('danhGia.chiTiet.moTa', { code: row.bookingCode })}
    >
      <div className="flex flex-col gap-item">
        <div className="flex items-center gap-item">
          <UserAvatar name={row.reviewerName} url={row.reviewerAvatar} size={40} />
          <div className="min-w-0">
            <p className="truncate text-label">{row.reviewerName}</p>
            <p className="truncate text-caption-sm text-text-secondary">
              {formatDateTime(row.createdAt)} · {row.serviceName}
            </p>
          </div>
          <div className="ml-auto">
            <RatingStars rating={row.rating} size={16} />
          </div>
        </div>

        <p className="text-label font-normal">{row.comment}</p>

        {row.photos.length > 0 ? (
          <div className="grid grid-cols-3 gap-label">
            {row.photos.map((photo, viTri) => (
              <button
                key={photo}
                type="button"
                aria-label={t('xemAnh.moAnh')}
                onClick={() => xem.mo(viTri)}
                className="h-[92px] overflow-hidden rounded-card bg-neutral-light/60"
              >
                <img src={photo} alt="" className="h-full w-full object-cover" />
              </button>
            ))}
          </div>
        ) : null}

        <div className="rounded-card bg-neutral-light/50 p-card">
          <p className="text-label-sm uppercase text-text-secondary">
            {t('danhGia.chiTiet.phanHoiNcc')}
          </p>
          {row.reply && row.replyAt ? (
            <>
              <p className="mt-label text-label font-normal">{row.reply}</p>
              <p className="mt-label text-caption-sm text-text-secondary">
                {formatDateTime(row.replyAt)}
              </p>
            </>
          ) : (
            <p className="mt-label text-label font-normal text-text-secondary">
              {t('danhGia.chiTiet.chuaDap')}
            </p>
          )}
        </div>
      </div>

      <ImageViewer anh={anh} moTai={xem.moTai} onDong={xem.dong} />
    </Modal>
  );
}
