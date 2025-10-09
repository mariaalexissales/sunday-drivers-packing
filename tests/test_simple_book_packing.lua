-- Unit tests for simple_book_packing.lua
-- Compatible with Lua 5.1

-- Add the src directory to package path
package.path = package.path .. ";../Contents/mods/SimplePackingVanilla/media/lua/server/?.lua"

local TestFramework = require("test_framework")
local Mocks = require("mocks")

-- Setup mocks
Mocks.setup()

-- Load the module under test
require("simple_book_packing")

local test = TestFramework.new()

-- ==========================
-- == Skill Book Tests ==
-- ==========================

test:test("Recipe.OnCreate.UnpackCarpentrySkillBook should add carpentry books", function()
    local player = Mocks.MockPlayer.new()
    local initialCount = player:getInventory():getItems():size()

    Recipe.OnCreate.UnpackCarpentrySkillBook(nil, nil, player)

    local finalCount = player:getInventory():getItems():size()
    test:assert_equals(finalCount - initialCount, 4, "Should add 4 carpentry books (levels 2-5)")

    -- Check that the correct books were added
    local inventory = player:getInventory():getItems()
    local expectedBooks = {
        "Base.BookCarpentry2",
        "Base.BookCarpentry3",
        "Base.BookCarpentry4",
        "Base.BookCarpentry5"
    }

    for i = 1, 4 do
        local book = inventory:get(i - 1)
        test:assert_not_nil(book, "Book " .. i .. " should exist")
        test:assert_equals(book:getFullType(), expectedBooks[i], "Should add correct carpentry book level " .. (i + 1))
    end
end)

test:test("Recipe.OnCreate.UnpackCookingSkillBook should add cooking books", function()
    local player = Mocks.MockPlayer.new()
    local initialCount = player:getInventory():getItems():size()

    Recipe.OnCreate.UnpackCookingSkillBook(nil, nil, player)

    local finalCount = player:getInventory():getItems():size()
    test:assert_equals(finalCount - initialCount, 4, "Should add 4 cooking books (levels 2-5)")

    local inventory = player:getInventory():getItems()
    local expectedBooks = {
        "Base.BookCooking2",
        "Base.BookCooking3",
        "Base.BookCooking4",
        "Base.BookCooking5"
    }

    for i = 1, 4 do
        local book = inventory:get(i - 1)
        test:assert_equals(book:getFullType(), expectedBooks[i], "Should add correct cooking book level " .. (i + 1))
    end
end)

test:test("Recipe.OnCreate.UnpackElectricitySkillBook should add electricity books", function()
    local player = Mocks.MockPlayer.new()
    local initialCount = player:getInventory():getItems():size()

    Recipe.OnCreate.UnpackElectricitySkillBook(nil, nil, player)

    local finalCount = player:getInventory():getItems():size()
    test:assert_equals(finalCount - initialCount, 4, "Should add 4 electricity books (levels 2-5)")

    local inventory = player:getInventory():getItems()
    local expectedBooks = {
        "Base.BookElectrician2",
        "Base.BookElectrician3",
        "Base.BookElectrician4",
        "Base.BookElectrician5"
    }

    for i = 1, 4 do
        local book = inventory:get(i - 1)
        test:assert_equals(book:getFullType(), expectedBooks[i], "Should add correct electricity book level " .. (i + 1))
    end
end)

test:test("Recipe.OnCreate.UnpackFarmingSkillBook should add farming books", function()
    local player = Mocks.MockPlayer.new()
    Recipe.OnCreate.UnpackFarmingSkillBook(nil, nil, player)

    local inventory = player:getInventory():getItems()
    test:assert_equals(inventory:size(), 4, "Should add 4 farming books")

    local expectedBooks = {
        "Base.BookFarming2",
        "Base.BookFarming3",
        "Base.BookFarming4",
        "Base.BookFarming5"
    }

    for i = 1, 4 do
        local book = inventory:get(i - 1)
        test:assert_equals(book:getFullType(), expectedBooks[i], "Should add correct farming book level " .. (i + 1))
    end
end)

test:test("Recipe.OnCreate.UnpackFirstaidSkillBook should add first aid books", function()
    local player = Mocks.MockPlayer.new()
    Recipe.OnCreate.UnpackFirstaidSkillBook(nil, nil, player)

    local inventory = player:getInventory():getItems()
    test:assert_equals(inventory:size(), 4, "Should add 4 first aid books")

    local expectedBooks = {
        "Base.BookFirstAid2",
        "Base.BookFirstAid3",
        "Base.BookFirstAid4",
        "Base.BookFirstAid5"
    }

    for i = 1, 4 do
        local book = inventory:get(i - 1)
        test:assert_equals(book:getFullType(), expectedBooks[i], "Should add correct first aid book level " .. (i + 1))
    end
end)

