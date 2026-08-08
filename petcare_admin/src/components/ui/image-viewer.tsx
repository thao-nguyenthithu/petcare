import { useCallback, useRef, useState } from 'react';
import type { KeyboardEvent, ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import * as Dialog from '@radix-ui/react-dialog';
import { ChevronLeft, ChevronRight, Minus, Plus, RotateCcw, X } from 'lucide-react';
import type { AnhXem } from '@/components/ui/use-image-viewer';
import { cn } from '@/lib/utils';

type ImageViewerProps = {
  anh: AnhXem[];
  moTai: number | null;
  onDong: () => void;
};

const TY_LE_MIN = 1;
const TY_LE_MAX = 4;
const BUOC_NUT = 0.5;
const BUOC_CUON = 0.25;

function kep(giaTri: number): number {
  return Math.min(TY_LE_MAX, Math.max(TY_LE_MIN, giaTri));
}

export function ImageViewer({ anh, moTai, onDong }: ImageViewerProps) {
  const { t } = useTranslation();
  const [chiSo, setChiSo] = useState(0);
  const [tyLe, setTyLe] = useState(1);
  const [keo, setKeo] = useState({ x: 0, y: 0 });
  const mocKeo = useRef<{ x: number; y: number } | null>(null);

  const mo = moTai !== null && anh.length > 0;
  const nhieuAnh = anh.length > 1;

  const veCoGoc = useCallback(() => {
    setTyLe(1);
    setKeo({ x: 0, y: 0 });
  }, []);

  const [moTruoc, setMoTruoc] = useState(moTai);
  if (moTai !== moTruoc) {
    setMoTruoc(moTai);
    if (moTai !== null) {
      setChiSo(Math.min(Math.max(0, moTai), anh.length - 1));
      setTyLe(1);
      setKeo({ x: 0, y: 0 });
    }
  }

  const doiAnh = useCallback(
    (buoc: number) => {
      if (anh.length < 2) return;
      setChiSo((truoc) => (truoc + buoc + anh.length) % anh.length);
      veCoGoc();
    },
    [anh.length, veCoGoc],
  );

  const doiTyLe = useCallback((buoc: number) => {
    setTyLe((truoc) => {
      const moi = kep(truoc + buoc);
      if (moi === TY_LE_MIN) setKeo({ x: 0, y: 0 });
      return moi;
    });
  }, []);

  const batPhim = (su: KeyboardEvent) => {
    if (su.key === 'ArrowLeft') doiAnh(-1);
    else if (su.key === 'ArrowRight') doiAnh(1);
    else if (su.key === '+' || su.key === '=') doiTyLe(BUOC_NUT);
    else if (su.key === '-' || su.key === '_') doiTyLe(-BUOC_NUT);
    else if (su.key === '0') veCoGoc();
    else return;
    su.preventDefault();
  };

  const dangXem = anh[chiSo];
  if (!dangXem) return null;

  return (
    <Dialog.Root open={mo} onOpenChange={(tiep) => (tiep ? undefined : onDong())}>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 z-40 bg-text-primary/85" />
        <Dialog.Content
          onKeyDown={batPhim}
          className="fixed inset-0 z-50 flex flex-col focus:outline-none"
        >
          <Dialog.Title className="sr-only">{t('xemAnh.tieuDe')}</Dialog.Title>

          <div className="flex items-center justify-between gap-item p-stack text-text-white">
            <span className="text-label">
              {nhieuAnh
                ? t('xemAnh.viTri', { index: chiSo + 1, total: anh.length })
                : (dangXem.nhan ?? '')}
            </span>

            <div className="flex items-center gap-label">
              <NutTron
                nhan={t('xemAnh.thuNho')}
                onBam={() => doiTyLe(-BUOC_NUT)}
                tat={tyLe <= TY_LE_MIN}
              >
                <Minus className="h-4 w-4" strokeWidth={1.8} />
              </NutTron>
              <span className="min-w-[52px] text-center text-label">
                {Math.round(tyLe * 100)}%
              </span>
              <NutTron
                nhan={t('xemAnh.phongTo')}
                onBam={() => doiTyLe(BUOC_NUT)}
                tat={tyLe >= TY_LE_MAX}
              >
                <Plus className="h-4 w-4" strokeWidth={1.8} />
              </NutTron>
              <NutTron nhan={t('xemAnh.coGoc')} onBam={veCoGoc} tat={tyLe === TY_LE_MIN}>
                <RotateCcw className="h-4 w-4" strokeWidth={1.8} />
              </NutTron>
              <NutTron nhan={t('xemAnh.dong')} onBam={onDong}>
                <X className="h-5 w-5" strokeWidth={1.8} />
              </NutTron>
            </div>
          </div>

          <div
            className="relative flex min-h-0 flex-1 items-center justify-center overflow-hidden p-stack"
            onClick={(su) => {
              if (su.target === su.currentTarget) onDong();
            }}
            onWheel={(su) => doiTyLe(su.deltaY < 0 ? BUOC_CUON : -BUOC_CUON)}
          >
            {nhieuAnh ? (
              <NutLuot
                nhan={t('xemAnh.anhTruoc')}
                ben="trai"
                onBam={() => doiAnh(-1)}
              >
                <ChevronLeft className="h-6 w-6" strokeWidth={1.8} />
              </NutLuot>
            ) : null}

            <img
              src={dangXem.url}
              alt={dangXem.nhan ?? ''}
              draggable={false}
              onPointerDown={(su) => {
                if (tyLe <= TY_LE_MIN) return;
                mocKeo.current = { x: su.clientX - keo.x, y: su.clientY - keo.y };
                su.currentTarget.setPointerCapture(su.pointerId);
              }}
              onPointerMove={(su) => {
                if (!mocKeo.current) return;
                setKeo({
                  x: su.clientX - mocKeo.current.x,
                  y: su.clientY - mocKeo.current.y,
                });
              }}
              onPointerUp={() => {
                mocKeo.current = null;
              }}
              style={{
                transform: `translate(${keo.x}px, ${keo.y}px) scale(${tyLe})`,
              }}
              className={cn(
                'max-h-full max-w-full select-none object-contain',
                tyLe > TY_LE_MIN ? 'cursor-grab active:cursor-grabbing' : 'cursor-default',
              )}
            />

            {nhieuAnh ? (
              <NutLuot nhan={t('xemAnh.anhSau')} ben="phai" onBam={() => doiAnh(1)}>
                <ChevronRight className="h-6 w-6" strokeWidth={1.8} />
              </NutLuot>
            ) : null}
          </div>

          {nhieuAnh && dangXem.nhan ? (
            <p className="p-stack text-center text-label text-text-white">{dangXem.nhan}</p>
          ) : null}
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}

function NutTron({
  nhan,
  onBam,
  tat = false,
  children,
}: {
  nhan: string;
  onBam: () => void;
  tat?: boolean;
  children: ReactNode;
}) {
  return (
    <button
      type="button"
      aria-label={nhan}
      disabled={tat}
      onClick={onBam}
      className="flex h-9 w-9 items-center justify-center rounded-card bg-surface/15 text-text-white transition-colors hover:bg-surface/30 disabled:opacity-40"
    >
      {children}
    </button>
  );
}

function NutLuot({
  nhan,
  ben,
  onBam,
  children,
}: {
  nhan: string;
  ben: 'trai' | 'phai';
  onBam: () => void;
  children: ReactNode;
}) {
  return (
    <button
      type="button"
      aria-label={nhan}
      onClick={onBam}
      className={cn(
        'absolute top-1/2 z-10 flex h-11 w-11 -translate-y-1/2 items-center justify-center rounded-full bg-surface/15 text-text-white transition-colors hover:bg-surface/30',
        ben === 'trai' ? 'left-stack' : 'right-stack',
      )}
    >
      {children}
    </button>
  );
}
