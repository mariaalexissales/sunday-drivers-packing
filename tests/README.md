# Pack Rat Mod - Test Suite

This directory contains the unit test suite for the Pack Rat Project Zomboid mod, designed to work with Lua 5.1 (the version supported by Project Zomboid).

## Test Structure

```
tests/
├── test_framework.lua      # Custom testing framework for Lua 5.1
├── mocks.lua              # Mock objects for Project Zomboid environment
├── test_simple_functions.lua       # Tests for simple_functions.lua
├── test_simple_book_packing.lua   # Tests for simple_book_packing.lua
├── test_simple_fuel.lua           # Tests for simple_fuel.lua
├── run_tests.lua          # Test runner script
└── README.md             # This file
```

## Running Tests Locally

### Prerequisites

- Lua 5.1 installed on your system
- Access to the Pack Rat mod source code

### Windows

```batch
# Install Lua 5.1 (using chocolatey)
choco install lua51

# Navigate to tests directory
cd tests

# Run all tests
lua5.1 run_tests.lua

# Or run individual test files
lua5.1 test_simple_functions.lua
lua5.1 test_simple_book_packing.lua
lua5.1 test_simple_fuel.lua
```

### Linux/macOS

```bash
# Install Lua 5.1 (Ubuntu/Debian)
sudo apt-get install lua5.1

# Navigate to tests directory
cd tests

# Run all tests
lua5.1 run_tests.lua

# Or run individual test files
lua5.1 test_simple_functions.lua
lua5.1 test_simple_book_packing.lua
lua5.1 test_simple_fuel.lua
```

## GitHub Actions CI/CD

The project includes two GitHub Actions workflows:

### 1. Basic Test Workflow (`.github/workflows/test.yml`)

- Runs on branches starting with `test-` or in the `test/` namespace
- Executes all unit tests
- Uploads test artifacts

### 2. Comprehensive Test Workflow (`.github/workflows/comprehensive-test.yml`)

- More thorough validation including syntax checking
- Integration tests
- Test status notifications
- Runs on branches matching `test*`, `test-*`, or `test/**`

### Trigger Conditions

Tests automatically run when you:

- Push to any branch starting with `test-`
- Push to any branch starting with `test`
- Create a pull request targeting test branches

Example branch names that trigger tests:

- `test-new-feature`
- `test-bugfix`
- `test/experimental`
- `testing-branch`

## Test Framework Features

### Assertions Available

```lua
local test = TestFramework.new()

-- Basic assertions
test:assert_equals(actual, expected, message)
test:assert_true(value, message)
test:assert_false(value, message)
test:assert_nil(value, message)
test:assert_not_nil(value, message)
test:assert_type(value, expected_type, message)
```

### Writing New Tests

```lua
local TestFramework = require("test_framework")
local Mocks = require("mocks")

-- Setup mocks
Mocks.setup()

-- Load your module
require("your_module")

local test = TestFramework.new()

test:test("Your test name", function()
    -- Your test code here
    test:assert_equals(actual, expected, "Custom error message")
end)

-- Run tests
test:run()
```

## Mock Objects

The `mocks.lua` file provides mock implementations of Project Zomboid objects:

- `MockInventoryItem` - Simulates game items
- `MockDrainableComboItem` - Simulates drainable items (extends InventoryItem)
- `MockItemContainer` - Simulates item containers
- `MockArrayList` - Simulates Java ArrayList (used in PZ)
- `MockInventory` - Simulates player inventory
- `MockPlayer` - Simulates game player
- `MockRecipe` - Simulates crafting recipes

## Test Coverage

Current test coverage includes:

### simple_functions.lua

- ✅ Utility functions (AMSI, recipe_opencigpack)
- ✅ Recipe OnTest functions (IsFavorite, WholeFood, WholeItem, IsEmpty, etc.)
- ✅ Save/Load functions (SaveUses, LoadUses, SaveFood, LoadFood)
- ✅ Unpack functions (rope, container unpacking)
- ✅ Merge/Split functions

### simple_book_packing.lua

- ✅ All skill book unpacking functions
- ✅ Verification of correct book types and quantities

### simple_fuel.lua

- ✅ Fuel type definitions
- ✅ Value consistency across material types
- ✅ Proper fuel value scaling

## Continuous Integration

### Branch Naming Convention

To trigger automated testing, create branches with names starting with `test`:

```bash
# Good branch names (will trigger tests)
git checkout -b test-new-packing-feature
git checkout -b test-bugfix-inventory
git checkout -b test/experimental-recipes

# These won't trigger tests
git checkout -b feature-new-items
git checkout -b bugfix-typo
```

### Viewing Test Results

1. Push your test branch to GitHub
2. Go to the "Actions" tab in your repository
3. Find your workflow run
4. Click on it to see detailed test results
5. Download test artifacts if needed

## Troubleshooting

### Common Issues

1. **Lua version mismatch**: Ensure you're using Lua 5.1, not a newer version
2. **Path issues**: Make sure you're running tests from the `tests/` directory
3. **Missing files**: Verify all test files are present and have correct permissions

### Debug Mode

To add debug output to your tests:

```lua
-- Add debug prints
print("[DEBUG] Testing function X with input Y")

-- Use assert messages
test:assert_equals(actual, expected, "Expected X but got Y in function Z")
```

## Contributing

When adding new functionality:

1. Create a test branch: `git checkout -b test-your-feature`
2. Write tests for your new code
3. Ensure all tests pass locally
4. Push the branch to trigger CI/CD
5. Create a pull request once tests pass

## License

This test suite is part of the Pack Rat mod and follows the same license terms.
