import { test, expect } from '@playwright/test';

/**
 * E2E Test: Login Flow
 *
 * Tests user authentication including:
 * - Successful login
 * - Invalid credentials
 * - Form validation
 * - Session persistence
 */

// Page Object Model (optional but recommended)
class LoginPage {
  constructor(private page) {}

  // Locators
  get emailInput() {
    return this.page.locator('[data-testid="email-input"]');
  }

  get passwordInput() {
    return this.page.locator('[data-testid="password-input"]');
  }

  get submitButton() {
    return this.page.locator('[data-testid="login-button"]');
  }

  get errorMessage() {
    return this.page.locator('[data-testid="error-message"]');
  }

  // Actions
  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async waitForErrorMessage() {
    await this.errorMessage.waitFor({ state: 'visible' });
    return await this.errorMessage.textContent();
  }
}

test.describe('Login Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to login page before each test
    await page.goto('/login');
  });

  test('should display login form', async ({ page }) => {
    // Verify form elements are visible
    await expect(page.locator('[data-testid="email-input"]')).toBeVisible();
    await expect(page.locator('[data-testid="password-input"]')).toBeVisible();
    await expect(page.locator('[data-testid="login-button"]')).toBeVisible();
    await expect(page.locator('h1')).toHaveText('Login');
  });

  test('should login successfully with valid credentials', async ({ page }) => {
    const loginPage = new LoginPage(page);

    // Fill in credentials
    await loginPage.login('user@example.com', 'password123');

    // Wait for navigation to dashboard
    await page.waitForURL('**/dashboard');

    // Verify successful login
    await expect(page.locator('[data-testid="user-name"]')).toContainText('user@example.com');
    await expect(page.locator('[data-testid="logout-button"]')).toBeVisible();
  });

  test('should show error with invalid email', async ({ page }) => {
    const loginPage = new LoginPage(page);

    // Try to login with invalid email
    await loginPage.login('invalid-email', 'password123');

    // Verify error message
    const errorText = await loginPage.waitForErrorMessage();
    expect(errorText).toContain('Invalid email format');

    // Verify we're still on login page
    expect(page.url()).toContain('/login');
  });

  test('should show error with wrong password', async ({ page }) => {
    const loginPage = new LoginPage(page);

    // Try to login with wrong password
    await loginPage.login('user@example.com', 'wrongpassword');

    // Verify error message
    const errorText = await loginPage.waitForErrorMessage();
    expect(errorText).toContain('Invalid credentials');
  });

  test('should show error with empty fields', async ({ page }) => {
    const loginPage = new LoginPage(page);

    // Try to submit empty form
    await loginPage.submitButton.click();

    // Verify validation errors
    await expect(page.locator('[data-testid="email-error"]')).toContainText('Email is required');
    await expect(page.locator('[data-testid="password-error"]')).toContainText('Password is required');
  });

  test('should toggle password visibility', async ({ page }) => {
    const passwordInput = page.locator('[data-testid="password-input"]');
    const toggleButton = page.locator('[data-testid="toggle-password"]');

    // Initially password should be hidden
    await expect(passwordInput).toHaveAttribute('type', 'password');

    // Click toggle to show password
    await toggleButton.click();
    await expect(passwordInput).toHaveAttribute('type', 'text');

    // Click toggle again to hide password
    await toggleButton.click();
    await expect(passwordInput).toHaveAttribute('type', 'password');
  });

  test('should persist session after login', async ({ page, context }) => {
    const loginPage = new LoginPage(page);

    // Login successfully
    await loginPage.login('user@example.com', 'password123');
    await page.waitForURL('**/dashboard');

    // Open new page in same context
    const newPage = await context.newPage();
    await newPage.goto('/dashboard');

    // Verify user is still logged in
    await expect(newPage.locator('[data-testid="user-name"]')).toBeVisible();

    await newPage.close();
  });

  test('should redirect to intended page after login', async ({ page }) => {
    // Try to access protected page while logged out
    await page.goto('/dashboard/settings');

    // Should redirect to login
    await page.waitForURL('**/login?redirect=/dashboard/settings');

    // Login
    const loginPage = new LoginPage(page);
    await loginPage.login('user@example.com', 'password123');

    // Should redirect to originally intended page
    await page.waitForURL('**/dashboard/settings');
    expect(page.url()).toContain('/dashboard/settings');
  });

  test('should handle network errors gracefully', async ({ page }) => {
    // Simulate network failure
    await page.route('**/api/login', route => route.abort());

    const loginPage = new LoginPage(page);
    await loginPage.login('user@example.com', 'password123');

    // Verify error message
    const errorText = await loginPage.waitForErrorMessage();
    expect(errorText).toContain('Network error');
  });

  test('should disable submit button while loading', async ({ page }) => {
    const loginPage = new LoginPage(page);

    // Start login
    await loginPage.emailInput.fill('user@example.com');
    await loginPage.passwordInput.fill('password123');

    // Delay the API response
    await page.route('**/api/login', async route => {
      await page.waitForTimeout(2000);
      await route.fulfill({ status: 200, body: '{"success": true}' });
    });

    // Click submit
    await loginPage.submitButton.click();

    // Button should be disabled during request
    await expect(loginPage.submitButton).toBeDisabled();

    // Wait for response
    await page.waitForURL('**/dashboard');

    // Button should be enabled again (if we go back)
    await page.goBack();
    await expect(loginPage.submitButton).toBeEnabled();
  });
});

test.describe('Login Flow - Mobile', () => {
  test.use({ viewport: { width: 375, height: 667 } });

  test('should display mobile-optimized login form', async ({ page }) => {
    await page.goto('/login');

    // Verify mobile layout
    const form = page.locator('form');
    const boundingBox = await form.boundingBox();

    expect(boundingBox?.width).toBeLessThanOrEqual(375);
    await expect(page.locator('[data-testid="mobile-header"]')).toBeVisible();
  });
});
