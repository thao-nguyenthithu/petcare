import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Search, X } from 'lucide-react';
import { cn } from '@/lib/utils';

type SearchFieldProps = {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  debounceMs?: number;
  className?: string;
};

export function SearchField({
  value,
  onChange,
  placeholder,
  debounceMs = 400,
  className,
}: SearchFieldProps) {
  const { t } = useTranslation();
  const [draft, setDraft] = useState(value);
  const [syncedValue, setSyncedValue] = useState(value);

  if (value !== syncedValue) {
    setSyncedValue(value);
    setDraft(value);
  }

  const onChangeRef = useRef(onChange);
  useEffect(() => {
    onChangeRef.current = onChange;
  }, [onChange]);

  useEffect(() => {
    if (draft === value) return;
    const timer = setTimeout(() => onChangeRef.current(draft), debounceMs);
    return () => clearTimeout(timer);
  }, [draft, value, debounceMs]);

  return (
    <div className={cn('relative', className)}>
      <Search
        className="pointer-events-none absolute left-item top-1/2 h-4 w-4 -translate-y-1/2 text-text-secondary"
        strokeWidth={1.8}
      />
      <input
        type="search"
        value={draft}
        onChange={(event) => setDraft(event.target.value)}
        placeholder={placeholder ?? t('chung.timKiem')}
        className="h-[42px] w-full rounded-card border border-neutral bg-surface pl-10 pr-10 text-label font-normal text-text-primary placeholder:text-text-secondary focus:border-primary focus:outline-none"
      />
      {draft ? (
        <button
          type="button"
          onClick={() => setDraft('')}
          aria-label={t('chung.xoaTuKhoa')}
          className="absolute right-item top-1/2 -translate-y-1/2 text-text-secondary hover:text-text-primary"
        >
          <X className="h-4 w-4" strokeWidth={1.8} />
        </button>
      ) : null}
    </div>
  );
}
