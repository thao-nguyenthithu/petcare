import { useRef } from 'react';
import { OTP_LENGTH } from '@/features/auth/auth-constants';
import { cn } from '@/lib/utils';

type OtpInputProps = {
  value: string;
  onChange: (value: string) => void;
  disabled?: boolean;
  hasError?: boolean;
};

export function OtpInput({ value, onChange, disabled = false, hasError = false }: OtpInputProps) {
  const inputs = useRef<Array<HTMLInputElement | null>>([]);

  const handleChange = (index: number, raw: string) => {
    const digits = raw.replace(/\D/g, '');
    if (!digits) {
      onChange(value.slice(0, index) + value.slice(index + 1));
      return;
    }
    if (digits.length > 1) {
      onChange((value.slice(0, index) + digits).slice(0, OTP_LENGTH));
      inputs.current[Math.min(index + digits.length, OTP_LENGTH - 1)]?.focus();
      return;
    }
    onChange((value.slice(0, index) + digits + value.slice(index + 1)).slice(0, OTP_LENGTH));
    inputs.current[Math.min(index + 1, OTP_LENGTH - 1)]?.focus();
  };

  const handleKeyDown = (index: number, event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'Backspace' && !value[index] && index > 0) {
      inputs.current[index - 1]?.focus();
    }
  };

  return (
    <div className="grid grid-cols-6 gap-item">
      {Array.from({ length: OTP_LENGTH }).map((_, index) => (
        <input
          key={index}
          ref={(element) => {
            inputs.current[index] = element;
          }}
          inputMode="numeric"
          autoComplete="one-time-code"
          maxLength={OTP_LENGTH}
          value={value[index] ?? ''}
          disabled={disabled}
          onChange={(event) => handleChange(index, event.target.value)}
          onKeyDown={(event) => handleKeyDown(index, event)}
          className={cn(
            'h-[52px] w-full rounded-card border bg-surface text-center text-h3 text-text-primary focus:outline-none disabled:bg-neutral-light disabled:text-text-secondary',
            hasError ? 'border-error' : 'border-neutral focus:border-primary',
          )}
        />
      ))}
    </div>
  );
}
