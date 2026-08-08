import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Send } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Field, TextInput } from '@/components/ui/field';
import { FilterSelect } from '@/components/ui/filter-select';
import { Modal } from '@/components/ui/modal';
import { SectionCard } from '@/components/ui/section-card';
import { Switch } from '@/components/ui/switch';
import { RecipientPicker } from '@/features/notifications/components/recipient-picker';
import {
  useAudienceCount,
  useBroadcast,
  useProvinces,
} from '@/features/notifications/hooks/use-notifications';
import type { AudienceKind, CampaignRow } from '@/features/notifications/types';
import { NHOM_NGUOI_NHAN } from '@/features/notifications/types';
import { getErrorMessage } from '@/lib/api/client';
import { formatDate, formatNumber, formatPercent } from '@/lib/format';
import { notify } from '@/lib/toast';

const TIEU_DE_TOI_THIEU = 6;
const NOI_DUNG_TOI_THIEU = 10;
const SO_LUOT_GAN_NHAT = 3;

type ComposeCardProps = {
  nguon: CampaignRow | null;
  nguonSeq: number;
  ganNhat: CampaignRow[];
};

export function ComposeCard({ nguon, nguonSeq, ganNhat }: ComposeCardProps) {
  const { t } = useTranslation();
  const tinhThanh = useProvinces();
  const gui = useBroadcast();

  const [tieuDe, setTieuDe] = useState('');
  const [noiDung, setNoiDung] = useState('');
  const [doiTuong, setDoiTuong] = useState<AudienceKind>('BOTH');
  const [tinh, setTinh] = useState<string | null>(null);
  const [nguoiNhan, setNguoiNhan] = useState<string | null>(null);
  const [henGio, setHenGio] = useState(false);
  const [mocHen, setMocHen] = useState('');
  const [gap, setGap] = useState(false);
  const [moXacNhan, setMoXacNhan] = useState(false);
  const [seqDaNap, setSeqDaNap] = useState(0);

  if (nguon && nguonSeq !== seqDaNap) {
    setSeqDaNap(nguonSeq);
    setTieuDe(nguon.title);
    setNoiDung(nguon.body);
    setDoiTuong(nguon.audienceKind);
    setTinh(nguon.audienceKind === 'OWNERS_BY_PROVINCE' ? nguon.audienceValue : null);
    setNguoiNhan(nguon.audienceKind === 'SINGLE_USER' ? nguon.audienceValue : null);
    setGap(nguon.urgent);
    setHenGio(false);
    setMocHen('');
  }

  const thamSo =
    doiTuong === 'OWNERS_BY_PROVINCE'
      ? (tinh ?? undefined)
      : doiTuong === 'SINGLE_USER'
        ? (nguoiNhan ?? undefined)
        : undefined;
  const nhomNhan = useAudienceCount(doiTuong, thamSo);
  const soNguoiNhan = nhomNhan.data?.count ?? 0;

  const dienDu =
    tieuDe.trim().length >= TIEU_DE_TOI_THIEU &&
    noiDung.trim().length >= NOI_DUNG_TOI_THIEU &&
    (!henGio || Boolean(mocHen));
  const guiDuoc = dienDu && nhomNhan.isSuccess && soNguoiNhan > 0 && !gui.isPending;

  const xoaForm = () => {
    setTieuDe('');
    setNoiDung('');
    setDoiTuong('BOTH');
    setTinh(null);
    setNguoiNhan(null);
    setHenGio(false);
    setMocHen('');
    setGap(false);
  };

  const xacNhanGui = () => {
    gui.mutate(
      {
        title: tieuDe.trim(),
        body: noiDung.trim(),
        audienceKind: doiTuong,
        audienceValue: thamSo,
        urgent: gap,
        scheduledAt: henGio && mocHen ? new Date(mocHen).toISOString() : undefined,
      },
      {
        onSuccess: () => {
          notify.success(henGio ? t('thongBao.daLenLich') : t('thongBao.daGui'));
          setMoXacNhan(false);
          xoaForm();
        },
        onError: (error) => notify.error(getErrorMessage(error)),
      },
    );
  };

  return (
    <SectionCard
      title={t('thongBao.soan.tieuDe')}
      subtitle={t('thongBao.soan.moTa')}
      bodyClassName="flex flex-col gap-stack"
    >
      <Field label={t('thongBao.truong.tieuDe')}>
        <TextInput
          value={tieuDe}
          maxLength={120}
          placeholder={t('thongBao.truong.tieuDeGoiY')}
          onChange={(event) => setTieuDe(event.target.value)}
        />
      </Field>

      <Field label={t('thongBao.truong.noiDung')}>
        <textarea
          value={noiDung}
          maxLength={500}
          rows={4}
          placeholder={t('thongBao.truong.noiDungGoiY')}
          onChange={(event) => setNoiDung(event.target.value)}
          className="w-full resize-none rounded-card border border-neutral bg-surface px-item py-item text-label font-normal text-text-primary placeholder:text-text-secondary focus:border-primary focus:outline-none"
        />
      </Field>

      <Field label={t('thongBao.truong.doiTuong')}>
        <FilterSelect
          className="w-full justify-between"
          placeholder={t('thongBao.truong.doiTuong')}
          clearLabel={t('thongBao.doiTuong.BOTH')}
          value={doiTuong}
          onChange={(value) => setDoiTuong(value ?? 'BOTH')}
          options={NHOM_NGUOI_NHAN.map((kind) => ({
            value: kind,
            label: t(`thongBao.doiTuong.${kind}`),
          }))}
        />
      </Field>

      {doiTuong === 'OWNERS_BY_PROVINCE' ? (
        <Field label={t('thongBao.truong.tinh')}>
          <FilterSelect
            className="w-full justify-between"
            placeholder={t('thongBao.truong.chonTinh')}
            clearLabel={t('thongBao.truong.chonTinh')}
            value={tinh}
            onChange={setTinh}
            options={(tinhThanh.data ?? []).map((item) => ({ value: item, label: item }))}
            disabled={tinhThanh.isPending || tinhThanh.isError}
          />
        </Field>
      ) : null}

      {doiTuong === 'SINGLE_USER' ? (
        <Field label={t('thongBao.truong.nguoiNhan')}>
          <RecipientPicker value={nguoiNhan} onChange={(id) => setNguoiNhan(id)} />
        </Field>
      ) : null}

      <SoNguoiNhan
        chuaDuThamSo={!nhomNhan.isFetching && !nhomNhan.isSuccess && !nhomNhan.isError}
        dangDem={nhomNhan.isFetching}
        loi={nhomNhan.isError}
        so={soNguoiNhan}
      />

      <Field label={t('thongBao.truong.thoiDiem')}>
        <div className="flex flex-col gap-label">
          <FilterSelect
            className="w-full justify-between"
            placeholder={t('thongBao.thoiDiem.ngay')}
            clearLabel={t('thongBao.thoiDiem.ngay')}
            value={henGio ? 'hen' : null}
            onChange={(value) => setHenGio(value === 'hen')}
            options={[{ value: 'hen', label: t('thongBao.thoiDiem.henGio') }]}
          />
          {henGio ? (
            <TextInput
              type="datetime-local"
              value={mocHen}
              onChange={(event) => setMocHen(event.target.value)}
            />
          ) : null}
        </div>
      </Field>

      <div className="flex items-center justify-between gap-item rounded-card bg-canvas px-item py-item">
        <div className="min-w-0">
          <p className="text-label">{t('thongBao.truong.gap')}</p>
          <p className="mt-text text-caption-sm text-text-secondary">
            {t('thongBao.truong.gapMoTa')}
          </p>
        </div>
        <Switch checked={gap} onChange={setGap} label={t('thongBao.truong.gap')} />
      </div>

      <Button className="w-full" onClick={() => setMoXacNhan(true)} disabled={!guiDuoc}>
        {henGio ? t('thongBao.nut.lenLich') : t('thongBao.nut.gui')}
      </Button>

      <div className="border-t border-neutral-light pt-stack">
        <p className="text-label">{t('thongBao.ganNhat')}</p>
        <div className="mt-item flex flex-col gap-item">
          {ganNhat.slice(0, SO_LUOT_GAN_NHAT).map((item) => (
            <div key={item.id} className="flex items-start gap-item">
              <span className="mt-text flex h-8 w-8 shrink-0 items-center justify-center rounded-card bg-card-mint text-primary">
                <Send className="h-4 w-4" strokeWidth={1.8} />
              </span>
              <div className="min-w-0">
                <p className="truncate text-label">{item.title}</p>
                <p className="mt-text truncate text-caption-sm text-text-secondary">
                  {t('thongBao.dongGanNhat', {
                    date: formatDate(item.sentAt ?? item.createdAt),
                    so: formatNumber(item.recipientCount),
                    percent: formatPercent(
                      item.recipientCount ? (item.readCount / item.recipientCount) * 100 : 0,
                      0,
                    ),
                  })}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>

      <Modal
        open={moXacNhan}
        onOpenChange={setMoXacNhan}
        title={t('thongBao.xacNhan.tieuDe')}
        description={t('thongBao.xacNhan.moTa', {
          so: formatNumber(soNguoiNhan),
          audience: t(`thongBao.doiTuong.${doiTuong}`),
        })}
        confirmLabel={henGio ? t('thongBao.nut.lenLich') : t('thongBao.nut.gui')}
        confirmDisabled={!guiDuoc}
        loading={gui.isPending}
        onConfirm={xacNhanGui}
      >
        <div className="flex flex-col gap-label rounded-card bg-canvas p-card">
          <p className="text-label">{tieuDe.trim()}</p>
          <p className="text-caption-sm text-text-secondary">{noiDung.trim()}</p>
          {henGio && mocHen ? (
            <p className="text-caption-sm text-honey">
              {t('thongBao.xacNhan.henLuc', { time: mocHen.replace('T', ' · ') })}
            </p>
          ) : null}
        </div>
      </Modal>
    </SectionCard>
  );
}

type SoNguoiNhanProps = {
  chuaDuThamSo: boolean;
  dangDem: boolean;
  loi: boolean;
  so: number;
};

function SoNguoiNhan({ chuaDuThamSo, dangDem, loi, so }: SoNguoiNhanProps) {
  const { t } = useTranslation();
  if (chuaDuThamSo) {
    return (
      <p className="text-caption-sm text-text-secondary">{t('thongBao.chonXongMoiDem')}</p>
    );
  }
  if (dangDem) {
    return <p className="text-caption-sm text-text-secondary">{t('thongBao.dangDem')}</p>;
  }
  if (loi) {
    return <p className="text-caption-sm text-error">{t('thongBao.demHong')}</p>;
  }
  return (
    <p className={so === 0 ? 'text-caption-sm text-error' : 'text-caption-sm text-primary'}>
      {so === 0
        ? t('thongBao.nhomRong')
        : t('thongBao.seGuiToi', { so: formatNumber(so) })}
    </p>
  );
}
