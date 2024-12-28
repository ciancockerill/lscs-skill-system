include("client/cl_skill_networking.lua")

LSCS_SKILLSTATION = LSCS_SKILLSTATION or {}

function buildTree(knightTree)
    for nodeName, nodeData in pairs(knightTree.Nodes) do
        -- For each prerequisite of the node (which is the previous child)
        for i, prereq in ipairs(nodeData.Prerequisites) do
            local prereqNode = knightTree.Nodes[prereq]  -- Get the prerequisite node
            if prereqNode then
                table.insert(prereqNode.Children, nodeData)
            end
        end
    end
end

function printTreeRecursive(node, indent)
    indent = indent or ""
    print(indent .. node.Name)
    for _, child in ipairs(node.Children) do
        printTreeRecursive(child, indent .. "  ")
    end
end

function printSkillTree()
    for _, nodeData in pairs(LSCS_SKILLTREE.CurrentSelected.Nodes) do
        if #nodeData.Prerequisites == 0 then 
            printTreeRecursive(nodeData)
        end
    end
end

LSCS_SKILLSTATION.Material = {
    icon_jediemblem = Material("materials/lscs_skill_station/icon_jediorder.png"),
    icon_defaultstance = Material("materials/lscs_skill_station/icon_defaultstance.png"),
    icon_defaultpower = Material("materials/lscs_skill_station/icon_defaultpower.png")
}

LSCS_SKILLSTATION.Colour = {
    BG = Color(17, 17, 33),
    HL = Color(35, 36, 70),
    Text = Color(255, 255, 255),
    SMLText = Color(102,102,204),
    HoverHL = Color(50,50,102)
}

function LSCS_SKILLSTATION:CreatePanel()
    local SW = ScrW()
    local SH = ScrH()

    self.W = SW * 0.75
    self.H = SH * 0.75
    self.X = SW / 2 - self.W / 2
    self.Y = SH / 2 - self.H / 2
    self.PAD = math.floor(SH * 0.00925)
    self.BodyPAD = self.PAD * 20
    self.CornerRAD = self.W * 0.015

    self.Panel = vgui.Create("DFrame")
    self.Panel:SetPos(self.X, self.Y)
    self.Panel:SetSize(self.W, self.H)
    self.Panel:SetTitle("")
    self.Panel:MakePopup()
    self.Panel:SetDraggable(false)
    self.Panel:ShowCloseButton(false)

    self.Panel.Paint = function(self,w,h)
        draw.RoundedBox(self:GetWide() * 0.015, 0, 0, w, h, LSCS_SKILLSTATION.Colour.BG)
        surface.SetDrawColor(255, 255, 255)
    end

    self.HeaderPanel = self:CreateHeader()
    self.PInfoBodyPanel = self:CreatePInfoPanel()

    self.HeadingBodyVertDiv = self:CreateVertDivider(self.HeaderPanel)
    self.BodySkillTreeVertDiv = self:CreateVertDivider(self.PInfoBodyPanel)

    self.SkillTreeSelectPanel = self:CreateSkillTreeSelectBar()
    self.SkillTreePanel = self:CreateSkillTreePanel()
end

