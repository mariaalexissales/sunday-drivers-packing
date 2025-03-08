print("[EasyPacking] Script is loading...")

local defaultItemHungerValues = {}

function Recipe.OnTest.IsFavorite(items, result)
	return not items:isFavorite()
end

function Recipe.OnCreate.SaveHunger(items, result, player)
    local hungerValues = {}
    for i = 0, items:size() - 1 do
        --@type Item
        local item = items:get(i)
        if item and instanceof(item, "Food") then
            table.insert(hungerValues, item:getHungerChange())
        end
    end
    result:getModData().EasyPackingHungerValues = hungerValues
end

function Recipe.OnCreate.LoadHunger(items, result, player)
    if instanceof(result, "Food") then
        local savedHunger = items:get(0):getModData().EasyPackingHungerValues
        if savedHunger then
            local inventory = player:getInventory()
            local itemToAdd = result:getFullType()
            for _, hungerValue in pairs(savedHunger) do
                local newItem = inventory:AddItem(itemToAdd)
                newItem:setHungerChange(hungerValue)
            end
        else
            -- If no saved hunger values exist, default to normal crafting behavior
            local inventory = player:getInventory()
            local itemToAdd = result:getFullType()
            local amount = defaultItemAmounts[items:get(0):getFullType()] or 1
            for i = 1, amount do
                inventory:AddItem(itemToAdd)
            end
        end
    end
end

local function saveItemHungerValues()
    local scriptManager = ScriptManager.instance
    local recipes = scriptManager:getAllRecipes()
    for i = 0, recipes:size() - 1 do
        ---@type Recipe
        local recipe = recipes:get(i)
        -- Check if the recipe has to save hunger values
        local recipeFunc = recipe:getLuaCreate()
        if recipeFunc == "Recipe.OnCreate.SaveHunger" then
            -- We assume the food item is the first item in the recipe source
            local recipeSource = recipe:getSource():get(0)
            local itemName = recipeSource:getOnlyItem()

            -- Check if the item is food (to avoid errors)
            local item = scriptManager:FindItem(itemName)
            if item and item:getTypeString() == "Food" then
                local hungerValue = item:getHungerChange()
                local recipeResult = recipe:getResult():getFullType()
                defaultItemHungerValues[recipeResult] = hungerValue
                print("Saved Hunger Value:", recipeResult, hungerValue)
            end
        end
    end
end

-- Ensure this function runs when the mod loads
Events.OnInitGlobalModData.Add(saveItemHungerValues)

print("[EasyPacking] Script finished loading!")