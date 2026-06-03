local Option, NC_State = nil, false
local mods = getActivatedMods()
KCM = KCM or {}
KCM.OPTIONS = {}

local function KCM_BuildOptions()
    if mods:contains("Neat_Crafting") then
        local PZ_Options = PZAPI.ModOptions:create('kcm_options', 'Know Craft Mag')
        local NC_RegisterUiToggleCallback = _G["NC_RegisterUiToggleCallback"]

        Option = PZ_Options:addTickBox("neatcrafting_compat", getText("IGUI_KCM_NeatCrafting"), NC_State)

        if type(PZAPI.ModOptions.load) == "function" then
            PZAPI.ModOptions.load = function(_, _)
                if Option then
                    Option:setValue(NC_State)
                end
            end
        end

        if type(NC_RegisterUiToggleCallback) == "function" then
            NC_RegisterUiToggleCallback(function(enabled)
                NC_State = enabled == true

                if Option then
                    Option:setValue(NC_State)

                    if KCM and KCM.CLIENT and KCM.CLIENT.onGameLoaded then
                        KCM.CLIENT:BuildTooltipForRecipe()
                    end
                end
            end)
        end

        Option.onChangeApply = function(_, selected)
            if KCM and KCM.CLIENT and KCM.CLIENT.onGameLoaded then
                KCM.CLIENT:BuildTooltipForRecipe()
            end
        end

        Option.onChange = function(_, selected)
            if KCM and KCM.CLIENT and KCM.CLIENT.onGameLoaded then
                KCM.CLIENT:BuildTooltipForRecipe()
            end
        end
    end
end

function KCM.OPTIONS.GetTickBoxValue()
    if Option then
        return Option:getValue()
    end
    return false
end

Events.OnGameBoot.Add(KCM_BuildOptions)
