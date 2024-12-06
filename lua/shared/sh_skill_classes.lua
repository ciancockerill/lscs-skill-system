LSCS_SKILLSYSTEM = {}
LSCS_SKILLSYSTEM.__index = LSCS_SKILLSYSTEM

LSCS_SKILLSYSTEM.MAX_LEVEL = 100
LSCS_SKILLSYSTEM.BASE_XP = 100
LSCS_SKILLSYSTEM.XP_MULT = 1.1

LSCS_SKILLSYSTEM.PLAYERKILL_XP = 25
LSCS_SKILLSYSTEM.NPCKILL_XP = 5

function LSCS_SKILLSYSTEM:New(ply)
    local obj = {
        Player = ply,
        XP = 0,
        Level = 1,
        SkillsPoints = 0,
        Skills = {},
        Stances = {}
    }
    setmetatable(obj, LSCS_SKILLSYSTEM)
    return obj
end

LSCS_SKILL = {}
LSCS_SKILL.__index = LSCS_SKILL

function LSCS_SKILL:New(name, description, cost, lscs_skillentity)
    local obj = {
        Name = name,
        Description = description,
        Cost = cost,
        LSCS_SkillEntity = lscs_skillentity
    }
    setmetatable(obj, LSCS_SKILL)
    return obj
end 

LSCS_STANCE = {}
LSCS_STANCE.__index = LSCS_STANCE

function LSCS_STANCE:New(name, description, cost, lscs_stanceentity)
    local obj = {
        Name = name,
        Description = description,
        Cost = cost,
        LSCS_StanceEntity = lscs_stanceentity
    }
    setmetatable(obj, LSCS_STANCE)
    return obj
end 


