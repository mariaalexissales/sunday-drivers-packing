

function AMSI(item, count, player)
	for x=0, count do
		player:getInventory():AddItem(item);
	end
end

function recipe_opencigpack(items, result, player)
	AMSI("Base.Cigarettes", 0, player);
end

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

function Recipe.OnCreate.UnpackCarpentrySkillBook(items, result, player)
	player:getInventory():AddItem("Base.BookCarpentry2");
	player:getInventory():AddItem("Base.BookCarpentry3");
	player:getInventory():AddItem("Base.BookCarpentry4");
	player:getInventory():AddItem("Base.BookCarpentry5");
end

function Recipe.OnCreate.UnpackCookingSkillBook(items, result, player)
	player:getInventory():AddItem("Base.BookCooking2");
	player:getInventory():AddItem("Base.BookCooking3");
	player:getInventory():AddItem("Base.BookCooking4");
	player:getInventory():AddItem("Base.BookCooking5");
end

function Recipe.OnCreate.UnpackElectricitySkillBook(items, result, player)
	player:getInventory():AddItem("Base.BookElectrician2");
	player:getInventory():AddItem("Base.BookElectrician3");
	player:getInventory():AddItem("Base.BookElectrician4");
	player:getInventory():AddItem("Base.BookElectrician5");
end

function Recipe.OnCreate.UnpackFarmingSkillBook(items, result, player)
	player:getInventory():AddItem("Base.BookFarming2");
	player:getInventory():AddItem("Base.BookFarming3");
	player:getInventory():AddItem("Base.BookFarming4");
	player:getInventory():AddItem("Base.BookFarming5");
end

function Recipe.OnCreate.UnpackFirstaidSkillBook(items, result, player)
	player:getInventory():AddItem("Base.BookFirstAid2");
	player:getInventory():AddItem("Base.BookFirstAid3");
	player:getInventory():AddItem("Base.BookFirstAid4");
	player:getInventory():AddItem("Base.BookFirstAid5");
end

function Recipe.OnCreate.UnpackFishingSkillBook(items, result, player)
	player:getInventory():AddItem("Base.BookFishing2");
	player:getInventory():AddItem("Base.BookFishing3");
	player:getInventory():AddItem("Base.BookFishing4");
	player:getInventory():AddItem("Base.BookFishing5");
end

function Recipe.OnCreate.UnpackMetalworkSkillBook(items, result, player)
	player:getInventory():AddItem("Base.BookMetalWelding2");
	player:getInventory():AddItem("Base.BookMetalWelding3");
	player:getInventory():AddItem("Base.BookMetalWelding4");
	player:getInventory():AddItem("Base.BookMetalWelding5");
end

function Recipe.OnCreate.UnpackMechanicsSkillBook(items, result, player)
	player:getInventory():AddItem("Base.BookMechanic2");
	player:getInventory():AddItem("Base.BookMechanic3");
	player:getInventory():AddItem("Base.BookMechanic4");
	player:getInventory():AddItem("Base.BookMechanic5");
end

function Recipe.OnCreate.UnpackTailoringSkillBook(items, result, player)
	player:getInventory():AddItem("Base.BookTailoring2");
	player:getInventory():AddItem("Base.BookTailoring3");
	player:getInventory():AddItem("Base.BookTailoring4");
	player:getInventory():AddItem("Base.BookTailoring5");
end

function Recipe.OnCreate.UnpackTrappingSkillBook(items, result, player)
	player:getInventory():AddItem("Base.BookTrapping2");
	player:getInventory():AddItem("Base.BookTrapping3");
	player:getInventory():AddItem("Base.BookTrapping4");
	player:getInventory():AddItem("Base.BookTrapping5");
end

function Recipe.OnCreate.UnpackForagingSkillBook(items, result, player)
	player:getInventory():AddItem("Base.BookForaging2");
	player:getInventory():AddItem("Base.BookForaging3");
	player:getInventory():AddItem("Base.BookForaging4");
	player:getInventory():AddItem("Base.BookForaging5");
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

function Recipe.OnCreate.Unpack2WoodenContainer(items, result, player)
	player:getInventory():AddItem("Packing.WoodenContainer");
	player:getInventory():AddItem("Packing.WoodenContainer");
end

function Recipe.OnCreate.Unpack1WoodenContainer(items, result, player)
	player:getInventory():AddItem("Packing.WoodenContainer");
end

campingFuelType["10pkRag"] = 50/60.0;
campingFuelType["50pkRag"] = 5;
campingFuelType["100pkRag"] = 650/60.0;