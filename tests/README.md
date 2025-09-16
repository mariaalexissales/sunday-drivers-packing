# Simple Packing - Unit Tests

This directory contains comprehensive unit tests for the Simple Packing mod's `simple_functions.lua` file, designed to be compatible with Project Zomboid Build 41's Lua 5.1 environment.

## Overview

The test suite covers all functions in `simple_functions.lua`:

- **Utility Functions**: `AMSI`, `recipe_opencigpack`, `getNeededForResult`
- **Recipe OnTest Functions**: `IsFavorite`, `FullAndNotTainted`, `WholeFood`, `WholeItem`, `IsEmpty`
- **Recipe OnCanPerform Functions**: `HasEnoughEmpties`
- **Save/Load Functions**: `SaveUses`, `LoadUses`, `SaveFood`, `LoadFood`
- **Rope and Container Functions**: Various unpack and load combinations
- **Splitting/Merging Functions**: `MergeUses`, `SplitUsesInTwo`

## Test Files

- `mocks.lua` - Mock objects for Project Zomboid API (Item, Player, Inventory, etc.)
- `test_simple_functions.lua` - Tests for core utility and recipe functions
- `test_food_functions.lua` - Tests for food packing and unpacking
- `test_rope_container_functions.lua` - Tests for rope and container handling
- `test_merge_split_functions.lua` - Tests for merge and split operations
- `run_tests.lua` - Main test runner that executes all test suites

## Requirements

### Local Development

1. **Lua 5.1+** (Project Zomboid B41 uses Lua 5.1)
2. **LuaRocks** (package manager)
3. **LuaUnit** testing framework

#### Installation

```bash
# Install Lua and LuaRocks (example for Ubuntu/Debian)
sudo apt-get install lua5.1 luarocks

# Install LuaUnit testing framework
luarocks install luaunit

# Optional: Install luacheck for linting
luarocks install luacheck
```

### Windows Installation

```cmd
# Install Lua for Windows or use Chocolatey
choco install lua

# Install LuaRocks
# Download from https://luarocks.org/

# Install LuaUnit
luarocks install luaunit
```

## Running Tests

### Run All Tests

```bash
# From the project root directory
lua tests/run_tests.lua
```

### Run Individual Test Suites

```bash
# Run specific test file
lua tests/test_simple_functions.lua
lua tests/test_food_functions.lua
lua tests/test_rope_container_functions.lua
lua tests/test_merge_split_functions.lua
```

### With Verbose Output

```bash
# Run with detailed output
LUA_PATH="./?.lua;./?/init.lua" lua tests/run_tests.lua
```

## GitHub Actions

The project includes a comprehensive GitHub Actions workflow (`.github/workflows/lua-tests.yml`) that:

1. **Tests across multiple Lua versions** (5.1, 5.2, 5.3, 5.4)
2. **Runs linting** with luacheck
3. **Generates coverage reports** (if luacov is available)
4. **Performs security scanning** for potential issues
5. **Triggers on**:
   - Push to main, develop, or vanilla-recipe-fixes branches
   - Pull requests to main or develop
   - Changes to Lua files or test files

## Test Structure

### Mock Objects

The test suite uses comprehensive mock objects that simulate the Project Zomboid API:

```lua
local mocks = require('tests.mocks')

-- Create mock objects
local mockPlayer = mocks.MockPlayer:new()
local mockItem = mocks.MockItem:new("Base.TestItem", "Test Item")
local mockInventory = mockPlayer:getInventory()
```

### Test Patterns

Each test follows the pattern:

```lua
function TestClass:testFunctionName()
    -- Setup
    local mockData = self:createMockData()

    -- Execute
    local result = functionUnderTest(mockData)

    -- Assert
    luaunit.assertEquals(result, expectedValue)
end
```

### Coverage

The tests cover:

- ✅ **Happy path scenarios** - Normal operation
- ✅ **Edge cases** - Empty containers, nil values, invalid data
- ✅ **Error conditions** - Invalid inputs, missing methods
- ✅ **Data validation** - Type checking, range validation
- ✅ **State management** - ModData persistence, inventory changes

## Project Zomboid B41 Compatibility

### Lua Version

Project Zomboid B41 uses a Java implementation of Lua called Kahlua, based on **Lua 5.1** with some modifications. The tests are designed to work with this constraint.

### API Differences

The mock objects account for Project Zomboid's specific API:

- Items have `getFullType()`, `getModData()`, `getDelta()`, etc.
- Players have `getInventory()` which returns an inventory with `AddItem()`
- Recipe system with `OnTest`, `OnCanPerform`, and `OnCreate` callbacks
- ModData system for persistent storage

### Testing Limitations

Since we can't run actual Project Zomboid code outside the game:

1. **Mock objects** simulate the PZ API behavior
2. **Unit tests** verify logic without game integration
3. **Integration testing** must be done in-game
4. **API compatibility** is maintained through careful mocking

## Continuous Integration

The GitHub Actions workflow provides:

### Test Matrix

```yaml
strategy:
  matrix:
    lua-version: ['5.1', '5.2', '5.3', '5.4']
    include:
      - lua-version: '5.1'
        primary: true  # PZ B41 target
```

### Quality Gates

- ✅ All tests must pass on Lua 5.1 (primary target)
- ✅ Linting with luacheck
- ✅ Security scanning for sensitive data
- ✅ Coverage reporting (optional)

### Trigger Conditions

- Push to protected branches
- Pull requests
- Changes to Lua source files
- Changes to test files

## Best Practices

### Writing Tests

1. **Use descriptive names**: `testSaveFoodWithMultipleItems`
2. **Test one thing**: Each test should verify one specific behavior
3. **Setup and teardown**: Use `setUp()` for common initialization
4. **Mock appropriately**: Don't test the framework, test your code
5. **Cover edge cases**: Nil values, empty collections, invalid data

### Mock Objects

1. **Maintain API compatibility**: Mocks should match PZ API signatures
2. **Implement essential methods**: Only mock what you need for tests
3. **Return realistic data**: Use sensible defaults and ranges
4. **Handle edge cases**: Mocks should behave reasonably with invalid input

### Test Organization

1. **Group related tests**: Put similar functionality in the same file
2. **Use clear file names**: `test_[functionality].lua`
3. **Consistent structure**: Setup, Execute, Assert pattern
4. **Document complex tests**: Add comments for non-obvious test logic

## Troubleshooting

### Common Issues

**"module 'luaunit' not found"**
```bash
luarocks install luaunit
```

**"module 'tests.mocks' not found"**
```bash
# Run from project root, not from tests directory
lua tests/run_tests.lua
```

**"attempt to index global 'Recipe'"**
- This is expected - the tests create these globals
- Make sure you're running the test files, not the source code

### Debug Mode

```bash
# Run with debug output
LUA_PATH="./?.lua;./?/init.lua" lua -e "
  require('luaunit').LuaUnit.verbosity = 2
  require('tests.run_tests')
"
```

## Contributing

When adding new functions to `simple_functions.lua`:

1. **Add corresponding tests** in the appropriate test file
2. **Update mocks** if new API methods are needed
3. **Run the full test suite** to ensure no regressions
4. **Update this README** if new test patterns are introduced

### Test Coverage Goals

- **100% function coverage** - Every function should have tests
- **Branch coverage** - Test both success and failure paths
- **Edge case coverage** - Test boundary conditions and invalid inputs
- **Error handling** - Verify graceful handling of error conditions