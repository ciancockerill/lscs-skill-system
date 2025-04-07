AddCSLuaFile("entities/lscs_saber_crafting/shared.lua")
AddCSLuaFile("entities/lscs_saber_crafting/cl_init.lua")
include("entities/lscs_saber_crafting/shared.lua")

util.AddNetworkString("LSCS_SABERSTATION_OpenUI")

function ENT:Initialize()
    self:SetModel("models/lscs/holocron.mdl")
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
        net.Start("LSCS_SABERSTATION_OpenUI")
        net.Send(caller)
    end
end


