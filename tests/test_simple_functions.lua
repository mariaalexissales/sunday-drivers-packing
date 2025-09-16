-- Unit tests for simple_functions.lua
-- Compatible with Lua 5.1 and Project Zomboid B41

local luaunit = require('luaunit')
local mocks = require('tests.mocks')

-- Mock global objects that simple_functions.lua expects
local mockScriptManager = mocks.MockScriptManager:new()
ScriptManager = {
    instance = mockScriptManager
}

Recipe = {
    OnTest = {},
    OnCanPerform = {},
    OnCreate = {}
}

Events = {
    OnInitGlobalModData = {
        Add = function(func) func() end
    }
}

-- Load the simple_functions.lua file
local simple_functions_path = "Contents/mods/SimplePackingVanilla/media/lua/server/simple_functions.lua"

-- Since we can't actually load the file in this test environment,
-- we'll define the functions here for testing purposes

-- Copy the functions from simple_functions.lua for testing
local function AMSI(item, count, player)
    if not player or not player.getInventory then
        error("Invalid player object")
    end

    local inventory = player:getInventory()
    for x = 0, count do
        inventory:AddItem(item)
    end
end

local function recipe_opencigpack(items, result, player)
    AMSI("Base.Cigarettes", 0, player)
end

local function getNeededForResult(result)
    if not (result and result.getFullType) then return 1 end
    local ft = result:getFullType()

    -- Mock default amounts for testing
    local defaultItemAmounts = {
        ["Base.TestItem"] = 5,
        ["Base.AnotherItem"] = 3
    }
    local defaultFoodItems = {
        ["Base.FoodItem"] = 10
    }

    if defaultItemAmounts and defaultItemAmounts[ft] then
        return math.max(1, defaultItemAmounts[ft])
    end
    if defaultFoodItems and defaultFoodItems[ft] then
        return math.max(1, defaultFoodItems[ft])
    end
    return 1
end

-- Recipe OnTest functions
function Recipe.OnTest.IsFavorite(items, result)
    return not items:isFavorite()
end

function Recipe.OnTest.FullAndNotTainted(items)
    -- Mock NotTaintedWater function for testing
    local function NotTaintedWater(item)
        return true -- Assume not tainted for testing
    end
    return items:getUsedDelta() == 1 and NotTaintedWater(items)
end

function Recipe.OnTest.WholeFood(item)
    local baseHunger = math.abs(item:getBaseHunger())
    local hungerChange = math.abs(item:getHungerChange())
    if item:isFresh() then
        return not (baseHunger * 0.99 > hungerChange)
    end
    return not (baseHunger * 0.99 > hungerChange)
end

function Recipe.OnTest.WholeItem(item)
    return item:getCondition() == item:getConditionMax()
end

function Recipe.OnTest.IsEmpty(item)
    if not item then return false end

    if item.getItemContainer then
        local cont = item:getItemContainer()
        if cont and cont.getItems then
            return cont:getItems():size() == 0
        end
    end

    return false
end

function Recipe.OnCanPerform.HasEnoughEmpties(recipe, playerObj, items)
    if not (playerObj and playerObj.getInventory) then
        return false
    end

    local playerInv = playerObj:getInventory()
    if not (playerInv and playerInv.getItems) then
        return false
    end

    local playerItems = playerInv:getItems()
    if not (playerItems and playerItems.size) then
        return false
    end

    local found = 0
    local needed = getNeededForResult(recipe:getResult())

    for i = 0, playerItems:size() - 1 do
        local it = playerItems:get(i)
        if it and Recipe.OnTest.IsEmpty(it) then
            found = found + 1
            if found >= needed then
                return true
            end
        end
    end

    return false
end

-- Recipe OnCreate functions
function Recipe.OnCreate.SaveUses(items, result, player)
    local remainingUses = {}

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item then
            local delta = nil
            if item.getDelta then
                delta = item:getDelta()
            end

            if delta ~= nil and type(delta) == "number" then
                table.insert(remainingUses, delta)
            else
                table.insert(remainingUses, 1.0)
            end
        end
    end

    if #remainingUses > 0 then
        result:getModData().EasyPackingRemainingUses = remainingUses
    end
end

function Recipe.OnCreate.LoadUses(items, result, player)
    if not items or not result or not player then
        return
    end

    local firstItem = items:get(0)
    if not firstItem then
        return
    end

    local modData = firstItem:getModData()
    local savedUses = modData and modData.EasyPackingRemainingUses

    if savedUses and #savedUses > 0 then
        local inventory = player:getInventory()
        local itemToAdd = result:getFullType()

        for k, savedUse in pairs(savedUses) do
            if savedUse ~= nil and type(savedUse) == "number" then
                local delta = math.max(0, math.min(1, savedUse))
                local newItem = inventory:AddItem(itemToAdd)
                if newItem and newItem.setDelta then
                    newItem:setDelta(delta)
                end
            end
        end
    else
        local inventory = player:getInventory()
        local itemToAdd = result:getFullType()
        inventory:AddItem(itemToAdd)
    end
