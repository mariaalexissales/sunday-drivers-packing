local defaultItemAmounts = {}
local defaultFoodItems = {}

-- ==========================
-- == Utility Functions ==
-- ==========================

function AMSI(item, count, player)
    print("[EasyPacking][Debug] Adding", count + 1, item)
    for x = 0, count do
        player:getInventory():AddItem(item)
    end
end

function recipe_opencigpack(items, result, player)
    AMSI("Base.Cigarettes", 0, player);
end

local function callIf(item, method, ...)
    if item[method] then return item[method](item, ...) end
end


local function getHunger(item)
    return (item.getHungerChange and item:getHungerChange())
        or (item.getHungChange and item:getHungChange())
        or 0
end

local function setHunger(item, v)
    if item.setHungerChange then
        item:setHungerChange(v)
    elseif item.setHungChange then
        item:setHungChange(v)
    end
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

-- ==========================
-- == Save/Load Functions ==
-- ==========================

function Recipe.OnCreate.SaveUses(items, result, player)
    local remainingUses = {}
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item and instanceof(item, "DrainableComboItem") then
            table.insert(remainingUses, item:getDelta())
        end
    end
    result:getModData().EasyPackingRemainingUses = remainingUses
end

function Recipe.OnCreate.LoadUses(items, result, player)
    if instanceof(result, "DrainableComboItem") then
        local savedUses = items:get(0):getModData().EasyPackingRemainingUses
        local inventory = player:getInventory()
        local itemToAdd = result:getFullType()

        if savedUses then
            for _, savedUse in pairs(savedUses) do
                local newItem = inventory:AddItem(itemToAdd)
                newItem:setDelta(savedUse)
            end
        else
            local amount = defaultItemAmounts[items:get(0):getFullType()]
            for i = 1, amount do
                inventory:AddItem(itemToAdd)
            end
        end
    end
end

function Recipe.OnCreate.SaveFood(items, result, player)
    local list = {}
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it and instanceof(it, "Food") then
            local entry = {
                schemaVersion = 1,
                type          = it:getFullType(),
                name          = it:getName(),
                calories      = it:getCalories() or 0,
                hunger        = getHunger(it) or 0,
                thirst        = it:getThirstChange() or 0,
                stress        = it:getStressChange() or 0,
                boredom       = it:getBoredomChange() or 0,
                poison        = it:getPoisonPower() or 0,
                age           = it:getAge() or 0,
                rotten        = it:isRotten() or false,
                cooked        = it:isCooked() or false,
                burnt         = it:isBurnt() or false,
                useDelta      = instanceof(it, "DrainableComboItem") and it:getUsedDelta() or nil,
            }
            table.insert(list, entry)
        end
    end
    result:getModData().EasyPackingFoodPack = list
end

function Recipe.OnCreate.LoadFood(items, result, player)
    if not instanceof(result, "Food") and not instanceof(result, "InventoryItem") then return end

    local source = items and items:size() > 0 and items:get(0) or nil
    local payload = source and source:getModData() and source:getModData().EasyPackingFoodPack or nil

    local inv = player and player:getInventory()
    if not inv then return end

    local spawnType = result:getFullType()

    if payload and type(payload) == "table" then
        for _, saved in ipairs(payload) do
            local newItem = inv:AddItem(spawnType)
            if newItem and instanceof(newItem, "Food") then
                callIf(newItem, "setCalories", saved.calories or 0)
                setHunger(newItem, saved.hunger or 0)
                callIf(newItem, "setThirstChange", saved.thirst or 0)
                callIf(newItem, "setStressChange", saved.stress or 0)
                callIf(newItem, "setBoredomChange", saved.boredom or 0)
                callIf(newItem, "setPoisonPower", saved.poison or 0)
                if saved.age then
                    local age = math.max(saved.age, 0)
                    callIf(newItem, "setAge", age)
                end
                if saved.rotten ~= nil then callIf(newItem, "setRotten", saved.rotten) end
                if saved.cooked ~= nil then callIf(newItem, "setCooked", saved.cooked) end
                if saved.burnt ~= nil then callIf(newItem, "setBurnt", saved.burnt) end
                if saved.useDelta and instanceof(newItem, "DrainableComboItem") then
                    newItem:setUsedDelta(saved.useDelta)
                end

                if saved.name and saved.name ~= "" then
                    newItem:setName(saved.name)
                    if newItem.setCustomName then newItem:setCustomName(true) end
                end
            end
        end
    else
        local defaults = defaultFoodItems or {}
        local count = defaults[source and source:getFullType() or ""] or 1
        for i = 1, count do inv:AddItem(spawnType) end
    end
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
    player:getInventory():AddItem("Packing.WoodenContainer")
    player:getInventory():AddItem("Packing.WoodenContainer")
end

function Recipe.OnCreate.Unpack1WoodenContainer(items, result, player)
    player:getInventory():AddItem("Packing.WoodenContainer")
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
                    print("[EasyPacking][Debug] Saved Drainable Amount", recipe:getResult():getFullType(), amount)
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
                if item and item:getTypeString() == "Food" then
                    local amount = recipeSource:getCount()
                    defaultFoodItems[recipe:getResult():getFullType()] = amount
                    print("[EasyPacking][Debug] Saved Food Amount", recipe:getResult():getFullType(), amount)
                end
            end
        end
    end
end

Events.OnInitGlobalModData.Add(saveItemAmounts)
Events.OnInitGlobalModData.Add(saveNutritionAmounts)
