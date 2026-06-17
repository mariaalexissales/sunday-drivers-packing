--[[
Logic for weight
5 pack = 5 * weight *                   0.7
10 pack = 10 * weight *                 0.5
5 pack with sheetrope = 5 * weight *    0.3
10 pack with sheetrope = 10 * weight *  0.25
5 pack with rope = 5 * weight * 0.2
10 pack with rope = 10 * weight * 0.15
also for Electronics Scrap, Rag, Denim, Leather:
10 pack = 10 * weight * 0.7
50 pack = 50 * weight * 0.6
100 pack = 100 * weight * 0.5
]]
local listToAdjust = {}
local function WeightAdjustment(itemName, baseItemName, amount, multiplier)
    local item = ScriptManager.instance:getItem(itemName)
    local baseItem = ScriptManager.instance:getItem(baseItemName)
    if item and baseItem then
        local baseItemWeight = baseItem:getActualWeight()
        local calculated = baseItemWeight * amount * multiplier
        item:DoParam("Weight = " .. calculated)
    end
end
local function AdjustWeight(itemName, baseItemName, amount, multiplier)
    if not listToAdjust[itemName] then
        listToAdjust[itemName] = {};
    end
    if not listToAdjust[itemName][baseItemName] then
        listToAdjust[itemName][baseItemName] = {}
    end
    listToAdjust[itemName][baseItemName][amount] = multiplier;
end
local function Perform()
    for itemName, v in pairs(listToAdjust) do
        for baseItemName, y in pairs(v) do
            for amount, multiplier in pairs(y) do
                if pcall(WeightAdjustment(itemName, baseItemName, amount, multiplier)) then
                    print("Could not patch Item's ", itemName, " Weight calculated from base item ", baseItemName,
                        " of amount", amount, " multiplied by ", multiplier)
                end
            end
        end
    end
end

