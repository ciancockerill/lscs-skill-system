include("client/cl_skill_networking.lua")
include("lscs_skillsystem_config.lua")

LSCS_SABERSTATION = LSCS_SABERSTATION or {}

LSCS_SABERSTATION.Colour = {
    BG = Color(17, 17, 33),
    HL = Color(35, 36, 70),
    Text = Color(255, 255, 255),
    SMLText = Color(102,102,204),
    HoverHL = Color(50,50,102),
    Owned = Color(0,255,0)
}

function LSCS_SABERSTATION:LoadPData() 
    net.Receive("LSCS_SendSkillDataToClient", function()
        local skillData = net.ReadTable()
        LocalPlayer().SkillSystem = skillData
        hook.Run("LSCS_OnLoadedSaberPlayerData")
    end)
    LSCS_SKILLSYSTEM:getDataOnClient()
end

function LSCS_SABERSTATION:CreatePanel()
    self:LoadPData()  

    local blurPanel = vgui.Create("DPanel")
    blurPanel:SetSize(ScrW(), ScrH()) 
    blurPanel:SetPos(0, 0)
    blurPanel.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, SysTime())
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150)) 
    end
    self.BlurPanel = blurPanel

    local SW = ScrW()
    local SH = ScrH()
    self.W = SW * 0.75
    self.H = SH * 0.75
    self.X = SW / 2 - self.W / 2
    self.Y = SH / 2 - self.H / 2
    self.PAD = math.floor(SH * 0.00925)
    self.BodyPAD = self.PAD * 20
    self.CornerRAD = self.W * 0.015

    self.Panel = vgui.Create("DFrame", blurPanel)
    self.Panel:SetPos(self.X, self.Y)
    self.Panel:SetSize(self.W, self.H)
    self.Panel:SetTitle("")
    self.Panel:MakePopup()
    self.Panel:SetDraggable(false)
    self.Panel:ShowCloseButton(false)
    self.Panel.Paint = function(self, w, h)
        draw.RoundedBox(self:GetWide() * 0.015, 0, 0, w, h, LSCS_SABERSTATION.Colour.BG)
    end

    self.Header = self:CreateHeader()
    self.HeaderVertDiv = self:CreateVertDivider(self.Header)

    hook.Add("LSCS_OnLoadedSaberPlayerData", "LSCS_OpenTheSaberCraftingMenu", function()
        if  table.IsEmpty(LocalPlayer().SkillSystem) then
            local errorLabel = vgui.Create("DLabel", self.Panel)
            errorLabel:SetText("You Are Not Force Sensitive!")
            errorLabel:SetTextColor(LSCS_SABERSTATION.Colour.Text)
            errorLabel:SetFont("sgb50")
            errorLabel:SizeToContents()
            errorLabel:SetPos((self.Panel:GetWide() - errorLabel:GetWide()) / 2, (self.Panel:GetTall() - errorLabel:GetTall()) / 2)
            return
        end

        self.CurrSelectedHand = "RH"
        self.currHiltName = LocalPlayer().SkillSystem.CurrEquipped[self.CurrSelectedHand].Hilt     
        self.currCrystalName = LocalPlayer().SkillSystem.CurrEquipped[self.CurrSelectedHand].Crystal
        
        if self:HasDualSabers() then
            self:CreateHandSelectionPanel(self.Panel)
        end

        self.PreviewPanel = self:CreateSaberPreview(self.Panel)
        
        self.HiltButton = self:CreateInventoryDropdown(self.Panel, "lscs_hilt_base", "Hilt")
        self.CrystalButton = self:CreateInventoryDropdown(self.Panel, "lscs_crystal_base", "Crystal")

        self.HiltButton:SetPos(self.Panel:GetWide() / 2 - self.HiltButton:GetWide() / 2 - self.PAD * 10, self.HeaderVertDiv:GetY() + self.PAD * 5)
        self.CrystalButton:SetPos(self.Panel:GetWide() / 2 - self.CrystalButton:GetWide() / 2 + self.PAD * 10, self.HeaderVertDiv:GetY() + self.PAD * 5)

        self.ConfirmButton = self:CreateConfirmButton(self.Panel)
    end)
end