function LSCS_SKILLSTATION:CreateCloseButton(parent)
    local CloseButton = vgui.Create("DButton", parent)
    CloseButton:SetSize(self.W * 0.025, self.W * 0.025)
    CloseButton:SetText("X")
    CloseButton:SetFont("CenterPrintText")

    CloseButton.Paint = function(self, w, h)
        local buttonColour = nil
        if CloseButton.Hovered then buttonColour = LSCS_SKILLSTATION.Colour.HoverHL else buttonColour = LSCS_SKILLSTATION.Colour.HL end
        draw.RoundedBox(self:GetWide() / 3, 0, 0, w, h, buttonColour)
        surface.SetDrawColor(255, 255, 255)
    end

    CloseButton.PaintOver = function(self, w, h)
        draw.SimpleText("X", "CenterPrintText", w / 2, h / 2, LSCS_SKILLSTATION.Colour.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    CloseButton.DoClick = function()
        self.Panel:Close()
        self.Panel = nil
    end

    return CloseButton
end

function LSCS_SKILLSTATION:CreateVertDivider(topPanel)
    local Div = vgui.Create("DPanel", self.Panel)
    Div:SetSize(self.Panel:GetWide() - self.PAD, self.PAD / 4)
    Div:SetPos(self.Panel:GetWide() / 2 - Div:GetWide() / 2, topPanel:GetTall() + topPanel:GetY())
    Div.Paint = function(self, w, h)
        draw.RoundedBox(self:GetTall() / 2, 0,0,w,h, LSCS_SKILLSTATION.Colour.Text)
    end
    return Div
end

function LSCS_SKILLSTATION:CreateHeader()
    local HeaderPanel = vgui.Create("DPanel", self.Panel)
    HeaderPanel:SetSize(self.W, self.H / 15)
    HeaderPanel:SetPos(0,0)
    HeaderPanel.Paint = function(self, w, h)
        draw.RoundedBox(self:GetWide() * 0.015, 0, 0, w, h, LSCS_SKILLSTATION.Colour.BG)
    end

    self.CloseButton = self:CreateCloseButton(HeaderPanel)
    self.CloseButton:SetPos(self.W - self.CloseButton:GetWide() - self.PAD, self.PAD)

    self.JediLogoPanel = vgui.Create("DPanel", HeaderPanel)
    self.JediLogoPanel:SetSize(HeaderPanel:GetTall() - self.PAD * 1.5, HeaderPanel:GetTall() - self.PAD * 1.5)
    self.JediLogoPanel:SetPos(self.PAD * 2, HeaderPanel:GetTall() / 2 - self.JediLogoPanel:GetTall() / 2)
    self.JediLogoPanel.Paint = function(self, w, h)
        surface.SetMaterial(LSCS_SKILLSTATION.Material.icon_jediemblem)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.HeaderText = self:CreateText(HeaderPanel)
    self.HeaderText:SetText("Galactic Republic - Skill Mastery")
    self.HeaderText:SetFont("sgb30")
    self.HeaderText:SetSize(self.HeaderText:GetTextSize())
    self.HeaderText:SetPos(self.JediLogoPanel:GetX() + self.JediLogoPanel:GetWide() + self.PAD * 0.25, HeaderPanel:GetTall() / 2 - select(2, self.HeaderText:GetTextSize()) / 2)

    return HeaderPanel
end

function LSCS_SKILLSTATION:CreateText(parent)
    local TextLabel = vgui.Create("DLabel", parent)
    TextLabel:SetColor(LSCS_SKILLSTATION.Colour.Text)

    return TextLabel
end

function LSCS_SKILLSTATION:CreatePlayerModelBox(parent)
    local Panel = vgui.Create( "DPanel", parent)
    local PMBoxSize = self.W / 10
    Panel:SetSize(PMBoxSize + self.PAD, PMBoxSize + self.PAD)
    Panel.Paint = function(self, w, h)
        draw.RoundedBox(self:GetWide() * 0.1, 0, 0, w, h, LSCS_SKILLSTATION.Colour.Text)
    end

    local PMBox = vgui.Create("DModelPanel", Panel)
    PMBox:SetSize(PMBoxSize, PMBoxSize)
    PMBox:SetModel(LocalPlayer():GetModel())
    PMBox:SetPos(Panel:GetWide() / 2 - PMBox:GetWide() / 2, self.PAD)
    PMBox:SetEnabled(false)

    function PMBox:LayoutEntity(Entity) return end

    local headpos = PMBox.Entity:GetBonePosition(PMBox.Entity:LookupBone("ValveBiped.Bip01_Head1"))
    PMBox:SetLookAt(headpos-Vector(-10,0,0))
    PMBox:SetCamPos(headpos-Vector(-17.5, 0, -1))
    PMBox.Entity:SetEyeTarget(headpos-Vector(-15, 0, 0))
    
    return Panel
end

function LSCS_SKILLSTATION:CreatePInfoPanel()
    local PInfoPanel = vgui.Create("DPanel", self.Panel)
    PInfoPanel:SetSize(self.Panel:GetWide(), self.Panel:GetTall() / 4)
    PInfoPanel:SetPos(0, self.HeaderPanel:GetTall())
    PInfoPanel.Paint = function(self,w,h)
        surface.SetDrawColor(LSCS_SKILLSTATION.Colour.BG)
        surface.DrawRect(0,0,w,h)
    end

    self.PMBox = self:CreatePlayerModelBox(PInfoPanel)
    self.PMBox:SetPos(self.BodyPAD, PInfoPanel:GetTall() / 2 - self.PMBox:GetTall() / 2)

    self.PlayerNameLabel = self:CreateText(PInfoPanel)
    self.PlayerNameLabel:SetText(LocalPlayer():Nick())
    self.PlayerNameLabel:SetFont("sgb40")
    self.PlayerNameLabel:SetSize(self.PlayerNameLabel:GetTextSize())

    local currLevel = LocalPlayer().SkillSystem.Level
    local darkrpJob = LocalPlayer().DarkRPVars.job
    self.PlayerLevelLabel = self:CreateText(PInfoPanel) 
    self.PlayerLevelLabel:SetText("Level "..currLevel.." "..darkrpJob)
    self.PlayerLevelLabel:SetFont("sgl25")
    self.PlayerLevelLabel:SetSize(self.PlayerLevelLabel:GetTextSize())
    self.PlayerLevelLabel:SetColor(LSCS_SKILLSTATION.Colour.SMLText)

    local currSkillPoints = LocalPlayer().SkillSystem.SkillPoints
    self.PlayerXPLabel = self:CreateText(PInfoPanel)
    self.PlayerXPLabel:SetText("Skill Points: "..currSkillPoints)
    self.PlayerXPLabel:SetFont("sgl25")
    self.PlayerXPLabel:SetSize(self.PlayerXPLabel:GetTextSize())
    self.PlayerXPLabel:SetColor(LSCS_SKILLSTATION.Colour.SMLText)

    local combinedTextSize = self.PlayerNameLabel:GetTall() + self.PlayerLevelLabel:GetTall() + self.PlayerXPLabel:GetTall()
    local centeredY = PInfoPanel:GetTall() / 2 - combinedTextSize / 2
    self.PlayerNameLabel:SetPos(self.PMBox:GetX() + self.PMBox:GetWide() + self.PAD, centeredY)
    self.PlayerLevelLabel:SetPos(self.PlayerNameLabel:GetX(), self.PlayerNameLabel:GetY() + self.PlayerNameLabel:GetTall())
    self.PlayerXPLabel:SetPos(self.PlayerLevelLabel:GetX(), self.PlayerLevelLabel:GetY() + self.PlayerLevelLabel:GetTall())

    self.XPBar = self:CreateXPBar(PInfoPanel)
    self.XPBar:SetPos(PInfoPanel:GetWide() - self.BodyPAD - self.XPBar:GetWide() , PInfoPanel:GetTall() / 2 - self.XPBar:GetTall() / 2)

    return PInfoPanel
end

function LSCS_SKILLSTATION:CreateXPBar(parent)
    local XPBarPanel = vgui.Create("DPanel", parent)
    XPBarPanel:SetSize(self.BodyPAD * 3, self.BodyPAD / 2.5)

    XPBarPanel.Paint = function(self, w, h)
        surface.SetDrawColor(LSCS_SKILLSTATION.Colour.BG)
        surface.DrawRect(0, 0, w, h)
    end

    local XPBarPAD = self.PAD * 10
    local currPlayerXP = LocalPlayer().SkillSystem.XP
    local nextLevelXP = LSCS_SKILLSYSTEM:GetXPToNextLevel(LocalPlayer().SkillSystem.Level + 1)

    local XPLabel = self:CreateText(XPBarPanel)
    XPLabel:SetText("Experience: " .. currPlayerXP .. " / " .. nextLevelXP)
    XPLabel:SetFont("sgl25")
    XPLabel:SetSize(XPLabel:GetTextSize())
    XPLabel:SetPos(XPBarPanel:GetWide() / 2 - XPLabel:GetWide() / 2, 0)
    XPLabel:SetColor(LSCS_SKILLSTATION.Colour.SMLText)

    local XPBar = vgui.Create("DPanel", XPBarPanel)
    XPBar:SetSize(XPBarPanel:GetWide() - XPBarPAD, XPBarPanel:GetTall() / 4)
    XPBar:SetPos(XPBarPanel:GetWide() / 2 - XPBar:GetWide() / 2, XPLabel:GetTall() + self.PAD)

    local animatedProgress = 0
    local animation = Derma_Anim("XPBarFill", XPBar, function(pnl, anim, delta, data)
        animatedProgress = delta * (currPlayerXP / nextLevelXP)
    end)
    animation:Start(1.2) 

    XPBar.Paint = function(self, w, h)
        draw.RoundedBox(self:GetWide() * 0.1, 0, 0, w, h, LSCS_SKILLSTATION.Colour.Text)
    end
    XPBar.PaintOver = function(self, w, h)
        if animation:Active() then
            animation:Run()
        end
        draw.RoundedBox(self:GetWide() * 0.1, -1, 0, math.ceil(w * animatedProgress) + 2, h, LSCS_SKILLSTATION.Colour.SMLText)
    end

    XPBarPanel.Think = function(self)
        if animation:Active() then
            animation:Run()
        end
    end

    return XPBarPanel
end

function LSCS_SKILLSTATION:CreateSkillTreeSelectBar()
    local SelectFrame = vgui.Create("DPanel", self.Panel)
    SelectFrame:SetSize(self.W, self.H / 12.5)
    SelectFrame:SetPos(0, self.Panel:GetTall() - SelectFrame:GetTall())

    SelectFrame.Paint = function(self, w, h)
        draw.RoundedBox(self:GetWide() * 0.015, 0, 0, w, h, LSCS_SKILLSTATION.Colour.BG)
    end

    self.currTreeSelectButton = self:CreateTreeSelectButton(LSCS_SKILLTREE.TreeNames[1], SelectFrame) -- Initially set it to the first SkillT

    self.leftPointer, self.rightPointer = self:CreatePointerButtons(SelectFrame)

    self.leftPointer:SetPos(SelectFrame:GetWide() / 2 - self.leftPointer:GetWide() / 2 - self.currTreeSelectButton:GetWide() - self.PAD, SelectFrame:GetTall() / 2 - self.leftPointer:GetTall() / 2)
    self.rightPointer:SetPos(SelectFrame:GetWide() / 2 - self.rightPointer:GetWide() / 2 + self.currTreeSelectButton:GetWide() + self.PAD, SelectFrame:GetTall() / 2 - self.rightPointer:GetTall() / 2)

    return SelectFrame
end

function LSCS_SKILLSTATION:CreateTreeSelectButton(TreeNames, parent)
    local treeSelectButton = vgui.Create("DButton", parent)
    local size = parent:GetTall() * 0.75
    treeSelectButton:SetSize(size, size)
    treeSelectButton:SetText("")
    treeSelectButton:SetPos(parent:GetWide() / 2 - treeSelectButton:GetWide() / 2, parent:GetTall() / 2 - treeSelectButton:GetTall() / 2)
    treeSelectButton.Paint = function(self, w, h)
        surface.SetDrawColor(LSCS_SKILLSTATION.Colour.HL)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(LSCS_SKILLSTATION.Colour.Text)
        surface.DrawOutlinedRect(0 , 0, w, w, 2 )

        surface.SetFont("sgb25")
        surface.SetTextColor(LSCS_SKILLSTATION.Colour.Text)
        local width, height = surface.GetTextSize(TreeNames[1])
        surface.SetTextPos(w / 2 - width / 2, h / 2 - height / 2) 
        surface.DrawText(TreeNames[1])
    end

    return treeSelectButton
end

function LSCS_SKILLSTATION:CreatePointerButtons(parent)
    local leftPointButton = vgui.Create("DButton", parent)
    local size = parent:GetTall() * 0.5
    leftPointButton:SetSize(size, size)
    leftPointButton:SetText("")
    
    local rightPointButton = vgui.Create("DButton", parent)
    rightPointButton:SetSize(size, size)
    rightPointButton:SetText("")

    leftPointButton.Paint = function(self, w, h)
        surface.SetDrawColor(LSCS_SKILLSTATION.Colour.HL)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(LSCS_SKILLSTATION.Colour.Text)
        surface.DrawOutlinedRect(0 , 0, w, w, 1 )

        surface.SetFont("sgb25")
        surface.SetTextColor(LSCS_SKILLSTATION.Colour.Text)
        local width, height = surface.GetTextSize("<")
        surface.SetTextPos(w / 2 - width / 2, h / 2 - height / 2) 
        surface.DrawText("<")
    end

    rightPointButton.Paint = function(self, w, h)
        surface.SetDrawColor(LSCS_SKILLSTATION.Colour.HL)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(LSCS_SKILLSTATION.Colour.Text)
        surface.DrawOutlinedRect(0 , 0, w, w, 1 )

        surface.SetFont("sgb25")
        surface.SetTextColor(LSCS_SKILLSTATION.Colour.Text)
        local width, height = surface.GetTextSize(">")
        surface.SetTextPos(w / 2 - width / 2, h / 2 - height / 2) 
        surface.DrawText(">")
    end

    return leftPointButton, rightPointButton
end

function LSCS_SKILLSTATION:CreateSkillTreePanel()
    local SkillFrame = vgui.Create("DPanel", self.Panel)
    SkillFrame:SetSize(self.W, self.H - self.HeaderPanel:GetTall() - self.PInfoBodyPanel:GetTall() - self.SkillTreeSelectPanel:GetTall())
    SkillFrame:SetPos(0, self.HeaderPanel:GetTall() + self.PInfoBodyPanel:GetTall() + self.BodySkillTreeVertDiv:GetTall() + self.HeadingBodyVertDiv:GetTall())

    SkillFrame.Paint = function(self, w, h)
        surface.SetDrawColor(LSCS_SKILLSTATION.Colour.BG)
        surface.DrawRect(0, 0, w, h)
    end

    local Throbber = self:CreateThrobber(SkillFrame)

    LSCS_SKILLSYSTEM:GetSelectedSkillTree(LSCS_SKILLTREE.TreeNames[1])

    hook.Add("LSCS_SelectedSkillTreeDataReady", "UpdateSelectedSkillTree", function()
        Throbber:Remove()
        self.Canvas = self:CreateDraggableCanvas(SkillFrame)

        local treeData = LSCS_SKILLTREE.CurrentSelected
        local startX = self.BodyPAD
        local startY = self.Canvas:GetTall() / 2
        local spacingX = SkillFrame:GetWide() * 0.045
        local spacingY = SkillFrame:GetTall() / 1.5

        buildTree(treeData)
        PrintTable(treeData)
        self:BuildTree(treeData.Nodes["Fireball"], self.Canvas, startX, startY, 1, spacingX, spacingY)
    end)

    return SkillFrame
end

function LSCS_SKILLSTATION:CreateDraggableCanvas(parent)
    local skillTreeCanvas = vgui.Create("DPanel", parent)
    skillTreeCanvas:SetSize(self.W * 5, self.H * 5)
    skillTreeCanvas:SetPos(0, -skillTreeCanvas:GetTall() / 2 + parent:GetTall() / 2)

    skillTreeCanvas.Paint = function(self, w, h)
        surface.SetDrawColor(LSCS_SKILLSTATION.Colour.BG)
        surface.DrawRect(0, 0, w, h)
    end

    local isDragging = false
    local dragOffset = {x = 0, y = 0}

    skillTreeCanvas.OnMousePressed = function(self)
        isDragging = true
        local mx, my = input.GetCursorPos()
        local px, py = self:GetPos()
        dragOffset.x = mx - px
        dragOffset.y = my - py
    end

    skillTreeCanvas.OnMouseReleased = function(self)
        isDragging = false
    end

    skillTreeCanvas.Think = function(self)
        if isDragging then
            local mx, my = input.GetCursorPos()
            local newX = mx - dragOffset.x
            local newY = my - dragOffset.y
            self:SetPos(newX, newY)
        end
    end

    return skillTreeCanvas
end

function LSCS_SKILLSTATION:CreateThrobber(parent)
    local Throbber = vgui.Create("DLabel", parent)
    Throbber:SetFont("sgb40")
    Throbber:SetTextColor(Color(255,255,255))
    Throbber:SetText("Loading...")
    Throbber:SetSize(Throbber:GetTextSize())
    Throbber:SetPos(parent:GetWide() / 2 - Throbber:GetWide() / 2, parent:GetTall() / 2 - Throbber:GetTall() / 2)
    return Throbber
end

function LSCS_SKILLSTATION:CreateNode(nodeData, parent)
    PrintTable(nodeData)
    local node = vgui.Create("DButton", parent)
    local size = self.PAD * 5
    node:SetSize(size,size)
    node:SetText("")
    
    node.Paint = function(self, w, h)
        surface.SetDrawColor(LSCS_SKILLSTATION.Colour.Text)
        surface.SetMaterial(Material(nodeData.Icon))
        surface.DrawTexturedRect(0,0,w,h)
        surface.DrawOutlinedRect(0 , 0, w, w, 1 )

        --draw.DrawText(nodeData.Name, "sgb10", self:GetWide() / 2, self:GetTall() / 2, LSCS_SKILLSTATION.Colour.Text, TEXT_ALIGN_CENTER)
    end

    return node
end

function LSCS_SKILLSTATION:_BuildTree(nodeData, parent, x, y, level, spacingX, spacingY, lineData)
    local node = self:CreateNode(nodeData, parent)

    local posX = x + (level * spacingX)
    local posY = y 
    node:SetPos(posX, posY)

    if not nodeData.Children or not istable(nodeData.Children) then
        return node
    end

    local childCount = #nodeData.Children
    if childCount == 0 then
        return node
    end

    local childSpacing = spacingY / math.max(childCount, 1)
    local childYStart = posY - (childSpacing * (childCount - 1) / 2)

    for i, childData in ipairs(nodeData.Children) do
        local childY = childYStart + ((i - 1) * childSpacing)

        self:_BuildTree(childData, parent, posX, childY, level + 1, spacingX, spacingY, lineData)
        local currLine = {{posX + node:GetWide(), y + node:GetTall() / 2}, {posX + (level * spacingX) + node:GetWide() * 1.39, childY + node:GetTall() / 2}} -- weird offsets to get line correct, need to look at
        table.insert(lineData, currLine)
    end

    return node
end

function LSCS_SKILLSTATION:BuildTree(nodeData, parent, x, y, level, spacingX, spacingY)
    local lineData = {}
    self:_BuildTree(nodeData, parent, x, y, level, spacingX, spacingY, lineData)
    PrintTable(lineData)

    parent.PaintOver = function(self, x, y)
        surface.SetDrawColor(255,255,255)
        for k, currLine in pairs(lineData) do
            surface.DrawLine(currLine[1][1], currLine[1][2], currLine[2][1], currLine[2][2])
        end
    end 
end
