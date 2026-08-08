import { AlertTriangle } from 'lucide-react';

export function EnumNote({ children }: { children: string }) {
  return (
    <div className="flex items-start gap-item rounded-card border border-honey/30 bg-honey/10 p-card">
      <AlertTriangle className="mt-[2px] h-4 w-4 shrink-0 text-honey" strokeWidth={1.8} />
      <p className="text-caption-sm text-text-secondary">{children}</p>
    </div>
  );
}
