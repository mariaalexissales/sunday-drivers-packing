local defaultFoodItems = {}

function Recipe.OnTest.IsFavorite(items, result)
	return not items:isFavorite()
end

function Recipe.OnTest.IsHerb(items, result)
    return items:getFoodType() == "Herb" or items:hasTag("HerbalTea")
end


function Recipe.OnCreate.SaveFood(items, result, player)
    local foodList = {};
    for i = 0, items:size() - 1 do
        ---@type Item
        local food = items:get(i)
        if food and instanceof(food, "Food") then
            table.insert(foodList, {
                weight      = food:getActualWeight(),
                base        = food:getBaseHunger(),
                boredom     = food:getBoredomChange(),
                calories    = food:getCalories(),
                carbs       = food:getCarbohydrates(),
                endurance   = food:getEnduranceChange(),
                hunger      = food:getHungChange(),
                lipids      = food:getLipids(),
                pain        = food:getPainReduction(),
                poison      = food:getPoisonPower(),
                protein     = food:getProteins(),
                name        = food:getName(),
                thirst      = food:getThirstChange(),
                stress      = food:getStressChange(),
                unhappy     = food:getUnhappyChange(),
                age         = food:getAge(),
                rotten      = food:isRotten(),
                cooked      = food:isCooked(),
                burnt       = food:isBurnt(),
                type        = food:getFullType(),
            })
        end
    end
    result:getModData().EasyPackingFoodPack = foodList
end

---@param items Item
---@param result InventoryItem
---@param player IsoGameCharacter
function Recipe.OnCreate.LoadFood(items, result, player)
    if instanceof(result, "Food") then
        local foodList = items:get(0):getModData().EasyPackingFoodPack
        if foodList then
            local inventory = player:getInventory()
            local itemToAdd = result:getFullType()
            for k, savedFood in pairs(foodList) do
                ---@type Food
                local newItem = inventory:AddItem(itemToAdd)
                newItem:setWeight(savedFood.weight)
                newItem:SetBaseHunger(savedFood.base)
                newItem:setBoredomChange(savedFood.boredom)
                newItem:setCalories(savedFood.calories)
                newItem:setCarbohydrates(savedFood.carbs)
                newItem:setEnduranceChange(savedFood.endurance)
                newItem:setHungChange(savedFood.hunger)
                newItem:setLipids(savedFood.lipids)
                newItem:setPainReduction(savedFood.pain)
                newItem:setPoisonPower(savedFood.poison)
                newItem:setProteins(savedFood.protein)
                newItem:setName(savedFood.name)
                newItem:setThirstChange(savedFood.thirst)
                newItem:setStressChange(savedFood.stress)
                newItem:setUnhappyChange(savedFood.unhappy)
                newItem:setAge(savedFood.age)
                newItem:setRotten(savedFood.rotten)
                newItem:setCooked(savedFood.cooked)
                newItem:setBurnt(savedFood.burnt)
                newItem:setType(savedFood.type)
            end
        else
            local inventory = player:getInventory()
            local itemToAdd = result:getFullType()
            local amount = defaultFoodItems[items:get(0):getFullType()]
            for i=1,amount do
                inventory:AddItem(itemToAdd)
            end
        end
    end
end

local function saveFoodAmounts()
    local scriptManager = ScriptManager.instance
    local recipes = scriptManager:getAllRecipes()
    for i=0, recipes:size() - 1 do
        ---@type Recipe
        local recipe = recipes:get(i)
        --Check if the recipe has to save the uses
        local recipeFunc = recipe:getLuaCreate()
        if recipeFunc == "Recipe.OnCreate.SaveFood" then
            --We assume the drainable is the first item in the recipe source
            local recipeSource = recipe:getSource():get(0)
            local itemName = recipeSource:getOnlyItem()
            --Check if the item is a drainable. For non-inventory items, the type is the actual class
            if scriptManager:FindItem(itemName):getTypeString() == "Food" then
                local amount = recipeSource:getCount()
                --for inventory items, the type is its internal name
                local recipeResult = recipe:getResult():getFullType()
                defaultFoodItems[recipeResult] = amount
                print(recipeResult,amount)
                --we can now exit the inner loop early
            end
        end
    end
end

Events.OnInitGlobalModData.Add(saveFoodAmounts)