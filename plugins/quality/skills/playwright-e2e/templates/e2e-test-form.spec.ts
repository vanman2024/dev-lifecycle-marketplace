import { test, expect } from '@playwright/test';

/**
 * E2E Test: Form Submission and Validation
 *
 * Tests complex form interactions including:
 * - Field validation
 * - Multi-step forms
 * - File uploads
 * - Dynamic fields
 * - Form submission
 */

test.describe('Contact Form', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/contact');
  });

  test('should display all form fields', async ({ page }) => {
    // Verify all form elements are present
    await expect(page.locator('[data-testid="name-input"]')).toBeVisible();
    await expect(page.locator('[data-testid="email-input"]')).toBeVisible();
    await expect(page.locator('[data-testid="subject-select"]')).toBeVisible();
    await expect(page.locator('[data-testid="message-textarea"]')).toBeVisible();
    await expect(page.locator('[data-testid="submit-button"]')).toBeVisible();
  });

  test('should submit form with valid data', async ({ page }) => {
    // Fill form fields
    await page.locator('[data-testid="name-input"]').fill('John Doe');
    await page.locator('[data-testid="email-input"]').fill('john@example.com');
    await page.locator('[data-testid="subject-select"]').selectOption('support');
    await page.locator('[data-testid="message-textarea"]').fill('This is a test message');

    // Submit form
    await page.locator('[data-testid="submit-button"]').click();

    // Verify success message
    await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
    await expect(page.locator('[data-testid="success-message"]')).toContainText('Thank you');
  });

  test('should validate required fields', async ({ page }) => {
    // Try to submit empty form
    await page.locator('[data-testid="submit-button"]').click();

    // Verify validation errors
    await expect(page.locator('[data-testid="name-error"]')).toContainText('Name is required');
    await expect(page.locator('[data-testid="email-error"]')).toContainText('Email is required');
    await expect(page.locator('[data-testid="message-error"]')).toContainText('Message is required');
  });

  test('should validate email format', async ({ page }) => {
    const emailInput = page.locator('[data-testid="email-input"]');
    const emailError = page.locator('[data-testid="email-error"]');

    // Test invalid email formats
    const invalidEmails = ['invalid', 'test@', '@example.com', 'test@.com'];

    for (const email of invalidEmails) {
      await emailInput.fill(email);
      await emailInput.blur();
      await expect(emailError).toContainText('Invalid email format');
      await emailError.waitFor({ state: 'hidden' });
    }

    // Test valid email
    await emailInput.fill('valid@example.com');
    await emailInput.blur();
    await expect(emailError).not.toBeVisible();
  });

  test('should enforce character limits', async ({ page }) => {
    const messageTextarea = page.locator('[data-testid="message-textarea"]');
    const charCount = page.locator('[data-testid="char-count"]');

    // Max length should be 500 characters
    const longMessage = 'A'.repeat(600);
    await messageTextarea.fill(longMessage);

    // Verify only 500 characters are accepted
    const value = await messageTextarea.inputValue();
    expect(value.length).toBe(500);

    // Verify character counter
    await expect(charCount).toHaveText('500 / 500');
  });

  test('should clear form on reset', async ({ page }) => {
    // Fill form fields
    await page.locator('[data-testid="name-input"]').fill('John Doe');
    await page.locator('[data-testid="email-input"]').fill('john@example.com');
    await page.locator('[data-testid="message-textarea"]').fill('Test message');

    // Click reset button
    await page.locator('[data-testid="reset-button"]').click();

    // Verify all fields are cleared
    await expect(page.locator('[data-testid="name-input"]')).toHaveValue('');
    await expect(page.locator('[data-testid="email-input"]')).toHaveValue('');
    await expect(page.locator('[data-testid="message-textarea"]')).toHaveValue('');
  });
});

