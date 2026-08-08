import { useState, type InputHTMLAttributes } from 'react';
import { useTranslation } from 'react-i18next';
import { Eye, EyeOff, Lock } from 'lucide-react';
import { cn } from '@/lib/utils';

type PasswordInputProps = InputHTMLAttributes<HTMLInputElement> & { hasError?: boolean };

export function PasswordInput({ className, hasError = false, ...props }: PasswordInputProps) {
  const { t } = useTranslation();
  const [visible, setVisible] = useState(false);
  const Icon = visible ? EyeOff : Eye;

  return (
    <div className="relative">
      <Lock
        className="pointer-events-none absolute left-stack top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-text-secondary"
        strokeWidth={1.8}
      />
      <input
        type={visible ? 'text' : 'password'}
        className={cn(
          'h-[46px] w-full rounded-card border bg-surface pl-[42px] pr-[42px] text-label font-normal text-text-primary placeholder:text-text-secondary focus:outline-none',
          hasError ? 'border-error' : 'border-neutral focus:border-primary',
          className,
        )}
        {...props}
      />
      <button
        type="button"
        onClick={() => setVisible((current) => !current)}
        aria-label={visible ? t('auth.dangNhap.anMatKhau') : t('auth.dangNhap.hienMatKhau')}
        className="absolute right-stack top-1/2 -translate-y-1/2 text-text-secondary hover:text-text-primary"
      >
        <Icon className="h-[18px] w-[18px]" strokeWidth={1.8} />
      </button>
    </div>
  );
}
