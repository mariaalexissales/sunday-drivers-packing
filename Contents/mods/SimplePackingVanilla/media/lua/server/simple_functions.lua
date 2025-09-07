local defaultItemAmounts = {}
local defaultFoodItems = {}

-- ==========================
-- == Utility Functions ==
-- ==========================

function AMSI(item, count, player)
    print("[Debug] Adding", count + 1, item)
    for x = 0, count do
        player:getInventory():AddItem(item)
    end
end

function recipe_opencigpack(items, result, player)
    AMSI("Base.Cigarettes", 0, player);
end

local function getHunger(item)
    return (item.getHungerChange and item:getHungerChange())
        or (item.getHungChange and item:getHungChange())
        or 0
end

-- ==========================
-- == Recipe OnTest ==
-- ==========================

function Recipe.OnTest.IsFavorite(items, result)
    return not items:isFavorite()
end

function Recipe.OnTest.FullAndNotTainted(items)
    return items:getUsedDelta() == 1 and Recipe.OnTest.NotTaintedWater(items)
end

function Recipe.OnTest.WholeFood(item)
    local baseHunger = math.abs(item:getBaseHunger())
    local hungerChange = math.abs(item:getHungerChange())
    if item:isFresh() then return not (baseHunger * 0.99 > hungerChange) end
    return not (baseHunger * 0.99 > hungerChange)
end

function Recipe.OnTest.WholeItem(item)
    return item:getCondition() == item:getConditionMax()
end

function Recipe.OnTest.IsEmpty(items, result)
    print("DEBUG: IsEmpty called")

    if not items then
        print("DEBUG: items is nil")
        return false
    end

    print("DEBUG: items type: " .. tostring(type(items)))

    -- Check if items is an ItemContainer
    if items.getItems then
        print("DEBUG: items has getItems method")
        local itemsList = items:getItems()
        if itemsList then
            print("DEBUG: got items list, size: " .. tostring(itemsList:size()))
            if itemsList:size() == 0 then
                print("DEBUG: no items in container")
                return false
            end
            local item = itemsList:get(0)
            print("DEBUG: got first item: " .. tostring(item and item:getType() or "nil"))
        else
            print("DEBUG: getItems returned nil")
            return false
        end
        -- Check if items is directly an item list
    elseif items.size then
        print("DEBUG: items has size method")
        if items:size() == 0 then
            print("DEBUG: no items in list")
            return false
        end
        local item = items:get(0)
        print("DEBUG: got first item: " .. tostring(item and item:getType() or "nil"))
        -- Check if items is a single item
    elseif items.getType then
        print("DEBUG: items appears to be a single item")
        local item = items
        print("DEBUG: single item type: " .. tostring(item:getType()))
    else
        print("DEBUG: unknown items type - checking available methods")
        -- Try to find what methods are available
        local mt = getmetatable(items)
        if mt and mt.__index then
            print("DEBUG: items has metatable")
        end
        return false
    end

    -- Now check if the item is a container
    local item = nil
    if items.getItems then
        local itemsList = items:getItems()
        if itemsList and itemsList:size() > 0 then
            item = itemsList:get(0)
        end
    elseif items.size and items:size() > 0 then
        item = items:get(0)
    elseif items.getType then
        item = items
    end

    if not item then
        print("DEBUG: no item found")
        return false
    end

    print("DEBUG: checking if item is container")
    print("DEBUG: has getContainer: " .. tostring(item.getContainer ~= nil))

    if item.getContainer and item:getContainer() then
        local container = item:getContainer()
        print("DEBUG: container exists")
        if container and container.getItems then
            local isEmpty = container:getItems():isEmpty()
            print("DEBUG: container is empty: " .. tostring(isEmpty))
            return isEmpty
        else
            print("DEBUG: container or getItems is nil")
        end
    else
        print("DEBUG: item is not a container")
    end

    return false
end

-- ==========================
-- == Save/Load Functions ==
-- ==========================

