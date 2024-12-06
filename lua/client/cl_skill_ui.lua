LSCS_SKILLSTATION = LSCS_SKILLSTATION or {}

LSCS_SKILLSTATION.Colour = {
    BG = Color(17, 17, 33),
    HL = Color(35, 36, 70),
    Text = Color(255, 255, 255),
    SMLText = Color(35, 36, 70)
}

function LSCS_SKILLSTATION:CreatePanel()
    local SW = ScrW()
    local SH = ScrH()

    self.W = SW * 0.75
    self.H = SH * 0.75
    self.X = SW / 2 - self.W / 2
    self.Y = SH / 2 - self.H / 2

    self.Panel = vgui.Create("DFrame")
    self.Panel:SetPos(self.X, self.Y)
    self.Panel:SetSize(self.W, self.H)
    self.Panel:SetTitle("")
    self.Panel:MakePopup()
    self.Panel:SetDraggable(false)
    self.Panel:ShowCloseButton(false)

    self.Panel.Paint = function(self,w,h)
        draw.RoundedBox(self:GetWide() * 0.01, 0, 0, w, h, LSCS_SKILLSTATION.Colour.BG)
        surface.SetDrawColor(255, 255, 255)
    end

    self:CreateCloseButton()
end

function LSCS_SKILLSTATION:CreateCloseButton()
    local CloseButton = vgui.Create("DButton", self.Panel)
    CloseButton:SetSize(self.W * 0.025, self.W * 0.025)
    CloseButton:SetPos(self.W - CloseButton:GetWide() - 10, 10)
    CloseButton:SetText("X")
    CloseButton:SetFont("CenterPrintText")

    -- Custom Paint function for the button
    CloseButton.Paint = function(self, w, h)
        draw.RoundedBox(self:GetWide() / 3, 0, 0, w, h, LSCS_SKILLSTATION.Colour.HL)
        surface.SetDrawColor(255, 255, 255)
    end

    CloseButton.PaintOver = function(self, w, h)
        if self.Hovered then
            draw.SimpleText("X", "CenterPrintText", w / 2, h / 2, LSCS_SKILLSTATION.Colour.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("X", "CenterPrintText", w / 2, h / 2, LSCS_SKILLSTATION.Colour.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    CloseButton.DoClick = function()
        self.Panel:Close()
        self.Panel = nil
    end

    return CloseButton
end

