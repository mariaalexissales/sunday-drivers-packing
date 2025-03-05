
function Recipe.OnTest.FullAndNotTainted(items)
	return items:getUsedDelta() == 1 and Recipe.OnTest.NotTaintedWater(items)
end

function Recipe.OnTest.Full(items)
	return items:getUsedDelta() == 1
end

function Recipe.OnTest.WholeFood(item)
    local baseHunger = math.abs(item:getBaseHunger())
    local hungerChange = math.abs(item:getHungerChange())
	if item:isFresh() then return not (baseHunger * 0.99 > hungerChange) end
    return not ((baseHunger * 0.99) > hungerChange)
end

function Recipe.OnTest.WholeItem(item)
	local maxItemCondition = item:getConditionMax()
	return item:getCondition() == maxItemCondition
end

function Recipe.OnTest.IsFavorite(items, result)
	return not items:isFavorite()
end