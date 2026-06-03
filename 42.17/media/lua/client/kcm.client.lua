require "ISUI/ISToolTip"

local MagazineObject, tooltipIcons = {}, nil
KCM = KCM or {}
KCM.CLIENT = {
    onGameLoaded = false
}

---get all possible keys for a recipe.
---@param recipe List<string>
---@return string[]
local function getRecipeKeys(recipe)
    local keys = {}
    if not recipe then return keys end

    local function add(value)
        if not value or value == "" then return end
        local lowerValue = string.lower(value)
        table.insert(keys, value)
        table.insert(keys, lowerValue)
        if string.find(value, ":") then
            table.insert(keys, string.match(value, ":(.+)"))
        else
            table.insert(keys, "base:" .. lowerValue)
        end
    end

    if type(recipe) == "string" then
        add(recipe)
        return keys
    end

    if type(recipe.getName) == "function" then
        add(recipe:getName())
    end

    if type(recipe.getMetaRecipe) == "function" then
        add(recipe:getMetaRecipe())
    end

    return keys
end

---get the all leaned magazines for a given recipe
local function BuildLearningMagMap()
    local allItems = getScriptManager():getAllItems()
    if not allItems then return end

    for i = 1, allItems:size() do
        local item = allItems:get(i - 1)

        if item and item:isItemType(ItemType.LITERATURE) then
            local learnedRecipes = item:getLearnedRecipes()

            if learnedRecipes then
                for j = 1, learnedRecipes:size() do
                    local recipe = learnedRecipes:get(j - 1)
                    local recipeKeys = getRecipeKeys(recipe)

                    for _, recipeKey in ipairs(recipeKeys) do
                        MagazineObject[recipeKey] = MagazineObject[recipeKey] or {}
                        table.insert(MagazineObject[recipeKey], item)
                    end
                end
            end
        end
    end
end

---return magazine candidates for a given recipe
---@param object ISWidgetTitleHeader
---@return table | nil
local function GetCandidateInRecipe(object)
    local self = object
    local recipe = self.recipe or ((self.logic and self.logic.getRecipe and self.logic:getRecipe()) or self)
    local mags = {}

    for _, recipeKey in ipairs(getRecipeKeys(recipe)) do
        local candidate = MagazineObject[recipeKey]
        if candidate and #candidate > 0 then
            mags = candidate
            break
        end
    end

    return mags
end

---crate tooltip for a magazine.
---@param imagePath string
---@param name string
---@return ISToolTip
---@return string
local function BuildTooltip(imagePath, name)
    ---@type ISToolTip
    local tooltip = ISToolTip:new()

    tooltip:initialise()
    tooltip:instantiate()

    tooltip.nameMarginX = 0
    tooltip.defaultMyWidth = 0

    local description = "<LINE> <IMAGE:" .. imagePath .. ",34,34> <TEXT> <SIZE:small> <RGB:1,1,1> " .. (name or "")
    tooltip:setDescription(description)
    tooltip:addToUIManager()
    tooltip:setVisible(false)

    return tooltip, description
end

function KCM.CLIENT:BuildTooltipForRecipe()
    local option = KCM.OPTIONS.GetTickBoxValue()
    local NCRecipeInfoPanel = _G["NC_RecipeInfoPanel"]
    local DefaultRecipeInfoPanel = _G["ISWidgetTitleHeader"]

    if NCRecipeInfoPanel and option and not NCRecipeInfoPanel._patchedUpdateRequireIcons then
        NCRecipeInfoPanel._patchedUpdateRequireIcons = true
        local oldUpdateRequireIcons = NCRecipeInfoPanel.updateRequireIcons

        ---@param recipe CraftRecipe
        function NCRecipeInfoPanel:updateRequireIcons(recipe)
            oldUpdateRequireIcons(self, recipe)

            if self.player:isRecipeKnown(recipe, true) then
                if tooltipIcons then
                    tooltipIcons:setVisible(false)
                    tooltipIcons:removeFromUIManager()
                    tooltipIcons:reset()
                    tooltipIcons = nil
                end
                return
            end

            local neatUIIcons = nil

            for _, icon in ipairs(self.requireIcons) do
                if icon and icon.texture == self.skillIconTexture then
                    neatUIIcons = icon
                    break
                end
            end

            if not neatUIIcons then
                return
            end

            local mags = GetCandidateInRecipe(self)

            if not mags or #mags == 0 or not mags[1] then
                return
            end

            local mag = mags[1]
            local name = mag:getDisplayName() or mag:getName()
            local iconTexture = mag:getNormalTexture()
            local iconTexturePath = iconTexture:getName() or tostring(iconTexture)

            if neatUIIcons then
                local tooltipDesc = nil

                tooltipIcons, tooltipDesc = BuildTooltip(iconTexturePath, name)
                tooltipIcons:setOwner(neatUIIcons)
                neatUIIcons:setMouseOverText(tooltipDesc)
                tooltipIcons:setAlwaysOnTop(true)

                if neatUIIcons.updateTooltip then
                    neatUIIcons:updateTooltip()
                end
            end
        end
    end

    if DefaultRecipeInfoPanel and not option and DefaultRecipeInfoPanel.updatePropertyIcons then
        local old_updateLabels = DefaultRecipeInfoPanel.updatePropertyIcons

        function DefaultRecipeInfoPanel:updatePropertyIcons()
            old_updateLabels(self)

            local icon = self.needToBeLearnIcon

            if not icon or self.player:isRecipeKnown(self.recipe, true) then
                if tooltipIcons then
                    tooltipIcons:setVisible(false)
                    tooltipIcons:removeFromUIManager()
                    tooltipIcons:reset()
                    tooltipIcons = nil
                end
                return
            end

            local mags = GetCandidateInRecipe(self)

            if not mags or #mags == 0 or not mags[1] then
                return
            end

            local mag = mags[1]
            local name = mag:getDisplayName() or mag:getName()
            local iconTexture = mag:getNormalTexture()
            local iconTexturePath = iconTexture:getName() or tostring(iconTexture)

            if name and name ~= "" and iconTexture then
                local tooltipDesc = nil

                tooltipIcons, tooltipDesc = BuildTooltip(iconTexturePath, name)
                tooltipIcons:setOwner(icon)
                icon:setMouseOverText(tooltipDesc)
                tooltipIcons:setAlwaysOnTop(true)

                if icon.updateTooltip then
                    icon:updateTooltip()
                end
            end
        end
    end
end

Events.OnGameStart.Add(function()
    KCM.CLIENT.onGameLoaded = true
    BuildLearningMagMap()
    KCM.CLIENT:BuildTooltipForRecipe()
end)
