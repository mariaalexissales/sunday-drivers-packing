Sandbox = Sandbox or {}

local function _SBV(k, def)
    local M = SandboxVars and SandboxVars.PRMeta
    if not M then return def end
    local v = M[k]
    if v == nil then return def end
    return v
end

function Sandbox.isEnabled() return _SBV("EnableEvent", true) end

function Sandbox.getChancePerDay() return tonumber(_SBV("ChancePerDay", 0.25)) or 0.25 end

function Sandbox.getDefaultProf() return tostring(_SBV("DefaultProfession", "medical")) end

function Sandbox.isDebugMenuEnabled() return _SBV("DebugMenu", true) end

return Sandbox
