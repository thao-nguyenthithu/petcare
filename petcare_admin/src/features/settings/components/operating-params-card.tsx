import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Button } from '@/components/ui/button';
import { FieldError } from '@/components/ui/field';
import { Modal } from '@/components/ui/modal';
import { SectionCard } from '@/components/ui/section-card';
import { Switch } from '@/components/ui/switch';
import { EmptyState } from '@/components/state/empty-state';
import { ErrorState } from '@/components/state/error-state';
import { Skeleton } from '@/components/state/skeleton';
import { useOperatingSettings, useUpdateSetting } from '@/features/settings/hooks/use-settings';
import { ParamChoiceRow } from '@/features/settings/components/param-choice-row';
import {
  khoaChuoi,
  nhanGiaTriChon,
  nhanNguoiDoi,
  type DichChuoi,
} from '@/features/settings/param-labels';
import { canLyDo, DAI_TOI_DA_LY_DO } from '@/features/settings/settings-constants';
import type { OperatingSetting } from '@/features/settings/types';
import { getErrorMessage } from '@/lib/api/client';
import { formatDateTime, formatNumber } from '@/lib/format';
import { notify } from '@/lib/toast';

type ThayDoi = { item: OperatingSetting; giaTriMoi: number };

export function OperatingParamsCard() {
  const { t } = useTranslation();
  const thamSo = useOperatingSettings();
  const capNhat = useUpdateSetting();

  const [giaTriGo, setGiaTriGo] = useState<Record<string, string>>({});
  const [loiTheoKhoa, setLoiTheoKhoa] = useState<Record<string, string>>({});
  const [hoiLyDo, setHoiLyDo] = useState(false);
  const [lyDo, setLyDo] = useState('');
  const [congTacDangHoi, setCongTacDangHoi] = useState<OperatingSetting | null>(null);

  const items = thamSo.data?.items ?? [];
  const dsSo = items.filter((item) => item.kieu === 'so');
  const dsLuaChon = items.filter((item) => item.kieu === 'chon');
  const dsCongTac = items.filter((item) => item.kieu === 'batTat');

  const layGiaTriGo = (item: OperatingSetting) => giaTriGo[item.key] ?? String(item.giaTri);
  const daGo = (item: OperatingSetting) => layGiaTriGo(item) !== String(item.giaTri);
  const coThayDoi = dsSo.some(daGo);

  const kiemTra = (item: OperatingSetting, tho: string): string | null => {
    const so = Number(tho.trim());
    if (!tho.trim() || !Number.isFinite(so) || !Number.isInteger(so)) {
      return t('caiDat.vanHanh.loiKhongNguyen');
    }
    if (item.min !== null && item.max !== null && (so < item.min || so > item.max)) {
      return t('caiDat.vanHanh.loiNgoaiKhoang', { min: item.min, max: item.max });
    }
    return null;
  };

  const gomThayDoi = (): ThayDoi[] | null => {
    const loi: Record<string, string> = {};
    const ds: ThayDoi[] = [];
    for (const item of dsSo) {
      if (!daGo(item)) continue;
      const tho = layGiaTriGo(item);
      const cauLoi = kiemTra(item, tho);
      if (cauLoi) loi[item.key] = cauLoi;
      else ds.push({ item, giaTriMoi: Number(tho.trim()) });
    }
    setLoiTheoKhoa(loi);
    return Object.keys(loi).length > 0 ? null : ds;
  };

  const luu = async (ds: ThayDoi[], lyDoGui?: string) => {
    const ketQua = await Promise.allSettled(
      ds.map((thayDoi) =>
        capNhat.mutateAsync({
          key: thayDoi.item.key,
          giaTri: thayDoi.giaTriMoi,
          lyDo: lyDoGui?.trim() || undefined,
        }),
      ),
    );

    const loi: Record<string, string> = {};
    const conGo: Record<string, string> = { ...giaTriGo };
    let soXong = 0;
    ketQua.forEach((ket, index) => {
      const khoa = ds[index].item.key;
      if (ket.status === 'fulfilled') {
        soXong += 1;
        delete conGo[khoa];
        return;
      }
      loi[khoa] = getErrorMessage(ket.reason);
    });

    setGiaTriGo(conGo);
    setLoiTheoKhoa(loi);

    const soLoi = Object.keys(loi).length;
    if (soLoi === 0) {
      notify.success(t('caiDat.vanHanh.daLuu', { so: soXong }));
    } else if (soXong === 0) {
      notify.error(t('caiDat.vanHanh.hongHet'));
    } else {
      notify.error(t('caiDat.vanHanh.luuMotPhan', { soXong, soLoi }));
    }
  };

  const bamLuu = () => {
    const ds = gomThayDoi();
    if (!ds || ds.length === 0) return;
    if (ds.some((thayDoi) => canLyDo(thayDoi.item.key))) {
      setHoiLyDo(true);
      return;
    }
    void luu(ds);
  };

  const xacNhanCoLyDo = () => {
    const ds = gomThayDoi();
    if (!ds || ds.length === 0) {
      setHoiLyDo(false);
      return;
    }
    void luu(ds, lyDo).then(() => {
      setHoiLyDo(false);
      setLyDo('');
    });
  };

  const gatCongTac = () => {
    if (!congTacDangHoi) return;
    const dangBat = congTacDangHoi.giaTri === true;
    capNhat.mutate(
      { key: congTacDangHoi.key, giaTri: !dangBat },
      {
        onSuccess: (ketQua) => {
          notify.success(
            ketQua.giaTri
              ? t('caiDat.congTac.daBat', { nhan: congTacDangHoi.nhan })
              : t('caiDat.congTac.daTat', { nhan: congTacDangHoi.nhan }),
          );
          setCongTacDangHoi(null);
        },
        onError: (error) => notify.error(getErrorMessage(error)),
      },
    );
  };

  const doiLuaChon = (item: OperatingSetting, giaTri: string) => {
    capNhat.mutate(
      { key: item.key, giaTri },
      {
        onSuccess: () =>
          notify.success(
            t('caiDat.luaChon.daDoi', {
              nhan: item.nhan,
              giaTri: nhanGiaTriChon(t, giaTri),
            }),
          ),
        onError: (error) => notify.error(getErrorMessage(error)),
      },
    );
  };

  const dsSuaChoXacNhan = dsSo.filter(daGo);

  return (
    <SectionCard
      title={t('caiDat.vanHanh.tieuDe')}
      subtitle={
        thamSo.data?.capNhatLuc
          ? t('caiDat.vanHanh.capNhatLuc', { time: formatDateTime(thamSo.data.capNhatLuc) })
          : t('caiDat.vanHanh.moTa')
      }
      action={
        <Button size="sm" disabled={!coThayDoi || capNhat.isPending} onClick={bamLuu}>
          {t('caiDat.vanHanh.luu')}
        </Button>
      }
      bodyClassName="flex flex-col"
    >
      {thamSo.isPending ? (
        <div className="flex flex-col gap-item pb-item">
          {Array.from({ length: 6 }).map((_, index) => (
            <Skeleton key={index} className="h-[58px] w-full" />
          ))}
        </div>
      ) : null}
      {thamSo.isError ? <ErrorState onRetry={() => void thamSo.refetch()} /> : null}
      {!thamSo.isPending && !thamSo.isError && items.length === 0 ? (
        <EmptyState message={t('chung.chuaCoDuLieu')} />
      ) : null}

      {dsSo.map((item) => (
        <DongThamSo
          key={item.key}
          item={item}
          giaTri={layGiaTriGo(item)}
          loi={loiTheoKhoa[item.key]}
          onChange={(value) => setGiaTriGo((truoc) => ({ ...truoc, [item.key]: value }))}
        />
      ))}

      {dsLuaChon.map((item) => (
        <ParamChoiceRow
          key={item.key}
          item={item}
          disabled={capNhat.isPending}
          onChon={(giaTri) => doiLuaChon(item, giaTri)}
        />
      ))}

      {dsCongTac.map((item, index) => (
        <DongCongTac
          key={item.key}
          item={item}
          disabled={capNhat.isPending}
          cuoi={index === dsCongTac.length - 1}
          onGat={() => setCongTacDangHoi(item)}
        />
      ))}

      <Modal
        open={hoiLyDo}
        onOpenChange={(open) => {
          if (!open) setHoiLyDo(false);
        }}
        title={t('caiDat.xacNhanSo.tieuDe')}
        description={t('caiDat.xacNhanSo.moTa')}
        confirmLabel={t('caiDat.xacNhanSo.nut')}
        confirmDisabled={lyDo.trim().length === 0}
        loading={capNhat.isPending}
        onConfirm={xacNhanCoLyDo}
      >
        <div className="flex flex-col gap-item">
          <div className="flex flex-col gap-label rounded-card bg-canvas p-card">
            {dsSuaChoXacNhan.map((item) => (
              <div key={item.key} className="flex items-center justify-between gap-item">
                <span className="min-w-0 truncate text-caption-sm text-text-secondary">
                  {item.nhan}
                </span>
                <span className="shrink-0 text-label-sm">
                  {String(item.giaTri)} → {layGiaTriGo(item)}
                </span>
              </div>
            ))}
          </div>
          <label className="flex flex-col gap-label">
            <span className="text-label-sm uppercase tracking-[0.02em]">
              {t('caiDat.xacNhanSo.lyDo')}
            </span>
            <textarea
              value={lyDo}
              maxLength={DAI_TOI_DA_LY_DO}
              rows={3}
              placeholder={t('caiDat.xacNhanSo.lyDoGoiY')}
              onChange={(event) => setLyDo(event.target.value)}
              className="w-full rounded-card border border-neutral bg-surface p-item text-label font-normal text-text-primary placeholder:text-text-secondary focus:border-primary focus:outline-none"
            />
          </label>
        </div>
      </Modal>

      <Modal
        open={Boolean(congTacDangHoi)}
        onOpenChange={(open) => {
          if (!open) setCongTacDangHoi(null);
        }}
        title={
          congTacDangHoi
            ? t(
                congTacDangHoi.giaTri
                  ? 'caiDat.congTacXacNhan.tatTieuDe'
                  : 'caiDat.congTacXacNhan.batTieuDe',
                {
                  nhan: congTacDangHoi.nhan,
                },
              )
            : ''
        }
        description={congTacDangHoi ? moTaCongTac(t, congTacDangHoi) : undefined}
        confirmLabel={t(
          congTacDangHoi?.giaTri ? 'caiDat.congTacXacNhan.tatNut' : 'caiDat.congTacXacNhan.batNut',
        )}
        danger={congTacDangHoi ? laGatNguyHiem(congTacDangHoi) : false}
        loading={capNhat.isPending}
        onConfirm={gatCongTac}
      />
    </SectionCard>
  );
}

