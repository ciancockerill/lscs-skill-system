SAVEDATA_DIR = "lscs-playerdata"

hook.Add("InitPostEntity", "CheckDirExists", function()
    if not file.IsDir(SAVEDATA_DIR, "DATA") then
        file.CreateDir(SAVEDATA_DIR)
    end
end)

hook.Add("PlayerDisconnected", "SaveSkillDataOnPLeave", function(ply)
    ply.SkillSystem:SavePlayerData()
    ply.SkillSystem = nil
end)

function LSCS_SKILLSYSTEM:SavePlayerData()
    local fileName = SAVEDATA_DIR.."/"..self.Player:SteamID64()..".json"

    local data = {
        Level = self.Level,
        XP = self.XP,
        SkillPoints = self.SkillPoints,
        Skills = self.Skills,
        Stances = self.Stances
    }

    file.Write(fileName, util.TableToJSON(data))
    print(fileName)
    print("Saved Data: ".. self.Player:Nick())
end

function LSCS_SKILLSYSTEM:LoadPlayerData(ply)
    local fileName = SAVEDATA_DIR .. "/" .. ply:SteamID64() .. ".json"
    local skillSystem = LSCS_SKILLSYSTEM:New(ply)

    if file.Exists(fileName, "DATA") then
        local data = util.JSONToTable(file.Read(fileName, "DATA"))
        
        skillSystem.Level = data.Level or 1
        skillSystem.XP = data.XP or 0
        skillSystem.SkillPoints = data.SkillPoints or 0
        skillSystem.Skills = data.Skills or {}
        skillSystem.Stances = data.Stances or {}
        
        ply.SkillSystem = skillSystem
        print("Loaded Data: ".. ply:Nick())
        PrintTable(ply.SkillSystem)
    else
        ply.SkillSystem = skillSystem
        skillSystem:SavePlayerData()
    end
end