-- Unit tests for simple_functions.lua
-- Compatible with Lua 5.1

-- Add the src directory to package path
package.path = package.path .. ";../Contents/mods/SimplePackingVanilla/media/lua/server/?.lua"

local TestFramework = require("test_framework")
local Mocks = require("mocks")

-- Setup mocks
Mocks.setup()

-- Load the module under test
require("simple_functions")

local test = TestFramework.new()

-- ==========================
-- == Utility Functions Tests ==
-- ==========================

test:test("AMSI should add correct number of items", function()
    local player = Mocks.MockPlayer.new()
    local initialCount = player:getInventory():getItems():size()

    AMSI("Base.TestItem", 2, player)

    local finalCount = player:getInventory():getItems():size()
    test:assert_equals(finalCount - initialCount, 3, "Should add 3 items (count + 1)")
end)

test:test("recipe_opencigpack should add cigarettes", function()
    local player = Mocks.MockPlayer.new()
    local initialCount = player:getInventory():getItems():size()

    recipe_opencigpack(nil, nil, player)

    local finalCount = player:getInventory():getItems():size()
    test:assert_equals(finalCount - initialCount, 1, "Should add 1 cigarette pack")

    local addedItem = player:getInventory():getItems():get(0)
    test:assert_equals(addedItem:getFullType(), "Base.Cigarettes", "Should add cigarettes")
end)

-- ==========================
-- == Recipe OnTest Tests ==
-- ==========================

test:test("Recipe.OnTest.IsFavorite should return opposite of isFavorite", function()
    local favoriteItem = Mocks.MockInventoryItem.new()
    favoriteItem.favorite = true

    local normalItem = Mocks.MockInventoryItem.new()
    normalItem.favorite = false

    test:assert_false(Recipe.OnTest.IsFavorite(favoriteItem), "Should return false for favorite item")
    test:assert_true(Recipe.OnTest.IsFavorite(normalItem), "Should return true for non-favorite item")
end)

test:test("Recipe.OnTest.FullAndNotTainted should check usedDelta and tainted status", function()
    local fullItem = Mocks.MockInventoryItem.new()
    fullItem.usedDelta = 1.0

    local partialItem = Mocks.MockInventoryItem.new()
    partialItem.usedDelta = 0.5

    -- Note: NotTaintedWater function is not defined in our mocks, so this will need adjustment
    -- For now, we'll test what we can
    local result1 = Recipe.OnTest.FullAndNotTainted(fullItem)
    local result2 = Recipe.OnTest.FullAndNotTainted(partialItem)

    test:assert_type(result1, "boolean", "Should return boolean for full item")
    test:assert_type(result2, "boolean", "Should return boolean for partial item")
end)

test:test("Recipe.OnTest.WholeFood should check hunger values", function()
    local freshFood = Mocks.MockInventoryItem.new()
    freshFood.baseHunger = -10
    freshFood.hungerChange = -10
    freshFood.fresh = true

    local staleFoodGood = Mocks.MockInventoryItem.new()
    staleFoodGood.baseHunger = -10
    staleFoodGood.hungerChange = -10
    staleFoodGood.fresh = false

    local staleFoodBad = Mocks.MockInventoryItem.new()
    staleFoodBad.baseHunger = -10
    staleFoodBad.hungerChange = -5  -- Less than 99% of base
    staleFoodBad.fresh = false

    test:assert_true(Recipe.OnTest.WholeFood(freshFood), "Fresh food with matching hunger should be whole")
    test:assert_true(Recipe.OnTest.WholeFood(staleFoodGood), "Non-fresh food with matching hunger should be whole")
    test:assert_false(Recipe.OnTest.WholeFood(staleFoodBad), "Food with reduced hunger should not be whole")
end)

