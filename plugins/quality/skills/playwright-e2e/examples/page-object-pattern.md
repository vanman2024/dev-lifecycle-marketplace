# Page Object Pattern - Playwright E2E Testing

The Page Object Model (POM) is a design pattern that creates an abstraction layer between tests and page interactions, making tests more maintainable and readable.

## Why Use Page Object Pattern?

### Without POM (Hard to Maintain)

```typescript
// login.spec.ts
test('login test', async ({ page }) => {
  await page.goto('/login');
  await page.locator('[data-testid="email"]').fill('user@example.com');
  await page.locator('[data-testid="password"]').fill('password123');
  await page.locator('[data-testid="submit"]').click();
  await expect(page.locator('[data-testid="welcome"]')).toBeVisible();
});

// profile.spec.ts - duplicate code!
test('profile test', async ({ page }) => {
  await page.goto('/login');
  await page.locator('[data-testid="email"]').fill('user@example.com');
  await page.locator('[data-testid="password"]').fill('password123');
  await page.locator('[data-testid="submit"]').click();
  // ... more test code
});
```

### With POM (Easy to Maintain)

```typescript
// login.page.ts
class LoginPage {
  constructor(private page) {}

  async login(email, password) {
    await this.page.goto('/login');
    await this.page.locator('[data-testid="email"]').fill(email);
    await this.page.locator('[data-testid="password"]').fill(password);
    await this.page.locator('[data-testid="submit"]').click();
  }
}

// Tests become simple and readable
test('login test', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.login('user@example.com', 'password123');
  await expect(page.locator('[data-testid="welcome"]')).toBeVisible();
});
```

## Generating Page Objects

Use the skill's script to generate a page object:

```bash
bash scripts/generate-pom.sh LoginPage https://example.com/login tests/page-objects
```

This creates `tests/page-objects/login-page.page.ts` with a basic structure.

## Page Object Structure

### Basic Page Object

```typescript
// tests/page-objects/login.page.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;

  // Locators - define all selectors here
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;

    // Initialize locators in constructor
    this.emailInput = page.locator('[data-testid="email"]');
    this.passwordInput = page.locator('[data-testid="password"]');
    this.submitButton = page.locator('[data-testid="submit"]');
    this.errorMessage = page.locator('[data-testid="error"]');
  }

  // Navigation methods
  async goto() {
    await this.page.goto('/login');
  }

  // Action methods
  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  // Getter methods
  async getErrorMessage() {
    return await this.errorMessage.textContent();
  }

  // Verification methods
  async hasError() {
    return await this.errorMessage.isVisible();
  }
}
```

### Using the Page Object

```typescript
// tests/e2e/login.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../page-objects/login.page';

test.describe('Login', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.goto();
  });

  test('successful login', async ({ page }) => {
    await loginPage.login('user@example.com', 'password123');
    await expect(page).toHaveURL('/dashboard');
  });

  test('invalid credentials', async () => {
    await loginPage.login('wrong@example.com', 'wrong');
    expect(await loginPage.hasError()).toBe(true);
    expect(await loginPage.getErrorMessage()).toContain('Invalid');
  });
});
```

## Advanced Patterns

### 1. Component Composition

Break down complex pages into reusable components:

```typescript
// components/header.component.ts
export class HeaderComponent {
  readonly page: Page;
  readonly logo: Locator;
  readonly searchInput: Locator;
  readonly userMenu: Locator;

  constructor(page: Page) {
    this.page = page;
    this.logo = page.locator('[data-testid="logo"]');
    this.searchInput = page.locator('[data-testid="search"]');
    this.userMenu = page.locator('[data-testid="user-menu"]');
  }

  async search(query: string) {
    await this.searchInput.fill(query);
    await this.searchInput.press('Enter');
  }

  async openUserMenu() {
    await this.userMenu.click();
  }
}

// pages/dashboard.page.ts
import { HeaderComponent } from '../components/header.component';

export class DashboardPage {
  readonly page: Page;
  readonly header: HeaderComponent;

  constructor(page: Page) {
    this.page = page;
    this.header = new HeaderComponent(page);
  }

  async searchProducts(query: string) {
    await this.header.search(query);
  }
}
```

