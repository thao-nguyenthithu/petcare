import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import * as Dialog from '@radix-ui/react-dialog';
import { X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

type ModalProps = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  description?: string;
  children?: ReactNode;
  confirmLabel?: string;
  cancelLabel?: string;
  onConfirm?: () => void;
  danger?: boolean;
  confirmDisabled?: boolean;
  loading?: boolean;
  className?: string;
};

export function Modal({
  open,
  onOpenChange,
  title,
  description,
  children,
  confirmLabel,
  cancelLabel,
  onConfirm,
  danger = false,
  confirmDisabled = false,
  loading = false,
  className,
}: ModalProps) {
  const { t } = useTranslation();
  return (
    <Dialog.Root open={open} onOpenChange={onOpenChange}>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 z-40 bg-text-primary/40 data-[state=open]:animate-in data-[state=open]:fade-in" />
        <Dialog.Content
          className={cn(
            'fixed left-1/2 top-1/2 z-50 w-[min(560px,calc(100vw-48px))] -translate-x-1/2 -translate-y-1/2 rounded-card bg-surface p-screen-wide shadow-pop focus:outline-none',
            className,
          )}
        >
          <div className="flex items-start justify-between gap-item">
            <div>
              <Dialog.Title className="text-h3">{title}</Dialog.Title>
              {description ? (
                <Dialog.Description className="mt-label text-body text-text-secondary">
                  {description}
                </Dialog.Description>
              ) : null}
            </div>
            <Dialog.Close asChild>
              <button
                type="button"
                aria-label={t('chung.dong')}
                className="text-text-secondary hover:text-text-primary"
              >
                <X className="h-5 w-5" strokeWidth={1.8} />
              </button>
            </Dialog.Close>
          </div>

          {children ? <div className="mt-block">{children}</div> : null}

          {onConfirm || confirmLabel ? (
            <div className="mt-group flex items-center justify-end gap-item">
              <Dialog.Close asChild>
                <Button variant="ghost">{cancelLabel ?? t('chung.huy')}</Button>
              </Dialog.Close>
              <Button
                variant={danger ? 'danger' : 'primary'}
                onClick={onConfirm}
                disabled={confirmDisabled}
                loading={loading}
              >
                {confirmLabel ?? t('chung.xacNhan')}
              </Button>
            </div>
          ) : null}
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
