import { useTranslation } from 'react-i18next';
import { Globe } from 'lucide-react';
import { LANGUAGES, type Language } from '@/core/i18n';
import { cn } from '@/lib/utils';

// Nút đổi ngôn ngữ
export function LanguageSwitch({ className }: { className?: string }) {
  const { t, i18n } = useTranslation();
  const current = (i18n.resolvedLanguage ?? 'vi') as Language;
  const next = LANGUAGES[(LANGUAGES.indexOf(current) + 1) % LANGUAGES.length];

  return (
    <button
      type="button"
      onClick={() => void i18n.changeLanguage(next)}
      aria-label={t('chung.doiNgonNgu')}
      className={cn(
        'flex h-[42px] items-center gap-text rounded-card border border-neutral px-item text-label uppercase text-text-secondary hover:bg-card-mint',
        className,
      )}
    >
      <Globe className="h-[18px] w-[18px]" strokeWidth={1.8} />
      {current}
    </button>
  );
}
