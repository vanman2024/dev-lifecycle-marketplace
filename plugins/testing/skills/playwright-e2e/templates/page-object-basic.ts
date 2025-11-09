import { Page, Locator } from '@playwright/test';

/**
 * Basic Page Object Model Template
 *
 * A simple page object that demonstrates the fundamental POM pattern.
 * Use this template for straightforward pages with basic interactions.
 */
export class BasicPage {
  readonly page: Page;

  // Locators - define all element selectors here
  readonly heading: Locator;
  readonly submitButton: Locator;
  readonly inputField: Locator;
  readonly errorMessage: Locator;
  readonly successMessage: Locator;

  constructor(page: Page) {
    this.page = page;

    // Initialize locators using data-testid (preferred) or other selectors
    this.heading = page.locator('h1');
    this.submitButton = page.locator('[data-testid="submit-button"]');
    this.inputField = page.locator('[data-testid="input-field"]');
    this.errorMessage = page.locator('.error-message');
    this.successMessage = page.locator('.success-message');
  }

  /**
   * Navigate to the page
   */
  async goto(): Promise<void> {
    await this.page.goto('/basic-page');
  }

  /**
   * Wait for page to be fully loaded
   */
  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
    await this.heading.waitFor({ state: 'visible' });
  }

  /**
   * Fill input field with provided text
   */
  async fillInput(text: string): Promise<void> {
    await this.inputField.fill(text);
  }

  /**
   * Click the submit button
   */
  async submit(): Promise<void> {
    await this.submitButton.click();
  }

  /**
   * Get error message text
   */
  async getErrorMessage(): Promise<string> {
    await this.errorMessage.waitFor({ state: 'visible' });
    return await this.errorMessage.textContent() ?? '';
  }

  /**
   * Get success message text
   */
  async getSuccessMessage(): Promise<string> {
    await this.successMessage.waitFor({ state: 'visible' });
    return await this.successMessage.textContent() ?? '';
  }

  /**
   * Check if error message is visible
   */
  async hasError(): Promise<boolean> {
    return await this.errorMessage.isVisible();
  }

  /**
   * Check if success message is visible
   */
  async hasSuccess(): Promise<boolean> {
    return await this.successMessage.isVisible();
  }

  /**
   * Complete the entire form submission workflow
   */
  async submitForm(text: string): Promise<void> {
    await this.fillInput(text);
    await this.submit();
  }
}
