local addonName, FTG = ...
-- Forever Talent Guide: intentionally part of the open Talent window.
local guide, menu, border, hooked, registered

local function getCanvas()
    if PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame then
        return PlayerSpellsFrame.TalentsFrame
    end
    if ClassTalentFrame then
        return ClassTalentFrame.TalentsFrame or ClassTalentFrame.TalentsTab
    end
end

local function isOpen()
    local f = getCanvas()
    return f and f.IsVisible and f:IsVisible()
end

local function skin(f)
    if not f.SetBackdrop then return end
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = {left=1, right=1, top=1, bottom=1},
    })
    f:SetBackdropColor(0.04,0.03,0.02,0.92)
    f:SetBackdropBorderColor(0.70,0.53,0.13,1)
end

local function makeGuide()
    local canvas = getCanvas()
    if not canvas then return end
    if guide then
        if guide:GetParent() ~= canvas then guide:SetParent(canvas) end
    else
        guide = CreateFrame("Frame", "ForeverTalentGuideFrame", canvas, "BackdropTemplate")
        guide:EnableMouse(true)
        guide:SetFrameLevel(canvas:GetFrameLevel()+10)
        skin(guide)
        guide.title = guide:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        guide.title:SetPoint("TOPLEFT",12,-6)
        guide.title:SetPoint("RIGHT",-86,0)
        guide.title:SetJustifyH("LEFT")
        guide.next = guide:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
        guide.next:SetPoint("TOPLEFT",12,-20)
        guide.next:SetPoint("RIGHT",-86,0)
        guide.next:SetJustifyH("LEFT")
        guide.note = guide:CreateFontString(nil,"OVERLAY","GameFontDisableSmall")
        guide.note:SetPoint("BOTTOMLEFT",12,5)
        guide.note:SetPoint("RIGHT",-10,0)
        guide.note:SetJustifyH("LEFT")
        guide.choose = CreateFrame("Button",nil,guide,"UIPanelButtonTemplate")
        guide.choose:SetSize(72,24)
        guide.choose:SetPoint("TOPRIGHT",-8,-13)
        guide.choose:SetText("Build")
        guide.choose:SetScript("OnClick",function() FTG:ToggleSettings() end)
        guide:Hide()
    end
    guide:SetSize(math.max(310,math.min(570,(canvas:GetWidth() or 1200)-260)),52)
    guide:ClearAllPoints()
    -- Forever's empty header band sits above the three talent trees.
    guide:SetPoint("TOP",canvas,"TOP",-65,-4)
    return guide
end

local choices = {
    {"leveling", "Fury Leveling"},
    {"arms_leveling", "Arms Leveling"},
    {"dps", "Fury DPS 60"},
    {"arms_dps", "Arms DPS 60"},
    {"tank", "Protection Tank 60"},
}

local function makeMenu()
    local g = makeGuide()
    if not g then return end
    if menu then return menu end
    menu = CreateFrame("Frame", "ForeverTalentGuideSelector", g, "BackdropTemplate")
    menu:SetSize(245,198)
    menu:SetFrameLevel(g:GetFrameLevel()+2)
    menu:EnableMouse(true)
    menu:SetPoint("TOPRIGHT",g,"BOTTOMRIGHT",0,-4)
    skin(menu)
    local heading = menu:CreateFontString(nil,"OVERLAY","GameFontNormal")
    heading:SetPoint("TOPLEFT",12,-8)
    heading:SetText("Choose Warrior build")
    menu.buttons={}
    for i, item in ipairs(choices) do
        local key,name=unpack(item)
        local b=CreateFrame("Button",nil,menu,"UIPanelButtonTemplate")
        b:SetSize(214,27)
        b:SetPoint("TOPLEFT",14,-30-(i-1)*31)
        b:SetText(name)
        b:SetScript("OnClick",function()
            menu:Hide()
            FTG:SetSelectedBuild(key)
            FTG:UpdateSettings()
            FTG:ShowGuide()
        end)
        menu.buttons[key]=b
    end
    menu:Hide()
    return menu
end

function FTG:InitializeUI()
    self:HookTalentUI()
end

function FTG:ToggleSettings()
    if not isOpen() then return end
    local m=makeMenu()
    if not m then return end
    if m:IsShown() then m:Hide()
    else self:UpdateSettings(); m:Show() end
end

function FTG:UpdateSettings()
    if not menu then return end
    local build=self:GetSelectedBuild()
    for key,button in pairs(menu.buttons) do
        if build and key==build.key then button:Disable()
        else button:Enable() end
    end
end

