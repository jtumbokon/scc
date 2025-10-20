import { test, expect } from '@playwright/test';

/**
 * Example Visual Regression Test for Dashboard
 *
 * This test demonstrates visual regression testing capabilities
 * and follows the screenshot naming conventions.
 */
test.describe('Dashboard Visual Tests', () => {
  test.beforeEach(async ({ page }) => {
    // Setup: Login and navigate to dashboard
    await page.goto('/login');
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('ValidPassword123!');
    await page.getByRole('button', { name: 'Sign In' }).click();
    await expect(page).toHaveURL(/.*\/dashboard/);
  });

  test('dashboard main page should match baseline', async ({ page }) => {
    // Act: Ensure dashboard is fully loaded
    await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
    await expect(page.getByRole('navigation')).toBeVisible();

    // Assert: Visual comparison with baseline
    await expect(page).toHaveScreenshot('dashboard-main.png', {
      fullPage: true,
      animations: 'disabled',
      caret: 'hide'
    });
  });

  test('dashboard should be responsive on mobile', async ({ page }) => {
    // Act: Emulate mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.reload();
    await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();

    // Assert: Visual comparison for mobile layout
    await expect(page).toHaveScreenshot('dashboard-mobile.png', {
      fullPage: true,
      animations: 'disabled',
      caret: 'hide'
    });
  });

  test('dashboard components should be visually consistent', async ({ page }) => {
    // Act: Focus on specific components
    const navigation = page.getByRole('navigation');
    const userWidget = page.getByTestId('user-widget');

    await expect(navigation).toBeVisible();
    await expect(userWidget).toBeVisible();

    // Assert: Component-level visual comparison
    await expect(navigation).toHaveScreenshot('navigation-component.png', {
      animations: 'disabled',
      caret: 'hide'
    });

    await expect(userWidget).toHaveScreenshot('user-widget-component.png', {
      animations: 'disabled',
      caret: 'hide'
    });
  });
});