function laGatNguyHiem(item: OperatingSetting): boolean {
  const dangBat = item.giaTri === true;
  return item.key === 'sitter.auto_approve' ? !dangBat : dangBat;
}

function moTaCongTac(t: DichChuoi, item: OperatingSetting): string {
  const nhanh = item.giaTri ? 'tat' : 'bat';
  const rieng = t(`caiDat.congTacXacNhan.rieng.${khoaChuoi(item.key)}.${nhanh}`, {
    defaultValue: '',
  });
  return rieng || t(`caiDat.congTacXacNhan.${nhanh}MoTaChung`);
}

function DongThamSo({
  item,
  giaTri,
  loi,
  onChange,
}: {
  item: OperatingSetting;
  giaTri: string;
  loi?: string;
  onChange: (value: string) => void;
}) {
  const { t } = useTranslation();
  const donVi = item.donVi ? t(`caiDat.donVi.${item.donVi}`) : '';
  const goiY =
    item.min !== null && item.max !== null
      ? t('caiDat.vanHanh.goiYKhoang', {
          min: formatNumber(item.min),
          max: formatNumber(item.max),
          macDinh: formatNumber(Number(item.macDinh)),
        })
      : '';

  return (
    <div className="flex items-start justify-between gap-item border-b border-neutral-light py-item first:pt-0">
      <div className="min-w-0">
        <p className="truncate text-label">{item.nhan}</p>
        <p className="mt-text truncate text-caption-sm text-text-secondary">{goiY}</p>
        <p className="mt-text truncate text-caption-sm text-text-secondary">
          {nhanNguoiDoi(t, item)}
        </p>
      </div>
      <div className="flex shrink-0 flex-col items-end gap-label">
        <div className="flex h-[42px] w-[168px] items-center gap-label rounded-card border border-neutral bg-surface px-item">
          <input
            value={giaTri}
            inputMode="numeric"
            aria-label={item.nhan}
            onChange={(event) => onChange(event.target.value)}
            className="w-full min-w-0 bg-transparent text-label font-normal text-text-primary focus:outline-none"
          />
          {donVi ? (
            <span className="shrink-0 text-caption-sm text-text-secondary">{donVi}</span>
          ) : null}
        </div>
        {loi ? <FieldError message={loi} /> : null}
      </div>
    </div>
  );
}

function DongCongTac({
  item,
  disabled,
  cuoi,
  onGat,
}: {
  item: OperatingSetting;
  disabled: boolean;
  cuoi: boolean;
  onGat: () => void;
}) {
  const { t } = useTranslation();
  return (
    <div
      className={
        cuoi
          ? 'flex items-start justify-between gap-item py-item'
          : 'flex items-start justify-between gap-item border-b border-neutral-light py-item'
      }
    >
      <div className="min-w-0">
        <p className="truncate text-label">{item.nhan}</p>
        <p className="mt-text truncate text-caption-sm text-text-secondary">
          {t('caiDat.vanHanh.goiYCongTac', {
            macDinh: item.macDinh ? t('caiDat.congTac.bat') : t('caiDat.congTac.tat'),
          })}
        </p>
        <p className="mt-text truncate text-caption-sm text-text-secondary">
          {nhanNguoiDoi(t, item)}
        </p>
      </div>
      <Switch
        checked={item.giaTri === true}
        onChange={onGat}
        label={item.nhan}
        disabled={disabled}
      />
    </div>
  );
}
