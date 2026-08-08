import type { ReactElement, ReactNode } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render } from '@testing-library/react';
import { I18nextProvider } from 'react-i18next';
import i18n from '@/core/i18n';

// Tắt retry: mạng lỗi phải hiện nhánh lỗi ngay chứ không treo qua ba lượt thử
function taoQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
      mutations: { retry: false },
    },
  });
}

export function renderVoiKhung(node: ReactElement) {
  const queryClient = taoQueryClient();
  function Khung({ children }: { children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>
        <I18nextProvider i18n={i18n}>{children}</I18nextProvider>
      </QueryClientProvider>
    );
  }
  return { queryClient, ...render(node, { wrapper: Khung }) };
}
