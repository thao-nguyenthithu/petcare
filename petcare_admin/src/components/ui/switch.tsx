import { cn } from '@/lib/utils';

type SwitchProps = {
  checked: boolean;
  onChange: (checked: boolean) => void;
  label: string;
  disabled?: boolean;
  className?: string;
};

export function Switch({ checked, onChange, label, disabled = false, className }: SwitchProps) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      onClick={() => onChange(!checked)}
      className={cn(
        'relative h-[23px] w-[40px] shrink-0 rounded-full transition-colors disabled:opacity-50',
        checked ? 'bg-primary' : 'bg-neutral',
        className,
      )}
    >
      <span
        className={cn(
          'absolute top-[3px] h-[17px] w-[17px] rounded-full bg-surface transition-all',
          checked ? 'left-[20px]' : 'left-[3px]',
        )}
      />
    </button>
  );
}
