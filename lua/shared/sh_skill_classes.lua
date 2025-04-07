LSCS_SKILLSYSTEM = {}
LSCS_SKILLSYSTEM.__index = LSCS_SKILLSYSTEM

LSCS_SKILLSYSTEM.MAX_LEVEL = 100
LSCS_SKILLSYSTEM.NODE_XP = 100
LSCS_SKILLSYSTEM.XP_MULT = 1.1

LSCS_SKILLSYSTEM.PLAYERKILL_XP = 25
LSCS_SKILLSYSTEM.NPCKILL_XP = 5

function LSCS_SKILLSYSTEM:New(ply)
    local obj = {
        Player = ply,
        XP = 0,
        Level = 1,
        SkillPoints = 0,
        Nodes = {},
        Inventory = {},
        CurrEquipped = {
            ["RH"] = {
                ["Crystal"] = nil,
                ["Hilt"] = nil
            },
            ["LH"] = {
                ["Crystal"] = nil,
                ["Hilt"] = nil
            }
        }
    }
    setmetatable(obj, LSCS_SKILLSYSTEM)
    return obj
end

function LSCS_SKILLSYSTEM:GetXPToNextLevel(level)
    return math.floor(self.NODE_XP * (level ^ self.XP_MULT))
end

function LSCS_IsPlayerJobAllowed(ply, jobTable)
    if not ply or not IsValid(ply) then return false end

    local job = ply:getDarkRPVar("job")
    return jobTable[job]
end

LSCS_SABERITEM = {}
LSCS_SABERITEM.__index = LSCS_SABERITEM

function LSCS_SABERITEM:New(entity)
    local obj = {
        Name = entity.PrintName,
        Entity = entity
    }
    setmetatable(obj, LSCS_SABERITEM)
    return obj
end

LSCS_HILT = setmetatable({}, { __index = LSCS_SABERITEM })
LSCS_HILT.__index = LSCS_HILT

function LSCS_HILT:New(entity)
    local obj = LSCS_SABERITEM:New(entity)

    setmetatable(obj, LSCS_HILT)
    return obj
end

LSCS_CRYSTAL = setmetatable({}, { __index = LSCS_SABERITEM })
LSCS_CRYSTAL.__index = LSCS_CRYSTAL

function LSCS_CRYSTAL:New(entity)
    local obj = LSCS_SABERITEM:New(entity)

    setmetatable(obj, LSCS_CRYSTAL)
    return obj
end

LSCS_NODE = {}
LSCS_NODE.__index = LSCS_NODE

function LSCS_NODE:New(name, description, cost, icon, entity)
    local obj = {
        Name = name,
        Description = description,
        Cost = cost,
        Icon = icon,
        Entity = entity,
        Prerequisites = {},
        Children = {}
    }
    
    setmetatable(obj, LSCS_NODE)
    return obj
end

function LSCS_NODE:AddPrerequisite(prerequisite)
    table.insert(self.Prerequisites, prerequisite)
end

LSCS_SKILL = setmetatable({}, { __index = LSCS_NODE })
LSCS_SKILL.__index = LSCS_SKILL

function LSCS_SKILL:New(name, description, cost, icon, lscs_skillentity)
    local obj = LSCS_NODE:New(name, description, cost, icon, lscs_skillentity)
    setmetatable(obj, LSCS_SKILL)
    return obj
end

LSCS_STANCE = setmetatable({}, { __index = LSCS_NODE })
LSCS_STANCE.__index = LSCS_STANCE

function LSCS_STANCE:New(name, description, cost, icon, lscs_stanceentity)
    local obj = LSCS_NODE:New(name, description, cost, icon, lscs_stanceentity)
    setmetatable(obj, LSCS_STANCE)
    return obj
end

LSCS_BUFFNODE = setmetatable({}, { __index = LSCS_NODE })
LSCS_BUFFNODE.__index = LSCS_BUFFNODE

function LSCS_BUFFNODE:New(name, description, cost, icon, actionFunction)
    local obj = LSCS_NODE:New(name, description, cost, icon, nil)
    obj.ActionFunction = actionFunction 
    setmetatable(obj, LSCS_BUFFNODE)
    return obj
end

LSCS_PERMISSIONNODE = setmetatable({}, { __index = LSCS_NODE })
LSCS_PERMISSIONNODE.__index = LSCS_PERMISSIONNODE

function LSCS_PERMISSIONNODE:New(name, description, cost, icon)
    local obj = LSCS_NODE:New(name, description, cost, icon, nil)
    setmetatable(obj, LSCS_PERMISSIONNODE)
    return obj
end


LSCS_SKILLTREE = {}
LSCS_SKILLTREE.__index = LSCS_SKILLTREE

function LSCS_SKILLTREE:New(name)
    local obj = {
        Name = name,
        Roots = {},
        Nodes = {},
        JobAccess = {}
    }
    setmetatable(obj, LSCS_SKILLTREE)
    return obj
end

function LSCS_SKILLTREE:AddNode(node)
    self.Nodes[node.Name] = node
end

function LSCS_SKILLTREE:AddRoot(node)
    table.insert(self.Roots, node)
    self.Nodes[node.Name] = node
end

function LSCS_SKILLSYSTEM:GetCrystalDataFromClass(classname)
    local name = string.match(classname, "^item_crystal_(.+)$")

    return name, LSCS.Blade[name]
end

function LSCS_SKILLSYSTEM:GetHiltDataFromClass(classname)
    local name = string.match(classname, "^item_saberhilt_(.+)$")

    return name, LSCS.Hilt[name]
end