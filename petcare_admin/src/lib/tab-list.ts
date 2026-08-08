import type { CountTab } from '@/components/ui/count-tabs';

export function dungTabs<K extends string>(
  keys: readonly K[],
  nhan: (key: K) => string,
  counts: Partial<Record<K, number>> | undefined,
): Array<CountTab<K>> {
  return keys.map((key) => ({ key, label: nhan(key), count: counts?.[key] }));
}