### 2. Dynamic Locators

Handle dynamic elements with methods:

```typescript
export class ProductListPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // Dynamic locator method
  productCard(productId: string) {
    return this.page.locator(`[data-product-id="${productId}"]`);
  }

  productAddButton(productId: string) {
    return this.productCard(productId).locator('[data-testid="add-to-cart"]');
  }

  // Use dynamic locators
  async addProductToCart(productId: string) {
    await this.productAddButton(productId).click();
  }

  async getProductPrice(productId: string) {
    return await this.productCard(productId)
      .locator('.price')
      .textContent();
  }
}
```

### 3. Page Inheritance

Share common functionality across pages:

```typescript
// pages/base.page.ts
export class BasePage {
  readonly page: Page;
  readonly header: HeaderComponent;
  readonly footer: FooterComponent;

  constructor(page: Page) {
    this.page = page;
    this.header = new HeaderComponent(page);
    this.footer = new FooterComponent(page);
  }

  async waitForPageLoad() {
    await this.page.waitForLoadState('networkidle');
  }

  async takeScreenshot(name: string) {
    await this.page.screenshot({ path: `screenshots/${name}.png` });
  }
}

// pages/products.page.ts
export class ProductsPage extends BasePage {
  readonly productList: Locator;
  readonly filterButton: Locator;

  constructor(page: Page) {
    super(page);
    this.productList = page.locator('[data-testid="product-list"]');
    this.filterButton = page.locator('[data-testid="filter"]');
  }

  async goto() {
    await this.page.goto('/products');
    await this.waitForPageLoad();
  }
}
```

### 4. Fluent Interface

Chain methods for readable tests:

```typescript
export class CheckoutPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async fillShippingAddress(address: Address) {
    await this.page.locator('[name="street"]').fill(address.street);
    await this.page.locator('[name="city"]').fill(address.city);
    await this.page.locator('[name="zip"]').fill(address.zip);
    return this; // Return this for chaining
  }

  async selectShippingMethod(method: string) {
    await this.page.locator(`[data-shipping="${method}"]`).click();
    return this;
  }

  async fillPaymentInfo(payment: PaymentInfo) {
    await this.page.locator('[name="cardNumber"]').fill(payment.cardNumber);
    await this.page.locator('[name="cvv"]').fill(payment.cvv);
    return this;
  }

  async placeOrder() {
    await this.page.locator('[data-testid="place-order"]').click();
  }
}

// Usage with fluent interface
test('complete checkout', async ({ page }) => {
  const checkout = new CheckoutPage(page);

  await checkout
    .fillShippingAddress({ street: '123 Main St', city: 'NYC', zip: '10001' })
    .then(p => p.selectShippingMethod('express'))
    .then(p => p.fillPaymentInfo({ cardNumber: '4111...', cvv: '123' }))
    .then(p => p.placeOrder());

  await expect(page.locator('[data-testid="order-success"]')).toBeVisible();
});
```

### 5. Custom Assertions

Add domain-specific assertions to page objects:

```typescript
export class DashboardPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // Custom assertion methods
  async assertUserLoggedIn(email: string) {
    await expect(this.page.locator('[data-testid="user-email"]'))
      .toHaveText(email);
    await expect(this.page.locator('[data-testid="logout-btn"]'))
      .toBeVisible();
  }

  async assertWelcomeMessageShown() {
    await expect(this.page.locator('[data-testid="welcome-message"]'))
      .toBeVisible();
    await expect(this.page.locator('[data-testid="welcome-message"]'))
      .toContainText('Welcome back');
  }

  async assertNotificationsCount(count: number) {
    const badge = this.page.locator('[data-testid="notification-badge"]');
    await expect(badge).toHaveText(count.toString());
  }
}
```