test.describe('Multi-Step Registration Form', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/register');
  });

  test('should complete multi-step registration', async ({ page }) => {
    // Step 1: Personal Information
    await expect(page.locator('[data-testid="step-indicator"]')).toHaveText('Step 1 of 3');
    await page.locator('[data-testid="first-name"]').fill('John');
    await page.locator('[data-testid="last-name"]').fill('Doe');
    await page.locator('[data-testid="date-of-birth"]').fill('1990-01-01');
    await page.locator('[data-testid="next-button"]').click();

    // Step 2: Account Details
    await expect(page.locator('[data-testid="step-indicator"]')).toHaveText('Step 2 of 3');
    await page.locator('[data-testid="username"]').fill('johndoe');
    await page.locator('[data-testid="email"]').fill('john@example.com');
    await page.locator('[data-testid="password"]').fill('SecurePassword123!');
    await page.locator('[data-testid="confirm-password"]').fill('SecurePassword123!');
    await page.locator('[data-testid="next-button"]').click();

    // Step 3: Preferences
    await expect(page.locator('[data-testid="step-indicator"]')).toHaveText('Step 3 of 3');
    await page.locator('[data-testid="newsletter-checkbox"]').check();
    await page.locator('[data-testid="terms-checkbox"]').check();
    await page.locator('[data-testid="submit-button"]').click();

    // Verify registration success
    await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
    await page.waitForURL('**/welcome');
  });

  test('should allow navigation between steps', async ({ page }) => {
    // Complete step 1
    await page.locator('[data-testid="first-name"]').fill('John');
    await page.locator('[data-testid="last-name"]').fill('Doe');
    await page.locator('[data-testid="date-of-birth"]').fill('1990-01-01');
    await page.locator('[data-testid="next-button"]').click();

    // Go to step 2
    await expect(page.locator('[data-testid="step-indicator"]')).toHaveText('Step 2 of 3');

    // Go back to step 1
    await page.locator('[data-testid="back-button"]').click();
    await expect(page.locator('[data-testid="step-indicator"]')).toHaveText('Step 1 of 3');

    // Verify data is preserved
    await expect(page.locator('[data-testid="first-name"]')).toHaveValue('John');
    await expect(page.locator('[data-testid="last-name"]')).toHaveValue('Doe');
  });

  test('should validate password strength', async ({ page }) => {
    // Navigate to step 2
    await page.locator('[data-testid="first-name"]').fill('John');
    await page.locator('[data-testid="last-name"]').fill('Doe');
    await page.locator('[data-testid="date-of-birth"]').fill('1990-01-01');
    await page.locator('[data-testid="next-button"]').click();

    const passwordInput = page.locator('[data-testid="password"]');
    const strengthIndicator = page.locator('[data-testid="password-strength"]');

    // Test weak password
    await passwordInput.fill('weak');
    await expect(strengthIndicator).toHaveText('Weak');
    await expect(strengthIndicator).toHaveClass(/weak/);

    // Test medium password
    await passwordInput.fill('Medium123');
    await expect(strengthIndicator).toHaveText('Medium');
    await expect(strengthIndicator).toHaveClass(/medium/);

    // Test strong password
    await passwordInput.fill('Strong123!@#');
    await expect(strengthIndicator).toHaveText('Strong');
    await expect(strengthIndicator).toHaveClass(/strong/);
  });
});

test.describe('File Upload Form', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/upload');
  });

  test('should upload single file', async ({ page }) => {
    const fileInput = page.locator('[data-testid="file-input"]');

    // Upload file
    await fileInput.setInputFiles({
      name: 'test.txt',
      mimeType: 'text/plain',
      buffer: Buffer.from('Test file content'),
    });

    // Verify file name is displayed
    await expect(page.locator('[data-testid="file-name"]')).toHaveText('test.txt');

    // Submit upload
    await page.locator('[data-testid="upload-button"]').click();

    // Verify success
    await expect(page.locator('[data-testid="upload-success"]')).toBeVisible();
  });

  test('should upload multiple files', async ({ page }) => {
    const fileInput = page.locator('[data-testid="multiple-file-input"]');

    // Upload multiple files
    await fileInput.setInputFiles([
      { name: 'file1.txt', mimeType: 'text/plain', buffer: Buffer.from('File 1') },
      { name: 'file2.txt', mimeType: 'text/plain', buffer: Buffer.from('File 2') },
      { name: 'file3.txt', mimeType: 'text/plain', buffer: Buffer.from('File 3') },
    ]);

    // Verify all files are listed
    await expect(page.locator('[data-testid="file-list"] li')).toHaveCount(3);

    // Submit upload
    await page.locator('[data-testid="upload-button"]').click();

    // Verify success
    await expect(page.locator('[data-testid="upload-success"]')).toContainText('3 files uploaded');
  });

  test('should validate file type', async ({ page }) => {
    const fileInput = page.locator('[data-testid="file-input"]');

    // Try to upload invalid file type
    await fileInput.setInputFiles({
      name: 'invalid.exe',
      mimeType: 'application/x-msdownload',
      buffer: Buffer.from('Invalid file'),
    });

    // Verify error message
    await expect(page.locator('[data-testid="file-error"]')).toContainText('Invalid file type');
  });

  test('should validate file size', async ({ page }) => {
    const fileInput = page.locator('[data-testid="file-input"]');

    // Create large file (over 5MB)
    const largeBuffer = Buffer.alloc(6 * 1024 * 1024);

    await fileInput.setInputFiles({
      name: 'large.txt',
      mimeType: 'text/plain',
      buffer: largeBuffer,
    });

    // Verify error message
    await expect(page.locator('[data-testid="file-error"]')).toContainText('File too large');
  });
});

test.describe('Dynamic Form Fields', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/dynamic-form');
  });

  test('should show/hide fields based on selection', async ({ page }) => {
    const typeSelect = page.locator('[data-testid="contact-type"]');
    const phoneField = page.locator('[data-testid="phone-number"]');
    const companyField = page.locator('[data-testid="company-name"]');

    // Select "Personal" - company should be hidden
    await typeSelect.selectOption('personal');
    await expect(phoneField).toBeVisible();
    await expect(companyField).not.toBeVisible();

    // Select "Business" - company should be visible
    await typeSelect.selectOption('business');
    await expect(phoneField).toBeVisible();
    await expect(companyField).toBeVisible();
  });

  test('should add and remove dynamic field groups', async ({ page }) => {
    const addButton = page.locator('[data-testid="add-address"]');
    const addressFields = page.locator('[data-testid^="address-group-"]');

    // Initially should have one address group
    await expect(addressFields).toHaveCount(1);

    // Add two more address groups
    await addButton.click();
    await addButton.click();
    await expect(addressFields).toHaveCount(3);

    // Remove second address group
    await page.locator('[data-testid="remove-address-1"]').click();
    await expect(addressFields).toHaveCount(2);
  });
});
