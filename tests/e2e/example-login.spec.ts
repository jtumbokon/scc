import { test, expect } from '@playwright/test';

/**
 * Example E2E Test for Login Flow
 *
 * This test demonstrates the use of Playwright MCP integration
 * and follows the testing standards enforced by the rules.
 */
test.describe('User Authentication', () => {
  test.beforeEach(async ({ page }) => {
    // Setup: Navigate to login page
    await page.goto('/login');
  });

  test('should allow user to login with valid credentials', async ({ page }) => {
    // Act: Fill login form with valid credentials
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('ValidPassword123!');
    await page.getByRole('button', { name: 'Sign In' }).click();

    // Assert: User is redirected to dashboard
    await expect(page).toHaveURL(/.*\/dashboard/);
    await expect(page.getByRole('heading', { name: 'Welcome' })).toBeVisible();
    await expect(page.getByText('Successfully logged in')).toBeVisible();
  });

  test('should show error for invalid credentials', async ({ page }) => {
    // Act: Fill login form with invalid credentials
    await page.getByLabel('Email').fill('invalid@example.com');
    await page.getByLabel('Password').fill('InvalidPassword');
    await page.getByRole('button', { name: 'Sign In' }).click();

    // Assert: Error message is shown
    await expect(page.getByRole('alert')).toBeVisible();
    await expect(page.getByText('Invalid email or password')).toBeVisible();
  });

  test('should require both email and password', async ({ page }) => {
    // Act: Try to login without entering credentials
    await page.getByRole('button', { name: 'Sign In' }).click();

    // Assert: Validation errors are shown
    await expect(page.getByText('Email is required')).toBeVisible();
    await expect(page.getByText('Password is required')).toBeVisible();
  });
});