function FTG:UpdateGuideFrame(step,state,record,reason)
    if not (self.db and self.db.enabled and self:IsSupportedCharacter() and isOpen()) then
        self:HideGuide()
        return
    end
    local g=makeGuide()
    local build=self:GetSelectedBuild()
    if not (g and build) then return end
    g.title:SetText(build.name.."  |  Icy Veins")
    if state=="complete" then
        g.next:SetText("Build complete")
        g.note:SetText("No more guided talent points.")
    elseif not step then
        g.next:SetText("No recommendation available")
        g.note:SetText("Check the selected Icy Veins build.")
    else
        local hasPoint=self.runtime and self.runtime.hasUnspentPoint
        g.next:SetText((hasPoint and "NEXT: " or "UP NEXT: ")..self:GetStepDisplay(step,record))
        if state=="unresolved" then
            g.note:SetText("Talent not resolved; use /ftg status for details.")
        elseif step.inferred then
            g.note:SetText("Approximate order; confirm against Icy Veins.")
        elseif step.level then
            g.note:SetText("Suggested at level "..tostring(step.level))
        else
            g.note:SetText(build.split or "")
        end
    end
    g:Show()
    self:UpdateSettings()
end

-- Leveling no longer spawns an independent popup. The strip appears inside
-- the talent window on every open, including after receiving a new point.
function FTG:ShowGuide()
    if not isOpen() then return end
    local g=makeGuide()
    if g then g:Show() end
end

function FTG:HideGuide()
    if menu then menu:Hide() end
    if guide then guide:Hide() end
end

function FTG:ClearTalentGlow()
    if border then border:Hide(); border:ClearAllPoints() end
end

local function makeBorder(canvas)
    if border then
        if border:GetParent()~=canvas then border:SetParent(canvas) end
        return border
    end
    border=CreateFrame("Frame",nil,canvas)
    border:EnableMouse(false)
    local function line(points,width,height)
        local t=border:CreateTexture(nil,"OVERLAY")
        t:SetColorTexture(1,0.76,0.12,0.98)
        for _,p in ipairs(points) do t:SetPoint(unpack(p)) end
        if width then t:SetWidth(width) end
        if height then t:SetHeight(height) end
    end
    line({{"TOPLEFT",border,"TOPLEFT"},{"TOPRIGHT",border,"TOPRIGHT"}},nil,3)
    line({{"BOTTOMLEFT",border,"BOTTOMLEFT"},{"BOTTOMRIGHT",border,"BOTTOMRIGHT"}},nil,3)
    line({{"TOPLEFT",border,"TOPLEFT"},{"BOTTOMLEFT",border,"BOTTOMLEFT"}},3,nil)
    line({{"TOPRIGHT",border,"TOPRIGHT"},{"BOTTOMRIGHT",border,"BOTTOMRIGHT"}},3,nil)
    border:Hide()
    return border
end

function FTG:UpdateTalentGlow(step)
    self:ClearTalentGlow()
    if not (self.db and self.db.showTalentGlow and step and isOpen()) then return end
    if not (self.runtime and self.runtime.hasUnspentPoint) then return end
    local rec=self:GetTalentRecord(step.talent)
    local canvas=getCanvas()
    if not (rec and rec.nodeID and canvas and type(canvas.GetTalentButtonByNodeID)=="function") then return end
    local ok,button=pcall(canvas.GetTalentButtonByNodeID,canvas,rec.nodeID)
    if not (ok and button) then return end
    local edge=makeBorder(canvas)
    edge:SetFrameLevel(math.max(canvas:GetFrameLevel()+3,button:GetFrameLevel()+3))
    edge:SetSize(math.max(30,button:GetWidth()+8),math.max(30,button:GetHeight()+8))
    edge:ClearAllPoints()
    edge:SetPoint("CENTER",button,"CENTER")
    edge:Show()
end

function FTG:HookTalentUI()
    local canvas=getCanvas()
    if not canvas then return end
    if hooked~=canvas then
        hooked=canvas
        if canvas.HookScript then
            canvas:HookScript("OnShow",function()
                C_Timer.After(0,function()
                    if FTG.db and FTG.db.enabled then FTG:RefreshGuide("talent-open") end
                end)
            end)
            canvas:HookScript("OnHide",function()
                FTG:HideGuide()
                FTG:ClearTalentGlow()
            end)
        end
    end
    if not registered and EventRegistry and EventRegistry.RegisterCallback then
        registered=true
        pcall(EventRegistry.RegisterCallback,EventRegistry,"TalentFrameBase.ButtonsUpdated",function()
            if isOpen() and FTG.db and FTG.db.enabled then
                C_Timer.After(0,function() FTG:RefreshGuide("talent-buttons-updated") end)
            end
        end,FTG)
    end
    if isOpen() and FTG.db and FTG.db.enabled then
        FTG:RefreshGuide("talent-open")
    end
end