function Recipe.OnCreate.SaveUses(items, result, player)
    local remainingUses = {};
    for i = 0, items:size() - 1 do
        ---@type Item
        local item = items:get(i)
        if item and instanceof(item, "DrainableComboItem") then
            table.insert(remainingUses, item:getDelta())
        end
    end
    result:getModData().EasyPackingRemainingUses = remainingUses
end

---@param items Item
---@param result InventoryItem
---@param player IsoGameCharacter
function Recipe.OnCreate.LoadUses(items, result, player)
    if instanceof(result, "DrainableComboItem") then
        local savedUses = items:get(0):getModData().EasyPackingRemainingUses
        if savedUses then
            local inventory = player:getInventory()
            local itemToAdd = result:getFullType()
            for k, savedUse in pairs(savedUses) do
                ---@type DrainableComboItem
                local newItem = inventory:AddItem(itemToAdd)
                newItem:setDelta(savedUse)
            end
        else
            local inventory = player:getInventory()
            local itemToAdd = result:getFullType()
            local amount = defaultItemAmounts[items:get(0):getFullType()]
            for i = 1, amount do
                inventory:AddItem(itemToAdd)
            end
        end
    end
end

---@param items Item
---@param result InventoryItem
---@param player IsoGameCharacter
function Recipe.OnCreate.SaveFood(items, result, player)
    print(string.format("[SaveFood] start - count=%d", items:size()))
    local list = {}

    for i = 0, items:size() - 1 do
        ---@type InventoryItem
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

---@param items Item
---@param result InventoryItem
---@param player IsoGameCharacter
function Recipe.OnCreate.LoadFood(items, result, player)
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
            ---@type InventoryItem
            local newItem = inv:AddItem(spawnType)
            if newItem and instanceof(newItem, "Food") then
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
        local defaults = defaultFoodItems or {}
        local key      = source.getFullType and source:getFullType() or ""
        local count    = defaults[key] or 1
        print(string.format("[LoadFood] no payload; spawn defaults %s x%d", spawnType, count))
        for i = 1, count do inv:AddItem(spawnType) end
    end

    print("[LoadFood] done")
end

-- ==========================
-- == Rope and Container Load ==
-- ==========================

function Recipe.OnCreate.LoadUsesOneRope(items, result, player)
    Recipe.OnCreate.LoadUses(items, result, player)
    Recipe.OnCreate.Unpack1Rope(items, result, player)
end

function Recipe.OnCreate.LoadUsesTwoRope(items, result, player)
    Recipe.OnCreate.LoadUses(items, result, player)
    Recipe.OnCreate.Unpack2Rope(items, result, player)
end

function Recipe.OnCreate.LoadUsesOneSheetRope(items, result, player)
    Recipe.OnCreate.LoadUses(items, result, player)
    Recipe.OnCreate.Unpack1SheetRope(items, result, player)
end

function Recipe.OnCreate.LoadUsesTwoSheetRope(items, result, player)
    Recipe.OnCreate.LoadUses(items, result, player)
    Recipe.OnCreate.Unpack2SheetRope(items, result, player)
end

function Recipe.OnCreate.LoadUsesOneWoodenContainer(items, result, player)
    Recipe.OnCreate.LoadUses(items, result, player)
    Recipe.OnCreate.Unpack1WoodenContainer(items, result, player)
end

function Recipe.OnCreate.LoadUsesTwoWoodenContainer(items, result, player)
    Recipe.OnCreate.LoadUses(items, result, player)
    Recipe.OnCreate.Unpack2WoodenContainer(items, result, player)
end

-- ==========================
-- == Splitting/Merging ==
-- ==========================

function Recipe.OnCreate.MergeUses(items, result, player)
    local toMerge = {}
    for i = 0, items:size() - 1 do
        local savedUses = items:get(i):getModData().EasyPackingRemainingUses
        if savedUses then
            for _, v in pairs(savedUses) do
                table.insert(toMerge, v)
            end
        else
            for j = 0, defaultItemAmounts[items:get(0):getFullType()] do
                table.insert(toMerge, 1)
            end
        end
    end
    result:getModData().EasyPackingRemainingUses = toMerge
