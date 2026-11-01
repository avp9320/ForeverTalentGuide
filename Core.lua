local addonName, FTG = ...

FTG = FTG or {}
_G.ForeverTalentGuide = FTG

local defaults = {
    selectedBuild = "leveling",
    enabled = true,
    showLevelPopup = true,
    showTalentGlow = true,
    dismissedUntilNextPoint = false,
}

local eventFrame = CreateFrame("Frame")
FTG.eventFrame = eventFrame
FTG.runtime = {
    talentsByName = {},
    talentsByNodeID = {},
    configID = nil,
    treeID = nil,
    classToken = nil,
    currentStep = nil,
    lastKnownPlayerLevel = nil,
}

local function safeRegisterEvent(frame, event)
    pcall(frame.RegisterEvent, frame, event)
end

local function copyDefaults()
    ForeverTalentGuideDB = ForeverTalentGuideDB or {}
    for key, value in pairs(defaults) do
        if ForeverTalentGuideDB[key] == nil then
            ForeverTalentGuideDB[key] = value
        end
    end
    FTG.db = ForeverTalentGuideDB
end

local function getClassToken()
    local _, classToken = UnitClass("player")
    return classToken
end

function FTG:IsSupportedCharacter()
    return getClassToken() == "WARRIOR"
end

function FTG:GetSelectedBuild()
    if not self:IsSupportedCharacter() then
        return nil
    end
    local warriorBuilds = self.Builds and self.Builds.WARRIOR
    if not warriorBuilds then
        return nil
    end
    local key = (self.db and self.db.selectedBuild) or "leveling"
    return warriorBuilds[key] or warriorBuilds.leveling
end

function FTG:SetSelectedBuild(key)
    if not self.Builds or not self.Builds.WARRIOR or not self.Builds.WARRIOR[key] then
        return false
    end
    self.db.selectedBuild = key
    self.db.dismissedUntilNextPoint = false
    self:RefreshTalentCache()
    self:RefreshGuide("build")
    return true
end

local function getSpellNameFromDefinition(definitionInfo)
    if not definitionInfo or not definitionInfo.spellID or not C_Spell or not C_Spell.GetSpellName then
        return nil
    end
    local ok, name = pcall(C_Spell.GetSpellName, definitionInfo.spellID)
    if ok then
        return name
    end
    return nil
end

local function getActiveEntryID(nodeInfo)
    if not nodeInfo then
        return nil
    end

    if nodeInfo.activeEntry and nodeInfo.activeEntry.entryID then
        return nodeInfo.activeEntry.entryID
    end

    if nodeInfo.entryIDs and #nodeInfo.entryIDs > 0 then
        return nodeInfo.entryIDs[1]
    end

    return nil
end

function FTG:RefreshTalentCache()
    wipe(self.runtime.talentsByName)
    wipe(self.runtime.talentsByNodeID)
    self.runtime.configID = nil
    self.runtime.treeID = nil

    if not self:IsSupportedCharacter() then
        return false
    end
    if not C_ClassTalents or not C_ClassTalents.GetActiveConfigID or not C_Traits then
        return false
    end

    local okConfig, configID = pcall(C_ClassTalents.GetActiveConfigID)
    if not okConfig or not configID then
        return false
    end

    local okInfo, configInfo = pcall(C_Traits.GetConfigInfo, configID)
    if not okInfo or not configInfo or not configInfo.treeIDs or not configInfo.treeIDs[1] then
        return false
    end

    local treeID = configInfo.treeIDs[1]
    local okNodes, nodeIDs = pcall(C_Traits.GetTreeNodes, treeID)
    if not okNodes or type(nodeIDs) ~= "table" then
        return false
    end

    self.runtime.configID = configID
    self.runtime.treeID = treeID

    for _, nodeID in ipairs(nodeIDs) do
        local okNode, nodeInfo = pcall(C_Traits.GetNodeInfo, configID, nodeID)
        if okNode and nodeInfo and nodeInfo.isVisible ~= false then
            local entryID = getActiveEntryID(nodeInfo)
            if entryID then
                local okEntry, entryInfo = pcall(C_Traits.GetEntryInfo, configID, entryID)
                if okEntry and entryInfo and entryInfo.definitionID then
                    local okDef, definitionInfo = pcall(C_Traits.GetDefinitionInfo, entryInfo.definitionID)
                    if okDef then
                        local talentName = getSpellNameFromDefinition(definitionInfo)
                        if talentName then
                            local record = {
                                name = talentName,
                                nodeID = nodeID,
                                entryID = entryID,
                                currentRank = nodeInfo.currentRank or 0,
                                maxRanks = nodeInfo.maxRanks or 0,
                                canPurchaseRank = nodeInfo.canPurchaseRank,
                                nodeInfo = nodeInfo,
                            }
                            self.runtime.talentsByName[talentName] = record
                            self.runtime.talentsByNodeID[nodeID] = record
                        end
                    end
                end
            end
        end
    end

    return true
