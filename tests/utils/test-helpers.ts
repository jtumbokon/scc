import { Page, expect } from '@playwright/test';
import path from 'path';

/**
 * Test Helper Utilities
 *
 * This file contains reusable helper functions for Playwright tests.
 * Follows the organization standards for test utilities.
 */

export class TestHelpers {
  constructor(private page: Page) {}

  /**
   * Navigate to a URL and wait for page to be ready
   */
  async navigateAndWait(url: string, timeout = 30000): Promise<void> {
    await this.page.goto(url, { waitUntil: 'networkidle', timeout });
    await this.page.waitForLoadState('domcontentloaded');
  }

  /**
   * Fill a form with provided data
   */
  async fillForm(formData: Record<string, string>): Promise<void> {
    for (const [field, value] of Object.entries(formData)) {
      const element = this.page.getByLabel(field);
      await element.waitFor({ state: 'visible' });
      await element.fill(value);
    }
  }

  /**
   * Take a screenshot with proper naming convention
   */
  async takeScreenshot(name: string, options = {}): Promise<string> {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
    const filename = `${name}-${timestamp}.png`;
    const screenshotPath = path.join('tests/artifacts/screenshots/current', filename);

    await this.page.screenshot({
      path: screenshotPath,
      fullPage: true,
      ...options
    });

    return screenshotPath;
  }

  /**
   * Wait for element to be visible and return it
   */
  async waitForElementVisible(selector: string, timeout = 10000) {
    return await this.page.locator(selector).waitFor({ state: 'visible', timeout });
  }

  /**
   * Check for console errors
   */
  async captureConsoleErrors(): Promise<string[]> {
    const consoleErrors: string[] = [];

    this.page.on('console', (msg) => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
      }
    });

    return consoleErrors;
  }

  /**
   * Handle login flow with proper error checking
   */
  async login(email: string, password: string): Promise<void> {
    await this.navigateAndWait('/login');

    // Fill login form
    await this.page.getByLabel('Email').fill(email);
    await this.page.getByLabel('Password').fill(password);

    // Submit form
    await this.page.getByRole('button', { name: 'Sign In' }).click();

    // Verify successful login
    await expect(this.page).toHaveURL(/.*\/dashboard/);
    await expect(this.page.getByRole('heading', { name: 'Welcome' })).toBeVisible();
  }

  /**
   * Generate test data with timestamp
   */
  static generateTestData(prefix = 'test'): Record<string, string> {
    const timestamp = Date.now();
    return {
      email: `${prefix}${timestamp}@example.com`,
      username: `${prefix}user${timestamp}`,
      name: `${prefix} User ${timestamp}`
    };
  }

  /**
   * Check accessibility of current page
   */
  async checkAccessibility(): Promise<void> {
    // Basic accessibility checks
    const title = await this.page.title();
    expect(title).toBeTruthy();
    expect(title.length).toBeGreaterThan(0);

    // Check for proper heading structure
    const mainHeading = this.page.getByRole('heading', { level: 1 });
    if (await mainHeading.isVisible()) {
      expect(await mainHeading.textContent()).toBeTruthy();
    }
  }

  /**
   * Clean up test data and reset state
   */
  async cleanup(): Promise<void> {
    // Clear cookies and local storage
    await this.page.context().clearCookies();
    await this.page.evaluate(() => {
      localStorage.clear();
      sessionStorage.clear();
    });
  }
}

/**
 * Custom test fixture that extends base test context
 */
export const testWithHelpers = test.extend({
  helpers: async ({ page }, use) => {
    const helpers = new TestHelpers(page);
    await use(helpers);
    await helpers.cleanup();
  },
});