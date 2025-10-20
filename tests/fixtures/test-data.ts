/**
 * Test Data Fixtures
 *
 * This file contains test data and utilities for Playwright tests.
 * Follows the organization standards for test fixtures.
 */

export const testUsers = {
  validUser: {
    email: 'test@example.com',
    password: 'ValidPassword123!',
    firstName: 'Test',
    lastName: 'User'
  },
  invalidUser: {
    email: 'invalid@example.com',
    password: 'InvalidPassword',
    firstName: 'Invalid',
    lastName: 'User'
  },
  adminUser: {
    email: 'admin@example.com',
    password: 'AdminPassword123!',
    firstName: 'Admin',
    lastName: 'User'
  }
};

export const testPages = {
  login: '/login',
  dashboard: '/dashboard',
  profile: '/profile',
  settings: '/settings'
};

export const testScenarios = {
  successfulLogin: {
    description: 'User logs in with valid credentials',
    steps: ['navigate to login', 'fill valid credentials', 'click submit', 'verify dashboard']
  },
  failedLogin: {
    description: 'User fails login with invalid credentials',
    steps: ['navigate to login', 'fill invalid credentials', 'click submit', 'verify error']
  },
  logout: {
    description: 'User logs out successfully',
    steps: ['login', 'navigate to dashboard', 'click logout', 'verify redirect to login']
  }
};

export const viewports = {
  desktop: { width: 1920, height: 1080 },
  tablet: { width: 768, height: 1024 },
  mobile: { width: 375, height: 667 }
};

export const timeOuts = {
  short: 5000,
  medium: 10000,
  long: 30000
};