end

function FTG:GetTalentRecord(talentName)
    if not talentName then
        return nil
    end
    local record = self.runtime.talentsByName[talentName]
    if not record then
        self:RefreshTalentCache()
        record = self.runtime.talentsByName[talentName]
    end
    return record
end

function FTG:GetNextStep()
    local build = self:GetSelectedBuild()
    if not build or not build.steps then
        return nil, "no-build"
    end

    if not self.runtime.configID then
        self:RefreshTalentCache()
    end

    for index, buildStep in ipairs(build.steps) do
        local record = self:GetTalentRecord(buildStep.talent)
        if not record then
            return buildStep, "unresolved", index
        end
        if (record.currentRank or 0) < buildStep.rank then
            return buildStep, "ready", index, record
        end
    end

    return nil, "complete"
end

function FTG:GetStepDisplay(step, record)
    if not step then
        return "No recommendation available."
    end

    local maxRanks = record and record.maxRanks
    if not maxRanks or maxRanks == 0 then
        maxRanks = step.rank
    end

    return string.format("%s %d/%d", step.talent, step.rank, maxRanks)
end

function FTG:GetStatusText()
    if not self:IsSupportedCharacter() then
        return "Forever Talent Guide currently supports Warrior only."
    end

    local build = self:GetSelectedBuild()
    if not build then
        return "No build is loaded."
    end

    local step, state, index, record = self:GetNextStep()
    if state == "complete" then
        return string.format("%s is complete.", build.name)
    end
    if state == "unresolved" then
        return string.format(
            "%s\nNext: %s\n\nThe live client talent tree could not resolve this talent yet. We will verify this on launch.",
            build.name,
            self:GetStepDisplay(step, record)
        )
    end

    local lines = {
        build.name,
        "Next: " .. self:GetStepDisplay(step, record),
    }

    if step.level then
        lines[#lines + 1] = "Normal level: " .. tostring(step.level)
    end

    if build.key == "leveling" then
        local playerLevel = UnitLevel("player") or 0
        if build.maxLevelCovered and playerLevel >= build.maxLevelCovered and index == #build.steps then
            lines[#lines + 1] = "Current Icy Veins leveling coverage ends at level " .. tostring(build.maxLevelCovered) .. "."
        end
    end

    return table.concat(lines, "\n")
end

function FTG:RefreshGuide(reason)
    if not self.db or not self.db.enabled then
        return
    end
    if not self:IsSupportedCharacter() then
        if self.HideGuide then
            self:HideGuide()
        end
        return
    end

    self:RefreshTalentCache()
    local step, state, _, record = self:GetNextStep()
    self.runtime.currentStep = step

    if self.UpdateGuideFrame then
        self:UpdateGuideFrame(step, state, record, reason)
    end
    if self.UpdateTalentGlow then
        self:UpdateTalentGlow(step)
    end
end

function FTG:PrintStatus()
    print("|cffd6a441Forever Talent Guide:|r " .. self:GetStatusText():gsub("\n", " | "))
end

local function handleSlash(msg)
    msg = strtrim((msg or ""):lower())

    if msg == "" or msg == "show" then
        FTG:RefreshGuide("slash")
        if FTG.ShowGuide then
            FTG:ShowGuide(true)
        end
        return
    end

    if msg == "leveling" or msg == "dps" or msg == "tank" then
        FTG:SetSelectedBuild(msg)
        if FTG.ShowGuide then
            FTG:ShowGuide(true)
        end
        return
    end

    if msg == "status" then
        FTG:PrintStatus()
        return
    end

    if msg == "source" then
        local build = FTG:GetSelectedBuild()
        if build then
            print("|cffd6a441Forever Talent Guide:|r " .. build.source .. " - " .. build.sourceURL)
            print("|cffd6a441Forever Talent Guide:|r Source updated " .. tostring(build.sourceLastUpdated) .. "; addon reviewed " .. tostring(build.reviewed))
        end
        return
    end

    if msg == "on" then
        FTG.db.enabled = true
        FTG:RefreshGuide("enabled")
        print("|cffd6a441Forever Talent Guide enabled.|r")
        return
    end

    if msg == "off" then
        FTG.db.enabled = false
        if FTG.HideGuide then FTG:HideGuide() end
        if FTG.ClearTalentGlow then FTG:ClearTalentGlow() end
        print("|cffd6a441Forever Talent Guide disabled.|r")
        return
    end

    print("|cffd6a441Forever Talent Guide commands:|r /ftg, /ftg leveling, /ftg dps, /ftg tank, /ftg status, /ftg source, /ftg on, /ftg off")
end

SLASH_FOREVERTALENTGUIDE1 = "/ftg"
SLASH_FOREVERTALENTGUIDE2 = "/forevertalentguide"
SlashCmdList.FOREVERTALENTGUIDE = handleSlash

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            copyDefaults()
            FTG.runtime.classToken = getClassToken()
            FTG.runtime.lastKnownPlayerLevel = UnitLevel("player")
            FTG:RefreshTalentCache()
            if FTG.InitializeUI then
                FTG:InitializeUI()
            end
            FTG:RefreshGuide("login")
        elseif loadedAddon == "Blizzard_ClassTalentUI" or loadedAddon == "Blizzard_PlayerSpells" then
            if FTG.HookTalentUI then
                FTG:HookTalentUI()
            end
            FTG:RefreshGuide("talent-ui-loaded")
        end
        return
    end

    if not FTG.db or not FTG.db.enabled then
        return
    end

    if event == "PLAYER_LEVEL_UP" then
        local newLevel = ...
        FTG.runtime.lastKnownPlayerLevel = newLevel
        FTG.db.dismissedUntilNextPoint = false
        C_Timer.After(0.25, function()
            FTG:RefreshGuide("level")
            if FTG.db.showLevelPopup and FTG.ShowGuide then
                FTG:ShowGuide(true)
            end
        end)
        return
    end

    if event == "TRAIT_CONFIG_UPDATED"
        or event == "TRAIT_NODE_CHANGED"
        or event == "PLAYER_ENTERING_WORLD"
        or event == "PLAYER_SPECIALIZATION_CHANGED"
    then
        C_Timer.After(0.10, function()
            FTG.db.dismissedUntilNextPoint = false
            FTG:RefreshGuide("talent")
        end)
    end
end)

safeRegisterEvent(eventFrame, "ADDON_LOADED")
safeRegisterEvent(eventFrame, "PLAYER_ENTERING_WORLD")
safeRegisterEvent(eventFrame, "PLAYER_LEVEL_UP")
safeRegisterEvent(eventFrame, "TRAIT_CONFIG_UPDATED")
safeRegisterEvent(eventFrame, "TRAIT_NODE_CHANGED")
safeRegisterEvent(eventFrame, "PLAYER_SPECIALIZATION_CHANGED")
