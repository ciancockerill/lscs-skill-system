include("server/sv_skill_data.lua")

hook.Add("PlayerInitialSpawn", "InitSkillSystem", function(ply)
    timer.Simple(0.5, function() -- Error w/ P2P servers, loading in too quick before table inits
        local skillSystem = LSCS_SKILLSYSTEM:New(ply)
        PrintTable(LSCS_SKILLSYSTEM)
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

function LSCS_SKILLSYSTEM:GetXPToNextLevel(level)
    return math.floor(self.BASE_XP * (level ^ self.XP_MULT))
end

function LSCS_SKILLSYSTEM:LevelUp()
    while(true) do
        if self.Level >= LSCS_SKILLSYSTEM.MAX_LEVEL then return end

        local currLvl = self.Level
        local xpToNextLevel = self:GetXPToNextLevel(currLvl + 1)
        local xpDifference = self.XP - xpToNextLevel
        
        if (xpDifference < 0) then
            break
        end

        self.XP = xpDifference
        self.Level = self.Level + 1
        self.SkillPoints = self.SkillPoints + 1
        print(self.Player:Nick().." Levelled up to Level ".. self.Level)
    end
end

function LSCS_SKILLSYSTEM:GetPlayerData()
    return {
        self.Level or 1,
        self.XP or 0,
        self.Stances or {},
        self.Skills or {},
        self.SkillPoints or 0
    }
end