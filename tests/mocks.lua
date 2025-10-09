-- Mock objects for Project Zomboid environment
-- Compatible with Lua 5.1

local Mocks = {}

-- Mock InventoryItem
local MockInventoryItem = {}
MockInventoryItem.__index = MockInventoryItem

function MockInventoryItem.new(fullType, name)
    local self = {
        fullType = fullType or "Base.TestItem",
        name = name or "Test Item",
        usedDelta = 1.0,
        condition = 100,
        conditionMax = 100,
        modData = {},
        baseHunger = -10,
        hungerChange = -10,
        calories = 100,
        thirstChange = 0,
        stressChange = 0,
        boredomChange = 0,
        poisonPower = 0,
        age = 0,
        rotten = false,
        cooked = false,
        burnt = false,
        fresh = true,
        favorite = false,
        delta = 1.0
    }
    setmetatable(self, MockInventoryItem)
    return self
end

function MockInventoryItem:getFullType() return self.fullType end
function MockInventoryItem:getName() return self.name end
function MockInventoryItem:setName(name) self.name = name end
function MockInventoryItem:getUsedDelta() return self.usedDelta end
function MockInventoryItem:getCondition() return self.condition end
function MockInventoryItem:getConditionMax() return self.conditionMax end
function MockInventoryItem:getModData() return self.modData end
function MockInventoryItem:getBaseHunger() return self.baseHunger end
function MockInventoryItem:getHungerChange() return self.hungerChange end
function MockInventoryItem:setHungerChange(value) self.hungerChange = value end
function MockInventoryItem:getCalories() return self.calories end
function MockInventoryItem:setCalories(value) self.calories = value end
function MockInventoryItem:getThirstChange() return self.thirstChange end
function MockInventoryItem:setThirstChange(value) self.thirstChange = value end
function MockInventoryItem:getStressChange() return self.stressChange end
function MockInventoryItem:setStressChange(value) self.stressChange = value end
function MockInventoryItem:getBoredomChange() return self.boredomChange end
function MockInventoryItem:setBoredomChange(value) self.boredomChange = value end
function MockInventoryItem:getPoisonPower() return self.poisonPower end
function MockInventoryItem:setPoisonPower(value) self.poisonPower = value end
function MockInventoryItem:getAge() return self.age end
function MockInventoryItem:setAge(value) self.age = value end
function MockInventoryItem:isRotten() return self.rotten end
function MockInventoryItem:setRotten(value) self.rotten = value end
function MockInventoryItem:isCooked() return self.cooked end
function MockInventoryItem:setCooked(value) self.cooked = value end
function MockInventoryItem:isBurnt() return self.burnt end
function MockInventoryItem:setBurnt(value) self.burnt = value end
function MockInventoryItem:isFresh() return self.fresh end
function MockInventoryItem:isFavorite() return self.favorite end
function MockInventoryItem:getDelta() return self.delta end
function MockInventoryItem:setDelta(value) self.delta = value end
function MockInventoryItem:setCustomName(value) self.customName = value end

-- Mock DrainableComboItem
local MockDrainableComboItem = {}
MockDrainableComboItem.__index = MockDrainableComboItem
setmetatable(MockDrainableComboItem, MockInventoryItem)

function MockDrainableComboItem.new(fullType, name)
    local self = MockInventoryItem.new(fullType, name)
    setmetatable(self, MockDrainableComboItem)
    return self
end

-- Mock ItemContainer
local MockItemContainer = {}
MockItemContainer.__index = MockItemContainer

function MockItemContainer.new()
    local self = {
        items = {}
    }
    setmetatable(self, MockItemContainer)
    return self
end

function MockItemContainer:getItems() return self.items end

-- Mock ArrayList (Java-like)
local MockArrayList = {}
MockArrayList.__index = MockArrayList

function MockArrayList.new()
    local self = {
        items = {}
    }
    setmetatable(self, MockArrayList)
    return self
end

function MockArrayList:add(item)
    table.insert(self.items, item)
end

function MockArrayList:get(index)
    return self.items[index + 1] -- Convert from 0-based to 1-based indexing
end

function MockArrayList:size()
    return #self.items
end

-- Mock Inventory
local MockInventory = {}
MockInventory.__index = MockInventory

function MockInventory.new()
    local self = {
        items = MockArrayList.new()
    }
    setmetatable(self, MockInventory)
    return self
end

function MockInventory:AddItem(itemType)
    local item = MockInventoryItem.new(itemType)
    self.items:add(item)
    return item
end

function MockInventory:getItems()
    return self.items
end

-- Mock Player
local MockPlayer = {}
MockPlayer.__index = MockPlayer

function MockPlayer.new()
    local self = {
        inventory = MockInventory.new()
    }
    setmetatable(self, MockPlayer)
    return self
end

function MockPlayer:getInventory()
    return self.inventory
end

-- Mock Recipe
local MockRecipe = {}
MockRecipe.__index = MockRecipe

function MockRecipe.new(result)
    local self = {
        result = result or MockInventoryItem.new()
    }
    setmetatable(self, MockRecipe)
    return self
end

function MockRecipe:getResult()
    return self.result
end

-- Global mocks
function Mocks.setup()
    -- Mock instanceof function
    _G.instanceof = function(obj, className)
        if className == "DrainableComboItem" then
            return getmetatable(obj) == MockDrainableComboItem
        end
        return false
    end

    -- Mock Recipe.OnTest and Recipe.OnCreate namespaces
    _G.Recipe = {
        OnTest = {},
        OnCreate = {},
        OnCanPerform = {}
    }

    -- Mock Events
    _G.Events = {
        OnInitGlobalModData = {
            Add = function(func) end
        }
    }

    -- Mock ScriptManager
    _G.ScriptManager = {
        instance = {
            getAllRecipes = function() return MockArrayList.new() end,
            FindItem = function(name) return MockInventoryItem.new(name) end
        }
    }
end

-- Factory functions
Mocks.MockInventoryItem = MockInventoryItem
Mocks.MockDrainableComboItem = MockDrainableComboItem
Mocks.MockItemContainer = MockItemContainer
Mocks.MockArrayList = MockArrayList
Mocks.MockInventory = MockInventory
Mocks.MockPlayer = MockPlayer
Mocks.MockRecipe = MockRecipe

return Mocks