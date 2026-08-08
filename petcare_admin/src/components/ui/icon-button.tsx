import type { LucideIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

type IconButtonProps = {
  label: string;
  icon: LucideIcon;
  onClick: () => void;
  disabled?: boolean;
  tone?: 'default' | 'danger';
  bordered?: boolean;
  title?: string;
};

export function IconButton({
  label,
  icon: Icon,
  onClick,
  disabled,
  tone = 'default',
  bordered,
  title,
}: IconButtonProps) {
  return (
    <button
      type="button"
      aria-label={label}
      title={title}
      disabled={disabled}
      onClick={onClick}
      className={cn(
        'flex h-8 w-8 items-center justify-center rounded-card text-text-secondary disabled:pointer-events-none disabled:opacity-40',
        bordered && 'border border-neutral-light',
        tone === 'danger'
          ? 'hover:bg-error/12 hover:text-error'
          : 'hover:bg-card-mint hover:text-primary',
      )}
    >
      <Icon className="h-4 w-4" strokeWidth={1.8} />
    </button>
  );
}
