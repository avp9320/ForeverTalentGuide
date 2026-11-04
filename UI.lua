local addonName, FTG = ...

local guideFrame
local settingsFrame
local glowingButton
local glowBorder

local function createGuideFrame()
    if guideFrame then return guideFrame end
    local frame = CreateFrame("Frame", "ForeverTalentGuideFrame", UIParent, "BackdropTemplate")
    frame:SetSize(330, 118)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 180)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    if frame.SetBackdrop then frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=24,insets={left=7,right=7,top=7,bottom=7}}) end
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 18, -16)
    frame.title:SetText("Forever Talent Guide")
    frame.build = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.build:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -6)
    frame.build:SetTextColor(0.75,0.75,0.75)
    frame.nextLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.nextLabel:SetPoint("TOPLEFT", frame.build, "BOTTOMLEFT", 0, -12)
    frame.nextLabel:SetText("NEXT POINT")
    frame.nextTalent = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.nextTalent:SetPoint("TOPLEFT", frame.nextLabel, "BOTTOMLEFT", 0, -2)
    frame.nextTalent:SetPoint("RIGHT", frame, "RIGHT", -18, 0)
    frame.nextTalent:SetJustifyH("LEFT")
    frame.note = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.note:SetPoint("TOPLEFT", frame.nextTalent, "BOTTOMLEFT", 0, -4)
    frame.note:SetPoint("RIGHT", frame, "RIGHT", -18, 0)
    frame.note:SetJustifyH("LEFT")
    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT", -4, -4)
    frame.close:SetScript("OnClick", function() frame:Hide(); if FTG.db then FTG.db.dismissedUntilNextPoint = true end end)
    frame.settings = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.settings:SetSize(66,20)
    frame.settings:SetPoint("BOTTOMRIGHT", -14, 12)
    frame.settings:SetText("Build")
    frame.settings:SetScript("OnClick", function() FTG:ToggleSettings() end)
    frame:Hide(); guideFrame = frame; return frame
end

local function createSettingsFrame()
    if settingsFrame then return settingsFrame end
    local frame = CreateFrame("Frame", "ForeverTalentGuideSettings", UIParent, "BackdropTemplate")
    frame:SetSize(370,235); frame:SetPoint("CENTER"); frame:SetFrameStrata("DIALOG"); frame:SetClampedToScreen(true); frame:EnableMouse(true); frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton"); frame:SetScript("OnDragStart", function(self) self:StartMoving() end); frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    if frame.SetBackdrop then frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=24,insets={left=7,right=7,top=7,bottom=7}}) end
    frame.title = frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge"); frame.title:SetPoint("TOPLEFT",18,-18); frame.title:SetText("Forever Talent Guide")
    frame.subtitle = frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); frame.subtitle:SetPoint("TOPLEFT",frame.title,"BOTTOMLEFT",0,-8); frame.subtitle:SetText("Warrior builds • Icy Veins")
    frame.close = CreateFrame("Button",nil,frame,"UIPanelCloseButton"); frame.close:SetPoint("TOPRIGHT",-4,-4)
    local options={{key="leveling",label="Leveling",y=-70},{key="dps",label="Level 60 DPS",y=-108},{key="tank",label="Level 60 Tank",y=-146}}
    frame.buttons={}
    for _,option in ipairs(options) do local button=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate"); button:SetSize(150,28); button:SetPoint("TOPLEFT",20,option.y); button:SetText(option.label); button:SetScript("OnClick",function() FTG:SetSelectedBuild(option.key); FTG:ShowGuide(true); FTG:UpdateSettings() end); frame.buttons[option.key]=button end
    frame.info=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); frame.info:SetPoint("TOPLEFT",190,-72); frame.info:SetPoint("RIGHT",-18,0); frame.info:SetJustifyH("LEFT"); frame.info:SetJustifyV("TOP")
    frame.source=frame:CreateFontString(nil,"OVERLAY","GameFontDisableSmall"); frame.source:SetPoint("BOTTOMLEFT",20,20); frame.source:SetPoint("RIGHT",-20,0); frame.source:SetJustifyH("LEFT")
    frame:Hide(); settingsFrame=frame; return frame
end

function FTG:InitializeUI() createGuideFrame(); createSettingsFrame(); self:UpdateSettings(); self:HookTalentUI() end
function FTG:ToggleSettings() local frame=createSettingsFrame(); if frame:IsShown() then frame:Hide() else self:UpdateSettings(); frame:Show() end end
function FTG:UpdateSettings()
    local frame=createSettingsFrame(); local build=self:GetSelectedBuild(); if not build then frame.info:SetText("Warrior only in v0.1."); return end
    frame.info:SetText(build.name.."\n\nSplit: "..tostring(build.split or "—").."\nCoverage: "..tostring(build.coverage or "—").."\nSource updated: "..tostring(build.sourceLastUpdated or "—"))
    frame.source:SetText("Source: "..tostring(build.source).."  •  /ftg source prints the guide URL")
    for key,button in pairs(frame.buttons) do if key==build.key then button:Disable() else button:Enable() end end
