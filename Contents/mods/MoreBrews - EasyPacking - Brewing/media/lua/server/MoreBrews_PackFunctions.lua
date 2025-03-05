function Recipe.OnCreate.UnpackBrewingSkillBook(items, result, player)
	player:getInventory():AddItem("MoreBrews.BookBrewing2");
	player:getInventory():AddItem("MoreBrews.BookBrewing3");
	player:getInventory():AddItem("MoreBrews.BookBrewing4");
	player:getInventory():AddItem("MoreBrews.BookBrewing5");
end

function Recipe.OnCreate.Unpack2SheetRope(items, result, player)
	player:getInventory():AddItem("Base.SheetRope");
	player:getInventory():AddItem("Base.SheetRope");
end

function Recipe.OnCreate.Unpack2Rope(items, result, player)
	player:getInventory():AddItem("Base.Rope");
	player:getInventory():AddItem("Base.Rope");
end

function Recipe.OnCreate.Unpack1SheetRope(items, result, player)
	player:getInventory():AddItem("Base.SheetRope");
end

function Recipe.OnCreate.Unpack1Rope(items, result, player)
	player:getInventory():AddItem("Base.Rope");
end

function Recipe.OnTest.IsFavorite(items, result)
	return not items:isFavorite()
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