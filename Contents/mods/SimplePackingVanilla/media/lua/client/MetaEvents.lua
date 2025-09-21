-- Pack Rat— “Profession Trio” meta event
-- Works SP/MP. Triggers a loud lure (“heli-ish” sweep), a gunshot ping at the target,
-- and when the player gets close, it spawns a 3-zombie team in themed outfits.
-- On death, those zombies drop items from the packing mod.

local MetaLoot = require "MetaLoot"
local Sandbox = require "Sandbox"

if MetaEvents then return end
MetaEvents            = {}

local M               = MetaEvents
local GT              = getGameTime
local ZR              = ZombRand
local World           = getWorld()

-- ---------------------------
-- Tunables
-- ---------------------------
M.CHANCE_PER_DAY      = Sandbox.getChancePerDay()
M.MIN_PLAYER_LEVEL    = 1   -- ignore tiny early games if you want
M.HELI_SWEEP_SECONDS  = 35  -- how long the sweeping noise runs
M.HELI_NOISE_RADIUS   = 100 -- “heli” perceived radius (tiles)
M.HELI_NOISE_VOLUME   = 150 -- 0-200ish
M.GUNSHOT_RADIUS      = 120
M.GUNSHOT_VOLUME      = 170
M.PROXIMITY_TO_SPAWN  = 22 -- tiles
M.DESPAWN_TIMEOUT_HRS = 8  -- if not engaged in time, abandon

-- ---------------------------
-- Runtime state
-- ---------------------------
M.state               = {
    active      = false,
    stage       = nil, -- "sweep" -> "gunshot" -> "awaitProx" -> "spawned"
    tStart      = 0,
    tStageStart = 0,
    target      = nil, -- {x,y,z}
    profKey     = nil,
    trio        = nil, -- {"Doctor","Nurse","Doctor"}
    zombies     = {},  -- spawned zombie refs
}

local function player()
    return getSpecificPlayer(0)
end

local function nowSeconds()
    return os.time()
end

local function hoursSinceGameStart()
    return GT():getWorldAgeHours()
end

local function pickNearbyTarget(px, py, radius)
    -- Pick a reachable random square near the player
    for _ = 1, 30 do
        local dx = ZR(-radius, radius + 1)
        local dy = ZR(-radius, radius + 1)
        local x, y = px + dx, py + dy
        local sq = getCell():getGridSquare(x, y, 0)
        if sq and not sq:Is(IsoFlagType.solidfloor) then
            return { x = x, y = y, z = 0 }
        end
    end
    return { x = px + 10, y = py + 10, z = 0 }
end

local function addLoudSoundAt(x, y, z, radius, volume)
    addSound(nil, x, y, z, radius, volume)
end

local function createHordeFromTo(x1, y1, x2, y2)
    createHordeFromTo(x1, y1, x2, y2)
end