end
function FTG:UpdateGuideFrame(step,state,record,reason)
    local frame=createGuideFrame(); local build=self:GetSelectedBuild(); if not build then frame.build:SetText("Warrior only"); frame.nextTalent:SetText("No Warrior build loaded"); frame.note:SetText(""); return end
    frame.build:SetText(build.name.."  •  "..build.source)
    if state=="complete" then frame.nextLabel:SetText("BUILD STATUS"); frame.nextTalent:SetText("Build complete"); frame.note:SetText(build.split or ""); if reason=="talent" then C_Timer.After(1.5,function() if frame:IsShown() then frame:Hide() end end) end; return end
    local hasPoint = self.runtime and self.runtime.hasUnspentPoint
    frame.nextLabel:SetText(hasPoint and "NEXT POINT" or "UPCOMING TALENT")
    frame.nextTalent:SetText(self:GetStepDisplay(step,record))
    if not hasPoint then
        frame.note:SetText("No unspent talent point yet. Normal first point: level 10.")
    elseif state=="unresolved" then
        frame.note:SetText("Talent not resolved in the current client yet; verification needed.")
    elseif build.key=="leveling" and build.maxLevelCovered and (UnitLevel("player") or 0)>=build.maxLevelCovered then
        frame.note:SetText("Icy Veins currently covers leveling through level "..build.maxLevelCovered..".")
    elseif step and step.level then
        frame.note:SetText("Normal leveling point: level "..step.level)
    else
        frame.note:SetText(build.split or "")
    end
    -- Automatic popups must represent a point that the player can spend.
    -- Slash/build opening remains a manual preview even without points.
    if reason=="level" and not hasPoint then
        frame:Hide()
    elseif reason=="talent" and not hasPoint then
        frame:Hide()
    elseif reason=="level" or reason=="slash" or reason=="build" then
        frame:Show()
    end
end
function FTG:ShowGuide(force) local frame=createGuideFrame(); if force or not (self.db and self.db.dismissedUntilNextPoint) then frame:Show() end end
function FTG:HideGuide() if guideFrame then guideFrame:Hide() end end
function FTG:ClearTalentGlow() if glowingButton and ActionButton_HideOverlayGlow then pcall(ActionButton_HideOverlayGlow,glowingButton) end; if glowBorder then glowBorder:Hide(); glowBorder:SetParent(UIParent); glowBorder:ClearAllPoints() end; glowingButton=nil end
local function getTalentFrame() if PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame then return PlayerSpellsFrame.TalentsFrame end; if ClassTalentFrame then return ClassTalentFrame.TalentsTab or ClassTalentFrame.TalentsFrame end; return nil end
local function showFallbackBorder(button) if not glowBorder then glowBorder=CreateFrame("Frame",nil,UIParent,"BackdropTemplate"); glowBorder:SetFrameStrata("TOOLTIP"); if glowBorder.SetBackdrop then glowBorder:SetBackdrop({edgeFile="Interface\\Buttons\\UI-ActionButton-Border",edgeSize=24}); glowBorder:SetBackdropBorderColor(1,0.82,0,1) end end; glowBorder:SetParent(button); glowBorder:ClearAllPoints(); glowBorder:SetPoint("TOPLEFT",button,"TOPLEFT",-6,6); glowBorder:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",6,-6); glowBorder:Show() end
function FTG:UpdateTalentGlow(step)
    self:ClearTalentGlow(); if not self.db or not self.db.showTalentGlow or not step
        or not (self.runtime and self.runtime.hasUnspentPoint) then return end
    local record=self:GetTalentRecord(step.talent); if not record or not record.nodeID then return end
    local talentFrame=getTalentFrame(); if not talentFrame or not talentFrame.GetTalentButtonByNodeID then return end
    local ok,button=pcall(talentFrame.GetTalentButtonByNodeID,talentFrame,record.nodeID); if not ok or not button then return end
    glowingButton=button; if ActionButton_ShowOverlayGlow then local glowOK=pcall(ActionButton_ShowOverlayGlow,button); if glowOK then return end end; showFallbackBorder(button)
end
function FTG:HookTalentUI()
    if self.runtime.talentUIHooked then return end; self.runtime.talentUIHooked=true
    if EventRegistry and EventRegistry.RegisterCallback then pcall(EventRegistry.RegisterCallback,EventRegistry,"TalentFrameBase.ButtonsUpdated",function() C_Timer.After(0,function() FTG:RefreshTalentCache(); local step=FTG:GetNextStep(); FTG:UpdateTalentGlow(step) end) end,self) end
    local talentFrame=getTalentFrame(); if talentFrame and talentFrame.HookScript then talentFrame:HookScript("OnShow",function() C_Timer.After(0.1,function() FTG:RefreshTalentCache(); local step=FTG:GetNextStep(); FTG:UpdateTalentGlow(step) end) end); talentFrame:HookScript("OnHide",function() FTG:ClearTalentGlow() end) end
end
