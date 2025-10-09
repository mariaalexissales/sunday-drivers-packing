-- Simple Lua 5.1 compatible test framework
-- Designed for Project Zomboid mod testing

local TestFramework = {}
TestFramework.__index = TestFramework

-- Test suite
function TestFramework.new()
    local self = {
        tests = {},
        passed = 0,
        failed = 0,
        total = 0
    }
    setmetatable(self, TestFramework)
    return self
end

-- Add a test case
function TestFramework:test(name, func)
    table.insert(self.tests, {name = name, func = func})
end

-- Assert functions
function TestFramework:assert_equals(actual, expected, message)
    if actual ~= expected then
        error(string.format("Assertion failed: %s\nExpected: %s\nActual: %s",
            message or "values should be equal", tostring(expected), tostring(actual)))
    end
end

function TestFramework:assert_true(value, message)
    if not value then
        error(string.format("Assertion failed: %s\nExpected: true\nActual: %s",
            message or "value should be true", tostring(value)))
    end
end

function TestFramework:assert_false(value, message)
    if value then
        error(string.format("Assertion failed: %s\nExpected: false\nActual: %s",
            message or "value should be false", tostring(value)))
    end
end

function TestFramework:assert_nil(value, message)
    if value ~= nil then
        error(string.format("Assertion failed: %s\nExpected: nil\nActual: %s",
            message or "value should be nil", tostring(value)))
    end
end

function TestFramework:assert_not_nil(value, message)
    if value == nil then
        error(string.format("Assertion failed: %s\nExpected: not nil\nActual: nil",
            message or "value should not be nil"))
    end
end

function TestFramework:assert_type(value, expected_type, message)
    local actual_type = type(value)
    if actual_type ~= expected_type then
        error(string.format("Assertion failed: %s\nExpected type: %s\nActual type: %s",
            message or "type mismatch", expected_type, actual_type))
    end
end

-- Run all tests
function TestFramework:run()
    print("Running tests...")
    print("================")

    for _, test in ipairs(self.tests) do
        self.total = self.total + 1

        local success, error_message = pcall(test.func)

        if success then
            self.passed = self.passed + 1
            print(string.format("✓ %s", test.name))
        else
            self.failed = self.failed + 1
            print(string.format("✗ %s", test.name))
            print(string.format("  Error: %s", error_message))
        end
    end

    print("================")
    print(string.format("Tests: %d, Passed: %d, Failed: %d", self.total, self.passed, self.failed))

    if self.failed > 0 then
        os.exit(1)
    else
        print("All tests passed!")
        os.exit(0)
    end
end

return TestFramework