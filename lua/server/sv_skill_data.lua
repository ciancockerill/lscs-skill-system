local SAVEDATA_DIR = "lscs-playerdata"

LSCS_SKILLSYSTEM.SkillTrees = {}

hook.Add("InitPostEntity", "CheckDirExists", function()
    if not file.IsDir(SAVEDATA_DIR, "DATA") then
        file.CreateDir(SAVEDATA_DIR)
    end
    LSCS_SKILLTREE.LoadSkillTreesFromFile()
end)

hook.Add("PlayerDisconnected", "SaveSkillDataOnPLeave", function(ply)
    ply.SkillSystem:SavePlayerData()
    ply.SkillSystem = nil
end)

function LSCS_SKILLSYSTEM:SavePlayerData()
    local fileName = SAVEDATA_DIR.."/"..self.Player:SteamID64()..".json"

    local data = {
        Level = self.Level or 1,
        XP = self.XP or 0,
        SkillPoints = self.SkillPoints or 0,
        Nodes = self.Nodes or {}
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
        
        skillSystem.Level = data.Level 
        skillSystem.XP = data.XP
        skillSystem.SkillPoints = data.SkillPoints
        skillSystem.Nodes = data.Nodes
        
        ply.SkillSystem = skillSystem
        print("Loaded Data: ".. ply:Nick())
        PrintTable(ply.SkillSystem)
    else
        ply.SkillSystem = skillSystem
        skillSystem:SavePlayerData()
    end
end

LSCS_SKILLTREE.LoadSkillTreesFromFile = function()
    local skillTreeFolder = "skilltrees/"
    local skillTreeFiles = file.Find(skillTreeFolder.."/*.lua", "LUA")

    local skillTrees = {}

    for _, fileName in ipairs(skillTreeFiles) do
        local skillTree = include(skillTreeFolder.."/"..fileName)

        if skillTree then
            LSCS_SKILLSYSTEM.SkillTrees[skillTree.Name] = skillTree
        else 
            print("Failed to Load")
        end
    end
    PrintTable(LSCS_SKILLSYSTEM.SkillTrees)
end