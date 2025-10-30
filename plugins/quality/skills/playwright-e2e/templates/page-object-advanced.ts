import { Page, Locator, expect } from '@playwright/test';

/**
 * Advanced Page Object Model Template
 *
 * Demonstrates advanced POM patterns including:
 * - Complex waiting strategies
 * - Dynamic element handling
 * - Component composition
 * - Custom assertions
 * - Error handling
 */
export class AdvancedPage {
  readonly page: Page;

  // Main page elements
  readonly header: HeaderComponent;
  readonly sidebar: SidebarComponent;
  readonly mainContent: Locator;
  readonly loadingSpinner: Locator;
  readonly errorBanner: Locator;

  // Dynamic elements
  private readonly dynamicListItem = (id: string) =>
    this.page.locator(`[data-testid="item-${id}"]`);

  private readonly dynamicButton = (action: string) =>
    this.page.locator(`button[data-action="${action}"]`);

  constructor(page: Page) {
    this.page = page;

    // Initialize components
    this.header = new HeaderComponent(page);
    this.sidebar = new SidebarComponent(page);

    // Initialize locators
    this.mainContent = page.locator('main');
    this.loadingSpinner = page.locator('[data-testid="loading-spinner"]');
    this.errorBanner = page.locator('[data-testid="error-banner"]');
  }

  /**
   * Navigate to the page with optional query parameters
   */
  async goto(params?: Record<string, string>): Promise<void> {
    const url = params
      ? `/advanced-page?${new URLSearchParams(params).toString()}`
      : '/advanced-page';
    await this.page.goto(url);
    await this.waitForPageReady();
  }

  /**
   * Advanced waiting strategy - wait for multiple conditions
   */
  async waitForPageReady(): Promise<void> {
    // Wait for network to be idle
    await this.page.waitForLoadState('networkidle');

    // Wait for critical elements
    await this.mainContent.waitFor({ state: 'visible' });

    // Wait for loading spinner to disappear
    await this.waitForLoadingComplete();

    // Wait for any pending animations
    await this.page.waitForTimeout(100);
  }

  /**
   * Wait for loading spinner to disappear
   */
  async waitForLoadingComplete(timeout = 10000): Promise<void> {
    try {
      await this.loadingSpinner.waitFor({ state: 'hidden', timeout });
    } catch (error) {
      // Loading spinner might not appear for fast operations
      console.log('Loading spinner not found or already hidden');
    }
  }

  /**
   * Handle dynamic list items
   */
  async clickListItem(id: string): Promise<void> {
    const item = this.dynamicListItem(id);
    await item.waitFor({ state: 'visible' });
    await item.click();
  }

  /**
   * Get text from dynamic list item
   */
  async getListItemText(id: string): Promise<string> {
    const item = this.dynamicListItem(id);
    return await item.textContent() ?? '';
  }

  /**
   * Check if list item exists
   */
  async hasListItem(id: string): Promise<boolean> {
    const item = this.dynamicListItem(id);
    return await item.isVisible();
  }

  /**
   * Click dynamic button by action name
   */
  async clickAction(action: string): Promise<void> {
    const button = this.dynamicButton(action);
    await button.waitFor({ state: 'visible' });
    await button.click();
  }

  /**
   * Wait for specific action button to be enabled
   */
  async waitForActionEnabled(action: string, timeout = 5000): Promise<void> {
    const button = this.dynamicButton(action);
    await button.waitFor({ state: 'visible', timeout });
    await expect(button).toBeEnabled({ timeout });
  }

  /**
   * Handle error banner
   */
  async getErrorMessage(): Promise<string | null> {
    if (await this.errorBanner.isVisible()) {
      return await this.errorBanner.textContent();
    }
    return null;
  }

  /**
   * Dismiss error banner if visible
   */
  async dismissError(): Promise<void> {
    if (await this.errorBanner.isVisible()) {
      const closeButton = this.errorBanner.locator('[data-testid="close-error"]');
      await closeButton.click();
      await this.errorBanner.waitFor({ state: 'hidden' });
    }
  }

  /**
   * Custom assertion - verify page state
   */
  async assertPageLoaded(): Promise<void> {
    await expect(this.mainContent).toBeVisible();
    await expect(this.loadingSpinner).toBeHidden();
  }

  /**
   * Scroll element into view
   */
  async scrollToItem(id: string): Promise<void> {
    const item = this.dynamicListItem(id);
    await item.scrollIntoViewIfNeeded();
  }

  /**
   * Take screenshot of specific element
   */
  async screenshotElement(selector: string, name: string): Promise<void> {
    const element = this.page.locator(selector);
    await element.screenshot({ path: `test-results/${name}.png` });
  }
}

/**
 * Header Component - reusable component pattern
 */
class HeaderComponent {
  readonly page: Page;
  readonly logo: Locator;
  readonly navigation: Locator;
  readonly userMenu: Locator;
  readonly searchInput: Locator;

  constructor(page: Page) {
    this.page = page;
    this.logo = page.locator('header [data-testid="logo"]');
    this.navigation = page.locator('header nav');
    this.userMenu = page.locator('[data-testid="user-menu"]');
    this.searchInput = page.locator('[data-testid="search-input"]');
  }

  async clickLogo(): Promise<void> {
    await this.logo.click();
  }

  async navigateTo(section: string): Promise<void> {
    await this.navigation.locator(`a[href*="${section}"]`).click();
  }

  async search(query: string): Promise<void> {
    await this.searchInput.fill(query);
    await this.searchInput.press('Enter');
  }

  async openUserMenu(): Promise<void> {
    await this.userMenu.click();
  }
}

/**
 * Sidebar Component - another reusable component
 */
class SidebarComponent {
  readonly page: Page;
  readonly container: Locator;
  readonly menuItems: Locator;

  constructor(page: Page) {
    this.page = page;
    this.container = page.locator('[data-testid="sidebar"]');
    this.menuItems = this.container.locator('.menu-item');
  }

  async selectMenuItem(text: string): Promise<void> {
    await this.menuItems.filter({ hasText: text }).click();
  }

  async isExpanded(): Promise<boolean> {
    return await this.container.getAttribute('data-expanded') === 'true';
  }

  async toggle(): Promise<void> {
    const toggleButton = this.container.locator('[data-testid="toggle-sidebar"]');
    await toggleButton.click();
  }
}
