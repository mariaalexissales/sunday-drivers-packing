#!/usr/bin/env lua

-- Main test runner for Simple Packing unit tests
-- This script runs all test suites and provides a comprehensive report

local luaunit = require('luaunit')

-- Add the current directory to the package path
package.path = package.path .. ";./?.lua;./?/init.lua"

-- Import all test modules
local test_simple_functions = require('tests.test_simple_functions')
local test_food_functions = require('tests.test_food_functions')
local test_rope_container_functions = require('tests.test_rope_container_functions')
local test_merge_split_functions = require('tests.test_merge_split_functions')

print("===============================================")
print("Running Simple Packing Lua Unit Tests")
print("Project Zomboid B41 Compatible (Lua 5.1)")
print("===============================================")
print()

-- Configure LuaUnit for more detailed output
luaunit.LuaUnit.verbosity = 2 -- Verbose output

-- Create a custom test runner to track results
local TestRunner = {}

function TestRunner.runAllTests()
    local startTime = os.time()

    print("Test Suites to run:")
    print("  1. test_simple_functions.lua - Core utility functions")
    print("  2. test_food_functions.lua - Food packing/unpacking")
    print("  3. test_rope_container_functions.lua - Rope and container handling")
    print("  4. test_merge_split_functions.lua - Merge and split operations")
    print()

    -- Run all tests
    local runner = luaunit.LuaUnit:new()
    runner.verbosity = 2

    -- Add test classes
    runner:addSuite('TestSimpleFunctions')
    runner:addSuite('TestFoodFunctions')
    runner:addSuite('TestRopeContainerFunctions')
    runner:addSuite('TestMergeSplitFunctions')

    local result = runner:runSuite()

    local endTime = os.time()
    local duration = endTime - startTime

    print()
    print("===============================================")
    print("Test Summary:")
    print("===============================================")
    print(string.format("Tests run: %d", runner.result.testCount))
    print(string.format("Failures: %d", runner.result.failureCount))
    print(string.format("Errors: %d", runner.result.errorCount))
    print(string.format("Duration: %d seconds", duration))

    if runner.result.failureCount == 0 and runner.result.errorCount == 0 then
        print()
        print("🎉 ALL TESTS PASSED! 🎉")
        print("The simple_functions.lua code is working correctly.")
    else
        print()
        print("❌ SOME TESTS FAILED")
        print("Please review the test output above for details.")
    end

    return result
end

-- Run tests if this file is executed directly
if arg and arg[0] and arg[0]:match("run_tests%.lua$") then
    local result = TestRunner.runAllTests()
    os.exit(result)
else
    -- Return the test runner for external use
    return TestRunner
end