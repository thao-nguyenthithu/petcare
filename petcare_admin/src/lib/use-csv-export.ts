import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  TRAN_DONG_XUAT,
  VuotTranXuatError,
  dungCsv,
  gomMoiTrang,
  taiVeCsv,
} from '@/lib/csv-export';
import { getErrorMessage } from '@/lib/api/client';
import { notify } from '@/lib/toast';

type ThamSoXuat<T> = {
  tai: (page: number, limit: number) => Promise<{ total: number; items: T[] }>;
  tenFile: string;
  tieuDe: string[];
  dong: (item: T) => Array<string | number | null>;
};

export function useCsvExport() {
  const { t } = useTranslation();
  const [dangXuat, setDangXuat] = useState(false);

  const xuat = async <T,>({ tai, tenFile, tieuDe, dong }: ThamSoXuat<T>) => {
    if (dangXuat) return;
    setDangXuat(true);
    try {
      const items = await gomMoiTrang(tai);
      if (items.length === 0) {
        notify.info(t('chung.xuatCsv.khongCoDong'));
        return;
      }
      taiVeCsv(dungCsv(tieuDe, items.map(dong)), tenFile);
      notify.success(t('chung.xuatCsv.xong', { count: items.length }));
    } catch (error) {
      if (error instanceof VuotTranXuatError) {
        notify.info(t('chung.xuatCsv.vuotTran', { total: error.total, tran: TRAN_DONG_XUAT }));
        return;
      }
      notify.error(getErrorMessage(error));
    } finally {
      setDangXuat(false);
    }
  };

  return { dangXuat, xuat };
}
