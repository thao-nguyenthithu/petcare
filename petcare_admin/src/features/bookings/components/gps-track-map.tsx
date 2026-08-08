import { useTranslation } from 'react-i18next';
import { MapPin } from 'lucide-react';

type Diem = { lat: number; lng: number; isNoise: boolean };

const RONG = 700;
const CAO = 170;
const LE = 24;

export function GpsTrackMap({ track }: { track: Diem[] }) {
  const { t } = useTranslation();
  const diem = track.filter((item) => !item.isNoise);

  if (diem.length < 2) {
    return (
      <div className="flex h-[170px] items-center justify-center rounded-card bg-card-mint/50 text-caption-sm text-text-secondary">
        {t('don.gps.chuaCoLoTrinh')}
      </div>
    );
  }

  const lats = diem.map((item) => item.lat);
  const lngs = diem.map((item) => item.lng);
  const minLat = Math.min(...lats);
  const maxLat = Math.max(...lats);
  const minLng = Math.min(...lngs);
  const maxLng = Math.max(...lngs);

  const toaDo = (item: Diem) => {
    const x = maxLng === minLng ? 0.5 : (item.lng - minLng) / (maxLng - minLng);
    const y = maxLat === minLat ? 0.5 : (item.lat - minLat) / (maxLat - minLat);
    return {
      x: LE + x * (RONG - LE * 2),
      y: CAO - LE - y * (CAO - LE * 2),
    };
  };

  const diemVe = diem.map(toaDo);
  const duong = diemVe.map((item) => `${item.x.toFixed(1)},${item.y.toFixed(1)}`).join(' ');
  const batDau = diemVe[0];
  const ketThuc = diemVe[diemVe.length - 1];

  return (
    <div className="relative h-[170px] overflow-hidden rounded-card bg-card-mint/50">
      <svg
        viewBox={`0 0 ${RONG} ${CAO}`}
        preserveAspectRatio="none"
        className="h-full w-full"
        role="img"
        aria-label={t('don.gps.tieuDe')}
      >
        {Array.from({ length: 7 }).map((_, index) => (
          <line
            key={`ngang-${index}`}
            x1={0}
            x2={RONG}
            y1={((index + 1) * CAO) / 8}
            y2={((index + 1) * CAO) / 8}
            className="stroke-neutral-light"
            strokeWidth={1}
          />
        ))}
        {Array.from({ length: 13 }).map((_, index) => (
          <line
            key={`doc-${index}`}
            y1={0}
            y2={CAO}
            x1={((index + 1) * RONG) / 14}
            x2={((index + 1) * RONG) / 14}
            className="stroke-neutral-light"
            strokeWidth={1}
          />
        ))}

        <polyline
          points={duong}
          fill="none"
          className="stroke-primary"
          strokeWidth={3}
          strokeLinecap="round"
          strokeLinejoin="round"
          vectorEffect="non-scaling-stroke"
        />
        <circle cx={batDau.x} cy={batDau.y} r={6} className="fill-primary" />
      </svg>

      <span
        className="pointer-events-none absolute -translate-x-1/2 -translate-y-1/2"
        style={{ left: `${(ketThuc.x / RONG) * 100}%`, top: `${(ketThuc.y / CAO) * 100}%` }}
      >
        <MapPin className="h-[26px] w-[26px] text-accent" strokeWidth={2} />
      </span>
    </div>
  );
}
