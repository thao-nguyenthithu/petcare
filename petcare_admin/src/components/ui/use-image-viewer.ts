import { useCallback, useState } from 'react';

export type AnhXem = { url: string; nhan?: string };

export function useImageViewer() {
  const [moTai, setMoTai] = useState<number | null>(null);
  const dong = useCallback(() => setMoTai(null), []);
  return { moTai, mo: setMoTai, dong };
}
