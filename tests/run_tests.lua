#!/usr/bin/env lua5.1

-- Test runner for Simple Packing mod
-- Compatible with Lua 5.1

print("Simple Packing Mod - Test Suite")
print("===============================")
print("")

local test_files = {
    "test_simple_functions.lua",
    "test_simple_book_packing.lua",
    "test_simple_fuel.lua"
}

local total_passed = 0
local total_failed = 0
local total_tests = 0

for _, test_file in ipairs(test_files) do
    print(string.format("Running %s...", test_file))
    print(string.rep("-", 40))

    -- Execute the test file
    local success, error_msg = pcall(function()
        dofile(test_file)
    end)

    if not success then
        print(string.format("ERROR: Failed to run %s", test_file))
        print(string.format("Error: %s", error_msg))
        total_failed = total_failed + 1
    end

    print("")
end

print("Test Suite Complete")
print("==================")

if total_failed > 0 then
    print(string.format("Some test files failed to execute: %d", total_failed))
    os.exit(1)
else
    print("All test files executed successfully!")
    os.exit(0)
end