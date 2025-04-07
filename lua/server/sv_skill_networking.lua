util.AddNetworkString("LSCS_RequestSkillDataFromServer")
util.AddNetworkString("LSCS_SendSkillDataToClient")
util.AddNetworkString("LSCS_RequestTreeDataFromServer")
util.AddNetworkString("LSCS_SendTreeDataToClient")
util.AddNetworkString("LSCS_RequestAllSkillTreeNamesFromServer")
util.AddNetworkString("LSCS_SendAllSkillTreeNamesToClient")
util.AddNetworkString("LSCS_UnlockNodeFromSkillMenu")
util.AddNetworkString("LSCS_SendLevelUpNotificationToClient")

util.AddNetworkString("LSCS_OpenAdminMenuOnClient")
util.AddNetworkString("LSCS_RequestPlayerDataForAdminMenu")
util.AddNetworkString("LSCS_SendPlayerDataForAdminMenu")
util.AddNetworkString("LSCS_AdminMenuSubmitPlayerData")
util.AddNetworkString("LSCS_RemoveInventoryItem")
util.AddNetworkString("LSCS_AddToInventory")
util.AddNetworkString("LSCS_CraftSaberFromSaberUI")

net.Receive("LSCS_CraftSaberFromSaberUI", function(len, ply)
    if not ply.SkillSystem then return end

    local hilt = net.ReadString()
    local crystal = net.ReadString()
    local hand = net.ReadString()

    if ply.SkillSystem.CurrEquipped[hand]["Hilt"] ~= nil then
        table.insert(ply.SkillSystem.Inventory, ply.SkillSystem.CurrEquipped[hand]["Hilt"]) 
    end

    if ply.SkillSystem.CurrEquipped[hand]["Crystal"] ~= nil then
        table.insert(ply.SkillSystem.Inventory, ply.SkillSystem.CurrEquipped[hand]["Crystal"]) 
    end

    ply.SkillSystem.CurrEquipped[hand]["Hilt"] = hilt
    ply.SkillSystem.CurrEquipped[hand]["Crystal"] = crystal

    table.RemoveByValue(ply.SkillSystem.Inventory, hilt)
    table.RemoveByValue(ply.SkillSystem.Inventory, crystal)

    ply.SkillSystem:SavePlayerData()
    ply.SkillSystem:LoadPlayerData(ply)

    timer.Simple(0, function()
        local skillSystem = ply.SkillSystem
        if not skillSystem then return end

        print("--------------------------------------------------rannington?")

        ply:lscsWipeInventory() -- Wipe to give new items, will have to change for inventory potentially.
        ply:Give("weapon_lscs")

        for tree, nodes in pairs(skillSystem.Nodes) do
            local skillTree = LSCS_SKILLSYSTEM.SkillTrees[tree]
            if not skillTree then continue end
            if not skillTree.JobAccess[ply:Team()] then continue end

            local treeNodes = skillTree.Nodes
            if not treeNodes then continue end

            for nodeName, nodeData in pairs(treeNodes) do
                if nodes[nodeName] then
                    local nodeType = getmetatable(nodeData)

                    if nodeType == LSCS_BUFFNODE then
                        nodeData.ActionFunction(ply)
                    end

                    if nodeType == LSCS_STANCE then
                        ply:lscsAddInventory(nodeData.Entity, true)
                    end

                    if nodeType == LSCS_SKILL then
                        ply:lscsAddInventory(nodeData.Entity, true)
                    end
                end
            end
        end

        if skillSystem.CurrEquipped.RH.Crystal ~= nil or skillSystem.CurrEquipped.RH.Hilt ~= nil then
            ply:lscsAddInventory(skillSystem.CurrEquipped.RH.Crystal, true)
            ply:lscsAddInventory(skillSystem.CurrEquipped.RH.Hilt, true)
        end

        if skillSystem.CurrEquipped.LH.Crystal ~= nil or skillSystem.CurrEquipped.LH.Hilt ~= nil then
            ply:lscsAddInventory(skillSystem.CurrEquipped.LH.Crystal, false)
            ply:lscsAddInventory(skillSystem.CurrEquipped.LH.Hilt, false)
        end

        timer.Simple(1, function()
            ply:lscsCraftSaber()        
        end)

    end)
end)

