import '@testing-library/jest-dom/vitest';
import { cleanup, configure } from '@testing-library/react';
import { afterAll, afterEach, beforeAll } from 'vitest';
import i18n from '@/core/i18n';
import { server } from '@tests/support/server';

// Hạn chờ của findBy nằm ngoài testTimeout, để mặc định 1s là đỏ giả khi máy tải nặng
configure({ asyncUtilTimeout: 5000 });

// jsdom không có ResizeObserver mà lớp thả xuống của Radix cần nó mới mở được
if (!('ResizeObserver' in globalThis)) {
  globalThis.ResizeObserver = class {
    observe() {}
    unobserve() {}
    disconnect() {}
  } as unknown as typeof ResizeObserver;
}

// Gọi ra ngoài mà không khai handler là lỗi, không được lặng lẽ trả rỗng
beforeAll(async () => {
  server.listen({ onUnhandledRequest: 'error' });
  // jsdom báo navigator.language là en nên phải ép, không thì test đọc chuỗi Anh
  await i18n.changeLanguage('vi');
});

afterEach(() => {
  server.resetHandlers();
  cleanup();
});

afterAll(() => server.close());