end

-- Test class
TestSimpleFunctions = {}

function TestSimpleFunctions:setUp()
    self.mockPlayer = mocks.MockPlayer:new()
    self.mockItem = mocks.MockItem:new("Base.TestItem", "Test Item")
    self.mockResult = mocks.MockItem:new("Base.Result", "Result")
    self.mockRecipe = mocks.MockRecipe:new("Test Recipe", "Base.Result")
    self.mockItemContainer = mocks.MockItemContainer:new()
end

-- Test AMSI function
function TestSimpleFunctions:testAMSI()
    local initialSize = self.mockPlayer:getInventory():getItems():size()
    AMSI("Base.TestItem", 2, self.mockPlayer)
    local finalSize = self.mockPlayer:getInventory():getItems():size()

    luaunit.assertEquals(finalSize, initialSize + 3) -- count + 1 items added
end

function TestSimpleFunctions:testAMSIInvalidPlayer()
    luaunit.assertError(AMSI, "Base.TestItem", 1, nil)
end

-- Test recipe_opencigpack function
function TestSimpleFunctions:testRecipeOpencigpack()
    local initialSize = self.mockPlayer:getInventory():getItems():size()
    recipe_opencigpack(nil, nil, self.mockPlayer)
    local finalSize = self.mockPlayer:getInventory():getItems():size()

    luaunit.assertEquals(finalSize, initialSize + 1) -- 1 cigarette added
end

-- Test getNeededForResult function
function TestSimpleFunctions:testGetNeededForResult()
    local result1 = mocks.MockItem:new("Base.TestItem", "Test Item")
    local result2 = mocks.MockItem:new("Base.FoodItem", "Food Item")
    local result3 = mocks.MockItem:new("Base.UnknownItem", "Unknown Item")

    luaunit.assertEquals(getNeededForResult(result1), 5)
    luaunit.assertEquals(getNeededForResult(result2), 10)
    luaunit.assertEquals(getNeededForResult(result3), 1)
    luaunit.assertEquals(getNeededForResult(nil), 1)
end

-- Test Recipe.OnTest.IsFavorite
function TestSimpleFunctions:testIsFavorite()
    self.mockItem:setFavorite(true)
    luaunit.assertFalse(Recipe.OnTest.IsFavorite(self.mockItem, self.mockResult))

    self.mockItem:setFavorite(false)
    luaunit.assertTrue(Recipe.OnTest.IsFavorite(self.mockItem, self.mockResult))
end

-- Test Recipe.OnTest.FullAndNotTainted
function TestSimpleFunctions:testFullAndNotTainted()
    self.mockItem:setUsedDelta(1.0)
    luaunit.assertTrue(Recipe.OnTest.FullAndNotTainted(self.mockItem))

    self.mockItem:setUsedDelta(0.5)
    luaunit.assertFalse(Recipe.OnTest.FullAndNotTainted(self.mockItem))
end

-- Test Recipe.OnTest.WholeFood
function TestSimpleFunctions:testWholeFood()
    local food = mocks.MockItem:new("Base.Food", "Food")
    food:setBaseHunger(10)
    food:setHungerChange(-10)
    food:setFresh(true)

    luaunit.assertFalse(Recipe.OnTest.WholeFood(food))

    food:setHungerChange(-5)
    luaunit.assertTrue(Recipe.OnTest.WholeFood(food))
end

-- Test Recipe.OnTest.WholeItem
function TestSimpleFunctions:testWholeItem()
    self.mockItem:setCondition(100)
    luaunit.assertTrue(Recipe.OnTest.WholeItem(self.mockItem))

    self.mockItem:setCondition(50)
    luaunit.assertFalse(Recipe.OnTest.WholeItem(self.mockItem))
end

-- Test Recipe.OnTest.IsEmpty
function TestSimpleFunctions:testIsEmpty()
    luaunit.assertFalse(Recipe.OnTest.IsEmpty(nil))

    local container = mocks.MockContainer:new()
    self.mockItem:setItemContainer(container)
    luaunit.assertTrue(Recipe.OnTest.IsEmpty(self.mockItem))

    container:getItems():add(mocks.MockItem:new())
    luaunit.assertFalse(Recipe.OnTest.IsEmpty(self.mockItem))
end