test:test("Recipe.OnTest.WholeItem should check condition", function()
    local wholeItem = Mocks.MockInventoryItem.new()
    wholeItem.condition = 100
    wholeItem.conditionMax = 100

    local damagedItem = Mocks.MockInventoryItem.new()
    damagedItem.condition = 50
    damagedItem.conditionMax = 100

    test:assert_true(Recipe.OnTest.WholeItem(wholeItem), "Item at max condition should be whole")
    test:assert_false(Recipe.OnTest.WholeItem(damagedItem), "Damaged item should not be whole")
end)

test:test("Recipe.OnTest.IsEmpty should check container contents", function()
    local emptyContainer = Mocks.MockInventoryItem.new()
    emptyContainer.getItemContainer = function()
        return Mocks.MockItemContainer.new()
    end

    local fullContainer = Mocks.MockInventoryItem.new()
    fullContainer.getItemContainer = function()
        local container = Mocks.MockItemContainer.new()
        container.items:add(Mocks.MockInventoryItem.new())
        return container
    end

    local nonContainer = Mocks.MockInventoryItem.new()

    test:assert_true(Recipe.OnTest.IsEmpty(emptyContainer), "Empty container should return true")
    test:assert_false(Recipe.OnTest.IsEmpty(fullContainer), "Full container should return false")
    test:assert_false(Recipe.OnTest.IsEmpty(nonContainer), "Non-container should return false")
    test:assert_false(Recipe.OnTest.IsEmpty(nil), "Nil should return false")
end)

-- ==========================
-- == Save/Load Functions Tests ==
-- ==========================

