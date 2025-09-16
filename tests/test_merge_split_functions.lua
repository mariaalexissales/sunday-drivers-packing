-- Unit tests for merge and split functions in simple_functions.lua
local luaunit = require('luaunit')
local mocks = require('tests.mocks')

-- Mock Recipe namespace
Recipe = Recipe or {
    OnCreate = {}
}

-- Mock defaultItemAmounts for testing
local defaultItemAmounts = {
    ["Base.PackedItem"] = 4,
    ["Base.TestItem"] = 6
}

-- Test merging and splitting functions
local function Recipe_OnCreate_MergeUses(items, result, player)
    local toMerge = {}
    for i = 0, items:size() - 1 do
        local savedUses = items:get(i):getModData().EasyPackingRemainingUses
        if savedUses then
            for _, v in pairs(savedUses) do
                table.insert(toMerge, v)
            end
        else
            local itemType = items:get(0):getFullType()
            local defaultAmount = defaultItemAmounts[itemType] or 1
            for j = 1, defaultAmount do
                table.insert(toMerge, 1)
            end
        end
    end
    result:getModData().EasyPackingRemainingUses = toMerge
end

local function Recipe_OnCreate_SplitUsesInTwo(items, result, player)
    local savedUses = items:get(0):getModData().EasyPackingRemainingUses
    local itemToAdd = result:getFullType()
    local inventory = player:getInventory()
    local unpackedModData = { {}, {} }

    if savedUses then
        local halfPoint = math.floor(#savedUses / 2)
        for i = 1, halfPoint do
            table.insert(unpackedModData[1], savedUses[i])
        end
        for i = halfPoint + 1, #savedUses do
            table.insert(unpackedModData[2], savedUses[i])
        end
    else
        local itemType = items:get(0):getFullType()
        local amount = defaultItemAmounts[itemType] or 1
        local halfAmount = math.floor(amount / 2)
        for i = 1, halfAmount do
            table.insert(unpackedModData[1], 1)
        end
        for i = halfAmount + 1, amount do
            table.insert(unpackedModData[2], 1)
        end
    end

    for _, v in pairs(unpackedModData) do
        local newItem = inventory:AddItem(itemToAdd)
        newItem:getModData().EasyPackingRemainingUses = v
    end
end

-- Assign functions to Recipe namespace
Recipe.OnCreate.MergeUses = Recipe_OnCreate_MergeUses
Recipe.OnCreate.SplitUsesInTwo = Recipe_OnCreate_SplitUsesInTwo

TestMergeSplitFunctions = {}

function TestMergeSplitFunctions:setUp()
    self.mockPlayer = mocks.MockPlayer:new()
    self.mockResult = mocks.MockItem:new("Base.MergedResult", "Merged Result")
    self.mockItemContainer = mocks.MockItemContainer:new()
end

-- Test merging uses with saved data
function TestMergeSplitFunctions:testMergeUsesWithSavedData()
    -- Create items with saved uses
    local item1 = mocks.MockItem:new("Base.PackedItem", "Packed Item 1")
    item1:getModData().EasyPackingRemainingUses = {0.8, 0.6, 0.4}

    local item2 = mocks.MockItem:new("Base.PackedItem", "Packed Item 2")
    item2:getModData().EasyPackingRemainingUses = {0.9, 0.7}

    self.mockItemContainer:add(item1)
    self.mockItemContainer:add(item2)

    Recipe.OnCreate.MergeUses(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local mergedUses = self.mockResult:getModData().EasyPackingRemainingUses
    luaunit.assertNotNil(mergedUses)
    luaunit.assertEquals(#mergedUses, 5) -- 3 + 2 uses

    -- Check that all values are merged correctly
    luaunit.assertEquals(mergedUses[1], 0.8)
    luaunit.assertEquals(mergedUses[2], 0.6)
    luaunit.assertEquals(mergedUses[3], 0.4)
    luaunit.assertEquals(mergedUses[4], 0.9)
    luaunit.assertEquals(mergedUses[5], 0.7)
end

-- Test merging uses without saved data (using defaults)
function TestMergeSplitFunctions:testMergeUsesWithoutSavedData()
    local item1 = mocks.MockItem:new("Base.PackedItem", "Packed Item 1")
    local item2 = mocks.MockItem:new("Base.PackedItem", "Packed Item 2")

    self.mockItemContainer:add(item1)
    self.mockItemContainer:add(item2)

    Recipe.OnCreate.MergeUses(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local mergedUses = self.mockResult:getModData().EasyPackingRemainingUses
    luaunit.assertNotNil(mergedUses)
    -- Should have defaultItemAmounts["Base.PackedItem"] = 4 uses from first item
    luaunit.assertEquals(#mergedUses, 4)

    -- All should be 1.0 (default value)
    for i = 1, 4 do
        luaunit.assertEquals(mergedUses[i], 1)
    end
end

-- Test merging mixed items (some with saved data, some without)
function TestMergeSplitFunctions:testMergeUsesMixed()
    local itemWithData = mocks.MockItem:new("Base.PackedItem", "Packed Item With Data")
    itemWithData:getModData().EasyPackingRemainingUses = {0.5, 0.3}

    local itemWithoutData = mocks.MockItem:new("Base.PackedItem", "Packed Item Without Data")

    self.mockItemContainer:add(itemWithData)
    self.mockItemContainer:add(itemWithoutData)

    Recipe.OnCreate.MergeUses(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local mergedUses = self.mockResult:getModData().EasyPackingRemainingUses
    luaunit.assertNotNil(mergedUses)
    -- Should have 2 from first item + 4 default from second item = 6 total
    luaunit.assertEquals(#mergedUses, 6)

    luaunit.assertEquals(mergedUses[1], 0.5) -- From first item
    luaunit.assertEquals(mergedUses[2], 0.3) -- From first item
    luaunit.assertEquals(mergedUses[3], 1)   -- Default from second item
    luaunit.assertEquals(mergedUses[4], 1)   -- Default from second item
    luaunit.assertEquals(mergedUses[5], 1)   -- Default from second item
    luaunit.assertEquals(mergedUses[6], 1)   -- Default from second item
end

-- Test splitting uses with even number of saved uses
function TestMergeSplitFunctions:testSplitUsesEvenNumber()
    local packedItem = mocks.MockItem:new("Base.PackedItem", "Packed Item")
    packedItem:getModData().EasyPackingRemainingUses = {0.9, 0.8, 0.7, 0.6}

    self.mockItemContainer:add(packedItem)

    local initialSize = self.mockPlayer:getInventory():getItems():size()
    Recipe.OnCreate.SplitUsesInTwo(self.mockItemContainer, self.mockResult, self.mockPlayer)
    local finalSize = self.mockPlayer:getInventory():getItems():size()

    luaunit.assertEquals(finalSize, initialSize + 2) -- Two new items created

    local inventory = self.mockPlayer:getInventory():getItems()
    local splitItem1 = inventory:get(inventory:size() - 2)
    local splitItem2 = inventory:get(inventory:size() - 1)

    local uses1 = splitItem1:getModData().EasyPackingRemainingUses
    local uses2 = splitItem2:getModData().EasyPackingRemainingUses

    luaunit.assertNotNil(uses1)
    luaunit.assertNotNil(uses2)
    luaunit.assertEquals(#uses1, 2) -- First half
    luaunit.assertEquals(#uses2, 2) -- Second half

    luaunit.assertEquals(uses1[1], 0.9)
    luaunit.assertEquals(uses1[2], 0.8)
    luaunit.assertEquals(uses2[1], 0.7)
    luaunit.assertEquals(uses2[2], 0.6)
end

-- Test splitting uses with odd number of saved uses
function TestMergeSplitFunctions:testSplitUsesOddNumber()
    local packedItem = mocks.MockItem:new("Base.PackedItem", "Packed Item")
    packedItem:getModData().EasyPackingRemainingUses = {0.9, 0.8, 0.7, 0.6, 0.5}

    self.mockItemContainer:add(packedItem)

    local initialSize = self.mockPlayer:getInventory():getItems():size()
    Recipe.OnCreate.SplitUsesInTwo(self.mockItemContainer, self.mockResult, self.mockPlayer)
    local finalSize = self.mockPlayer:getInventory():getItems():size()

    luaunit.assertEquals(finalSize, initialSize + 2) -- Two new items created

    local inventory = self.mockPlayer:getInventory():getItems()
    local splitItem1 = inventory:get(inventory:size() - 2)
    local splitItem2 = inventory:get(inventory:size() - 1)

    local uses1 = splitItem1:getModData().EasyPackingRemainingUses
    local uses2 = splitItem2:getModData().EasyPackingRemainingUses

    luaunit.assertNotNil(uses1)
    luaunit.assertNotNil(uses2)
    luaunit.assertEquals(#uses1, 2) -- First half (floor(5/2) = 2)
    luaunit.assertEquals(#uses2, 3) -- Second half (remaining 3)

    luaunit.assertEquals(uses1[1], 0.9)
    luaunit.assertEquals(uses1[2], 0.8)
    luaunit.assertEquals(uses2[1], 0.7)
    luaunit.assertEquals(uses2[2], 0.6)
    luaunit.assertEquals(uses2[3], 0.5)
end

-- Test splitting without saved data (using defaults)
function TestMergeSplitFunctions:testSplitUsesWithoutSavedData()
    local packedItem = mocks.MockItem:new("Base.PackedItem", "Packed Item")
    -- No saved uses data

    self.mockItemContainer:add(packedItem)

    local initialSize = self.mockPlayer:getInventory():getItems():size()
    Recipe.OnCreate.SplitUsesInTwo(self.mockItemContainer, self.mockResult, self.mockPlayer)
    local finalSize = self.mockPlayer:getInventory():getItems():size()

    luaunit.assertEquals(finalSize, initialSize + 2) -- Two new items created

    local inventory = self.mockPlayer:getInventory():getItems()
    local splitItem1 = inventory:get(inventory:size() - 2)
    local splitItem2 = inventory:get(inventory:size() - 1)

    local uses1 = splitItem1:getModData().EasyPackingRemainingUses
    local uses2 = splitItem2:getModData().EasyPackingRemainingUses

    luaunit.assertNotNil(uses1)
    luaunit.assertNotNil(uses2)
    -- Default amount is 4, so floor(4/2) = 2 and remaining 2
    luaunit.assertEquals(#uses1, 2)
    luaunit.assertEquals(#uses2, 2)

    -- All should be default value of 1
    for i = 1, #uses1 do
        luaunit.assertEquals(uses1[i], 1)
    end
    for i = 1, #uses2 do
        luaunit.assertEquals(uses2[i], 1)
    end
end

-- Test splitting with single use
function TestMergeSplitFunctions:testSplitUsesSingleUse()
    local packedItem = mocks.MockItem:new("Base.TestItem", "Test Item")
    packedItem:getModData().EasyPackingRemainingUses = {0.5}

    self.mockItemContainer:add(packedItem)

    local initialSize = self.mockPlayer:getInventory():getItems():size()
    Recipe.OnCreate.SplitUsesInTwo(self.mockItemContainer, self.mockResult, self.mockPlayer)
    local finalSize = self.mockPlayer:getInventory():getItems():size()

    luaunit.assertEquals(finalSize, initialSize + 2) -- Two new items created

    local inventory = self.mockPlayer:getInventory():getItems()
    local splitItem1 = inventory:get(inventory:size() - 2)
    local splitItem2 = inventory:get(inventory:size() - 1)

    local uses1 = splitItem1:getModData().EasyPackingRemainingUses
    local uses2 = splitItem2:getModData().EasyPackingRemainingUses

    luaunit.assertNotNil(uses1)
    luaunit.assertNotNil(uses2)
    luaunit.assertEquals(#uses1, 0) -- floor(1/2) = 0
    luaunit.assertEquals(#uses2, 1) -- remaining 1

    luaunit.assertEquals(uses2[1], 0.5)
end

-- Test edge cases
function TestMergeSplitFunctions:testMergeUsesEmptyContainer()
    local emptyContainer = mocks.MockItemContainer:new()

    Recipe.OnCreate.MergeUses(emptyContainer, self.mockResult, self.mockPlayer)

    local mergedUses = self.mockResult:getModData().EasyPackingRemainingUses
    luaunit.assertNotNil(mergedUses)
    luaunit.assertEquals(#mergedUses, 0) -- No items to merge
end

function TestMergeSplitFunctions:testSplitUsesEmptyContainer()
    local emptyContainer = mocks.MockItemContainer:new()

    -- Should error due to trying to access items:get(0) on empty container
    luaunit.assertError(Recipe.OnCreate.SplitUsesInTwo, emptyContainer, self.mockResult, self.mockPlayer)
end

-- Test unknown item type (not in defaultItemAmounts)
function TestMergeSplitFunctions:testMergeUsesUnknownItemType()
    local unknownItem = mocks.MockItem:new("Base.UnknownItem", "Unknown Item")
    self.mockItemContainer:add(unknownItem)

    Recipe.OnCreate.MergeUses(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local mergedUses = self.mockResult:getModData().EasyPackingRemainingUses
    luaunit.assertNotNil(mergedUses)
    luaunit.assertEquals(#mergedUses, 1) -- Default fallback to 1
    luaunit.assertEquals(mergedUses[1], 1)
end

-- Run tests if this file is executed directly
if arg and arg[0] == "test_merge_split_functions.lua" then
    os.exit(luaunit.LuaUnit.run())
end

return TestMergeSplitFunctions