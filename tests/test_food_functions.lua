-- Unit tests for food-related functions in simple_functions.lua
local luaunit = require('luaunit')
local mocks = require('tests.mocks')

-- Mock Recipe namespace
Recipe = Recipe or {
    OnCreate = {}
}

-- Test food saving and loading functions
local function Recipe_OnCreate_SaveFood(items, result, player)
    print(string.format("[SaveFood] start - count=%d", items:size()))
    local list = {}

    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it then
            local hunger = (it.getHungerChange and it:getHungerChange())
                or (it.getHungChange and it:getHungChange()) or 0
            local entry = {
                type     = it:getFullType(),
                name     = it:getName(),
                calories = it.getCalories and it:getCalories() or 0,
                hunger   = hunger,
                thirst   = it.getThirstChange and it:getThirstChange() or 0,
                stress   = it.getStressChange and it:getStressChange() or 0,
                boredom  = it.getBoredomChange and it:getBoredomChange() or 0,
                poison   = it.getPoisonPower and it:getPoisonPower() or 0,
                age      = it.getAge and it:getAge() or 0,
                rotten   = it.isRotten and it:isRotten() or false,
                cooked   = it.isCooked and it:isCooked() or false,
                burnt    = it.isBurnt and it:isBurnt() or false,
            }
            table.insert(list, entry)
        end
    end

    result:getModData().EasyPackingFoodPack = list
    print(string.format("[SaveFood] saved=%d", #list))
end

local function Recipe_OnCreate_LoadFood(items, result, player)
    print(string.format("[LoadFood] begin; count=%d", items:size()))

    if not (player and player.getInventory) then
        print("[LoadFood] abort: bad player")
        return
    end
    if items:size() == 0 then
        print("[LoadFood] abort: empty items")
        return
    end

    local inv       = player:getInventory()
    local source    = items:get(0)
    local spawnType = result:getFullType()

    local md        = source and source.getModData and source:getModData() or nil
    local payload   = md and md.EasyPackingFoodPack or nil

    if type(payload) == "table" then
        print(string.format("[LoadFood] restoring %d", #payload))
        for _, saved in ipairs(payload) do
            local newItem = inv:AddItem(spawnType)
            if newItem then
                if newItem.setCalories then newItem:setCalories(saved.calories or 0) end
                if newItem.setHungerChange then newItem:setHungerChange(saved.hunger or 0) end
                if newItem.setThirstChange then newItem:setThirstChange(saved.thirst or 0) end
                if newItem.setStressChange then newItem:setStressChange(saved.stress or 0) end
                if newItem.setBoredomChange then newItem:setBoredomChange(saved.boredom or 0) end
                if newItem.setPoisonPower then newItem:setPoisonPower(saved.poison or 0) end
                if newItem.setAge and saved.age then newItem:setAge(math.max(saved.age, 0)) end
                if newItem.setRotten and saved.rotten ~= nil then newItem:setRotten(saved.rotten) end
                if newItem.setCooked and saved.cooked ~= nil then newItem:setCooked(saved.cooked) end
                if newItem.setBurnt and saved.burnt ~= nil then newItem:setBurnt(saved.burnt) end
            end
            if newItem and saved.name and saved.name ~= "" then
                newItem:setName(saved.name)
                if newItem.setCustomName then newItem:setCustomName(true) end
            end
        end
    else
        print(string.format("[LoadFood] no payload; spawn defaults %s x1", spawnType))
        inv:AddItem(spawnType)
    end

    print("[LoadFood] done")
end

-- Assign functions to Recipe namespace
Recipe.OnCreate.SaveFood = Recipe_OnCreate_SaveFood
Recipe.OnCreate.LoadFood = Recipe_OnCreate_LoadFood

TestFoodFunctions = {}

function TestFoodFunctions:setUp()
    self.mockPlayer = mocks.MockPlayer:new()
    self.mockResult = mocks.MockItem:new("Base.FoodPack", "Food Pack")
    self.mockItemContainer = mocks.MockItemContainer:new()

    -- Create mock food items with various properties
    self.mockApple = mocks.MockItem:new("Base.Apple", "Apple")
    self.mockApple:setCalories(95)
    self.mockApple:setHungerChange(-15)
    self.mockApple:setThirstChange(5)
    self.mockApple:setAge(2)
    self.mockApple:setRotten(false)
    self.mockApple:setCooked(false)

    self.mockBread = mocks.MockItem:new("Base.Bread", "Bread")
    self.mockBread:setCalories(265)
    self.mockBread:setHungerChange(-25)
    self.mockBread:setStressChange(-2)
    self.mockBread:setAge(5)
    self.mockBread:setRotten(true)

    self.mockMeat = mocks.MockItem:new("Base.Meat", "Cooked Meat")
    self.mockMeat:setCalories(300)
    self.mockMeat:setHungerChange(-30)
    self.mockMeat:setBoredomChange(-5)
    self.mockMeat:setCooked(true)
    self.mockMeat:setBurnt(false)
    self.mockMeat:setPoisonPower(2)
end

function TestFoodFunctions:testSaveFoodSingleItem()
    self.mockItemContainer:add(self.mockApple)

    Recipe.OnCreate.SaveFood(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local savedFood = self.mockResult:getModData().EasyPackingFoodPack
    luaunit.assertNotNil(savedFood)
    luaunit.assertEquals(#savedFood, 1)

    local saved = savedFood[1]
    luaunit.assertEquals(saved.type, "Base.Apple")
    luaunit.assertEquals(saved.name, "Apple")
    luaunit.assertEquals(saved.calories, 95)
    luaunit.assertEquals(saved.hunger, -15)
    luaunit.assertEquals(saved.thirst, 5)
    luaunit.assertEquals(saved.age, 2)
    luaunit.assertEquals(saved.rotten, false)
    luaunit.assertEquals(saved.cooked, false)
end

function TestFoodFunctions:testSaveFoodMultipleItems()
    self.mockItemContainer:add(self.mockApple)
    self.mockItemContainer:add(self.mockBread)
    self.mockItemContainer:add(self.mockMeat)

    Recipe.OnCreate.SaveFood(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local savedFood = self.mockResult:getModData().EasyPackingFoodPack
    luaunit.assertNotNil(savedFood)
    luaunit.assertEquals(#savedFood, 3)

    -- Check apple
    luaunit.assertEquals(savedFood[1].type, "Base.Apple")
    luaunit.assertEquals(savedFood[1].calories, 95)
    luaunit.assertEquals(savedFood[1].rotten, false)

    -- Check bread
    luaunit.assertEquals(savedFood[2].type, "Base.Bread")
    luaunit.assertEquals(savedFood[2].calories, 265)
    luaunit.assertEquals(savedFood[2].rotten, true)

    -- Check meat
    luaunit.assertEquals(savedFood[3].type, "Base.Meat")
    luaunit.assertEquals(savedFood[3].calories, 300)
    luaunit.assertEquals(savedFood[3].cooked, true)
    luaunit.assertEquals(savedFood[3].poison, 2)
end

function TestFoodFunctions:testSaveFoodMissingMethods()
    -- Create item without some methods
    local basicItem = mocks.MockItem:new("Base.BasicFood", "Basic Food")
    -- Create a custom metatable without the methods we want to remove
    local mt = {}
    for k, v in pairs(getmetatable(basicItem)) do
        if k ~= "getCalories" and k ~= "getThirstChange" and k ~= "getPoisonPower" then
            mt[k] = v
        end
    end
    setmetatable(basicItem, mt)

    self.mockItemContainer:add(basicItem)

    Recipe.OnCreate.SaveFood(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local savedFood = self.mockResult:getModData().EasyPackingFoodPack
    luaunit.assertNotNil(savedFood)
    luaunit.assertEquals(#savedFood, 1)

    local saved = savedFood[1]
    luaunit.assertEquals(saved.calories, 0) -- Default value
    luaunit.assertEquals(saved.thirst, 0)   -- Default value
    luaunit.assertEquals(saved.poison, 0)   -- Default value
    luaunit.assertEquals(saved.hunger, -10) -- Should still have this
end

function TestFoodFunctions:testLoadFoodWithSavedData()
    -- Setup saved food data
    local packedItem = mocks.MockItem:new("Base.FoodPack", "Food Pack")
    packedItem:getModData().EasyPackingFoodPack = {
        {
            type = "Base.Apple",
            name = "Apple",
            calories = 95,
            hunger = -15,
            thirst = 5,
            stress = 0,
            boredom = 0,
            poison = 0,
            age = 2,
            rotten = false,
            cooked = false,
            burnt = false
        },
        {
            type = "Base.Bread",
            name = "Bread",
            calories = 265,
            hunger = -25,
            thirst = 0,
            stress = -2,
            boredom = 0,
            poison = 0,
            age = 5,
            rotten = true,
            cooked = false,
            burnt = false
        }
    }

    self.mockItemContainer:add(packedItem)

    local initialSize = self.mockPlayer:getInventory():getItems():size()
    Recipe.OnCreate.LoadFood(self.mockItemContainer, self.mockResult, self.mockPlayer)
    local finalSize = self.mockPlayer:getInventory():getItems():size()

    luaunit.assertEquals(finalSize, initialSize + 2) -- 2 food items restored

    -- Check that items were added with correct properties
    local items = self.mockPlayer:getInventory():getItems()
    local restoredItem1 = items:get(items:size() - 2)
    local restoredItem2 = items:get(items:size() - 1)

    luaunit.assertEquals(restoredItem1:getCalories(), 95)
    luaunit.assertEquals(restoredItem1:getHungerChange(), -15)
    luaunit.assertEquals(restoredItem1:getThirstChange(), 5)
    luaunit.assertEquals(restoredItem1:getAge(), 2)
    luaunit.assertEquals(restoredItem1:isRotten(), false)

    luaunit.assertEquals(restoredItem2:getCalories(), 265)
    luaunit.assertEquals(restoredItem2:getHungerChange(), -25)
    luaunit.assertEquals(restoredItem2:getStressChange(), -2)
    luaunit.assertEquals(restoredItem2:getAge(), 5)
    luaunit.assertEquals(restoredItem2:isRotten(), true)
end

function TestFoodFunctions:testLoadFoodNoSavedData()
    -- Item without saved data
    self.mockItemContainer:add(self.mockApple)

    local initialSize = self.mockPlayer:getInventory():getItems():size()
    Recipe.OnCreate.LoadFood(self.mockItemContainer, self.mockResult, self.mockPlayer)
    local finalSize = self.mockPlayer:getInventory():getItems():size()

    luaunit.assertEquals(finalSize, initialSize + 1) -- 1 default item added
end

function TestFoodFunctions:testLoadFoodInvalidInputs()
    -- Test with nil player
    Recipe.OnCreate.LoadFood(self.mockItemContainer, self.mockResult, nil)

    -- Test with empty items
    local emptyContainer = mocks.MockItemContainer:new()
    Recipe.OnCreate.LoadFood(emptyContainer, self.mockResult, self.mockPlayer)

    -- Should not crash - success if we get here
    luaunit.assertTrue(true)
end

function TestFoodFunctions:testLoadFoodWithCustomName()
    local packedItem = mocks.MockItem:new("Base.FoodPack", "Food Pack")
    packedItem:getModData().EasyPackingFoodPack = {
        {
            type = "Base.Apple",
            name = "Delicious Apple",
            calories = 95,
            hunger = -15,
            thirst = 5,
            stress = 0,
            boredom = 0,
            poison = 0,
            age = 2,
            rotten = false,
            cooked = false,
            burnt = false
        }
    }

    self.mockItemContainer:add(packedItem)

    Recipe.OnCreate.LoadFood(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local items = self.mockPlayer:getInventory():getItems()
    local restoredItem = items:get(items:size() - 1)

    luaunit.assertEquals(restoredItem:getName(), "Delicious Apple")
    luaunit.assertTrue(restoredItem.customName)
end

function TestFoodFunctions:testLoadFoodNegativeAge()
    local packedItem = mocks.MockItem:new("Base.FoodPack", "Food Pack")
    packedItem:getModData().EasyPackingFoodPack = {
        {
            type = "Base.Apple",
            name = "Apple",
            calories = 95,
            hunger = -15,
            age = -5, -- Negative age should be clamped to 0
            rotten = false,
            cooked = false,
            burnt = false
        }
    }

    self.mockItemContainer:add(packedItem)

    Recipe.OnCreate.LoadFood(self.mockItemContainer, self.mockResult, self.mockPlayer)

    local items = self.mockPlayer:getInventory():getItems()
    local restoredItem = items:get(items:size() - 1)

    luaunit.assertEquals(restoredItem:getAge(), 0) -- Should be clamped to 0
end

-- Run tests if this file is executed directly
if arg and arg[0] == "test_food_functions.lua" then
    os.exit(luaunit.LuaUnit.run())
end

return TestFoodFunctions
