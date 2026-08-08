import { cva } from 'class-variance-authority';

export const buttonVariants = cva(
  'inline-flex items-center justify-center gap-label rounded-card text-button transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/40 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-primary text-text-white hover:bg-primary/90',
        secondary: 'border border-neutral bg-surface text-text-primary hover:bg-card-mint',
        ghost: 'text-text-secondary hover:bg-neutral-light hover:text-text-primary',
        danger: 'bg-error text-text-white hover:bg-error/90',
      },
      size: {
        md: 'h-10 px-block',
        sm: 'h-9 px-stack text-label',
        icon: 'h-9 w-9 p-0',
      },
    },
    defaultVariants: { variant: 'primary', size: 'md' },
  },
);