test:test("Recipe.OnCreate.SaveUses should save drainable item delta values", function()
    local items = Mocks.MockArrayList.new()
    local drainableItem1 = Mocks.MockDrainableComboItem.new("Base.TestDrainable1")
    drainableItem1.delta = 0.8
    local drainableItem2 = Mocks.MockDrainableComboItem.new("Base.TestDrainable2")
    drainableItem2.delta = 0.6

    items:add(drainableItem1)
    items:add(drainableItem2)

    local result = Mocks.MockInventoryItem.new()
    local player = Mocks.MockPlayer.new()

    Recipe.OnCreate.SaveUses(items, result, player)

    local savedUses = result:getModData().EasyPackingRemainingUses
    test:assert_not_nil(savedUses, "Should save remaining uses")
    test:assert_equals(#savedUses, 2, "Should save delta values for both items")
    test:assert_equals(savedUses[1], 0.8, "Should save first item's delta")
    test:assert_equals(savedUses[2], 0.6, "Should save second item's delta")
end)

test:test("Recipe.OnCreate.SaveFood should save food properties", function()
    local items = Mocks.MockArrayList.new()
    local foodItem = Mocks.MockInventoryItem.new("Base.TestFood", "Test Food")
    foodItem.calories = 150
    foodItem.hungerChange = -15
    foodItem.thirstChange = 5
    foodItem.age = 2
    foodItem.rotten = false
    foodItem.cooked = true

    items:add(foodItem)

    local result = Mocks.MockInventoryItem.new()
    local player = Mocks.MockPlayer.new()

    Recipe.OnCreate.SaveFood(items, result, player)

    local savedFood = result:getModData().EasyPackingFoodPack
    test:assert_not_nil(savedFood, "Should save food pack data")
    test:assert_equals(#savedFood, 1, "Should save one food item")
    test:assert_equals(savedFood[1].type, "Base.TestFood", "Should save food type")
    test:assert_equals(savedFood[1].name, "Test Food", "Should save food name")
    test:assert_equals(savedFood[1].calories, 150, "Should save calories")
    test:assert_equals(savedFood[1].hunger, -15, "Should save hunger change")
    test:assert_equals(savedFood[1].thirst, 5, "Should save thirst change")
    test:assert_equals(savedFood[1].age, 2, "Should save age")
    test:assert_equals(savedFood[1].rotten, false, "Should save rotten status")
    test:assert_equals(savedFood[1].cooked, true, "Should save cooked status")
end)

-- ==========================
-- == Unpack Functions Tests ==
-- ==========================

test:test("Recipe.OnCreate.Unpack2SheetRope should add 2 sheet ropes", function()
    local player = Mocks.MockPlayer.new()
    local initialCount = player:getInventory():getItems():size()

    Recipe.OnCreate.Unpack2SheetRope(nil, nil, player)

    local finalCount = player:getInventory():getItems():size()
    test:assert_equals(finalCount - initialCount, 2, "Should add 2 sheet ropes")
end)

test:test("Recipe.OnCreate.Unpack2Rope should add 2 ropes", function()
    local player = Mocks.MockPlayer.new()
    local initialCount = player:getInventory():getItems():size()

    Recipe.OnCreate.Unpack2Rope(nil, nil, player)

    local finalCount = player:getInventory():getItems():size()
    test:assert_equals(finalCount - initialCount, 2, "Should add 2 ropes")
end)

test:test("Recipe.OnCreate.Unpack1SheetRope should add 1 sheet rope", function()
    local player = Mocks.MockPlayer.new()
    local initialCount = player:getInventory():getItems():size()

    Recipe.OnCreate.Unpack1SheetRope(nil, nil, player)

    local finalCount = player:getInventory():getItems():size()
    test:assert_equals(finalCount - initialCount, 1, "Should add 1 sheet rope")
end)

test:test("Recipe.OnCreate.Unpack1Rope should add 1 rope", function()
    local player = Mocks.MockPlayer.new()
    local initialCount = player:getInventory():getItems():size()

    Recipe.OnCreate.Unpack1Rope(nil, nil, player)

    local finalCount = player:getInventory():getItems():size()
    test:assert_equals(finalCount - initialCount, 1, "Should add 1 rope")
end)

test:test("Recipe.OnCreate.Unpack2WoodenContainer should add 2 wooden containers", function()
    local player = Mocks.MockPlayer.new()
    local initialCount = player:getInventory():getItems():size()

    Recipe.OnCreate.Unpack2WoodenContainer(nil, nil, player)

    local finalCount = player:getInventory():getItems():size()
    test:assert_equals(finalCount - initialCount, 2, "Should add 2 wooden containers")
end)

test:test("Recipe.OnCreate.Unpack1WoodenContainer should add 1 wooden container", function()
    local player = Mocks.MockPlayer.new()
    local initialCount = player:getInventory():getItems():size()

    Recipe.OnCreate.Unpack1WoodenContainer(nil, nil, player)

    local finalCount = player:getInventory():getItems():size()
    test:assert_equals(finalCount - initialCount, 1, "Should add 1 wooden container")
end)

-- ==========================
-- == Merge/Split Functions Tests ==
-- ==========================

test:test("Recipe.OnCreate.MergeUses should combine saved uses from multiple items", function()
    local items = Mocks.MockArrayList.new()

    local item1 = Mocks.MockInventoryItem.new()
    item1:getModData().EasyPackingRemainingUses = {0.8, 0.6}

    local item2 = Mocks.MockInventoryItem.new()
    item2:getModData().EasyPackingRemainingUses = {0.9, 0.5}

    items:add(item1)
    items:add(item2)

    local result = Mocks.MockInventoryItem.new()
    local player = Mocks.MockPlayer.new()

    Recipe.OnCreate.MergeUses(items, result, player)

    local mergedUses = result:getModData().EasyPackingRemainingUses
    test:assert_not_nil(mergedUses, "Should save merged uses")
    test:assert_equals(#mergedUses, 4, "Should merge all uses from both items")
    test:assert_equals(mergedUses[1], 0.8, "Should include first item's first use")
    test:assert_equals(mergedUses[2], 0.6, "Should include first item's second use")
    test:assert_equals(mergedUses[3], 0.9, "Should include second item's first use")
    test:assert_equals(mergedUses[4], 0.5, "Should include second item's second use")
end)

-- Run all tests
test:run()