include("server/sv_skill_data.lua")
include("lscs_skillsystem_config.lua")

hook.Add("PlayerSpawn", "InitSkillSystem", function(ply)
    timer.Simple(0.5, function() -- Error w/ P2P servers, loading in too quick before table inits
        if (LSCS_SS_CONFIG.ForceUserJobs[ply:getDarkRPVar("job")]) then
            local skillSystem = LSCS_SKILLSYSTEM:New(ply)
            skillSystem:LoadPlayerData(ply)

            hook.Run("LSCS_SS_SkillSystemLoadedOnPlayer", ply)
        end

        if ply.SkillSystem and not LSCS_SS_CONFIG.ForceUserJobs[ply:getDarkRPVar("job")] then
            ply.SkillSystem = nil
            ply:lscsWipeInventory()
        end
    end)
end)

concommand.Add( "lscs_saveyourdata", function( ply, cmd, args )
    ply.SkillSystem:SavePlayerData()
end )

concommand.Add( "lscs_additemtoinventory", function( ply, cmd, args )
    ply.SkillSystem.Inventory[args[1] or arg] = true
end )

concommand.Add( "lscs_loadyourdata", function( ply, cmd, args )
    ply.SkillSystem:LoadPlayerData(ply)
end )

concommand.Add("lscs_printPData", function(ply, cmd, args)
    PrintTable(ply.SkillSystem)
end)

concommand.Add("lscs_levelmeup", function(ply, cmd, args)
    ply.SkillSystem:LevelUp()
end)

concommand.Add("lscs_loadtrees", function(ply,cmd,args)
    LSCS_SKILLTREE.LoadSkillTreesFromFile()
end)

concommand.Add("lscs_openadminmenu", function(ply, cmd, args)
    if !(LSCS_SS_CONFIG.AdminMenu.AllowedUserGroups[ply:GetUserGroup()] or LSCS_SS_CONFIG.AdminMenu.AllowedDarkRPJobs[ply:getDarkRPVar("job")]) then 
        print(ply:Nick().." tried to access LSCS admin menu")
        return 
    end

    net.Start("LSCS_OpenAdminMenuOnClient")
    net.Send(ply)
end)

function LSCS_SKILLSYSTEM:LevelUp()
    if self.Level >= LSCS_SKILLSYSTEM.MAX_LEVEL then return end

    while(true) do
        local currLvl = self.Level
        local xpToNextLevel = self:GetXPToNextLevel(currLvl + 1)
        local xpDifference = self.XP - xpToNextLevel
        
        if (xpDifference < 0) then
            break
        end

        self.XP = xpDifference
        self.Level = self.Level + 1
        self.SkillPoints = self.SkillPoints + 1

        net.Start("LSCS_SendLevelUpNotificationToClient")
            net.WriteUInt(self.Level, LEVEL_BIT_COUNT) -- Level
            net.WriteUInt(8, COOLDOWN_BIT_COUNT) -- Time for noti
        net.Send(self.Player)
    end
end

function LSCS_SKILLSYSTEM:AddXP(xp)
    if self == nil then return end

    self.XP = self.XP + xp
    self:LevelUp()
    self:SavePlayerData()
end

hook.Add( "OnNPCKilled", "LSCS_GivePlayerXPonNPCKill", function(npc, attacker,inflictor )
    if not attacker.SkillSystem then return end

    if (attacker:IsPlayer()) then
        attacker.SkillSystem:AddXP(LSCS_SS_CONFIG.NPCXP)
    end
end)

hook.Add( "PlayerDeath", "LSCS_GivePlayerXPonPlayerKill", function( victim, inflictor, attacker )
    if not attacker.SkillSystem then return end

    if (attacker:IsPlayer() and victim != attacker) then
        attacker.SkillSystem:AddXP(LSCS_SS_CONFIG.PlayerXP)
    end
end )

hook.Add("LSCS_SS_SkillSystemLoadedOnPlayer", "LSCS_ApplyOwnedNodes", function(ply)
    timer.Simple(0, function()
        local skillSystem = ply.SkillSystem
        if not skillSystem then return end

        ply:lscsWipeInventory() -- Wipe to give new items, will have to change for inventory potentially.
        ply:Give("weapon_lscs")
        print("--------------------------------------------------ran????????????")
        for tree, nodes in pairs(skillSystem.Nodes) do
            local skillTree = LSCS_SKILLSYSTEM.SkillTrees[tree]
            if not skillTree then continue end
            if not skillTree.JobAccess[ply:Team()] then continue end

            local treeNodes = skillTree.Nodes
            if not treeNodes then continue end

            for nodeName, nodeData in pairs(treeNodes) do
                if nodes[nodeName] then
                    local nodeType = getmetatable(nodeData)

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


hook.Add( "LSCS:OnPlayerDroppedItem", "LSCS_DisableItemDrop", function( ply, item_entity, inventory_id, classname )
    return false
end )

hook.Add( "LSCS:PlayerInventory", "LSCS_DisableItemPickup", function( ply, classname, index )
    if not ply:IsSuperAdmin() then
        return true
    end
end )
