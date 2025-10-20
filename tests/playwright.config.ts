import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright Configuration for Super-Claude Project
 *
 * This configuration supports E2E testing, visual regression testing,
 * and integration with the Playwright MCP system.
 */
export default defineConfig({
  // Test directory structure
  testDir: '.',

  // Run tests in files in parallel
  fullyParallel: true,

  // Fail the build on CI if you accidentally left test.only in the source code
  forbidOnly: !!process.env.CI,

  // Retry on CI only
  retries: process.env.CI ? 2 : 0,

  // Opt out of parallel tests on CI
  workers: process.env.CI ? 1 : undefined,

  // Reporter to use
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['json', { outputFile: 'test-results.json' }],
    ['junit', { outputFile: 'test-results.xml' }],
    ['list']
  ],

  // Global setup and teardown
  globalSetup: require.resolve('./config/global-setup.ts'),
  globalTeardown: require.resolve('./config/global-teardown.ts'),

  // Shared settings for all projects
  use: {
    // Base URL to use in actions like `await page.goto('/')`
    baseURL: process.env.BASE_URL || 'http://localhost:3000',

    // Collect trace when retrying the failed test
    trace: 'on-first-retry',

    // Record video on failure
    video: 'retain-on-failure',

    // Take screenshot on failure
    screenshot: 'only-on-failure',

    // Global timeout for each action
    actionTimeout: 10000,

    // Global timeout for navigation
    navigationTimeout: 30000,
  },

  // Configure projects for major browsers
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },

    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },

    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },

    // Test against mobile viewports
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },

    // Visual regression testing project
    {
      name: 'visual-regression',
      use: {
        ...devices['Desktop Chrome'],
        // Visual testing specific settings
        viewport: { width: 1280, height: 720 },
        ignoreHTTPSErrors: true,
      },
      testMatch: '**/visual/**/*.spec.ts',
      dependencies: ['chromium'],
    },

    // E2E testing project
    {
      name: 'e2e',
      use: {
        ...devices['Desktop Chrome'],
        // E2E specific settings
        viewport: { width: 1920, height: 1080 },
        ignoreHTTPSErrors: true,
      },
      testMatch: '**/e2e/**/*.spec.ts',
      dependencies: ['chromium'],
    },

    // Integration testing project
    {
      name: 'integration',
      use: {
        ...devices['Desktop Chrome'],
        // Integration specific settings
        viewport: { width: 1280, height: 720 },
      },
      testMatch: '**/integration/**/*.spec.ts',
      dependencies: ['chromium'],
    },

    // Debugging project with headed browser
    {
      name: 'debug',
      use: {
        ...devices['Desktop Chrome'],
        headless: false,
        slowMo: 100,
        viewport: { width: 1920, height: 1080 },
      },
      testMatch: '**/*.debug.spec.ts',
    },
  ],

  // Run your local dev server before starting the tests
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },

  // Output directory for test artifacts
  outputDir: 'test-results/',

  // Global test timeout
  timeout: 60 * 1000,

  // Expect timeout
  expect: {
    timeout: 10 * 1000,
  },
});