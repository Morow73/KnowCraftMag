local Option, NC_State = nil, false
local mods = getActivatedMods()
KRM = KRM or {}
KRM.OPTIONS = {}

local function KRM_BuildOptions()
    if mods:contains("Neat_Crafting") then
        local PZ_Options = PZAPI.ModOptions:create('krm_options', 'Know Recipe Mag')
        local NC_RegisterUiToggleCallback = _G["NC_RegisterUiToggleCallback"]

        Option = PZ_Options:addTickBox("neatcrafting_compat", getText("IGUI_KRM_NeatCrafting"), NC_State)

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

                    if KRM and KRM.CLIENT and KRM.CLIENT.onGameLoaded then
                        KRM.CLIENT:BuildTooltipForRecipe()
                    end
                end
            end)
        end

        Option.onChangeApply = function(_, selected)
            if KRM and KRM.CLIENT and KRM.CLIENT.onGameLoaded then
                KRM.CLIENT:BuildTooltipForRecipe()
            end
        end

        Option.onChange = function(_, selected)
            if KRM and KRM.CLIENT and KRM.CLIENT.onGameLoaded then
                KRM.CLIENT:BuildTooltipForRecipe()
            end
        end
    end
end

function KRM.OPTIONS.GetTickBoxValue()
    if Option then
        return Option:getValue()
    end
    return false
end

Events.OnGameBoot.Add(KRM_BuildOptions)
