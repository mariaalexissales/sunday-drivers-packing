-- Unit tests for simple_fuel.lua
-- Compatible with Lua 5.1

-- Add the src directory to package path
package.path = package.path .. ";../Contents/mods/SimplePackingVanilla/media/lua/server/?.lua"

local TestFramework = require("test_framework")
local Mocks = require("mocks")

-- Setup mocks
Mocks.setup()

-- Mock campingFuelType global
_G.campingFuelType = {}

-- Load the module under test
require("simple_fuel")

local test = TestFramework.new()

-- ==========================
-- == Fuel Type Tests ==
-- ==========================

test:test("campingFuelType should have rag fuel entries", function()
    local expectedRagTypes = {
        "10pkRag",
        "50pkRag",
        "100pkRag",
        "500pkRag"
    }

    for _, ragType in ipairs(expectedRagTypes) do
        test:assert_not_nil(campingFuelType[ragType], ragType .. " should be defined")
        test:assert_type(campingFuelType[ragType], "number", ragType .. " should be a number")
        test:assert_true(campingFuelType[ragType] > 0, ragType .. " should have positive fuel value")
    end
end)

test:test("campingFuelType should have leather fuel entries", function()
    local expectedLeatherTypes = {
        "10pkLeather",
        "50pkLeather",
        "100pkLeather",
        "500pkLeather"
    }

    for _, leatherType in ipairs(expectedLeatherTypes) do
        test:assert_not_nil(campingFuelType[leatherType], leatherType .. " should be defined")
        test:assert_type(campingFuelType[leatherType], "number", leatherType .. " should be a number")
        test:assert_true(campingFuelType[leatherType] > 0, leatherType .. " should have positive fuel value")
    end
end)

test:test("campingFuelType should have denim fuel entries", function()
    local expectedDenimTypes = {
        "10pkDenim",
        "50pkDenim",
        "100pkDenim",
        "500pkDenim"
    }

    for _, denimType in ipairs(expectedDenimTypes) do
        test:assert_not_nil(campingFuelType[denimType], denimType .. " should be defined")
        test:assert_type(campingFuelType[denimType], "number", denimType .. " should be a number")
        test:assert_true(campingFuelType[denimType] > 0, denimType .. " should have positive fuel value")
    end
end)

test:test("10pk variants should have correct fuel values", function()
    local expected10pkValue = 50 / 60.0

    test:assert_equals(campingFuelType["10pkRag"], expected10pkValue, "10pkRag should have correct value")
    test:assert_equals(campingFuelType["10pkLeather"], expected10pkValue, "10pkLeather should have correct value")
    test:assert_equals(campingFuelType["10pkDenim"], expected10pkValue, "10pkDenim should have correct value")
end)

test:test("50pk variants should have correct fuel values", function()
    local expected50pkValue = 5

    test:assert_equals(campingFuelType["50pkRag"], expected50pkValue, "50pkRag should have correct value")
    test:assert_equals(campingFuelType["50pkLeather"], expected50pkValue, "50pkLeather should have correct value")
    test:assert_equals(campingFuelType["50pkDenim"], expected50pkValue, "50pkDenim should have correct value")
end)

test:test("100pk variants should have correct fuel values", function()
    local expected100pkValue = 650 / 60.0

    test:assert_equals(campingFuelType["100pkRag"], expected100pkValue, "100pkRag should have correct value")
    test:assert_equals(campingFuelType["100pkLeather"], expected100pkValue, "100pkLeather should have correct value")
    test:assert_equals(campingFuelType["100pkDenim"], expected100pkValue, "100pkDenim should have correct value")
end)

test:test("500pk variants should have correct fuel values", function()
    local expected500pkValue = 800 / 60.0

    test:assert_equals(campingFuelType["500pkRag"], expected500pkValue, "500pkRag should have correct value")
    test:assert_equals(campingFuelType["500pkLeather"], expected500pkValue, "500pkLeather should have correct value")
    test:assert_equals(campingFuelType["500pkDenim"], expected500pkValue, "500pkDenim should have correct value")
end)

test:test("fuel values should increase with pack size", function()
    local materials = {"Rag", "Leather", "Denim"}

    for _, material in ipairs(materials) do
        local value10 = campingFuelType["10pk" .. material]
        local value50 = campingFuelType["50pk" .. material]
        local value100 = campingFuelType["100pk" .. material]
        local value500 = campingFuelType["500pk" .. material]

        test:assert_true(value10 < value50, "10pk should be less than 50pk for " .. material)
        test:assert_true(value50 < value100, "50pk should be less than 100pk for " .. material)
        test:assert_true(value100 < value500, "100pk should be less than 500pk for " .. material)
    end
end)

test:test("material types should have consistent values across sizes", function()
    local sizes = {"10pk", "50pk", "100pk", "500pk"}

    for _, size in ipairs(sizes) do
        local ragValue = campingFuelType[size .. "Rag"]
        local leatherValue = campingFuelType[size .. "Leather"]
        local denimValue = campingFuelType[size .. "Denim"]

        test:assert_equals(ragValue, leatherValue, size .. " Rag and Leather should have same value")
        test:assert_equals(leatherValue, denimValue, size .. " Leather and Denim should have same value")
        test:assert_equals(ragValue, denimValue, size .. " Rag and Denim should have same value")
    end
end)

-- Run all tests
test:run()