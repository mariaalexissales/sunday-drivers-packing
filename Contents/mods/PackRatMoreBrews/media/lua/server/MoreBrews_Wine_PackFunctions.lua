function Recipe.OnCreate.UnpackWineMakingSkillBook(items, result, player)
	player:getInventory():AddItem("MoreBrews.BookWineMaking2");
	player:getInventory():AddItem("MoreBrews.BookWineMaking3");
	player:getInventory():AddItem("MoreBrews.BookWineMaking4");
	player:getInventory():AddItem("MoreBrews.BookWineMaking5");
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