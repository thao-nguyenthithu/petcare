import { forwardRef, type InputHTMLAttributes, type ReactNode } from 'react';
import { AlertCircle, type LucideIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

type FieldProps = {
  label: string;
  error?: string;
  hint?: string;
  children: ReactNode;
  className?: string;
};

export function Field({ label, error, hint, children, className }: FieldProps) {
  return (
    <div className={cn('flex flex-col gap-label', className)}>
      <span className="text-label-sm uppercase tracking-[0.02em] text-text-primary">{label}</span>
      {children}
      {error ? <FieldError message={error} /> : null}
      {!error && hint ? <span className="text-caption-sm text-text-secondary">{hint}</span> : null}
    </div>
  );
}

// Dòng lỗi inline dùng chung, chữ đỏ kèm icon cảnh báo
export function FieldError({ message }: { message: string }) {
  return (
    <span className="flex items-center gap-text text-caption-sm text-error">
      <AlertCircle className="h-[14px] w-[14px] shrink-0" strokeWidth={1.8} />
      {message}
    </span>
  );
}

type TextInputProps = InputHTMLAttributes<HTMLInputElement> & {
  hasError?: boolean;
  leadingIcon?: LucideIcon;
};

export const TextInput = forwardRef<HTMLInputElement, TextInputProps>(function TextInput(
  { className, hasError = false, leadingIcon: Icon, ...props },
  ref,
) {
  return (
    <div className="relative">
      {Icon ? (
        <Icon
          className="pointer-events-none absolute left-stack top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-text-secondary"
          strokeWidth={1.8}
        />
      ) : null}
      <input
        ref={ref}
        className={cn(
          'h-[46px] w-full rounded-card border bg-surface text-label font-normal text-text-primary placeholder:text-text-secondary focus:outline-none',
          Icon ? 'pl-[42px] pr-item' : 'px-item',
          hasError ? 'border-error' : 'border-neutral focus:border-primary',
          className,
        )}
        {...props}
      />
    </div>
  );
});
