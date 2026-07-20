# Playwright UI Tests for SHPH Flutter Web

## Setup (already done)

```bash
cd playwright
npm install
npx playwright install chromium
```

## Running Tests

### Step 1: Start the Flutter Web Server

```bash
flutter run -d chrome --web-port=8080
```

Or use a specific Chrome browser:

```bash
flutter run -d web-server --web-port=8080
```

### Step 2: Run Playwright Tests

```bash
# Headless (fast, CI-friendly)
npx playwright test

# Headed (see the browser)
npx playwright test --headed

# UI mode (interactive, best for development)
npx playwright test --ui

# Debug mode (step-by-step with inspector)
npx playwright test --debug

# Generate code from browser actions
npx playwright codegen http://localhost:8080
```

### Step 3: View Test Report

```bash
npx playwright show-report
```

## Test Files

- `tests/smoke.spec.ts` — Smoke tests for app boot + new routes (Phases 1e, 4, 5)

## Screenshots

Tests automatically capture screenshots to `screenshots/` directory for visual verification.
