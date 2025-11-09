#!/bin/bash
# generate-pom.sh - Generate Page Object Model classes
set -euo pipefail

# Arguments
PAGE_NAME="${1:-}"
PAGE_URL="${2:-}"
OUTPUT_DIR="${3:-tests/page-objects}"

if [ -z "$PAGE_NAME" ]; then
    echo "❌ Error: Page name required"
    echo "Usage: $0 <page-name> <url> [output-dir]"
    echo "Example: $0 LoginPage https://example.com/login"
    exit 1
fi

if [ -z "$PAGE_URL" ]; then
    echo "❌ Error: URL required"
    echo "Usage: $0 <page-name> <url> [output-dir]"
    exit 1
fi

echo "🎭 Generating Page Object Model: $PAGE_NAME..."

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Convert page name to various formats
PAGE_CLASS_NAME=$(echo "$PAGE_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1' | sed 's/ //g')
PAGE_FILE_NAME=$(echo "$PAGE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

OUTPUT_FILE="$OUTPUT_DIR/${PAGE_FILE_NAME}.page.ts"

# Check if file already exists
if [ -f "$OUTPUT_FILE" ]; then
    echo "⚠️ Warning: $OUTPUT_FILE already exists"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled"
        exit 1
    fi
fi

# Generate Page Object Model
cat > "$OUTPUT_FILE" << EOF
import { Page, Locator } from '@playwright/test';

/**
 * Page Object Model for $PAGE_CLASS_NAME
 * URL: $PAGE_URL
 */
export class ${PAGE_CLASS_NAME}Page {
  readonly page: Page;

  // Locators
  // TODO: Add your page-specific locators here
  // Example:
  // readonly submitButton: Locator;
  // readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;

    // Initialize locators
    // Example:
    // this.submitButton = page.locator('[data-testid="submit-button"]');
    // this.errorMessage = page.locator('.error-message');
  }

  /**
   * Navigate to the page
   */
  async goto(): Promise<void> {
    await this.page.goto('$PAGE_URL');
  }

  /**
   * Wait for page to be loaded
   */
  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
  }

  // TODO: Add your page-specific methods here
  // Example:
  // async clickSubmit(): Promise<void> {
  //   await this.submitButton.click();
  // }
  //
  // async getErrorMessage(): Promise<string> {
  //   return await this.errorMessage.textContent() ?? '';
  // }
}
EOF

echo "✅ Page Object Model generated: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "  1. Add locators for page elements"
echo "  2. Implement interaction methods"
echo "  3. Import and use in your tests:"
echo ""
echo "     import { ${PAGE_CLASS_NAME}Page } from './${PAGE_FILE_NAME}.page';"
echo "     const page = new ${PAGE_CLASS_NAME}Page(page);"
echo ""