function LSCS_SABERSTATION:CreateHandSelectionPanel(parent)
    local panelWidth = self.W * 0.3
    local panelHeight = self.H * 0.075
    local handPanel = vgui.Create("DPanel", parent)
    handPanel:SetSize(panelWidth, panelHeight)
    handPanel:SetPos(0, self.Panel:GetTall() - panelHeight - self.PAD * 3.5)
    
    handPanel.Paint = function(self, w, h)
    end

    local buttonWidth = panelWidth * 0.3
    local buttonHeight = panelHeight * 0.9
    local buttonPadding = panelWidth * 0.175

    local leftButton = vgui.Create("DButton", handPanel)
    leftButton:SetSize(buttonWidth, buttonHeight)
    leftButton:SetPos(buttonPadding, panelHeight * 0.1)
    leftButton:SetText("")
    leftButton.Paint = function(self, w, h)
        local bgColor = self.Hovered and LSCS_SABERSTATION.Colour.HoverHL or LSCS_SABERSTATION.Colour.HL
        draw.RoundedBox(w * 0.05, 0, 0, w, h, bgColor)
        draw.SimpleText("Left Hand", "sgb30", w/2, h/2, LSCS_SABERSTATION.Colour.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(LSCS_SABERSTATION.Colour.Text)

        surface.SetDrawColor(LSCS_SABERSTATION.Colour.Text)
        if saberStation.CurrSelectedHand == "LH" then
            surface.SetDrawColor(LSCS_SABERSTATION.Colour.Owned)
        end
        
        surface.DrawOutlinedRect(0, 0, w, h, 1.5)
        surface.SetDrawColor(LSCS_SABERSTATION.Colour.Text)

    end

    local rightButton = vgui.Create("DButton", handPanel)
    rightButton:SetSize(buttonWidth, buttonHeight)
    rightButton:SetPos(panelWidth - buttonWidth - buttonPadding, panelHeight * 0.1)
    rightButton:SetText("")
    rightButton.Paint = function(self, w, h)
        local bgColor = self.Hovered and LSCS_SABERSTATION.Colour.HoverHL or LSCS_SABERSTATION.Colour.HL
        draw.RoundedBox(w * 0.05, 0, 0, w, h, bgColor)
        draw.SimpleText("Right Hand", "sgb30", w/2, h/2, LSCS_SABERSTATION.Colour.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(LSCS_SABERSTATION.Colour.Text)
        if saberStation.CurrSelectedHand == "RH" then
            surface.SetDrawColor(LSCS_SABERSTATION.Colour.Owned)
        end
        surface.DrawOutlinedRect(0, 0, w, h, 1.5)
        surface.SetDrawColor(LSCS_SABERSTATION.Colour.Text)
    end

    saberStation = self

    leftButton.DoClick = function()
        saberStation.CurrSelectedHand = "LH"

        self.currHiltName = LocalPlayer().SkillSystem.CurrEquipped[self.CurrSelectedHand].Hilt     
        self.currCrystalName = LocalPlayer().SkillSystem.CurrEquipped[self.CurrSelectedHand].Crystal

        saberStation.PreviewPanel = saberStation:CreateSaberPreview(saberStation.Panel)
    end

    rightButton.DoClick = function()
        saberStation.CurrSelectedHand = "RH"

        self.currHiltName = LocalPlayer().SkillSystem.CurrEquipped[self.CurrSelectedHand].Hilt     
        self.currCrystalName = LocalPlayer().SkillSystem.CurrEquipped[self.CurrSelectedHand].Crystal

        if IsValid(saberStation.PreviewPanel) then
            saberStation.PreviewPanel:Remove()
        end
        saberStation.PreviewPanel = saberStation:CreateSaberPreview(saberStation.Panel)
    end

    return handPanel
end


function LSCS_SABERSTATION:CreateHeader()
    local HeaderPanel = vgui.Create("DPanel", self.Panel)
    HeaderPanel:SetSize(self.W, self.H / 15)
    HeaderPanel:SetPos(0,0)
    HeaderPanel.Paint = function(self, w, h)
        draw.RoundedBox(self:GetWide() * 0.015, 0, 0, w, h, LSCS_SABERSTATION.Colour.BG)
    end

    self.CloseButton = self:CreateCloseButton(HeaderPanel)
    self.CloseButton:SetPos(self.W - self.CloseButton:GetWide() - self.PAD, self.PAD)

    self.JediLogoPanel = vgui.Create("DPanel", HeaderPanel)
    self.JediLogoPanel:SetSize(HeaderPanel:GetTall() - self.PAD * 1.5, HeaderPanel:GetTall() - self.PAD * 1.5)
    self.JediLogoPanel:SetPos(self.PAD * 2, HeaderPanel:GetTall() / 2 - self.JediLogoPanel:GetTall() / 2)
    self.JediLogoPanel.Paint = function(self, w, h)
        surface.SetDrawColor(LSCS_SABERSTATION.Colour.Text)
        surface.SetMaterial(LSCS_SKILLSTATION.Material.icon_jediemblem)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.HeaderText = self:CreateText(HeaderPanel)
    self.HeaderText:SetText("Galactic Republic - Saber Crafting Station")
    self.HeaderText:SetFont("sgb30")
    self.HeaderText:SetSize(self.HeaderText:GetTextSize())
    self.HeaderText:SetPos(self.JediLogoPanel:GetX() + self.JediLogoPanel:GetWide() + self.PAD * 0.25, HeaderPanel:GetTall() / 2 - select(2, self.HeaderText:GetTextSize()) / 2)

    return HeaderPanel
end

function LSCS_SABERSTATION:CreateText(parent)
    local TextLabel = vgui.Create("DLabel", parent)
    TextLabel:SetColor(LSCS_SABERSTATION.Colour.Text)

    return TextLabel
end

function LSCS_SABERSTATION:CreateCloseButton(parent)
    local CloseButton = vgui.Create("DButton", parent)
    CloseButton:SetSize(self.W * 0.025, self.W * 0.025)
    CloseButton:SetText("X")
    CloseButton:SetFont("CenterPrintText")
    CloseButton.Paint = function(self, w, h)
        local buttonColour = CloseButton.Hovered and LSCS_SABERSTATION.Colour.HoverHL or LSCS_SABERSTATION.Colour.HL
        draw.RoundedBox(self:GetWide() / 3, 0, 0, w, h, buttonColour)
    end
    CloseButton.PaintOver = function(self, w, h)
        draw.SimpleText("X", "CenterPrintText", w/2, h/2, LSCS_SABERSTATION.Colour.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    CloseButton.DoClick = function()
        if self.PreviewPanel and IsValid(self.PreviewPanel) then self.PreviewPanel:Remove() end
        if self.Panel and IsValid(self.Panel) then self.Panel:Close() end
        if self.BlurPanel and IsValid(self.BlurPanel) then self.BlurPanel:Remove() end
        self.Panel = nil
    end
    return CloseButton
end

function LSCS_SABERSTATION:CreateVertDivider(topPanel)
    local Div = vgui.Create("DPanel", self.Panel)
    Div:SetSize(self.Panel:GetWide() - self.PAD, self.PAD / 4)
    Div:SetPos(self.Panel:GetWide() / 2 - Div:GetWide() / 2, topPanel:GetTall() + topPanel:GetY())
    Div.Paint = function(self, w, h)
        draw.RoundedBox(self:GetTall() / 2, 0,0,w,h, LSCS_SABERSTATION.Colour.Text)
    end
    return Div
end

function LSCS_SABERSTATION:CreateSaberPreview(parent)
    local previewPanel = vgui.Create("DPanel", parent)
    previewPanel:SetSize(parent:GetWide(), parent:GetTall() * 0.5)
    previewPanel:SetPos(0, parent:GetTall() * 0.35)
    previewPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, LSCS_SABERSTATION.Colour.HL)
    end

    local _, hiltData = nil, nil
    local _, crystalData = nil, nil

    print(self.currHiltName)
    print(self.currCrystalName)

    if self.currHiltName ~= nil and self.currCrystalName ~= nil then
        _, hiltData = LSCS_SKILLSYSTEM:GetHiltDataFromClass(self.currHiltName)   
        _, crystalData = LSCS_SKILLSYSTEM:GetCrystalDataFromClass(self.currCrystalName)   
    end 

    if not hiltData or not hiltData.mdl then
        print("Invalid hilt model path")
        return
    end
    if not crystalData then
        print("Invalid crystal data")
        return
    end

    local saberPanel = vgui.Create("DModelPanel", previewPanel)
    saberPanel:Dock(FILL)
    saberPanel:SetModel(hiltData.mdl)
    saberPanel:SetFOV(70)
    
    function saberPanel:LayoutEntity(ent)
        ent:SetAngles( Angle( 0, 0, 45 ) )
    end

    local modelEntity = saberPanel.Entity
    if IsValid(modelEntity) then
        local minBound, maxBound = modelEntity:GetModelBounds()
        local modelCenter = (minBound + maxBound) / 2
        local crystalLength = crystalData.length or 45
        local cameraShiftRight = crystalLength * 0.75 
        local offsetZ = 100 
        local cameraPos = Vector(modelCenter.x - 22.5, modelCenter.y, modelCenter.z - offsetZ + 30)
        saberPanel:SetCamPos(cameraPos)        
        saberPanel:SetLookAt(modelCenter)
    end

    saberPanel.Paint = function(self, w, h)
        local x, y = self:LocalToScreen(0, 0)
        local camPos = self:GetCamPos()
        local camAng = (self:GetLookAt() - camPos):Angle()
        camAng.pitch = -90
        camAng.yaw = -90
        cam.Start3D(camPos, camAng, self.fFOV or 70, x, y, w, h)
            self:LayoutEntity(self.Entity)
            self.Entity:DrawModel()
    
            local ent = self.Entity
            if not IsValid(ent) then return end
    
            local attIndex = ent:LookupAttachment("blade1")
            local attData = ent:GetAttachment(attIndex)
            local bladeDir = Vector(-1, 0, 0)
            if attData then
                local bladeStart = attData.Pos 
                local bladeAng = Angle(attData.Ang.p, attData.Ang.y, attData.Ang.r)
                bladeAng:RotateAroundAxis(attData.Ang:Right(), -90) 
                local bladeLength = crystalData.length or 45
    
                local coreMat = crystalData.material_core or Material("lscs/effects/lightsaber_core")
                local tipMat = crystalData.material_core_tip or Material("lscs/effects/lightsaber_tip")
                local glowMat = crystalData.material_glow or Material("lscs/effects/lightsaber_glow")
    
                local coreColor = Color(crystalData.color_core.r, crystalData.color_core.g, crystalData.color_core.b, crystalData.color_core.a)
                local glowColor = Color(crystalData.color_blur.r, crystalData.color_blur.g, crystalData.color_blur.b, crystalData.color_blur.a)
    
                local coreWidth = crystalData.width or 0.9
                local tipWidth = coreWidth * 2

                render.SetMaterial(glowMat)
                local spriteSize = 5 
                local numSteps = 200      

                for i = 0, numSteps do
                    local fraction = i / numSteps
                    local pos = bladeStart + bladeDir * (fraction * bladeLength)
                    render.DrawSprite(pos, spriteSize, spriteSize, glowColor)
                end

                render.SetMaterial(coreMat)
                render.DrawBeam(bladeStart, bladeStart + bladeDir * bladeLength, coreWidth, 0, 1, coreColor)

                render.SetMaterial(tipMat)
                render.DrawBeam(bladeStart + bladeDir * (bladeLength - 1), bladeStart + bladeDir * (bladeLength + 1), 1, 1, 0, coreColor)
            end
        cam.End3D()
    end
    
    return previewPanel
end

function LSCS_SABERSTATION:CreateInventoryDropdown(parent, neededItemType, displayName)
    local size = self.W * 0.1
    local posX, posY
    if neededItemType == "lscs_hilt_base" then
        posX = self.PAD * 2
        posY = self.PAD * 2
    elseif neededItemType == "lscs_crystal_base" then
        posX = self.PAD * 2 + size + self.PAD * 2
        posY = self.PAD * 2
    end

    local button = vgui.Create("DImageButton", parent)
    button:SetSize(size, size)
    button:SetPos(posX, posY)
    button:SetTooltip(displayName)
    button:SetStretchToFit(true)
    
    local inv = LocalPlayer().SkillSystem and LocalPlayer().SkillSystem.Inventory or {}
    for k, v in pairs(inv) do
        if neededItemType == "lscs_hilt_base" then
            local name, data = LSCS_SKILLSYSTEM:GetHiltDataFromClass(v)
            if data == nil then continue end

            button:SetMaterial(data.icon)
            button.SelectedItem = v
            break
        elseif neededItemType == "lscs_crystal_base" then
            local name, data = LSCS_SKILLSYSTEM:GetCrystalDataFromClass(v)

            if data == nil then continue end

            button:SetMaterial(data.icon)
            button.SelectedItem = v
            break
        end
    end

    local saberStation = self

    button.DoClick = function()
        local menu = DermaMenu()
        for k, entClass in pairs(inv) do
            if neededItemType == "lscs_hilt_base" then
                local name, data = LSCS_SKILLSYSTEM:GetHiltDataFromClass(entClass)
                if data == nil then print(entClass); continue end
                menu:AddOption(data.name, function()
                    button:SetMaterial(data.icon)
                    button.SelectedItem = entClass
                    saberStation.currHiltName = entClass
        
                    if IsValid(saberStation.PreviewPanel) then
                        saberStation.PreviewPanel:Remove()
                    end
                    saberStation.PreviewPanel = saberStation:CreateSaberPreview(saberStation.Panel)
                end)
            elseif neededItemType == "lscs_crystal_base" then
                local name, data = LSCS_SKILLSYSTEM:GetCrystalDataFromClass(entClass)
                if data == nil then print(entClass); continue end

                menu:AddOption(data.name, function()
                    button:SetMaterial(data.icon)
                    button.SelectedItem = entClass
                    saberStation.currCrystalName = entClass
        
                    if IsValid(saberStation.PreviewPanel) then
                        saberStation.PreviewPanel:Remove()
                    end
                    saberStation.PreviewPanel = saberStation:CreateSaberPreview(saberStation.Panel)
                end)
            end
        end
        
    menu:Open()
    end

    button.Paint = function(self, w, h) 
        surface.SetDrawColor(LSCS_SABERSTATION.Colour.Text)
        surface.DrawOutlinedRect(0,0,w,h, 1.5)
    end

    return button
end

function LSCS_SABERSTATION:CreateConfirmButton(parent)
    local buttonW, buttonH = self.W * 0.15, self.H * 0.05
    local button = vgui.Create("DButton", parent)
    button:SetSize(buttonW, buttonH)
    button:SetText("")
    
    button:SetPos(parent:GetWide() / 2 - buttonW / 2, parent:GetTall() - buttonH - self.PAD * 4)

    button.Paint = function(self, w, h)
        local bgColor = self.Hovered and LSCS_SABERSTATION.Colour.HoverHL or LSCS_SABERSTATION.Colour.HL

        draw.RoundedBox(self:GetWide() * 0.05, 0, 0, w, h, bgColor)
        draw.SimpleText("Craft", "sgb30", w / 2, h / 2, LSCS_SABERSTATION.Colour.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(LSCS_SABERSTATION.Colour.Text)
        surface.DrawOutlinedRect(0, 0, w, h, 1.5)
    end

    button.DoClick = function()
        local hiltClass = self.currHiltName or ""
        local crystalClass = self.currCrystalName or ""

        if hiltClass == "" or crystalClass == "" then
            surface.PlaySound("common/wpn_denyselect.wav")
            return
        end
        
        net.Start("LSCS_CraftSaberFromSaberUI")
            net.WriteString(hiltClass)
            net.WriteString(crystalClass)
            net.WriteString(self.CurrSelectedHand)
        net.SendToServer()

        surface.PlaySound("buttons/button14.wav")
        chat.AddText(Color(0, 255, 0), "[DG] ", color_white, "Saber crafting confirmed!")

        if self.PreviewPanel and IsValid(self.PreviewPanel) then self.PreviewPanel:Remove() end
        if self.Panel and IsValid(self.Panel) then self.Panel:Close() end
        if self.BlurPanel and IsValid(self.BlurPanel) then self.BlurPanel:Remove() end
        self.Panel = nil
    end
    
    return button
end

function LSCS_SABERSTATION:HasDualSabers() 
    local ownedNodes = LocalPlayer().SkillSystem.Nodes

    for tree, nodes in pairs(ownedNodes) do
        if nodes[LSCS_SS_CONFIG.DualSaberNodeName] then
            return true
        end
    end

    return false
end


