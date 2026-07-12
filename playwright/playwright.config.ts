import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright configuration for SHPH Flutter web app testing.
 *
 * Prerequisites:
 * 1. Start Flutter web server:  flutter run -d chrome --web-port=8080
 * 2. Run tests:                 npx playwright test --headed
 */
export default defineConfig({
  testDir: './tests',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1,
  reporter: 'html',
  timeout: 60_000,

  use: {
    baseURL: 'http://localhost:8080',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 15_000,
    navigationTimeout: 30_000,
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],

  // Uncomment to auto-start Flutter web server
  // webServer: {
  //   command: 'flutter run -d chrome --web-port=8080',
  //   url: 'http://localhost:8080',
  //   reuseExistingServer: true,
  //   timeout: 120_000,
  // },
});
