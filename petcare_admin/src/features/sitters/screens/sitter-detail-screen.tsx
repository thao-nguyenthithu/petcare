import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { TextInput } from '@/components/ui/field';
import { Modal } from '@/components/ui/modal';
import { PageHeader } from '@/components/ui/page-header';
import { ErrorState } from '@/components/state/error-state';
import { Skeleton } from '@/components/state/skeleton';
import {
  GiayToCard,
  HoSoCard,
  VungPhucVuCard,
} from '@/features/sitters/components/sitter-identity-cards';
import {
  DichVuCard,
  KyLuatCard,
} from '@/features/sitters/components/sitter-service-cards';
import {
  useBanSitter,
  useDecideSitter,
  useHideSitter,
  useRequestSupplement,
  useSitterDetail,
} from '@/features/sitters/hooks/use-sitters';
import {
  BAC_NGAY_TAM_AN,
  NGAY_TAM_AN_MAC_DINH,
  SO_LAN_TAM_AN_KHOA,
  THANG_DEM_LAN_TAM_AN,
  trangThaiCuaNcc,
} from '@/features/sitters/sitter-constants';
import { RunningBookingNotice } from '@/features/users/components/running-booking-notice';
import { getErrorMessage } from '@/lib/api/client';
import { formatDateTime } from '@/lib/format';
import { notify } from '@/lib/toast';
import { PATHS } from '@/routes/paths';

const TU_KHOA_KHOA = 'KHOA VINH VIEN';

