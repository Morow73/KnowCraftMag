local NC_State = false
local mods = getActivatedMods()
KCM = KCM or {}
KCM.OPTIONS = {}

local function KCM_BuildOptions()
    if mods:contains("Neat_Crafting") then
        local NC_RegisterUiToggleCallback = _G["NC_RegisterUiToggleCallback"]

        if type(NC_RegisterUiToggleCallback) == "function" then
            NC_RegisterUiToggleCallback(function(enabled)
                NC_State = enabled

                if KCM and KCM.CLIENT and KCM.CLIENT.onGameLoaded then
                    KCM.CLIENT:BuildTooltipForRecipe()
                end
            end)
        end
    end
end

function KCM.OPTIONS.GetTickBoxValue()
    return NC_State
end

Events.OnGameBoot.Add(KCM_BuildOptions)