test:test("Recipe.OnCreate.UnpackFishingSkillBook should add fishing books", function()
    local player = Mocks.MockPlayer.new()
    Recipe.OnCreate.UnpackFishingSkillBook(nil, nil, player)

    local inventory = player:getInventory():getItems()
    test:assert_equals(inventory:size(), 4, "Should add 4 fishing books")

    local expectedBooks = {
        "Base.BookFishing2",
        "Base.BookFishing3",
        "Base.BookFishing4",
        "Base.BookFishing5"
    }

    for i = 1, 4 do
        local book = inventory:get(i - 1)
        test:assert_equals(book:getFullType(), expectedBooks[i], "Should add correct fishing book level " .. (i + 1))
    end
end)

test:test("Recipe.OnCreate.UnpackMetalworkSkillBook should add metalwork books", function()
    local player = Mocks.MockPlayer.new()
    Recipe.OnCreate.UnpackMetalworkSkillBook(nil, nil, player)

    local inventory = player:getInventory():getItems()
    test:assert_equals(inventory:size(), 4, "Should add 4 metalwork books")

    local expectedBooks = {
        "Base.BookMetalWelding2",
        "Base.BookMetalWelding3",
        "Base.BookMetalWelding4",
        "Base.BookMetalWelding5"
    }

    for i = 1, 4 do
        local book = inventory:get(i - 1)
        test:assert_equals(book:getFullType(), expectedBooks[i], "Should add correct metalwork book level " .. (i + 1))
    end
end)

test:test("Recipe.OnCreate.UnpackMechanicsSkillBook should add mechanics books", function()
    local player = Mocks.MockPlayer.new()
    Recipe.OnCreate.UnpackMechanicsSkillBook(nil, nil, player)

    local inventory = player:getInventory():getItems()
    test:assert_equals(inventory:size(), 4, "Should add 4 mechanics books")

    local expectedBooks = {
        "Base.BookMechanic2",
        "Base.BookMechanic3",
        "Base.BookMechanic4",
        "Base.BookMechanic5"
    }

    for i = 1, 4 do
        local book = inventory:get(i - 1)
        test:assert_equals(book:getFullType(), expectedBooks[i], "Should add correct mechanics book level " .. (i + 1))
    end
end)

test:test("Recipe.OnCreate.UnpackTailoringSkillBook should add tailoring books", function()
    local player = Mocks.MockPlayer.new()
    Recipe.OnCreate.UnpackTailoringSkillBook(nil, nil, player)

    local inventory = player:getInventory():getItems()
    test:assert_equals(inventory:size(), 4, "Should add 4 tailoring books")

    local expectedBooks = {
        "Base.BookTailoring2",
        "Base.BookTailoring3",
        "Base.BookTailoring4",
        "Base.BookTailoring5"
    }

    for i = 1, 4 do
        local book = inventory:get(i - 1)
        test:assert_equals(book:getFullType(), expectedBooks[i], "Should add correct tailoring book level " .. (i + 1))
    end
end)

test:test("Recipe.OnCreate.UnpackTrappingSkillBook should add trapping books", function()
    local player = Mocks.MockPlayer.new()
    Recipe.OnCreate.UnpackTrappingSkillBook(nil, nil, player)

    local inventory = player:getInventory():getItems()
    test:assert_equals(inventory:size(), 4, "Should add 4 trapping books")

    local expectedBooks = {
        "Base.BookTrapping2",
        "Base.BookTrapping3",
        "Base.BookTrapping4",
        "Base.BookTrapping5"
    }

    for i = 1, 4 do
        local book = inventory:get(i - 1)
        test:assert_equals(book:getFullType(), expectedBooks[i], "Should add correct trapping book level " .. (i + 1))
    end
end)

test:test("Recipe.OnCreate.UnpackForagingSkillBook should add foraging books", function()
    local player = Mocks.MockPlayer.new()
    Recipe.OnCreate.UnpackForagingSkillBook(nil, nil, player)

    local inventory = player:getInventory():getItems()
    test:assert_equals(inventory:size(), 4, "Should add 4 foraging books")

    local expectedBooks = {
        "Base.BookForaging2",
        "Base.BookForaging3",
        "Base.BookForaging4",
        "Base.BookForaging5"
    }

    for i = 1, 4 do
        local book = inventory:get(i - 1)
        test:assert_equals(book:getFullType(), expectedBooks[i], "Should add correct foraging book level " .. (i + 1))
    end
end)

-- Run all tests
test:run()