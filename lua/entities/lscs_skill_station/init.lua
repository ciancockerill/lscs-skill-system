AddCSLuaFile("entities/lscs_skill_station/shared.lua")
AddCSLuaFile("entities/lscs_skill_station/cl_init.lua")
include("entities/lscs_skill_station/shared.lua")

util.AddNetworkString("LSCS_SKILLSTATION_OpenUI")

function ENT:Initialize()
    self:SetModel("models/props_c17/Lockers001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()                        
    end
end

function ENT:Use(activator, caller)
    if IsValid(caller) and caller:IsPlayer() then
        net.Start("LSCS_SKILLSTATION_OpenUI")
        net.Send(caller)
    end
end
