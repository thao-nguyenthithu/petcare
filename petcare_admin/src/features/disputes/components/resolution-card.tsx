import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Check } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { FieldError, TextInput } from '@/components/ui/field';
import { FilterSelect } from '@/components/ui/filter-select';
import { DongThongTin } from '@/components/ui/info-row';
import { Modal } from '@/components/ui/modal';
import { SectionCard } from '@/components/ui/section-card';
import { Switch } from '@/components/ui/switch';
import { CAC_KET_LUAN, CAC_MUC_PHAT, type KetLuanKey } from '@/features/disputes/dispute-constants';
import type { DisputeDetail, DisputePenalty, ResolveDisputeInput } from '@/features/disputes/types';
import { formatDateTime, formatMoney } from '@/lib/format';
import { cn } from '@/lib/utils';

type ResolutionCardProps = {
  data: DisputeDetail;
  dangGui: boolean;
  onResolve: (input: ResolveDisputeInput) => void;
};

function chiSo(value: string): string {
  return value.replace(/\D/g, '');
}

export function ResolutionCard({ data, dangGui, onResolve }: ResolutionCardProps) {
  const { t } = useTranslation();
  const { dispute, booking } = data;

  const [ketLuan, setKetLuan] = useState<KetLuanKey | null>(null);
  const [mucPhat, setMucPhat] = useState<DisputePenalty | null>(null);
  const [hoanTien, setHoanTien] = useState(false);
  const [soTien, setSoTien] = useState('');
  const [lyDo, setLyDo] = useState('');
  const [baoCaHaiVai, setBaoCaHaiVai] = useState(true);
  const [moXacNhan, setMoXacNhan] = useState(false);

  const tran = booking.totalPrice;
  const soTienHoan = hoanTien ? Number(soTien || 0) : 0;
  const vuotTran = soTienHoan > tran;
  const thieuLyDo = lyDo.trim().length === 0;
  const chuaHopLe = !ketLuan || thieuLyDo || vuotTran || (hoanTien && soTienHoan <= 0);

  const guiKetLuan = () => {
    if (!ketLuan) return;
    onResolve({
      code: dispute.code,
      resolution: t(`khieuNai.ketLuan.${ketLuan}`),
      resolutionReason: lyDo.trim(),
      refundAmount: soTienHoan,
      penalty: mucPhat ?? undefined,
      notifyBoth: baoCaHaiVai,
    });
    setMoXacNhan(false);
  };

  return (
    <SectionCard title={t('khieuNai.hoSo.ketLuanTieuDe')} subtitle={t('khieuNai.hoSo.ketLuanMoTa')}>
      <div className="flex flex-col gap-item">
        <div className="flex flex-col gap-label">
          <span className="text-label-sm uppercase text-text-secondary">
            {t('khieuNai.hoSo.oKetLuan')}
          </span>
          <FilterSelect
            placeholder={t('khieuNai.hoSo.chonKetLuan')}
            clearLabel={t('khieuNai.hoSo.boChonKetLuan')}
            value={ketLuan}
            onChange={setKetLuan}
            className="w-full justify-between"
            options={CAC_KET_LUAN.map((key) => ({
              value: key,
              label: t(`khieuNai.ketLuan.${key}`),
            }))}
          />
        </div>

        <div className="flex flex-col gap-label">
          <span className="text-label-sm uppercase text-text-secondary">
            {t('khieuNai.hoSo.ghiHoSoNguoiCham')}
          </span>
          <LuaChonPhat
            dangChon={mucPhat === null}
            nhan={t('khieuNai.mucPhat.NONE')}
            onChon={() => setMucPhat(null)}
          />
          {CAC_MUC_PHAT.map((muc) => (
            <LuaChonPhat
              key={muc}
              dangChon={mucPhat === muc}
              nhan={t(`khieuNai.mucPhat.${muc}`)}
              onChon={() => setMucPhat(muc)}
            />
          ))}
          {mucPhat === 'HIDE' ? (
            <p className="text-caption-sm text-text-secondary">
              {t('khieuNai.mucPhatMoTa.HIDE')}
            </p>
          ) : null}
        </div>

        <div className="flex items-center gap-item">
          <div className="min-w-0 flex-1">
            <p className="text-label">{t('khieuNai.hoSo.hoanTienChoChuNuoi')}</p>
            <p className="mt-text text-caption-sm text-text-secondary">
              {t('khieuNai.hoSo.hoanTienMoTa')}
            </p>
          </div>
          <Switch
            checked={hoanTien}
            onChange={(next) => {
              setHoanTien(next);
              if (!next) setSoTien('');
            }}
            label={t('khieuNai.hoSo.hoanTienChoChuNuoi')}
          />
        </div>

        {hoanTien ? (
          <div className="flex flex-col gap-label">
            <span className="flex flex-wrap items-center gap-text text-label-sm uppercase text-text-secondary">
              {t('khieuNai.hoSo.soTienHoan')}
              <span className="text-accent">
                {t('khieuNai.hoSo.tranHoan', { tran: formatMoney(tran) })}
              </span>
            </span>
            <TextInput
              inputMode="numeric"
              value={soTien}
              hasError={vuotTran}
              onChange={(event) => setSoTien(chiSo(event.target.value))}
              placeholder={t('khieuNai.hoSo.soTienGoiY')}
            />
            {vuotTran ? <FieldError message={t('khieuNai.hoSo.loiVuotTran')} /> : null}
          </div>
        ) : null}

        <div className="flex flex-col gap-label">
          <span className="text-label-sm uppercase text-text-secondary">
            {t('khieuNai.hoSo.lyDoKetLuan')}
          </span>
          <textarea
            value={lyDo}
            onChange={(event) => setLyDo(event.target.value)}
            rows={3}
            placeholder={t('khieuNai.hoSo.lyDoGoiY')}
            className={cn(
              'w-full rounded-card border bg-surface px-item py-label text-label font-normal text-text-primary placeholder:text-text-secondary focus:outline-none',
              thieuLyDo ? 'border-accent' : 'border-neutral focus:border-primary',
            )}
          />
          {thieuLyDo ? <FieldError message={t('khieuNai.hoSo.loiThieuLyDo')} /> : null}
        </div>

        <label className="flex items-center gap-label text-label font-normal text-text-secondary">
          <input
            type="checkbox"
            checked={baoCaHaiVai}
            onChange={(event) => setBaoCaHaiVai(event.target.checked)}
            className="h-[19px] w-[19px] rounded-[6px] accent-[rgb(var(--color-primary))]"
          />
          {t('khieuNai.hoSo.banThongBaoHaiVai')}
        </label>

        <p className="flex items-center gap-label text-label font-normal text-text-secondary">
          <span className="flex h-[19px] w-[19px] items-center justify-center rounded-[6px] bg-primary">
            <Check className="h-3 w-3 text-text-white" strokeWidth={2.4} />
          </span>
          {t('khieuNai.hoSo.nhaEscrowSauKhiResolved')}
        </p>

        <div className="flex items-center gap-item">
          <Button variant="ghost" className="flex-1" onClick={() => window.history.back()}>
            {t('khieuNai.hoSo.boQua')}
          </Button>
          <Button
            className="flex-1"
            disabled={chuaHopLe}
            loading={dangGui}
            onClick={() => setMoXacNhan(true)}
          >
            {t('khieuNai.hoSo.xacNhanXuLy')}
          </Button>
        </div>
      </div>

      <Modal
        open={moXacNhan}
        onOpenChange={setMoXacNhan}
        title={t('khieuNai.hoSo.dialogTieuDe')}
        description={t('khieuNai.hoSo.dialogMoTa', { code: dispute.code })}
        confirmLabel={t('khieuNai.hoSo.xacNhanXuLy')}
        onConfirm={guiKetLuan}
        loading={dangGui}
      >
        <ul className="flex flex-col gap-label text-label font-normal">
          <li>
            {t('khieuNai.hoSo.tomTatKetLuan')}: {ketLuan ? t(`khieuNai.ketLuan.${ketLuan}`) : ''}
          </li>
          <li>
            {t('khieuNai.hoSo.tomTatHoanTien')}: {formatMoney(soTienHoan)}
          </li>
          <li>
            {t('khieuNai.hoSo.tomTatPhat')}: {t(`khieuNai.mucPhat.${mucPhat ?? 'NONE'}`)}
          </li>
        </ul>
      </Modal>
    </SectionCard>
  );
}

