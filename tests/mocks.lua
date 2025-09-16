-- Mock objects for Project Zomboid API
local mocks = {}

-- Mock Item class
local MockItem = {}
MockItem.__index = MockItem

function MockItem:new(fullType, name)
    local item = {
        fullType = fullType or "Base.TestItem",
        name = name or "Test Item",
        delta = 1.0,
        condition = 100,
        conditionMax = 100,
        usedDelta = 1.0,
        age = 0,
        calories = 100,
        hungerChange = -10,
        thirstChange = 0,
        stressChange = 0,
        boredomChange = 0,
        poisonPower = 0,
        rotten = false,
        cooked = false,
        burnt = false,
        fresh = true,
        baseHunger = 10,
        favorite = false,
        modData = {},
        customName = false,
        container = nil
    }
    setmetatable(item, self)
    return item
end

function MockItem:getFullType() return self.fullType end
function MockItem:getName() return self.name end
function MockItem:setName(name) self.name = name end
function MockItem:getDelta() return self.delta end
function MockItem:setDelta(delta) self.delta = delta end
function MockItem:getUsedDelta() return self.usedDelta end
function MockItem:setUsedDelta(delta) self.usedDelta = delta end
function MockItem:getCondition() return self.condition end
function MockItem:getConditionMax() return self.conditionMax end
function MockItem:setCondition(condition) self.condition = condition end
function MockItem:getAge() return self.age end
function MockItem:setAge(age) self.age = age end
function MockItem:getCalories() return self.calories end
function MockItem:setCalories(calories) self.calories = calories end
function MockItem:getHungerChange() return self.hungerChange end
function MockItem:setHungerChange(hunger) self.hungerChange = hunger end
function MockItem:getThirstChange() return self.thirstChange end
function MockItem:setThirstChange(thirst) self.thirstChange = thirst end
function MockItem:getStressChange() return self.stressChange end
function MockItem:setStressChange(stress) self.stressChange = stress end
function MockItem:getBoredomChange() return self.boredomChange end
function MockItem:setBoredomChange(boredom) self.boredomChange = boredom end
function MockItem:getPoisonPower() return self.poisonPower end
function MockItem:setPoisonPower(poison) self.poisonPower = poison end
function MockItem:isRotten() return self.rotten end
function MockItem:setRotten(rotten) self.rotten = rotten end
function MockItem:isCooked() return self.cooked end
function MockItem:setCooked(cooked) self.cooked = cooked end
function MockItem:isBurnt() return self.burnt end
function MockItem:setBurnt(burnt) self.burnt = burnt end
function MockItem:isFresh() return self.fresh end
function MockItem:setFresh(fresh) self.fresh = fresh end
function MockItem:getBaseHunger() return self.baseHunger end
function MockItem:setBaseHunger(hunger) self.baseHunger = hunger end
function MockItem:isFavorite() return self.favorite end
function MockItem:setFavorite(favorite) self.favorite = favorite end
function MockItem:getModData() return self.modData end
function MockItem:setCustomName(custom) self.customName = custom end

function MockItem:getItemContainer()
    return self.container
end

function MockItem:setItemContainer(container)
    self.container = container
end

-- Mock Container class
local MockContainer = {}
MockContainer.__index = MockContainer

function MockContainer:new()
    local container = {
        items = {}
    }
    setmetatable(container, self)
    return container
end

function MockContainer:getItems()
    return {
        size = function() return #self.items end,
        get = function(_, index) return self.items[index + 1] end,
        add = function(_, item) table.insert(self.items, item) end
    }
end

-- Mock ItemContainer (list of items)
local MockItemContainer = {}
MockItemContainer.__index = MockItemContainer

function MockItemContainer:new()
    local container = {
        items = {}
    }
    setmetatable(container, self)
    return container
end

function MockItemContainer:size() return #self.items end
function MockItemContainer:get(index) return self.items[index + 1] end
function MockItemContainer:add(item) table.insert(self.items, item) end

-- Mock Inventory class
local MockInventory = {}
MockInventory.__index = MockInventory

function MockInventory:new()
    local inventory = {
        items = {}
    }
    setmetatable(inventory, self)
    return inventory
end

function MockInventory:AddItem(itemType)
    local item = MockItem:new(itemType, itemType)
    table.insert(self.items, item)
    return item
end

function MockInventory:getItems()
    local itemContainer = MockItemContainer:new()
    itemContainer.items = self.items
    return itemContainer
end

-- Mock Player class
local MockPlayer = {}
MockPlayer.__index = MockPlayer

function MockPlayer:new()
    local player = {
        inventory = MockInventory:new()
    }
    setmetatable(player, self)
    return player
end

function MockPlayer:getInventory() return self.inventory end

-- Mock Recipe class
local MockRecipe = {}
MockRecipe.__index = MockRecipe

function MockRecipe:new(name, resultType)
    local recipe = {
        name = name or "Test Recipe",
        resultType = resultType or "Base.TestResult"
    }
    setmetatable(recipe, self)
    return recipe
end

function MockRecipe:getName() return self.name end
function MockRecipe:getResult()
    return MockItem:new(self.resultType, self.resultType)
end

-- Mock ScriptManager
local MockScriptManager = {}
MockScriptManager.__index = MockScriptManager

function MockScriptManager:new()
    local manager = {
        recipes = {},
        items = {}
    }
    setmetatable(manager, self)
    return manager
end

function MockScriptManager:getAllRecipes()
    return {
        size = function() return #self.recipes end,
        get = function(_, index) return self.recipes[index + 1] end
    }
end

function MockScriptManager:FindItem(itemType)
    return self.items[itemType] or MockItem:new(itemType, itemType)
end

function MockScriptManager:addRecipe(recipe)
    table.insert(self.recipes, recipe)
end

function MockScriptManager:addItem(itemType, item)
    self.items[itemType] = item
end

-- Export mocks
mocks.MockItem = MockItem
mocks.MockContainer = MockContainer
mocks.MockItemContainer = MockItemContainer
mocks.MockInventory = MockInventory
mocks.MockPlayer = MockPlayer
mocks.MockRecipe = MockRecipe
mocks.MockScriptManager = MockScriptManager

return mocks