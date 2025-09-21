if Server then return end
Server = {}

local function _safeSpawn(args)
    print("[Server] DEBUG: _safeSpawn() called")
    if not args then
        print("[Server] DEBUG: _safeSpawn() - no args provided, returning")
        return
    end
    local x, y, z = args.x, args.y, args.z or 0
    local prof    = args.prof or "medical"
    print("[Server] DEBUG: _safeSpawn() - position: (" .. tostring(x) .. "," .. tostring(y) .. "," .. z .. "), profession: " .. prof)
    if not x or not y then
        print("[Server] DEBUG: _safeSpawn() - invalid coordinates, returning")
        return
    end

    if MetaEvents and MetaEvents.spawnTrioAt then
        print("[Server] DEBUG: _safeSpawn() - calling MetaEvents.spawnTrioAt()")
        MetaEvents.spawnTrioAt(x, y, z, prof)
        print("[Server] DEBUG: _safeSpawn() - MetaEvents.spawnTrioAt() completed")
    else
        print("[Server] DEBUG: _safeSpawn() - MetaEvents.spawnTrioAt not available")
    end
end

function Server.forceSpawn(args)
    print("[Server] DEBUG: Server.forceSpawn() called")
    _safeSpawn(args)
    print("[Server] DEBUG: Server.forceSpawn() completed")
end

function Server.rollNow()
    print("[Server] DEBUG: Server.rollNow() called")
    if MetaEvents and MetaEvents.rollDailyNow then
        print("[Server] DEBUG: Server.rollNow() - calling MetaEvents.rollDailyNow()")
        MetaEvents.rollDailyNow()
        print("[Server] DEBUG: Server.rollNow() - MetaEvents.rollDailyNow() completed")
    else
        print("[Server] DEBUG: Server.rollNow() - MetaEvents.rollDailyNow not available")
    end
end

local function onClientCommand(module, command, player, args)
    print("[Server] DEBUG: onClientCommand() called - module: " .. tostring(module) .. ", command: " .. tostring(command))
    if module ~= "PRMeta" then
        print("[Server] DEBUG: onClientCommand() - wrong module, returning")
        return
    end
    -- Gate by access level
    local lvl = player and player:getAccessLevel()
    print("[Server] DEBUG: onClientCommand() - player access level: " .. tostring(lvl))
    if lvl ~= "admin" and lvl ~= "moderator" then
        print("[Server] DEBUG: onClientCommand() - insufficient access level, returning")
        return
    end

    if command == "ForceSpawn" then
        print("[Server] DEBUG: onClientCommand() - executing ForceSpawn command")
        Server.forceSpawn(args)
    elseif command == "RollNow" then
        print("[Server] DEBUG: onClientCommand() - executing RollNow command")
        Server.rollNow()
    else
        print("[Server] DEBUG: onClientCommand() - unknown command: " .. tostring(command))
    end
end

Events.OnClientCommand.Add(onClientCommand)