end

function Recipe.OnCreate.SplitUsesInTwo(items, result, player)
    local savedUses = items:get(0):getModData().EasyPackingRemainingUses
    local itemToAdd = result:getFullType()
    local inventory = player:getInventory()
    local unpackedModData = { {}, {} }

    if savedUses then
        for i = 1, #savedUses / 2 do table.insert(unpackedModData[1], savedUses[i]) end
        for i = #savedUses / 2 + 1, #savedUses do table.insert(unpackedModData[2], savedUses[i]) end
    else
        local amount = defaultItemAmounts[items:get(0):getFullType()]
        for i = 1, amount / 2 do table.insert(unpackedModData[1], 1) end
        for i = amount / 2 + 1, amount do table.insert(unpackedModData[2], 1) end
    end

    for _, v in pairs(unpackedModData) do
        local newItem = inventory:AddItem(itemToAdd)
        newItem:getModData().EasyPackingRemainingUses = v
    end
end

-- ==========================
-- == Unpack Functions ==
-- ==========================

function Recipe.OnCreate.Unpack2SheetRope(items, result, player)
    player:getInventory():AddItem("Base.SheetRope")
    player:getInventory():AddItem("Base.SheetRope")
end

function Recipe.OnCreate.Unpack2Rope(items, result, player)
    player:getInventory():AddItem("Base.Rope")
    player:getInventory():AddItem("Base.Rope")
end

function Recipe.OnCreate.Unpack1SheetRope(items, result, player)
    player:getInventory():AddItem("Base.SheetRope")
end

function Recipe.OnCreate.Unpack1Rope(items, result, player)
    player:getInventory():AddItem("Base.Rope")
end

function Recipe.OnCreate.Unpack2WoodenContainer(items, result, player)
    player:getInventory():AddItem("SP.WoodenContainer")
    player:getInventory():AddItem("SP.WoodenContainer")
end

function Recipe.OnCreate.Unpack1WoodenContainer(items, result, player)
    player:getInventory():AddItem("SP.WoodenContainer")
end

-- ==========================
-- == Init Tracking Tables ==
-- ==========================

local function saveItemAmounts()
    local scriptManager = ScriptManager.instance
    local recipes = scriptManager:getAllRecipes()
    for i = 0, recipes:size() - 1 do
        local recipe = recipes:get(i)
        if recipe and recipe:getLuaCreate() == "Recipe.OnCreate.SaveUses" then
            local source = recipe:getSource()
            if source and source:size() > 0 then
                local recipeSource = source:get(0)
                local itemName = recipeSource:getOnlyItem()
                local item = scriptManager:FindItem(itemName)
                if item and item:getTypeString() == "Drainable" then
                    local amount = recipeSource:getCount()
                    defaultItemAmounts[recipe:getResult():getFullType()] = amount
                end
            end
        end
    end
end

local function saveNutritionAmounts()
    local scriptManager = ScriptManager.instance
    local recipes = scriptManager:getAllRecipes()
    for i = 0, recipes:size() - 1 do
        local recipe = recipes:get(i)
        if recipe and recipe:getLuaCreate() == "Recipe.OnCreate.SaveFood" then
            local source = recipe:getSource()
            if source and source:size() > 0 then
                local recipeSource = source:get(0)
                local itemName = recipeSource:getOnlyItem()
                local item = scriptManager:FindItem(itemName)
                if item then
                    local amount = recipeSource:getCount()
                    defaultFoodItems[recipe:getResult():getFullType()] = amount
                end
            end
        end
    end
end

Events.OnInitGlobalModData.Add(saveItemAmounts)
Events.OnInitGlobalModData.Add(saveNutritionAmounts)