local function chooseProfession()
    print("[MetaEvents] DEBUG: chooseProfession() called")
    local profKeys = {}
    for key, _ in pairs(MetaLoot.professions) do
        table.insert(profKeys, key)
    end
    print("[MetaEvents] DEBUG: chooseProfession() - found " .. #profKeys .. " professions: " .. table.concat(profKeys, ", "))
    if #profKeys > 0 then
        local chosen = profKeys[ZR(#profKeys) + 1]
        print("[MetaEvents] DEBUG: chooseProfession() - selected: " .. chosen)
        return chosen
    end
    print("[MetaEvents] DEBUG: chooseProfession() - no professions found, returning default: medical")
    return "medical"
end

local function chooseTrio(profKey)
    print("[MetaEvents] DEBUG: chooseTrio() called with profKey: " .. profKey)
    local prof = MetaLoot.professions[profKey]
    if prof and prof.outfits and #prof.outfits > 0 then
        print("[MetaEvents] DEBUG: chooseTrio() - found profession outfits: " .. table.concat(prof.outfits, ", "))
        -- Pick 3 outfits from the profession's outfit list (can repeat)
        local outfits = prof.outfits
        local trio = {
            outfits[ZR(#outfits) + 1],
            outfits[ZR(#outfits) + 1],
            outfits[ZR(#outfits) + 1]
        }
        print("[MetaEvents] DEBUG: chooseTrio() - selected trio: " .. table.concat(trio, ", "))
        return trio
    end
    print("[MetaEvents] DEBUG: chooseTrio() - profession not found or no outfits, using fallback")
    -- fallback: three random from a default set
    local fallbackOutfits = { "Survivor", "Bandid", "BaseballPlayer" }
    local trio = {
        fallbackOutfits[ZR(#fallbackOutfits) + 1],
        fallbackOutfits[ZR(#fallbackOutfits) + 1],
        fallbackOutfits[ZR(#fallbackOutfits) + 1]
    }
    print("[MetaEvents] DEBUG: chooseTrio() - fallback trio: " .. table.concat(trio, ", "))
    return trio
end

local function startEvent()
    print("[MetaEvents] DEBUG: startEvent() called")
    local p = player()
    if not p then
        print("[MetaEvents] DEBUG: startEvent() - no player found, returning")
        return
    end
    local px, py, pz    = math.floor(p:getX()), math.floor(p:getY()), p:getZ()
    local tgt           = pickNearbyTarget(px, py, 120)
    print("[MetaEvents] DEBUG: startEvent() - player position: (" .. px .. "," .. py .. "," .. pz .. ")")
    print("[MetaEvents] DEBUG: startEvent() - target position: (" .. tgt.x .. "," .. tgt.y .. "," .. tgt.z .. ")")

    M.state.active      = true
    M.state.stage       = "sweep"
    M.state.tStart      = nowSeconds()
    M.state.tStageStart = nowSeconds()
    M.state.target      = tgt
    M.state.profKey     = chooseProfession()
    M.state.trio        = chooseTrio(M.state.profKey)
    M.state.zombies     = {}

    print("[MetaEvents] DEBUG: startEvent() - profession: " .. M.state.profKey)
    print("[MetaEvents] DEBUG: startEvent() - trio outfits: " .. table.concat(M.state.trio, ", "))

    local sx            = tgt.x + ZR(-200, 201)
    local sy            = tgt.y + ZR(-200, 201)
    print("[MetaEvents] DEBUG: startEvent() - creating horde from (" .. sx .. "," .. sy .. ") to (" .. tgt.x .. "," .. tgt.y .. ")")
    createHordeFromTo(sx, sy, tgt.x, tgt.y)
    print("[MetaEvents] DEBUG: startEvent() - event started successfully")
end

local function endEvent()
    print("[MetaEvents] DEBUG: endEvent() called")
    print("[MetaEvents] DEBUG: endEvent() - previous state: active=" .. tostring(M.state.active) .. ", stage=" .. tostring(M.state.stage))
    M.state.active  = false
    M.state.stage   = nil
    M.state.zombies = {}
    M.state.target  = nil
    print("[MetaEvents] DEBUG: endEvent() - event ended, state cleared")
end

-- Stage logic

local function tickSweep()
    print("[MetaEvents] DEBUG: tickSweep() called")
    local tgt = M.state.target
    if not tgt then
        print("[MetaEvents] DEBUG: tickSweep() - no target, returning")
        return
    end
    -- Sweep: drop a moving noise bead around the target to mimic a heli
    local t   = nowSeconds() - M.state.tStageStart
    local ang = (t % 12) / 12.0 * math.pi * 2
    local r   = 18
    local x   = tgt.x + math.floor(math.cos(ang) * r)
    local y   = tgt.y + math.floor(math.sin(ang) * r)
    print("[MetaEvents] DEBUG: tickSweep() - time elapsed: " .. t .. "s, noise at (" .. x .. "," .. y .. ")")
    addLoudSoundAt(x, y, 0, M.HELI_NOISE_RADIUS, M.HELI_NOISE_VOLUME)

    if t >= M.HELI_SWEEP_SECONDS then
        -- Transition to gunshot ping at the center
        print("[MetaEvents] DEBUG: tickSweep() - sweep complete, transitioning to awaitProx stage")
        print("[MetaEvents] DEBUG: tickSweep() - gunshot at target (" .. tgt.x .. "," .. tgt.y .. ")")
        addLoudSoundAt(tgt.x, tgt.y, 0, M.GUNSHOT_RADIUS, M.GUNSHOT_VOLUME)
        M.state.stage = "awaitProx"
        M.state.tStageStart = nowSeconds()
    end
end

local function tickAwaitProximity()
    print("[MetaEvents] DEBUG: tickAwaitProximity() called")
    local p = player()
    local tgt = M.state.target
    if not (p and tgt) then
        print("[MetaEvents] DEBUG: tickAwaitProximity() - no player or target, returning")
        return
    end
    local dx = p:getX() - tgt.x
    local dy = p:getY() - tgt.y
    local dist2 = dx * dx + dy * dy
    local dist = math.sqrt(dist2)
    print("[MetaEvents] DEBUG: tickAwaitProximity() - player distance to target: " .. dist .. " (threshold: " .. M.PROXIMITY_TO_SPAWN .. ")")

    if dist2 <= (M.PROXIMITY_TO_SPAWN * M.PROXIMITY_TO_SPAWN) then
        print("[MetaEvents] DEBUG: tickAwaitProximity() - player close enough, spawning trio")
        M.state.stage = "spawned"
        M.state.tStageStart = nowSeconds()
        -- Spawn the trio
        -- addZombiesInOutfit(x, y, z, count, {outfits...})
        -- Spawns as a cohesive group centered around x,y
        print("[MetaEvents] DEBUG: tickAwaitProximity() - spawning zombie 1 (" .. M.state.trio[1] .. ") at (" .. tgt.x .. "," .. tgt.y .. ")")
        addZombiesInOutfit(tgt.x, tgt.y, 0, 1, { M.state.trio[1] })
        print("[MetaEvents] DEBUG: tickAwaitProximity() - spawning zombie 2 (" .. M.state.trio[2] .. ") at (" .. (tgt.x + 1) .. "," .. tgt.y .. ")")
        addZombiesInOutfit(tgt.x + 1, tgt.y, 0, 1, { M.state.trio[2] })
        print("[MetaEvents] DEBUG: tickAwaitProximity() - spawning zombie 3 (" .. M.state.trio[3] .. ") at (" .. tgt.x .. "," .. (tgt.y + 1) .. ")")
        addZombiesInOutfit(tgt.x, tgt.y + 1, 0, 1, { M.state.trio[3] })

        -- We can't directly capture those references here (API returns none),
        -- so tag by proximity using a short window: we'll scan nearby zombies and mark them.
        print("[MetaEvents] DEBUG: tickAwaitProximity() - tagging spawned zombies")
        local cell = getCell()
        local taggedCount = 0
        for xi = tgt.x - 2, tgt.x + 2 do
            for yi = tgt.y - 2, tgt.y + 2 do
                local sq = cell:getGridSquare(xi, yi, 0)
                if sq then
                    local zeds = sq:getMovingObjects()
                    if zeds then
                        for i = 0, zeds:size() - 1 do
                            local mo = zeds:get(i)
                            if instanceof(mo, "IsoZombie") then
                                local z = mo
                                -- Tag with our modData so OnZombieDead can reward packing loot
                                local md = z:getModData()
                                if not md.Tagged then
                                    md.Tagged  = true
                                    md.Prof    = M.state.profKey
                                    md.SDStamp = GT():getWorldAgeHours()
                                    taggedCount = taggedCount + 1
                                    print("[MetaEvents] DEBUG: tickAwaitProximity() - tagged zombie at (" .. xi .. "," .. yi .. ") with profession: " .. M.state.profKey)
                                end
                            end
                        end
                    end
                end
            end
        end
        print("[MetaEvents] DEBUG: tickAwaitProximity() - tagged " .. taggedCount .. " zombies total")
    else
        -- keep the scene "alive" by popping a quieter lure now and then
        if (nowSeconds() - M.state.tStageStart) % 8 == 0 then
            print("[MetaEvents] DEBUG: tickAwaitProximity() - maintaining lure noise")
            addLoudSoundAt(tgt.x, tgt.y, 0, math.floor(M.GUNSHOT_RADIUS * 0.65), math.floor(M.GUNSHOT_VOLUME * 0.6))
        end
        -- timeout if ignored
        local hoursElapsed = hoursSinceGameStart() - (M.state.tStartedGameHours or hoursSinceGameStart())
        if hoursElapsed > M.DESPAWN_TIMEOUT_HRS then
            print("[MetaEvents] DEBUG: tickAwaitProximity() - timeout reached (" .. hoursElapsed .. "h), ending event")
            endEvent()
        end
    end
end

-- ---------------------------
-- Public tick
-- ---------------------------
function M.update()
    -- If inactive, roll daily chance right after midnight
    if not M.state.active then
        if Sandbox and Sandbox.isEnabled and not Sandbox.isEnabled() then
            print("[MetaEvents] DEBUG: update() - sandbox disabled, skipping")
            return
        end

        local p = player()
        if not p then return end
        if p:getPerkLevel(Perks.Fitness) < M.MIN_PLAYER_LEVEL then return end

        -- Roll once per day at ~06:00 game time
        local hour = GT():getHour()
        local minute = GT():getMinutes()
        if hour == 6 and minute < 2 then
            local roll = ZR(1000)
            local threshold = M.CHANCE_PER_DAY * 1000
            print("[MetaEvents] DEBUG: update() - daily roll at 6AM: " .. roll .. " vs threshold " .. threshold)
            if roll < threshold then
                print("[MetaEvents] DEBUG: update() - daily roll succeeded, starting event")
                startEvent()
                M.state.tStartedGameHours = hoursSinceGameStart()
            else
                print("[MetaEvents] DEBUG: update() - daily roll failed")
            end
        end
        return
    end

    -- If active, run stage logic
    print("[MetaEvents] DEBUG: update() - event active, stage: " .. tostring(M.state.stage))
    if M.state.stage == "sweep" then
        tickSweep()
    elseif M.state.stage == "awaitProx" then
        tickAwaitProximity()
    elseif M.state.stage == "spawned" then
        -- mild continuing noise to keep local migration interesting
        if (nowSeconds() - M.state.tStageStart) % 15 == 0 and M.state.target then
            print("[MetaEvents] DEBUG: update() - spawned stage, maintaining background noise")
            addLoudSoundAt(M.state.target.x, M.state.target.y, 0, 40, 80)
        end
        -- You can end after some time if you like
        local spawnedTime = nowSeconds() - M.state.tStageStart
        if spawnedTime > 120 then
            print("[MetaEvents] DEBUG: update() - spawned stage timeout (" .. spawnedTime .. "s), ending event")
            endEvent()
        end
    end
end

-- ---------------------------
-- Rewards: on tagged zombie death, add your packing loot
-- ---------------------------
local function onZombieDead(zombie)
    print("[MetaEvents] DEBUG: onZombieDead() called")
    if not zombie then
        print("[MetaEvents] DEBUG: onZombieDead() - no zombie, returning")
        return
    end
    local md = zombie:getModData()
    if not (md and md.Tagged and md.Prof) then
        print("[MetaEvents] DEBUG: onZombieDead() - zombie not tagged or missing profession, returning")
        return
    end

    print("[MetaEvents] DEBUG: onZombieDead() - tagged zombie died, profession: " .. md.Prof)
    local inv   = zombie:getInventory()
    local drops = MetaLoot.rollDrops(md.Prof)
    print("[MetaEvents] DEBUG: onZombieDead() - rolling drops for profession: " .. md.Prof)
    MetaLoot.applyToInventory(inv, drops)
    print("[MetaEvents] DEBUG: onZombieDead() - drops applied to zombie inventory")
end

-- Public helpers so server/client admin tools can call into this module
function MetaEvents.spawnTrioAt(x, y, z, profKey)
    print("[MetaEvents] DEBUG: spawnTrioAt() called - position: (" .. x .. "," .. y .. "," .. (z or 0) .. "), profKey: " .. tostring(profKey))
    local prof = profKey or chooseProfession()
    local trio = chooseTrio(prof)
    print("[MetaEvents] DEBUG: spawnTrioAt() - using profession: " .. prof)
    print("[MetaEvents] DEBUG: spawnTrioAt() - trio outfits: " .. table.concat(trio, ", "))

    -- Spawn trio
    print("[MetaEvents] DEBUG: spawnTrioAt() - spawning zombie 1 (" .. trio[1] .. ") at (" .. x .. "," .. y .. ")")
    addZombiesInOutfit(x, y, z or 0, 1, { trio[1] })
    print("[MetaEvents] DEBUG: spawnTrioAt() - spawning zombie 2 (" .. (trio[2] or trio[1]) .. ") at (" .. (x + 1) .. "," .. y .. ")")
    addZombiesInOutfit(x + 1, y, z or 0, 1, { trio[2] or trio[1] })
    print("[MetaEvents] DEBUG: spawnTrioAt() - spawning zombie 3 (" .. (trio[3] or trio[1]) .. ") at (" .. x .. "," .. (y + 1) .. ")")
    addZombiesInOutfit(x, y + 1, z or 0, 1, { trio[3] or trio[1] })

    -- Tag the spawned ones by proximity (so OnZombieDead grants loot)
    print("[MetaEvents] DEBUG: spawnTrioAt() - tagging spawned zombies")
    local cell = getCell()
    local taggedCount = 0
    for xi = x - 2, x + 2 do
        for yi = y - 2, y + 2 do
            local sq = cell:getGridSquare(xi, yi, z or 0)
            if sq then
                local zeds = sq:getMovingObjects()
                if zeds then
                    for i = 0, zeds:size() - 1 do
                        local mo = zeds:get(i)
                        if instanceof(mo, "IsoZombie") then
                            local md = mo:getModData()
                            if not md.Tagged then
                                md.Tagged  = true
                                md.Prof    = prof
                                md.SDStamp = GT():getWorldAgeHours()
                                taggedCount = taggedCount + 1
                                print("[MetaEvents] DEBUG: spawnTrioAt() - tagged zombie at (" .. xi .. "," .. yi .. ") with profession: " .. prof)
                            end
                        end
                    end
                end
            end
        end
    end
    print("[MetaEvents] DEBUG: spawnTrioAt() - tagged " .. taggedCount .. " zombies total")
end

function MetaEvents.rollDailyNow()
    print("[MetaEvents] DEBUG: rollDailyNow() called")
    -- Respect sandbox if you expose it; otherwise just start immediately
    if Sandbox and Sandbox.isEnabled and not Sandbox.isEnabled() then
        print("[MetaEvents] DEBUG: rollDailyNow() - sandbox disabled, returning")
        return
    end
    print("[MetaEvents] DEBUG: rollDailyNow() - forcing event start")
    startEvent()
    M.state.tStartedGameHours = (M.state.tStartedGameHours or GT():getWorldAgeHours())
    print("[MetaEvents] DEBUG: rollDailyNow() - event forced to start")
end

-- ---------------------------
-- Hooks
-- ---------------------------
Events.OnPlayerUpdate.Add(function() M.update() end)
Events.OnZombieDead.Add(onZombieDead)
