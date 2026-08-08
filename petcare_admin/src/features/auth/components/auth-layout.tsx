import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { Check } from 'lucide-react';
import { LanguageSwitch } from '@/components/ui/language-switch';

export function AuthLayout({ children }: { children: ReactNode }) {
  const { t } = useTranslation();

  const diemNhan = [
    t('auth.gioiThieu.diemGps'),
    t('auth.gioiThieu.diemAnh'),
    t('auth.gioiThieu.diemDoiSoat'),
  ];

  return (
    <div className="flex h-screen overflow-hidden bg-surface">
      <section className="relative hidden w-[43%] shrink-0 flex-col justify-center overflow-hidden bg-primary px-[64px] lg:flex">
        <div className="flex items-center gap-stack">
          <span className="flex h-[80px] w-[80px] items-center justify-center rounded-lg bg-surface">
            <img src="/paw.svg" alt="" aria-hidden className="h-[75px] w-[75px]" />
          </span>
          <span className="text-[30px] font-bold leading-[38px] text-text-white">
            {t('chung.tenSanPham')}
          </span>
        </div>

        <h1 className="mt-block max-w-[492px] text-[32px] font-bold leading-[44px] text-text-white">
          {t('auth.gioiThieu.tieuDe')}
        </h1>

        <p className="mt-block max-w-[492px] text-body text-text-white/80">
          {t('auth.gioiThieu.moTa')}
        </p>

        <ul className="mt-block flex flex-col gap-item">
          {diemNhan.map((text) => (
            <li key={text} className="flex items-center gap-label">
              <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-text-white/15">
                <Check className="h-[14px] w-[14px] text-text-white" strokeWidth={2} />
              </span>
              <span className="text-label font-normal text-text-white/90">{text}</span>
            </li>
          ))}
        </ul>
      </section>

      <section className="relative flex flex-1 items-center justify-center overflow-y-auto px-screen py-edge">
        <div className="absolute right-screen top-screen">
          <LanguageSwitch />
        </div>
        <div className="w-full max-w-[380px]">{children}</div>
      </section>
    </div>
  );
}