function LuaChonPhat({
  dangChon,
  nhan,
  onChon,
}: {
  dangChon: boolean;
  nhan: string;
  onChon: () => void;
}) {
  return (
    <button
      type="button"
      role="radio"
      aria-checked={dangChon}
      onClick={onChon}
      className={cn(
        'flex items-center gap-label rounded-card border px-item py-label text-left text-label font-normal transition-colors',
        dangChon
          ? 'border-primary bg-card-mint text-text-primary'
          : 'border-neutral-light text-text-secondary hover:bg-card-mint/40',
      )}
    >
      <span
        className={cn(
          'h-[18px] w-[18px] shrink-0 rounded-full border-2 bg-surface',
          dangChon ? 'border-[5px] border-primary' : 'border-neutral',
        )}
      />
      {nhan}
    </button>
  );
}

export function ResolvedSummaryCard({ data }: { data: DisputeDetail }) {
  const { t } = useTranslation();
  const { dispute } = data;

  return (
    <SectionCard
      title={t('khieuNai.hoSo.ketLuanTieuDe')}
      subtitle={t('khieuNai.hoSo.daKetLuanMoTa')}
    >
      <ul className="flex flex-col gap-item">
        <DongThongTin label={t('khieuNai.hoSo.oKetLuan')} value={dispute.resolution} />
        <DongThongTin
          label={t('khieuNai.hoSo.soTienHoan')}
          value={formatMoney(dispute.refundAmount ?? 0)}
        />
        <DongThongTin
          label={t('khieuNai.hoSo.chotLuc')}
          value={dispute.resolvedAt ? formatDateTime(dispute.resolvedAt) : null}
        />
      </ul>
      <p className="mt-item rounded-card bg-neutral-light/50 p-card text-label font-normal">
        {dispute.resolutionReason ?? t('khieuNai.hoSo.khongCoLyDo')}
      </p>
    </SectionCard>
  );
}
