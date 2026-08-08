import { useEffect, useRef } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { cn } from '@/lib/utils';

const NEN_TILE = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const GHI_NGUON = '&copy; OpenStreetMap contributors';
const ZOOM_TOI_DA = 19;

const GHIM =
  '<svg viewBox="0 0 24 24" width="32" height="32" fill="currentColor" aria-hidden="true"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5a2.5 2.5 0 0 1 0-5 2.5 2.5 0 0 1 0 5z"/></svg>';
const CANH_GHIM = 32;

const ZOOM_KHONG_BAN_KINH = 14;
const CAO_MAC_DINH = 240;

const LE_QUANH_VONG = 0.1;

type ServiceAreaMapProps = {
  lat: number;
  lng: number;
  banKinhKm: number | null;
  chieuCao?: number;
  tuongTac?: boolean;
  nhan?: string;
  className?: string;
};

export function ServiceAreaMap({
  lat,
  lng,
  banKinhKm,
  chieuCao = CAO_MAC_DINH,
  tuongTac = false,
  nhan,
  className,
}: ServiceAreaMapProps) {
  const khung = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const o = khung.current;
    if (!o) return;

    const banDo = L.map(o, {
      zoomControl: tuongTac,
      scrollWheelZoom: tuongTac,
      dragging: tuongTac,
      doubleClickZoom: tuongTac,
      touchZoom: tuongTac,
      boxZoom: tuongTac,
      keyboard: tuongTac,
    });
    L.tileLayer(NEN_TILE, {
      attribution: GHI_NGUON,
      maxZoom: ZOOM_TOI_DA,
    }).addTo(banDo);

    const tam = L.latLng(lat, lng);
    const khungNhin = banKinhKm
      ? tam.toBounds(banKinhKm * 2000).pad(LE_QUANH_VONG)
      : null;
    if (khungNhin) {
      banDo.fitBounds(khungNhin);
    } else {
      banDo.setView(tam, ZOOM_KHONG_BAN_KINH);
    }

    if (banKinhKm) {
      L.circle(tam, {
        radius: banKinhKm * 1000,
        className: 'fill-primary/15 stroke-primary',
        weight: 2,
      }).addTo(banDo);
    }

    L.marker(tam, {
      keyboard: false,
      icon: L.divIcon({
        html: GHIM,
        className: 'text-primary',
        iconSize: [CANH_GHIM, CANH_GHIM],
        iconAnchor: [CANH_GHIM / 2, CANH_GHIM],
      }),
    }).addTo(banDo);

    let daCoKichThuoc = o.clientHeight > 0;
    const doKhung =
      typeof ResizeObserver === 'undefined'
        ? null
        : new ResizeObserver(() => {
            banDo.invalidateSize();
            if (daCoKichThuoc || o.clientHeight === 0) return;
            daCoKichThuoc = true;
            if (khungNhin) banDo.fitBounds(khungNhin);
          });
    doKhung?.observe(o);

    return () => {
      doKhung?.disconnect();
      banDo.remove();
    };
  }, [lat, lng, banKinhKm, tuongTac]);

  return (
    <div
      ref={khung}
      role="img"
      aria-label={nhan}
      style={{ height: chieuCao }}
      className={cn(
        'z-0 w-full rounded-card border border-neutral-light bg-neutral-light',
        className,
      )}
    />
  );
}
