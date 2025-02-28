include("server/sv_skill_data.lua")

hook.Add("PlayerInitialSpawn", "InitSkillSystem", function(ply)
    timer.Simple(0.5, function() -- Error w/ P2P servers, loading in too quick before table inits
        local skillSystem = LSCS_SKILLSYSTEM:New(ply)
        skillSystem:LoadPlayerData(ply)
    end)
end)

concommand.Add( "lscs_saveyourdata", function( ply, cmd, args )
    ply.SkillSystem:SavePlayerData()
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
            net.WriteUInt(currLvl, LEVEL_BIT_COUNT) -- Level
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
    if (attacker:IsPlayer()) then
        attacker.SkillSystem:AddXP(100)
    end
end)

hook.Add( "PlayerDeath", "LSCS_GivePlayerXPonPlayerKill", function( victim, inflictor, attacker )
    if (attacker:IsPlayer() and victim != attacker) then
        attacker.SkillSystem:AddXP(100)
    end
end )

hook.Add("PlayerSpawn", "LSCS_ApplyOwnedNodes", function(ply)
    timer.Simple(0, function() -- 0 second timer needed to avoid overwriting
        local skillSystem = ply.SkillSystem
        if not skillSystem then return end

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
    end)
end)


