import { cva, type VariantProps } from 'class-variance-authority';
import type { LucideIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

const badgeVariants = cva(
  'inline-flex items-center gap-text rounded-card px-label py-[5px] text-label-sm whitespace-nowrap',
  {
    variants: {
      tone: {
        // đã xong, đã đạt
        success: 'bg-primary/12 text-primary',
        // đang chờ người khác
        pending: 'bg-honey/15 text-honey',
        // có vấn đề, cần can thiệp
        danger: 'bg-error/12 text-error',
        // đang chạy
        info: 'bg-card-mint text-primary',
        // không áp dụng, đã đóng
        neutral: 'bg-neutral-light text-text-secondary',
      },
    },
    defaultVariants: { tone: 'neutral' },
  },
);

export type BadgeTone = NonNullable<VariantProps<typeof badgeVariants>['tone']>;

type BadgeProps = React.HTMLAttributes<HTMLSpanElement> &
  VariantProps<typeof badgeVariants> & {
    icon?: LucideIcon;
  };

export function Badge({ tone, className, icon: Icon, children, ...props }: BadgeProps) {
  return (
    <span className={cn(badgeVariants({ tone }), className)} {...props}>
      {Icon ? <Icon className="h-[14px] w-[14px] shrink-0" strokeWidth={2} /> : null}
      {children}
    </span>
  );
}