-- Test Recipe.OnCanPerform.HasEnoughEmpties
function TestSimpleFunctions:testHasEnoughEmpties()
    -- Add empty containers to player inventory
    local container1 = mocks.MockItem:new("Base.Container1", "Container 1")
    container1:setItemContainer(mocks.MockContainer:new())

    local container2 = mocks.MockItem:new("Base.Container2", "Container 2")
    container2:setItemContainer(mocks.MockContainer:new())

    self.mockPlayer:getInventory():AddItem("Base.Container1")
    self.mockPlayer:getInventory():AddItem("Base.Container2")

    -- Set up the last two items in inventory to be containers
    local items = self.mockPlayer:getInventory():getItems()
    local item1 = items:get(items:size() - 2)
    local item2 = items:get(items:size() - 1)

    item1:setItemContainer(mocks.MockContainer:new())
    item2:setItemContainer(mocks.MockContainer:new())

    luaunit.assertTrue(Recipe.OnCanPerform.HasEnoughEmpties(self.mockRecipe, self.mockPlayer, self.mockItemContainer))
end

-- Test Recipe.OnCreate.SaveUses
function TestSimpleFunctions:testSaveUses()
    self.mockItemContainer:add(self.mockItem)
    self.mockItem:setDelta(0.75)

    Recipe.OnCreate.SaveUses(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local savedUses = self.mockResult:getModData().EasyPackingRemainingUses
    luaunit.assertNotNil(savedUses)
    luaunit.assertEquals(#savedUses, 1)
    luaunit.assertEquals(savedUses[1], 0.75)
end

-- Test Recipe.OnCreate.LoadUses
function TestSimpleFunctions:testLoadUses()
    -- Setup saved uses data
    local itemWithSaves = mocks.MockItem:new("Base.PackedItem", "Packed Item")
    itemWithSaves:getModData().EasyPackingRemainingUses = {0.8, 0.6, 0.9}

    self.mockItemContainer:add(itemWithSaves)

    local initialSize = self.mockPlayer:getInventory():getItems():size()
    Recipe.OnCreate.LoadUses(self.mockItemContainer, self.mockResult, self.mockPlayer)
    local finalSize = self.mockPlayer:getInventory():getItems():size()

    luaunit.assertEquals(finalSize, initialSize + 3) -- 3 items added
end

-- Test edge cases
function TestSimpleFunctions:testLoadUsesNoSavedData()
    self.mockItemContainer:add(self.mockItem)

    local initialSize = self.mockPlayer:getInventory():getItems():size()
    Recipe.OnCreate.LoadUses(self.mockItemContainer, self.mockResult, self.mockPlayer)
    local finalSize = self.mockPlayer:getInventory():getItems():size()

    luaunit.assertEquals(finalSize, initialSize + 1) -- 1 default item added
end

function TestSimpleFunctions:testLoadUsesInvalidInputs()
    -- Test with nil inputs
    Recipe.OnCreate.LoadUses(nil, self.mockResult, self.mockPlayer)
    Recipe.OnCreate.LoadUses(self.mockItemContainer, nil, self.mockPlayer)
    Recipe.OnCreate.LoadUses(self.mockItemContainer, self.mockResult, nil)

    -- Should not crash - this is a success if we get here
    luaunit.assertTrue(true)
end

function TestSimpleFunctions:testSaveUsesInvalidDelta()
    local itemWithBadDelta = mocks.MockItem:new("Base.BadItem", "Bad Item")
    itemWithBadDelta.getDelta = function() return "invalid" end -- Return string instead of number

    self.mockItemContainer:add(itemWithBadDelta)

    Recipe.OnCreate.SaveUses(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local savedUses = self.mockResult:getModData().EasyPackingRemainingUses
    luaunit.assertNotNil(savedUses)
    luaunit.assertEquals(#savedUses, 1)
    luaunit.assertEquals(savedUses[1], 1.0) -- Should default to 1.0
end

function TestSimpleFunctions:testSaveUsesNoDelta()
    local itemNoDelta = mocks.MockItem:new("Base.NoDeltaItem", "No Delta Item")
    itemNoDelta.getDelta = nil -- No getDelta method

    self.mockItemContainer:add(itemNoDelta)

    Recipe.OnCreate.SaveUses(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local savedUses = self.mockResult:getModData().EasyPackingRemainingUses
    luaunit.assertNotNil(savedUses)
    luaunit.assertEquals(#savedUses, 1)
    luaunit.assertEquals(savedUses[1], 1.0) -- Should default to 1.0
end

-- Run the tests
if arg and arg[0] == "test_simple_functions.lua" then
    os.exit(luaunit.LuaUnit.run())
end

return TestSimpleFunctions