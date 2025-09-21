if AdminMenu then return end
AdminMenu = {}

local function isAdminOrDebug(player)
    if isDebugEnabled() then return true end
    local lvl = getAccessLevel()
    return lvl == "admin" or lvl == "moderator"
end

local function getCursorSquare(worldobjects)
    if worldobjects and #worldobjects > 0 then
        local sq = worldobjects[1] and worldobjects[1]:getSquare()
        if sq then return sq end
    end
    local p = getSpecificPlayer(0)
    return p and p:getSquare() or nil
end

local function sendForceSpawn(profKey, sq)
    if not sq then return end
    local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ(), prof = profKey }
    if isClient() then
        sendClientCommand("PRMeta", "ForceSpawn", args)
    else
        if Server and Server.forceSpawn then Server.forceSpawn(args) end
    end
end

local function onFill(playerNum, context, worldobjects, test)
    if test then return end
    if not isClient() and not isServer() then return end -- works SP/MP
    local player = getSpecificPlayer(playerNum)
    if not isAdminOrDebug(player) then return end

    local root = context:addOption("[Packing Meta Event]")
    local sub  = ISContextMenu:getNew(context); context:addSubMenu(root, sub)

    local profs = { "medical", "police", "fire" }
    for _, key in ipairs(profs) do
        sub:addOption("Spawn trio: " .. key, player, function()
            local sq = getCursorSquare(worldobjects)
            sendForceSpawn(key, sq)
        end)
    end

    context:addOption("Spawn default at cursor", player, function()
        local sq = getCursorSquare(worldobjects)
        local prof = (Sandbox and Sandbox.getDefaultProf and Sandbox.getDefaultProf()) or "medical"
        sendForceSpawn(prof, sq)
    end)

    context:addOption("Roll daily chance now", player, function()
        if isClient() then
            sendClientCommand("PRMeta", "RollNow", {})
        else
            if Server and Server.rollNow then Server.rollNow() end
        end
    end)
end

Events.OnFillWorldObjectContextMenu.Add(onFill)