--add for every packed item: Name, BaseName,Amount,Multiplier. Scroll up for for multiplier
-- Generated AdjustWeight calls
AdjustWeight("PR.5pkAppleBagSeed", "PZGFarm.AppleBagSeed", 5, 0.7)
AdjustWeight("PR.10pkAppleBagSeed", "PZGFarm.AppleBagSeed", 10, 0.5)
AdjustWeight("PR.50pkAppleBagSeed", "PZGFarm.AppleBagSeed", 50, 0.5)
AdjustWeight("PR.100pkAppleBagSeed", "PZGFarm.AppleBagSeed", 100, 0.5)
AdjustWeight("PR.5pkAvocadoBagSeed", "PZGFarm.AvocadoBagSeed", 5, 0.7)
AdjustWeight("PR.10pkAvocadoBagSeed", "PZGFarm.AvocadoBagSeed", 10, 0.5)
AdjustWeight("PR.50pkAvocadoBagSeed", "PZGFarm.AvocadoBagSeed", 50, 0.5)
AdjustWeight("PR.100pkAvocadoBagSeed", "PZGFarm.AvocadoBagSeed", 100, 0.5)
AdjustWeight("PR.5pkBananaBagSeed", "PZGFarm.BananaBagSeed", 5, 0.7)
AdjustWeight("PR.10pkBananaBagSeed", "PZGFarm.BananaBagSeed", 10, 0.5)
AdjustWeight("PR.50pkBananaBagSeed", "PZGFarm.BananaBagSeed", 50, 0.5)
AdjustWeight("PR.100pkBananaBagSeed", "PZGFarm.BananaBagSeed", 100, 0.5)
AdjustWeight("PR.5pkBellpepperBagSeed", "PZGFarm.BellpepperBagSeed", 5, 0.7)
AdjustWeight("PR.10pkBellpepperBagSeed", "PZGFarm.BellpepperBagSeed", 10, 0.5)
AdjustWeight("PR.50pkBellpepperBagSeed", "PZGFarm.BellpepperBagSeed", 50, 0.5)
AdjustWeight("PR.100pkBellpepperBagSeed", "PZGFarm.BellpepperBagSeed", 100, 0.5)
AdjustWeight("PR.5pkBlackbeansBagSeed", "PZGFarm.BlackbeansBagSeed", 5, 0.7)
AdjustWeight("PR.10pkBlackbeansBagSeed", "PZGFarm.BlackbeansBagSeed", 10, 0.5)
AdjustWeight("PR.50pkBlackbeansBagSeed", "PZGFarm.BlackbeansBagSeed", 50, 0.5)
AdjustWeight("PR.100pkBlackbeansBagSeed", "PZGFarm.BlackbeansBagSeed", 100, 0.5)
AdjustWeight("PR.5pkBlackberryBagSeed", "PZGFarm.BlackberryBagSeed", 5, 0.7)
AdjustWeight("PR.10pkBlackberryBagSeed", "PZGFarm.BlackberryBagSeed", 10, 0.5)
AdjustWeight("PR.50pkBlackberryBagSeed", "PZGFarm.BlackberryBagSeed", 50, 0.5)
AdjustWeight("PR.100pkBlackberryBagSeed", "PZGFarm.BlackberryBagSeed", 100, 0.5)
AdjustWeight("PR.5pkBlueberryBagSeed", "PZGFarm.BlueberryBagSeed", 5, 0.7)
AdjustWeight("PR.10pkBlueberryBagSeed", "PZGFarm.BlueberryBagSeed", 10, 0.5)
AdjustWeight("PR.50pkBlueberryBagSeed", "PZGFarm.BlueberryBagSeed", 50, 0.5)
AdjustWeight("PR.100pkBlueberryBagSeed", "PZGFarm.BlueberryBagSeed", 100, 0.5)
AdjustWeight("PR.5pkCherryBagSeed", "PZGFarm.CherryBagSeed", 5, 0.7)
AdjustWeight("PR.10pkCherryBagSeed", "PZGFarm.CherryBagSeed", 10, 0.5)
AdjustWeight("PR.50pkCherryBagSeed", "PZGFarm.CherryBagSeed", 50, 0.5)
AdjustWeight("PR.100pkCherryBagSeed", "PZGFarm.CherryBagSeed", 100, 0.5)
AdjustWeight("PR.5pkCoconutBagSeed", "PZGFarm.CoconutBagSeed", 5, 0.7)
AdjustWeight("PR.10pkCoconutBagSeed", "PZGFarm.CoconutBagSeed", 10, 0.5)
AdjustWeight("PR.50pkCoconutBagSeed", "PZGFarm.CoconutBagSeed", 50, 0.5)
AdjustWeight("PR.100pkCoconutBagSeed", "PZGFarm.CoconutBagSeed", 100, 0.5)
AdjustWeight("PR.5pkCornBagSeed", "PZGFarm.CornBagSeed", 5, 0.7)
AdjustWeight("PR.10pkCornBagSeed", "PZGFarm.CornBagSeed", 10, 0.5)
AdjustWeight("PR.50pkCornBagSeed", "PZGFarm.CornBagSeed", 50, 0.5)
AdjustWeight("PR.100pkCornBagSeed", "PZGFarm.CornBagSeed", 100, 0.5)
AdjustWeight("PR.5pkCucumberBagSeed", "PZGFarm.CucumberBagSeed", 5, 0.7)
AdjustWeight("PR.10pkCucumberBagSeed", "PZGFarm.CucumberBagSeed", 10, 0.5)
AdjustWeight("PR.50pkCucumberBagSeed", "PZGFarm.CucumberBagSeed", 50, 0.5)
AdjustWeight("PR.100pkCucumberBagSeed", "PZGFarm.CucumberBagSeed", 100, 0.5)
AdjustWeight("PR.5pkDaikonBagSeed", "PZGFarm.DaikonBagSeed", 5, 0.7)
AdjustWeight("PR.10pkDaikonBagSeed", "PZGFarm.DaikonBagSeed", 10, 0.5)
AdjustWeight("PR.50pkDaikonBagSeed", "PZGFarm.DaikonBagSeed", 50, 0.5)
AdjustWeight("PR.100pkDaikonBagSeed", "PZGFarm.DaikonBagSeed", 100, 0.5)
AdjustWeight("PR.5pkEdamameBagSeed", "PZGFarm.EdamameBagSeed", 5, 0.7)
AdjustWeight("PR.10pkEdamameBagSeed", "PZGFarm.EdamameBagSeed", 10, 0.5)
AdjustWeight("PR.50pkEdamameBagSeed", "PZGFarm.EdamameBagSeed", 50, 0.5)
AdjustWeight("PR.100pkEdamameBagSeed", "PZGFarm.EdamameBagSeed", 100, 0.5)
AdjustWeight("PR.5pkEggplantBagSeed", "PZGFarm.EggplantBagSeed", 5, 0.7)
AdjustWeight("PR.10pkEggplantBagSeed", "PZGFarm.EggplantBagSeed", 10, 0.5)
AdjustWeight("PR.50pkEggplantBagSeed", "PZGFarm.EggplantBagSeed", 50, 0.5)
AdjustWeight("PR.100pkEggplantBagSeed", "PZGFarm.EggplantBagSeed", 100, 0.5)
AdjustWeight("PR.5pkGrapefruitBagSeed", "PZGFarm.GrapefruitBagSeed", 5, 0.7)
AdjustWeight("PR.10pkGrapefruitBagSeed", "PZGFarm.GrapefruitBagSeed", 10, 0.5)
AdjustWeight("PR.50pkGrapefruitBagSeed", "PZGFarm.GrapefruitBagSeed", 50, 0.5)
AdjustWeight("PR.100pkGrapefruitBagSeed", "PZGFarm.GrapefruitBagSeed", 100, 0.5)
AdjustWeight("PR.5pkGrapeBagSeed", "PZGFarm.GrapeBagSeed", 5, 0.7)
AdjustWeight("PR.10pkGrapeBagSeed", "PZGFarm.GrapeBagSeed", 10, 0.5)
AdjustWeight("PR.50pkGrapeBagSeed", "PZGFarm.GrapeBagSeed", 50, 0.5)
AdjustWeight("PR.100pkGrapeBagSeed", "PZGFarm.GrapeBagSeed", 100, 0.5)
AdjustWeight("PR.5pkPepperHabaneroBagSeed", "PZGFarm.PepperHabaneroBagSeed", 5, 0.7)
AdjustWeight("PR.10pkPepperHabaneroBagSeed", "PZGFarm.PepperHabaneroBagSeed", 10, 0.5)
AdjustWeight("PR.50pkPepperHabaneroBagSeed", "PZGFarm.PepperHabaneroBagSeed", 50, 0.5)
AdjustWeight("PR.100pkPepperHabaneroBagSeed", "PZGFarm.PepperHabaneroBagSeed", 100, 0.5)
AdjustWeight("PR.5pkPepperJalapenoBagSeed", "PZGFarm.PepperJalapenoBagSeed", 5, 0.7)
AdjustWeight("PR.10pkPepperJalapenoBagSeed", "PZGFarm.PepperJalapenoBagSeed", 10, 0.5)
AdjustWeight("PR.50pkPepperJalapenoBagSeed", "PZGFarm.PepperJalapenoBagSeed", 50, 0.5)
AdjustWeight("PR.100pkPepperJalapenoBagSeed", "PZGFarm.PepperJalapenoBagSeed", 100, 0.5)
AdjustWeight("PR.5pkLeekBagSeed", "PZGFarm.LeekBagSeed", 5, 0.7)
AdjustWeight("PR.10pkLeekBagSeed", "PZGFarm.LeekBagSeed", 10, 0.5)
AdjustWeight("PR.50pkLeekBagSeed", "PZGFarm.LeekBagSeed", 50, 0.5)
AdjustWeight("PR.100pkLeekBagSeed", "PZGFarm.LeekBagSeed", 100, 0.5)
AdjustWeight("PR.5pkLemonBagSeed", "PZGFarm.LemonBagSeed", 5, 0.7)
AdjustWeight("PR.10pkLemonBagSeed", "PZGFarm.LemonBagSeed", 10, 0.5)
AdjustWeight("PR.50pkLemonBagSeed", "PZGFarm.LemonBagSeed", 50, 0.5)
AdjustWeight("PR.100pkLemonBagSeed", "PZGFarm.LemonBagSeed", 100, 0.5)
AdjustWeight("PR.5pkLettuceBagSeed", "PZGFarm.LettuceBagSeed", 5, 0.7)
AdjustWeight("PR.10pkLettuceBagSeed", "PZGFarm.LettuceBagSeed", 10, 0.5)
AdjustWeight("PR.50pkLettuceBagSeed", "PZGFarm.LettuceBagSeed", 50, 0.5)
AdjustWeight("PR.100pkLettuceBagSeed", "PZGFarm.LettuceBagSeed", 100, 0.5)
AdjustWeight("PR.5pkLimeBagSeed", "PZGFarm.LimeBagSeed", 5, 0.7)
AdjustWeight("PR.10pkLimeBagSeed", "PZGFarm.LimeBagSeed", 10, 0.5)
AdjustWeight("PR.50pkLimeBagSeed", "PZGFarm.LimeBagSeed", 50, 0.5)
AdjustWeight("PR.100pkLimeBagSeed", "PZGFarm.LimeBagSeed", 100, 0.5)
AdjustWeight("PR.5pkMangoBagSeed", "PZGFarm.MangoBagSeed", 5, 0.7)
AdjustWeight("PR.10pkMangoBagSeed", "PZGFarm.MangoBagSeed", 10, 0.5)
AdjustWeight("PR.50pkMangoBagSeed", "PZGFarm.MangoBagSeed", 50, 0.5)
AdjustWeight("PR.100pkMangoBagSeed", "PZGFarm.MangoBagSeed", 100, 0.5)
AdjustWeight("PR.5pkOnionBagSeed", "PZGFarm.OnionBagSeed", 5, 0.7)
AdjustWeight("PR.10pkOnionBagSeed", "PZGFarm.OnionBagSeed", 10, 0.5)
AdjustWeight("PR.50pkOnionBagSeed", "PZGFarm.OnionBagSeed", 50, 0.5)
AdjustWeight("PR.100pkOnionBagSeed", "PZGFarm.OnionBagSeed", 100, 0.5)
AdjustWeight("PR.5pkOrangeBagSeed", "PZGFarm.OrangeBagSeed", 5, 0.7)
AdjustWeight("PR.10pkOrangeBagSeed", "PZGFarm.OrangeBagSeed", 10, 0.5)
AdjustWeight("PR.50pkOrangeBagSeed", "PZGFarm.OrangeBagSeed", 50, 0.5)
AdjustWeight("PR.100pkOrangeBagSeed", "PZGFarm.OrangeBagSeed", 100, 0.5)
AdjustWeight("PR.5pkPeachBagSeed", "PZGFarm.PeachBagSeed", 5, 0.7)
AdjustWeight("PR.10pkPeachBagSeed", "PZGFarm.PeachBagSeed", 10, 0.5)
AdjustWeight("PR.50pkPeachBagSeed", "PZGFarm.PeachBagSeed", 50, 0.5)
AdjustWeight("PR.100pkPeachBagSeed", "PZGFarm.PeachBagSeed", 100, 0.5)
AdjustWeight("PR.5pkPearBagSeed", "PZGFarm.PearBagSeed", 5, 0.7)
AdjustWeight("PR.10pkPearBagSeed", "PZGFarm.PearBagSeed", 10, 0.5)
AdjustWeight("PR.50pkPearBagSeed", "PZGFarm.PearBagSeed", 50, 0.5)
AdjustWeight("PR.100pkPearBagSeed", "PZGFarm.PearBagSeed", 100, 0.5)
AdjustWeight("PR.5pkPineappleBagSeed", "PZGFarm.PineappleBagSeed", 5, 0.7)
AdjustWeight("PR.10pkPineappleBagSeed", "PZGFarm.PineappleBagSeed", 10, 0.5)
AdjustWeight("PR.50pkPineappleBagSeed", "PZGFarm.PineappleBagSeed", 50, 0.5)
AdjustWeight("PR.100pkPineappleBagSeed", "PZGFarm.PineappleBagSeed", 100, 0.5)
AdjustWeight("PR.5pkPumpkinBagSeed", "PZGFarm.PumpkinBagSeed", 5, 0.7)
AdjustWeight("PR.10pkPumpkinBagSeed", "PZGFarm.PumpkinBagSeed", 10, 0.5)
AdjustWeight("PR.50pkPumpkinBagSeed", "PZGFarm.PumpkinBagSeed", 50, 0.5)
AdjustWeight("PR.100pkPumpkinBagSeed", "PZGFarm.PumpkinBagSeed", 100, 0.5)
AdjustWeight("PR.5pkSugarcaneBagSeed", "PZGFarm.SugarcaneBagSeed", 5, 0.7)
AdjustWeight("PR.10pkSugarcaneBagSeed", "PZGFarm.SugarcaneBagSeed", 10, 0.5)
AdjustWeight("PR.50pkSugarcaneBagSeed", "PZGFarm.SugarcaneBagSeed", 50, 0.5)
AdjustWeight("PR.100pkSugarcaneBagSeed", "PZGFarm.SugarcaneBagSeed", 100, 0.5)
AdjustWeight("PR.5pkWatermelonBagSeed", "PZGFarm.WatermelonBagSeed", 5, 0.7)
AdjustWeight("PR.10pkWatermelonBagSeed", "PZGFarm.WatermelonBagSeed", 10, 0.5)
AdjustWeight("PR.50pkWatermelonBagSeed", "PZGFarm.WatermelonBagSeed", 50, 0.5)
AdjustWeight("PR.100pkWatermelonBagSeed", "PZGFarm.WatermelonBagSeed", 100, 0.5)
AdjustWeight("PR.5pkWheatBagSeed", "PZGFarm.WheatBagSeed", 5, 0.7)
AdjustWeight("PR.10pkWheatBagSeed", "PZGFarm.WheatBagSeed", 10, 0.5)
AdjustWeight("PR.50pkWheatBagSeed", "PZGFarm.WheatBagSeed", 50, 0.5)
AdjustWeight("PR.100pkWheatBagSeed", "PZGFarm.WheatBagSeed", 100, 0.5)
AdjustWeight("PR.5pkZucchiniBagSeed", "PZGFarm.ZucchiniBagSeed", 5, 0.7)
AdjustWeight("PR.10pkZucchiniBagSeed", "PZGFarm.ZucchiniBagSeed", 10, 0.5)
AdjustWeight("PR.50pkZucchiniBagSeed", "PZGFarm.ZucchiniBagSeed", 50, 0.5)
AdjustWeight("PR.100pkZucchiniBagSeed", "PZGFarm.ZucchiniBagSeed", 100, 0.5)

Events.OnGameTimeLoaded.Add(Perform)
