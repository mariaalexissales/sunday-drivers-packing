--[[
  Pack Rat — Meta Event Loot Config
  Purpose: Define corpse loot for profession-themed meta-event zombies.
  Scope:   ONLY used by meta events (not recipes/menus).

  HOW TO READ:
  - Each profession has:
      label     : human-friendly name for future-you
      outfits   : outfit names used by your trio spawn (kept here for clarity)
      rolls     : how many weighted picks to do per corpse (in addition to "guarantee")
      guarantee : items always added (with count range)
      table     : weighted item entries; higher weight = more likely
                  Each entry: { item="Mod.Type", min=1, max=2, weight=5 }

  API (helpers at bottom):
    MetaLoot.rollDrops(profKey, rng?) -> { {item="...", count=n}, ... }
    MetaLoot.applyToInventory(inv, drops)
--]]

MetaLoot = MetaLoot or {}

MetaLoot.version = 1

MetaLoot.professions = {
    -- Keep keys lowercase and stable; trio spawner can read outfits from here too.
    medical = {
        label     = "Medical Team",
        outfits   = { "Doctor", "Nurse", "Doctor_Scrubs", "Nurse_White" },
        rolls     = 2,
        guarantee = {
            { item = "SimplePacking.GarbageBagPack5", min = 1, max = 1 },
        },
        table     = {
            { item = "Base.Bandage",      min = 2, max = 5, weight = 6 },
            { item = "Base.AlcoholWipes", min = 1, max = 3, weight = 4 },
            { item = "Base.SutureNeedle", min = 1, max = 2, weight = 2 },
        },
    },

    police = {
        label     = "Police Detail",
        outfits   = { "Police", "PoliceSWAT" },
        rolls     = 2,
        guarantee = {
            { item = "SimplePacking.EmptyBoxesPack", min = 1, max = 1 },
        },
        table     = {
            { item = "Base.Bullets9mmBox", min = 1, max = 2, weight = 6 },
            { item = "Base.HandTorch",     min = 1, max = 1, weight = 3 },
        },
    },

    fire = {
        label     = "Fire Crew",
        outfits   = { "Fireman", "Fireman_FullSuit" },
        rolls     = 2,
        guarantee = {},
        table     = {
            { item = "Base.DuctTape", min = 1, max = 2, weight = 5 },
            { item = "Base.Torch",    min = 1, max = 1, weight = 3 },
        },
    },
}

-- ---------------------------
-- Helpers (keep logic near data for future readability)
-- ---------------------------
local function _rng(n) return ZombRand(n) end                     -- 0..n-1
local function _rngRange(a, b) return a + ZombRand(b - a + 1) end -- inclusive

local function _weightedPick(pool, rng)
    rng = rng or _rng
    local total = 0
    for _, e in ipairs(pool) do total = total + (e.weight or 1) end
    if total <= 0 then return nil end
    local roll = rng(total) + 1
    local acc  = 0
    for _, e in ipairs(pool) do
        acc = acc + (e.weight or 1)
        if roll <= acc then return e end
    end
end

-- Public: build a drop list for a profession
function MetaLoot.rollDrops(profKey, rng)
    local prof = MetaLoot.professions[profKey]
    if not prof then return {} end

    local out = {}

    -- Guarantees first
    if prof.guarantee then
        for _, g in ipairs(prof.guarantee) do
            local c = _rngRange(g.min or 1, g.max or (g.min or 1))
            if c > 0 then table.insert(out, { item = g.item, count = c }) end
        end
    end

    -- Weighted rolls
    local rolls = math.max(0, prof.rolls or 0)
    for _ = 1, rolls do
        local pick = _weightedPick(prof.table or {}, rng)
        if pick then
            local c = _rngRange(pick.min or 1, pick.max or (pick.min or 1))
            if c > 0 then table.insert(out, { item = pick.item, count = c }) end
        end
    end

    return out
end

-- Public: add the drops to an IsoDeadBody/Inventory (zombie corpse inventory)
function MetaLoot.applyToInventory(inv, drops)
    if not (inv and drops) then return end
    for _, d in ipairs(drops) do
        for i = 1, (d.count or 1) do
            inv:AddItem(d.item)
        end
    end
end

return MetaLoot
