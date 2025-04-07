include("client/cl_skill_networking.lua")

LSCS_ADMINMENU = LSCS_ADMINMENU or {}

function LSCS_ADMINMENU:Open()
    if IsValid(self.Frame) then
        self.Frame:Remove()
    end

    local frameW, frameH = ScrW() * 0.4, ScrH() * 0.6
    local sidebarW = frameW * 0.25

    self.Frame = vgui.Create("DFrame")
    self.Frame:SetSize(frameW, frameH)
    self.Frame:Center()
    self.Frame:SetTitle("LSCS Admin Menu")
    self.Frame:MakePopup()

    local Sidebar = vgui.Create("DPanel", self.Frame)
    Sidebar:SetSize(sidebarW, frameH)
    Sidebar:SetPos(0, 25)
    Sidebar.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 255))
    end

    local Content = vgui.Create("DPanel", self.Frame)
    Content:SetSize(frameW - sidebarW, frameH - 25)
    Content:SetPos(sidebarW, 25)
    Content.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(70, 70, 70, 255))
    end

    local Pages = {}

    function self:OpenPage(name)
        for k, v in pairs(Pages) do
            v:SetVisible(k == name)
        end
    end

    local function AddPage(name, buildFunc)
        local btn = vgui.Create("DButton", Sidebar)
        btn:SetText(name)
        btn:Dock(TOP)
        btn:DockMargin(5, 5, 5, 0)
        btn.DoClick = function()
            self:OpenPage(name)
        end

        local page = vgui.Create("DPanel", Content)
        page:SetSize(Content:GetWide(), Content:GetTall())
        page.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(90, 90, 90, 255))
        end
        page:SetVisible(false)

        Pages[name] = page
        buildFunc(page)
    end

    function LSCS_ADMINMENU:CreatePlayerStatMenu(panel)
        local statPanel = nil
        local numberFields = {}
        local submitButton = nil
    
        local playerList = vgui.Create("DListView", panel)
        playerList:SetSize(panel:GetWide() * 0.75, panel:GetTall() / 3)
        playerList:SetPos(panel:GetWide() / 2 - playerList:GetWide() / 2, panel:GetTall() * 0.05)
        playerList:AddColumn("Name")
        playerList:AddColumn("SteamID64")
        playerList:SetMultiSelect(false)
    
        for _, player in ipairs(player.GetAll()) do
            playerList:AddLine(player:Nick(), player:SteamID64())
        end
    
        playerList.OnRowSelected = function(_, _, pnl)
            net.Start("LSCS_RequestPlayerDataForAdminMenu")
            net.WriteString(pnl:GetColumnText(2))
            net.SendToServer()
    
            net.Receive("LSCS_SendPlayerDataForAdminMenu", function()
                local playerTable = net.ReadTable()
    
                if IsValid(statPanel) then
                    statPanel:Remove()
                end
    
                statPanel = vgui.Create("DPanel", panel)
                statPanel:SetSize(panel:GetWide(), panel:GetTall() / 2)
                statPanel:SetPos(0, panel:GetTall() * 0.4)
                statPanel.Paint = function(self, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, Color(90, 90, 90, 255))
                end
    
                for _, field in pairs(numberFields) do
                    if IsValid(field) then field:Remove() end
                end

                numberFields = {}
                    
                local counter = 0
                for k, v in pairs(playerTable) do
                    if type(v) ~= "number" then continue end
    
                    local yPos = 20 + (counter * 30)
                    local xPos = 20
    
                    local textLabel = vgui.Create("DLabel", statPanel)
                    textLabel:SetText(k .. ":")
                    textLabel:SetPos(xPos, yPos)
                    textLabel:SizeToContents()
    
                    local textEntry = vgui.Create("DTextEntry", statPanel)
                    textEntry:SetPos(xPos + 100, yPos)
                    textEntry:SetSize(100, 20)
                    textEntry:SetTextColor(Color(0,0,0))
                    textEntry:SetText(tostring(v))
    
                    numberFields[k] = textEntry 
                    counter = counter + 1
                end
    
                if IsValid(submitButton) then
                    submitButton:Remove()
                end
    
                submitButton = vgui.Create("DButton", statPanel)
                submitButton:SetSize(panel:GetWide(), panel:GetTall() * 0.1)
                submitButton:SetPos(0, statPanel:GetTall() - submitButton:GetTall())
                submitButton:SetText("Save")

                submitButton.DoClick = function()
                    local steamid64 = pnl:GetColumnText(2)
                    local tbl = {}

                    for k, v in pairs(numberFields) do
                        local val = tonumber(v:GetValue())
            
                        if val == nil then 
                            surface.PlaySound("common/wpn_denyselect.wav")
                            return 
                        end

                        tbl[k] = val
                    end

                    net.Start("LSCS_AdminMenuSubmitPlayerData")
                        net.WriteString(steamid64)
                        net.WriteTable(tbl)
                    net.SendToServer()

                    surface.PlaySound("common/wpn_select.wav")
                end
            end)
        end
    end

    function LSCS_ADMINMENU:CreateInventoryMenu(panel)
        local statPanel = nil
        local inventoryList = nil
        local submitButton = nil
        local allItemList = nil
        
        local playerList = vgui.Create("DListView", panel)
        playerList:SetSize(panel:GetWide() * 0.75, panel:GetTall() / 3)
        playerList:SetPos(panel:GetWide() / 2 - playerList:GetWide() / 2, panel:GetTall() * 0.05)
        playerList:AddColumn("Name")
        playerList:AddColumn("SteamID64")
        playerList:SetMultiSelect(false)
    
        for _, player in ipairs(player.GetAll()) do
            playerList:AddLine(player:Nick(), player:SteamID64())
        end
    
        playerList.OnRowSelected = function(_, _, pnl)
            net.Start("LSCS_RequestPlayerDataForAdminMenu")
                net.WriteString(pnl:GetColumnText(2))
            net.SendToServer()
        
            net.Receive("LSCS_SendPlayerDataForAdminMenu", function()
                local playerTable = net.ReadTable()
        
                if IsValid(inventoryList) then inventoryList:Remove() end
        
                inventoryList = nil
                inventoryList = vgui.Create("DListView", panel)
                inventoryList:SetSize(panel:GetWide() / 1.5, panel:GetTall() / 5)
                inventoryList:SetPos(panel:GetWide() / 2 - inventoryList:GetWide() / 2, playerList:GetTall() + playerList:GetY() + panel:GetTall() * 0.05)
                inventoryList:SetMultiSelect(false)
                inventoryList:AddColumn("Inventory")
        
                for k, v in pairs(playerTable.Inventory) do
                    if v == nil  or v == "" then continue end
                    
                    local ent = scripted_ents.Get(v)
                    local steamid64 = pnl:GetColumnText(2)

                    if ent == nil then
                        net.Start("LSCS_RemoveInventoryItem")
                            net.WriteString(steamid64)
                            net.WriteString(v)  -- Send entity key
                        net.SendToServer()

                        continue
                    end

                    local entName = ent.PrintName
                    local line = inventoryList:AddLine(entName)
        
                    line.OnRightClick = function()
                        local menu = DermaMenu()

                        menu:AddOption("Remove", function()
                            inventoryList:RemoveLine(line:GetID())
        
                            net.Start("LSCS_RemoveInventoryItem")
                                net.WriteString(steamid64)
                                net.WriteString(v)  -- Send entity key
                            net.SendToServer()
                        end):SetIcon("icon16/delete.png")
        
                        menu:Open()
                    end
                end

                allItemList = nil
                allItemList = vgui.Create("DListView", panel)
                allItemList:SetSize(panel:GetWide() / 1.5, panel:GetTall() / 3.25)
                allItemList:SetPos(panel:GetWide() / 2 - allItemList:GetWide() / 2, inventoryList:GetTall() + inventoryList:GetY() + panel:GetTall() * 0.025)
                allItemList:SetMultiSelect(false)
                allItemList:AddColumn("Add To Inventory")
                
                for k, v in SortedPairs(table.Merge(LSCS.Hilt, LSCS.Blade)) do
                    local name = v.Type .. " | " .. v.name
                    local line = allItemList:AddLine(name)
                
                    line.OnRightClick = function()
                        local menu = DermaMenu()
                        local steamid64 = pnl:GetColumnText(2)
                
                        menu:AddOption("Add to Inventory", function()
                            net.Start("LSCS_AddToInventory")
                                net.WriteString(steamid64)
                                net.WriteString(v.class)
                            net.SendToServer()
                
                            if IsValid(inventoryList) then
                                inventoryList:AddLine(name)
                            end
                        end):SetIcon("icon16/add.png") 
                
                        menu:Open()
                    end
                end
            end)
        end        
    end
    
    AddPage("Dashboard", function(panel)
        local lbl = vgui.Create("DLabel", panel)
        lbl:SetText("Welcome to LSCS Admin Menu")
        lbl:SetFont("DermaLarge")
        lbl:SizeToContents()
        lbl:Center()
    end)

    AddPage("Player Stats", function(panel)
        LSCS_ADMINMENU:CreatePlayerStatMenu(panel)
    end)

    AddPage("Inventory", function(panel)
        LSCS_ADMINMENU:CreateInventoryMenu(panel)
    end)

    self:OpenPage("Dashboard")
end

net.Receive("LSCS_OpenAdminMenuOnClient", function()
    LSCS_ADMINMENU:Open()
end)