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
        item:DoParam("Weight = "..calculated)
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
    for itemName,v in pairs(listToAdjust) do
        for baseItemName,y in pairs(v) do
            for amount,multiplier in pairs(y) do
                if pcall(WeightAdjustment(itemName,baseItemName,amount,multiplier)) then
                    print("Could not patch Item's ",itemName," Weight calculated from base item ",baseItemName," of amount",amount," multiplied by ", multiplier)
                end
            end
        end
    end
end

--add for every packed item: Name, BaseName,Amount,Multiplier. Scroll up for for multiplier
AdjustWeight("SDPacking.50pkleadpipe","Base.LeadPipe",50,0.5)
AdjustWeight("SDPacking.10pkleadpipe","Base.LeadPipe",10,0.5)
AdjustWeight("SDPacking.20pkLightBulb","Base.LightBulb",20,0.5)
AdjustWeight("SDPacking.20pkLightBulbGreen","Base.LightBulbGreen",20,0.5)
AdjustWeight("SDPacking.20pkYarn","Base.Yarn",20,0.5)
AdjustWeight("SDPacking.100pkYarn","Base.Yarn",100,0.5)
AdjustWeight("SDPacking.4pkBlackPaint","Base.BlackPaint",4,0.5)
AdjustWeight("SDPacking.4pkBluePaint","Base.BluePaint",4,0.5)
AdjustWeight("SDPacking.4pkBrownPaint","Base.BrownPaint",4,0.5)
AdjustWeight("SDPacking.4pkCyanPaint","Base.CyanPaint",4,0.5)
AdjustWeight("SDPacking.4pkGreenPaint","Base.GreenPaint",4,0.5)
AdjustWeight("SDPacking.4pkGreyPaint","Base.GreyPaint",4,0.5)
AdjustWeight("SDPacking.4pkLightBluePaint","Base.LightBluePaint",4,0.5)
AdjustWeight("SDPacking.4pkLightBrownPaint","Base.LightBrownPaint",4,0.5)
AdjustWeight("SDPacking.4pkPinkPaint","Base.PinkPaint",4,0.5)
AdjustWeight("SDPacking.4pkPurplePaint","Base.PurplePaint",4,0.5)
AdjustWeight("SDPacking.4pkRedPaint","Base.RedPaint",4,0.5)
AdjustWeight("SDPacking.4pkTurquoisePaint","Base.TurquoisePaint",4,0.5)
AdjustWeight("SDPacking.4pkWhitePaint","Base.WhitePaint",4,0.5)
AdjustWeight("SDPacking.4pkYellowPaint","Base.YellowPaint",4,0.5)
AdjustWeight("SDPacking.4pkOrangePaint","Base.OrangePaint",4,0.5)
AdjustWeight("SDPacking.4pkPlantain","Base.Plantain",4,0.7)
AdjustWeight("SDPacking.8pkPlantain","Base.Plantain",8,0.5)
AdjustWeight("SDPacking.4pkComfrey","Base.Comfrey",4,0.7)
AdjustWeight("SDPacking.8pkComfrey","Base.Comfrey",8,0.5)
AdjustWeight("SDPacking.4pkWildGarlic","Base.WildGarlic",4,0.7)
AdjustWeight("SDPacking.8pkWildGarlic","Base.WildGarlic",8,0.5)
AdjustWeight("SDPacking.4pkCommonMallow","Base.CommonMallow",4,0.7)
AdjustWeight("SDPacking.8pkCommonMallow","Base.CommonMallow",8,0.5)
AdjustWeight("SDPacking.4pkLemonGrass","Base.LemonGrass",4,0.7)
AdjustWeight("SDPacking.8pkLemonGrass","Base.LemonGrass",8,0.5)
AdjustWeight("SDPacking.4pkBlackSage","Base.BlackSage",4,0.7)
AdjustWeight("SDPacking.8pkBlackSage","Base.BlackSage",8,0.5)
AdjustWeight("SDPacking.4pkGinseng","Base.Ginseng",4,0.7)
AdjustWeight("SDPacking.8pkGinseng","Base.Ginseng",8,0.5)
AdjustWeight("SDPacking.20pkWorm","Base.Worm",20,0.5)
AdjustWeight("SDPacking.100pkWorm","Base.Worm",100,0.5)
AdjustWeight("SDPacking.500pkWorm","Base.Worm",500,0.5)
AdjustWeight("SDPacking.25pkAluminum","Base.Aluminum",25,0.5)
AdjustWeight("SDPacking.25pkAmplifier","Base.Amplifier",25,0.5)
AdjustWeight("SDPacking.20pkRadioReceiver","Base.RadioReceiver",20,0.5)
AdjustWeight("SDPacking.20pkRadioTransmitter","Base.RadioTransmitter",20,0.5)
AdjustWeight("SDPacking.10pkStone","Base.Stone",10,0.5)
AdjustWeight("SDPacking.10pkSharpedStone","Base.SharpedStone",10,0.5)
AdjustWeight("SDPacking.10pkWhiskey","Base.WhiskeyFull",10,0.5)
AdjustWeight("SDPacking.5pkWhiskey","Base.WhiskeyFull",5,0.7)

Events.OnGameTimeLoaded.Add(Perform)