net.Receive("LSCS_AddToInventory", function(len, ply)
    local SteamID64 = net.ReadString()
    local ent = net.ReadString()
    local player = player.GetBySteamID64(SteamID64)

    if not player then print("noplayerfound") return end
    if not player.SkillSystem then print("noplayerskillsystemfound") return end

    table.insert(player.SkillSystem.Inventory, ent)
    player.SkillSystem:SavePlayerData()
    player.SkillSystem:LoadPlayerData(player)
end)

net.Receive("LSCS_RemoveInventoryItem", function(len, ply)
    local SteamID64 = net.ReadString()
    local ent = net.ReadString()
    local player = player.GetBySteamID64(SteamID64)

    if not player then print("LSCS Ssys | No Player Found") return end
    if not player.SkillSystem then print("noplayerskillsystemfound") return end

    table.RemoveByValue(player.SkillSystem.Inventory, ent)
    player.SkillSystem:SavePlayerData()
    player.SkillSystem:LoadPlayerData(player)
end)

net.Receive("LSCS_RequestPlayerDataForAdminMenu", function(len, ply)
    local SteamID64 = net.ReadString()
    local player = player.GetBySteamID64(SteamID64)

    if not player then print("noplayerfound") return end
    if not player.SkillSystem then print("noplayerskillsystemfound") return end
    
    net.Start("LSCS_SendPlayerDataForAdminMenu")
        net.WriteTable(player.SkillSystem)
    net.Send(ply)
end)

net.Receive("LSCS_AdminMenuSubmitPlayerData", function(len, ply)
    local pSteamID64 = net.ReadString()
    local playerTable = net.ReadTable()
    local player = player.GetBySteamID64(pSteamID64)

    if not player then return end
    if not player.SkillSystem then return end

    for k, v in pairs(playerTable) do
        player.SkillSystem[k] = v
    end

    player.SkillSystem:SavePlayerData()
    player.SkillSystem:LoadPlayerData(player)
end)

net.Receive("LSCS_RequestSkillDataFromServer", function(len, ply)
    local skillData = ply.SkillSystem or {}

    net.Start("LSCS_SendSkillDataToClient")
        net.WriteTable(skillData)
    net.Send(ply)
end)

local function RemoveFunctionsFromTable(tbl) -- get rid of functions 
    local copy = {}

    for k, v in pairs(tbl) do
        if type(v) ~= "function" then
            if type(v) == "table" then
                copy[k] = RemoveFunctionsFromTable(v)
            else
                copy[k] = v
            end
        end
    end

    return copy
end

net.Receive("LSCS_RequestTreeDataFromServer", function(len, ply)
    local treeRequested = net.ReadString()
    local treeData = LSCS_SKILLSYSTEM.SkillTrees[treeRequested]

    if treeData then
        local sanitizedData = RemoveFunctionsFromTable(treeData)

        net.Start("LSCS_SendTreeDataToClient")
            net.WriteTable(sanitizedData)
        net.Send(ply)
    end
end)

net.Receive("LSCS_RequestAllSkillTreeNamesFromServer", function(len,ply)
    local skillKeys = table.GetKeys(LSCS_SKILLSYSTEM.SkillTrees)
    if not skillKeys then return end

    for i = #skillKeys, 1, -1 do
        local treeName = skillKeys[i]
    
        if not LSCS_SKILLSYSTEM.SkillTrees[treeName].JobAccess[ply:Team()] or table.IsEmpty(LSCS_SKILLSYSTEM.SkillTrees[treeName].JobAccess) then
            table.remove(skillKeys, i)
        end
    end
    
    net.Start("LSCS_SendAllSkillTreeNamesToClient")
        net.WriteTable(skillKeys)
    net.Send(ply)
end)

net.Receive("LSCS_UnlockNodeFromSkillMenu", function(len,ply)
    local currTree = net.ReadString()
    local nodeToUnlock = net.ReadString()
    local skillPointsToDeduct = net.ReadUInt(SKILLPOINT_BIT_COUNT)

    ply.SkillSystem.Nodes[currTree] = ply.SkillSystem.Nodes[currTree] or {}

    ply.SkillSystem.Nodes[currTree][nodeToUnlock] = true
    ply.SkillSystem.SkillPoints = ply.SkillSystem.SkillPoints - skillPointsToDeduct
    ply.SkillSystem:SavePlayerData()
    ply.SkillSystem:LoadPlayerData(ply)
end)