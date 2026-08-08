import path from 'node:path';
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(import.meta.dirname, 'src'),
      '@tests': path.resolve(import.meta.dirname, 'tests'),
    },
  },
  server: { port: 5174 },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./tests/support/setup.ts'],
    include: ['tests/**/*.test.{ts,tsx}'],
    testTimeout: 15000,
    hookTimeout: 15000,
  },
});
