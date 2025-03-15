print("[EasyPacking] Script is loading...")

local defaultItemHungerValues = {}

function Recipe.OnTest.IsFavorite(items, result)
	return not items:isFavorite()
end

-- Function to save all relevant food data dynamically
function Recipe.OnCreate.SaveFood(items, result, player)
    local savedFoodData = {}

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item and instanceof(item, "Food") then
            print("[DEBUG] Serializing food item:", item:getFullType())

            local foodData = {
                type = item:getFullType(),  -- Store item type to recreate later
                modData = item:getModData(),  -- Preserve custom mod data
            }

            -- Save all food stats dynamically
            local properties = {
                "Calories", "Carbohydrates", "Proteins", "Lipids",
                "ThirstChange", "HungerChange", "Age", "OffAge",
                "GoodHot", "BadInMicrowave", "Heat", "Cooked",
                "Burnt", "CookedInMicrowave", "Rotten", "PoisonPower",
                "PoisonDetectionLevel", "BaseHunger", "Weight",
                "ActualWeight", "Uses", "Name", "Tooltip",
                "BoredomChange", "UnhappyChange"
            }

            for _, prop in ipairs(properties) do
                local getter = "get" .. prop
                if item[getter] then
                    foodData[prop] = item[getter](item)
                end
            end

            table.insert(savedFoodData, foodData)
            print("[DEBUG] Saved item data:", foodData)
        end
    end

    result:getModData().EasyPackingFoodValues = savedFoodData
end


-- Function to restore all saved food attributes dynamically
function Recipe.OnCreate.LoadFood(items, result, player)
    print("[DEBUG] LoadFood function called")

    if instanceof(result, "Food") then
        print("[DEBUG] Result is a Food item")

        local savedFoodData = items:get(0):getModData().EasyPackingFoodValues
        print("[DEBUG] Retrieved savedFoodData:", savedFoodData)

        if savedFoodData then
            print("[DEBUG] Found saved food data, processing...")

            local inventory = player:getInventory()

            for _, foodData in ipairs(savedFoodData) do
                print("[DEBUG] Restoring food item:", foodData.type)

                -- Recreate item
                local newItem = inventory:AddItem(foodData.type)

                -- Restore all stored properties dynamically
                for key, value in pairs(foodData) do
                    if key ~= "type" and key ~= "modData" then
                        local setter = "set" .. key
                        if newItem[setter] then
                            newItem[setter](newItem, value)
                        end
                    end
                end

                -- Restore modData
                if foodData.modData then
                    for k, v in pairs(foodData.modData) do
                        newItem:getModData()[k] = v
                    end
                end

                print("[DEBUG] Restored food item:", newItem:getFullType())
            end
        else
            print("[DEBUG] No saved food stats found, using default item amounts")
            local inventory = player:getInventory()
            local itemToAdd = result:getFullType()
            local amount = defaultItemAmounts[items:get(0):getFullType()] or 1

            print(string.format("[DEBUG] Default item amount: %d", amount))
            for i = 1, amount do
                print(string.format("[DEBUG] Adding item %d/%d to inventory", i, amount))
                inventory:AddItem(itemToAdd)
            end
        end
    else
        print("[DEBUG] Result is not a Food item, skipping LoadFood logic")
    end
end



-- Ensure this function runs when the mod loads
Events.OnInitGlobalModData.Add(saveItemFoodValues)

print("[EasyPacking] Script finished loading!")