## Directory Structure

Organize page objects clearly:

```
tests/
├── page-objects/
│   ├── auth/
│   │   ├── login.page.ts
│   │   └── register.page.ts
│   ├── dashboard/
│   │   ├── dashboard.page.ts
│   │   └── settings.page.ts
│   ├── products/
│   │   ├── product-list.page.ts
│   │   └── product-detail.page.ts
│   ├── components/
│   │   ├── header.component.ts
│   │   ├── footer.component.ts
│   │   └── modal.component.ts
│   └── base.page.ts
├── e2e/
│   ├── auth/
│   │   └── login.spec.ts
│   ├── dashboard/
│   │   └── dashboard.spec.ts
│   └── products/
│       └── products.spec.ts
└── fixtures/
    └── user.fixture.ts
```

## Best Practices

### 1. One Page Object Per Page

Create separate page objects for different pages or major sections.

### 2. Initialize Locators in Constructor

Define all locators in the constructor, not in methods.

```typescript
// Good
constructor(page: Page) {
  this.page = page;
  this.button = page.locator('button');
}

// Bad
async clickButton() {
  await this.page.locator('button').click(); // Locator defined in method
}
```

### 3. Keep Page Objects Framework-Agnostic

Don't put assertions in page objects:

```typescript
// Good - returns data
async getTitle() {
  return await this.titleElement.textContent();
}

// Bad - includes assertion
async verifyTitle(expected: string) {
  await expect(this.titleElement).toHaveText(expected);
}
```

### 4. Use Descriptive Method Names

Method names should describe actions or queries:

```typescript
// Good
async clickSubmitButton()
async fillLoginForm(email, password)
async isErrorVisible()
async getWelcomeMessage()

// Bad
async doStuff()
async click()
async check()
```

### 5. Group Related Actions

Combine related actions into single methods:

```typescript
// Instead of multiple small methods
async fillEmail(email: string) { ... }
async fillPassword(password: string) { ... }
async clickSubmit() { ... }

// Use one method for the workflow
async login(email: string, password: string) {
  await this.emailInput.fill(email);
  await this.passwordInput.fill(password);
  await this.submitButton.click();
}
```

## Testing Page Objects

Page objects themselves can be tested:

```typescript
test.describe('LoginPage', () => {
  test('should navigate to login page', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    expect(page.url()).toContain('/login');
    await expect(loginPage.emailInput).toBeVisible();
  });

  test('should display error for invalid email', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('invalid', 'password');

    expect(await loginPage.hasError()).toBe(true);
  });
});
```

## Common Pitfalls

### 1. Over-Abstraction

Don't create page objects for simple pages:

```typescript
// Too much abstraction for a simple page
class SimplePage {
  async clickTheOnlyButton() {
    await this.page.locator('button').click();
  }
}

// Just use direct interaction
test('simple test', async ({ page }) => {
  await page.locator('button').click();
});
```

### 2. Tight Coupling

Avoid coupling page objects too tightly:

```typescript
// Bad - tightly coupled
async loginAndGoToDashboard() {
  await this.login();
  const dashboard = new DashboardPage(this.page);
  return dashboard;
}

// Good - keep separate
async login() {
  // just login
}
```

### 3. Missing Waits

Always wait for elements when needed:

```typescript
// Bad - no waiting
async getModalText() {
  return await this.modal.textContent();
}

// Good - wait for visibility
async getModalText() {
  await this.modal.waitFor({ state: 'visible' });
  return await this.modal.textContent();
}
```

## Resources

- [Playwright POM Guide](https://playwright.dev/docs/pom)
- [Page Object Pattern Examples](https://github.com/microsoft/playwright/tree/main/examples)
- [Template: page-object-basic.ts](../templates/page-object-basic.ts)
- [Template: page-object-advanced.ts](../templates/page-object-advanced.ts)
