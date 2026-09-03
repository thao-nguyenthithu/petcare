import { useEffect, useMemo, useRef } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { useTranslation } from 'react-i18next';

type Diem = { lat: number; lng: number; isNoise: boolean };

const NEN_TILE = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const GHI_NGUON = '&copy; OpenStreetMap contributors';
const ZOOM_TOI_DA = 19;
const CAO = 280;
const LE_KHUNG = 0.15;

const GHIM =
  '<svg viewBox="0 0 24 24" width="28" height="28" fill="currentColor" aria-hidden="true"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5a2.5 2.5 0 0 1 0-5 2.5 2.5 0 0 1 0 5z"/></svg>';
const CANH_GHIM = 28;
const CANH_CHAM = 14;

const CHAM =
  '<span class="block h-[14px] w-[14px] rounded-full border-2 border-surface bg-primary"></span>';

export function GpsTrackMap({ track }: { track: Diem[] }) {
  const { t } = useTranslation();
  const khung = useRef<HTMLDivElement>(null);
  // Lọc lại mỗi lần dựng thì mảng luôn khác tham chiếu, bản đồ sẽ tạo lại liên tục
  const diem = useMemo(() => track.filter((item) => !item.isNoise), [track]);
  const duDiem = diem.length >= 2;

  useEffect(() => {
    const o = khung.current;
    if (!o || !duDiem) return;

    const toaDo = diem.map((item) => L.latLng(item.lat, item.lng));
    const banDo = L.map(o, { scrollWheelZoom: false });
    L.tileLayer(NEN_TILE, {
      attribution: GHI_NGUON,
      maxZoom: ZOOM_TOI_DA,
    }).addTo(banDo);

    const khungNhin = L.latLngBounds(toaDo).pad(LE_KHUNG);
    banDo.fitBounds(khungNhin);

    L.polyline(toaDo, {
      className: 'stroke-primary',
      weight: 4,
      lineCap: 'round',
      lineJoin: 'round',
    }).addTo(banDo);

    L.marker(toaDo[0], {
      keyboard: false,
      icon: L.divIcon({
        html: CHAM,
        className: '',
        iconSize: [CANH_CHAM, CANH_CHAM],
        iconAnchor: [CANH_CHAM / 2, CANH_CHAM / 2],
      }),
    }).addTo(banDo);

    L.marker(toaDo[toaDo.length - 1], {
      keyboard: false,
      icon: L.divIcon({
        html: GHIM,
        className: 'text-accent',
        iconSize: [CANH_GHIM, CANH_GHIM],
        iconAnchor: [CANH_GHIM / 2, CANH_GHIM],
      }),
    }).addTo(banDo);

    // Khối bị ẩn lúc dựng thì bản đồ ra kích thước 0, phải đo lại rồi khớp khung nhìn
    let daCoKichThuoc = o.clientHeight > 0;
    const doKhung =
      typeof ResizeObserver === 'undefined'
        ? null
        : new ResizeObserver(() => {
            banDo.invalidateSize();
            if (daCoKichThuoc || o.clientHeight === 0) return;
            daCoKichThuoc = true;
            banDo.fitBounds(khungNhin);
          });
    doKhung?.observe(o);

    return () => {
      doKhung?.disconnect();
      banDo.remove();
    };
  }, [diem, duDiem]);

  if (!duDiem) {
    return (
      <div className="flex h-[170px] items-center justify-center rounded-card bg-card-mint/50 text-caption-sm text-text-secondary">
        {t('don.gps.chuaCoLoTrinh')}
      </div>
    );
  }

  return (
    <div
      ref={khung}
      role="img"
      aria-label={t('don.gps.tieuDe')}
      style={{ height: CAO }}
      className="z-0 w-full rounded-card border border-neutral-light bg-neutral-light"
    />
  );
}