export function SitterDetailScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { id = '' } = useParams();
  const chiTiet = useSitterDetail(id);
  const duyet = useDecideSitter();
  const boSung = useRequestSupplement();
  const tamAn = useHideSitter();
  const khoa = useBanSitter();

  const [moBoSung, setMoBoSung] = useState(false);
  const [moTuChoi, setMoTuChoi] = useState(false);
  const [moDuyet, setMoDuyet] = useState(false);
  const [moTamAn, setMoTamAn] = useState(false);
  const [moKhoa, setMoKhoa] = useState(false);
  const [moGoKhoa, setMoGoKhoa] = useState(false);
  const [lyDo, setLyDo] = useState('');
  const [soNgayAn, setSoNgayAn] = useState(NGAY_TAM_AN_MAC_DINH);
  const [tuKhoa, setTuKhoa] = useState('');

  if (chiTiet.isError) {
    return <ErrorState onRetry={() => void chiTiet.refetch()} />;
  }

  const data = chiTiet.data;
  const ten = data ? data.user.fullName : id;
  const trangThai = data ? trangThaiCuaNcc(data.sitter) : null;
  const choDuyet = trangThai === 'pending';
  const dangHoatDong = trangThai === 'active' || trangThai === 'hidden';
  const chuaDuyet = data ? !data.sitter.approvedAt : false;

  const dongDialog = () => {
    setMoBoSung(false);
    setMoTuChoi(false);
    setMoDuyet(false);
    setMoTamAn(false);
    setMoKhoa(false);
    setMoGoKhoa(false);
    setLyDo('');
    setSoNgayAn(NGAY_TAM_AN_MAC_DINH);
    setTuKhoa('');
  };

  const baoLoi = (error: unknown) => notify.error(getErrorMessage(error));
  const daKhoa = trangThai === 'banned';
  const dangAn = trangThai === 'hidden';
  const lanAnKeTiep = (data?.sitter.hiddenTimesInWindow ?? 0) + 1;
  const donDangChay = data?.stats.runningBookingCount;

  return (
    <div className="flex flex-col gap-stack pb-block">
      <PageHeader
        backTo={PATHS.sitterApprovals}
        crumbs={[{ label: t('man.hoSoChoDuyet.title'), to: PATHS.sitterApprovals }, { label: ten }]}
        actions={
          choDuyet ? (
            <>
              <Button variant="ghost" onClick={() => setMoBoSung(true)}>
                {t('hoSoNcc.hanhDong.yeuCauBoSung')}
              </Button>
              <Button variant="danger" onClick={() => setMoTuChoi(true)}>
                {t('hoSoNcc.hanhDong.tuChoi')}
              </Button>
              <Button onClick={() => setMoDuyet(true)}>{t('hoSoNcc.hanhDong.duyet')}</Button>
            </>
          ) : daKhoa ? (
            <Button variant="secondary" onClick={() => setMoGoKhoa(true)}>
              {t('hoSoNcc.hanhDong.goKhoa')}
            </Button>
          ) : dangHoatDong ? (
            <>
              <Button
                variant="secondary"
                disabled={dangAn}
                title={
                  dangAn && data?.sitter.hiddenUntil
                    ? t('hoSoNcc.dangTrongHanAn', {
                        den: formatDateTime(data.sitter.hiddenUntil),
                      })
                    : undefined
                }
                onClick={() => setMoTamAn(true)}
              >
                {t('hoSoNcc.hanhDong.tamAn')}
              </Button>
              <Button variant="danger" onClick={() => setMoKhoa(true)}>
                {t('hoSoNcc.hanhDong.khoa')}
              </Button>
            </>
          ) : null
        }
      />

      {chiTiet.isPending || !data ? (
        <div className="grid grid-cols-[352px_1fr] gap-stack">
          <Skeleton className="h-[560px] w-full rounded-card" />
          <Skeleton className="h-[560px] w-full rounded-card" />
        </div>
      ) : chuaDuyet ? (
        <div className="grid grid-cols-2 items-start gap-stack">
          <HoSoCard data={data} />
          <GiayToCard data={data} />
        </div>
      ) : (
        <div className="grid grid-cols-[352px_1fr] items-start gap-stack">
          <div className="flex flex-col gap-stack">
            <HoSoCard data={data} />
            <GiayToCard data={data} />
          </div>

          <div className="flex flex-col gap-stack">
            {data.sitter.serviceAddress ? <VungPhucVuCard data={data} /> : null}
            {data.services.length > 0 ? <DichVuCard data={data} /> : null}
            <KyLuatCard data={data} />
          </div>
        </div>
      )}

      <Modal
        open={moBoSung}
        onOpenChange={(open) => (open ? setMoBoSung(true) : dongDialog())}
        title={t('hoSoNcc.dialogBoSung.tieuDe')}
        description={t('hoSoNcc.dialogBoSung.moTa')}
        confirmLabel={t('hoSoNcc.hanhDong.yeuCauBoSung')}
        confirmDisabled={lyDo.trim().length < 3}
        loading={boSung.isPending}
        onConfirm={() =>
          boSung.mutate(
            { id, reason: lyDo.trim() },
            {
              onSuccess: () => {
                notify.success(t('hoSoNcc.daYeuCauBoSung'));
                dongDialog();
              },
              onError: baoLoi,
            },
          )
        }
      >
        <label className="flex flex-col gap-label">
          <span className="text-label-sm uppercase text-text-primary">
            {t('hoSoNcc.dialogBoSung.thieuGi')}
          </span>
          <TextInput
            value={lyDo}
            onChange={(event) => setLyDo(event.target.value)}
            placeholder={t('hoSoNcc.dialogBoSung.thieuGiGoiY')}
          />
        </label>
      </Modal>

      <Modal
        open={moDuyet}
        onOpenChange={(open) => (open ? setMoDuyet(true) : dongDialog())}
        title={t('hoSoNcc.dialogDuyet.tieuDe')}
        description={t('hoSoNcc.dialogDuyet.moTa', { ten })}
        confirmLabel={t('hoSoNcc.hanhDong.duyet')}
        loading={duyet.isPending}
        onConfirm={() =>
          duyet.mutate(
            { id, decision: 'APPROVED' },
            {
              onSuccess: () => {
                notify.success(t('hoSoNcc.daDuyet'));
                dongDialog();
              },
              onError: baoLoi,
            },
          )
        }
      />

      <Modal
        open={moTuChoi}
        onOpenChange={(open) => (open ? setMoTuChoi(true) : dongDialog())}
        title={t('hoSoNcc.dialogTuChoi.tieuDe')}
        description={t('hoSoNcc.dialogTuChoi.moTa')}
        danger
        confirmLabel={t('hoSoNcc.hanhDong.tuChoi')}
        confirmDisabled={lyDo.trim().length < 3}
        loading={duyet.isPending}
        onConfirm={() =>
          duyet.mutate(
            { id, decision: 'REJECTED', reason: lyDo.trim() },
            {
              onSuccess: () => {
                notify.success(t('hoSoNcc.daTuChoi'));
                dongDialog();
              },
              onError: baoLoi,
            },
          )
        }
      >
        <label className="flex flex-col gap-label">
          <span className="text-label-sm uppercase text-text-primary">
            {t('hoSoNcc.dialogTuChoi.lyDo')}
          </span>
          <TextInput
            value={lyDo}
            onChange={(event) => setLyDo(event.target.value)}
            placeholder={t('hoSoNcc.dialogTuChoi.lyDoGoiY')}
          />
        </label>
      </Modal>

      <Modal
        open={moTamAn}
        onOpenChange={(open) => (open ? setMoTamAn(true) : dongDialog())}
        title={t('hoSoNcc.dialogTamAn.tieuDe')}
        description={t('hoSoNcc.dialogTamAn.moTa')}
        confirmLabel={t('hoSoNcc.hanhDong.tamAn')}
        confirmDisabled={lyDo.trim().length < 3 || chiTiet.isPending}
        loading={tamAn.isPending}
        onConfirm={() =>
          tamAn.mutate(
            { id, days: soNgayAn, reason: lyDo.trim() },
            {
              onSuccess: (ketQua) => {
                notify.success(
                  ketQua.banned
                    ? t('hoSoNcc.daTamAnThanhKhoa')
                    : t('hoSoNcc.daTamAn', { ngay: ketQua.hiddenDays }),
                );
                dongDialog();
              },
              onError: baoLoi,
            },
          )
        }
      >
        <div className="flex flex-col gap-item">
          <p className="rounded-card bg-honey/15 p-item text-caption-sm text-text-primary">
            {t('hoSoNcc.dialogTamAn.canhBaoLanThu', {
              lan: lanAnKeTiep,
              nguong: SO_LAN_TAM_AN_KHOA,
              thang: THANG_DEM_LAN_TAM_AN,
            })}
          </p>
          <RunningBookingNotice
            isPending={chiTiet.isPending}
            isError={chiTiet.isError}
            count={donDangChay}
          />
          <label className="flex flex-col gap-label">
            <span className="text-label-sm uppercase text-text-primary">
              {t('hoSoNcc.dialogTamAn.soNgay')}
            </span>
            <div className="flex gap-label">
              {BAC_NGAY_TAM_AN.map((ngay) => (
                <Button
                  key={ngay}
                  type="button"
                  size="sm"
                  variant={ngay === soNgayAn ? 'primary' : 'secondary'}
                  onClick={() => setSoNgayAn(ngay)}
                >
                  {t('hoSoNcc.dialogTamAn.nNgay', { ngay })}
                </Button>
              ))}
            </div>
          </label>
          <label className="flex flex-col gap-label">
            <span className="text-label-sm uppercase text-text-primary">
              {t('hoSoNcc.lyDo')}
            </span>
            <TextInput
              value={lyDo}
              onChange={(event) => setLyDo(event.target.value)}
              placeholder={t('hoSoNcc.dialogTamAn.lyDoGoiY')}
            />
          </label>
        </div>
      </Modal>

      <Modal
        open={moKhoa}
        onOpenChange={(open) => (open ? setMoKhoa(true) : dongDialog())}
        title={t('hoSoNcc.dialogKhoa.tieuDe')}
        description={t('hoSoNcc.dialogKhoa.moTa')}
        danger
        confirmLabel={t('hoSoNcc.hanhDong.khoa')}
        confirmDisabled={
          tuKhoa.trim().toUpperCase() !== TU_KHOA_KHOA ||
          lyDo.trim().length < 3 ||
          chiTiet.isPending
        }
        loading={khoa.isPending}
        onConfirm={() =>
          khoa.mutate(
            { id, banned: true, reason: lyDo.trim() },
            {
              onSuccess: () => {
                notify.success(t('hoSoNcc.daKhoa'));
                dongDialog();
                void navigate(PATHS.sitterApprovals);
              },
              onError: baoLoi,
            },
          )
        }
      >
        <div className="flex flex-col gap-item">
          <RunningBookingNotice
            isPending={chiTiet.isPending}
            isError={chiTiet.isError}
            count={donDangChay}
          />
          <label className="flex flex-col gap-label">
            <span className="text-label-sm uppercase text-text-primary">
              {t('hoSoNcc.lyDo')}
            </span>
            <TextInput
              value={lyDo}
              onChange={(event) => setLyDo(event.target.value)}
              placeholder={t('hoSoNcc.dialogKhoa.lyDoGoiY')}
            />
          </label>
          <label className="flex flex-col gap-label">
            <span className="text-label-sm uppercase text-text-primary">
              {t('hoSoNcc.dialogKhoa.goTuKhoa', { tuKhoa: TU_KHOA_KHOA })}
            </span>
            <TextInput
              value={tuKhoa}
              onChange={(event) => setTuKhoa(event.target.value)}
              placeholder={TU_KHOA_KHOA}
            />
          </label>
        </div>
      </Modal>

      <Modal
        open={moGoKhoa}
        onOpenChange={(open) => (open ? setMoGoKhoa(true) : dongDialog())}
        title={t('hoSoNcc.dialogGoKhoa.tieuDe')}
        description={t('hoSoNcc.dialogGoKhoa.moTa')}
        confirmLabel={t('hoSoNcc.hanhDong.goKhoa')}
        confirmDisabled={lyDo.trim().length < 3}
        loading={khoa.isPending}
        onConfirm={() =>
          khoa.mutate(
            { id, banned: false, reason: lyDo.trim() },
            {
              onSuccess: (ketQua) => {
                notify.success(
                  ketQua.waivedHides > 0
                    ? t('hoSoNcc.daGoKhoaKemMien', { so: ketQua.waivedHides })
                    : t('hoSoNcc.daGoKhoa'),
                );
                dongDialog();
              },
              onError: baoLoi,
            },
          )
        }
      >
        <label className="flex flex-col gap-label">
          <span className="text-label-sm uppercase text-text-primary">
            {t('hoSoNcc.lyDo')}
          </span>
          <TextInput
            value={lyDo}
            onChange={(event) => setLyDo(event.target.value)}
            placeholder={t('hoSoNcc.dialogGoKhoa.lyDoGoiY')}
          />
        </label>
      </Modal>
    </div>
  );
}

