import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: __dirname,
  timeout: 300_000,
  expect: {
    timeout: 120_000,
  },
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL ?? 'http://127.0.0.1:4173',
    headless: true,
    ignoreHTTPSErrors: true,
    viewport: { width: 1440, height: 900 },
  },
  reporter: [['list']],
});
