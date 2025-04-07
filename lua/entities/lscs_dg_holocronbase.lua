AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "[Base] Holocron"
ENT.Author = "Your Name"
ENT.Category = "[DG] LSCS"

ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/lscs/holocron.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE) 
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if phys and phys:IsValid() then
            phys:Wake()
            phys:EnableMotion(false)
        end

        self:PlayAnimation("idle_open")
        self.StartPos = self:GetPos()
    end
end

function ENT:PlayAnimation(animation, playbackrate)
    playbackrate = playbackrate or 1
    local sequence = self:LookupSequence(animation)
    self:ResetSequence(sequence)
    self:SetPlaybackRate(playbackrate)
    self:SetSequence(sequence)
end

function ENT:Think()
    if SERVER then
        -- Floating effect.
        local floatHeight = 20
        local floatAmplitude = 5
        local newZ = self.StartPos.z + floatHeight + math.sin(CurTime() * 2) * floatAmplitude
        self:SetPos(Vector(self.StartPos.x, self.StartPos.y, newZ))
        
        -- Spinning effect.
        local ang = self:GetAngles()
        ang.y = ang.y + 1
        self:SetAngles(ang)
        
        self:NextThink(CurTime())
        return true
    end
end

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end

    local spawnPos = tr.HitPos + tr.HitNormal * 16
    local ent = ents.Create(ClassName)
    ent:SetPos(spawnPos)
    ent:Spawn()
    ent:Activate()

    local allowed = false
    if LSCS_SS_CONFIG and LSCS_SS_CONFIG.AdminMenu then
        if LSCS_SS_CONFIG.AdminMenu.AllowedUserGroups[ply:GetUserGroup()] or LSCS_SS_CONFIG.UsergroupCanSpawnHolocron[ply:GetUserGroup()] then
            allowed = true
        end
        if ply.getDarkRPVar then
            local job = ply:getDarkRPVar("job")
            if LSCS_SS_CONFIG.AdminMenu.AllowedDarkRPJobs[job] then
                allowed = true
            end
        end
    end

    if not allowed then
        ply:ChatPrint("You are not allowed to spawn this entity!")
        ent:Remove()
        return nil
    end

    return ent
end

function ENT:Use(ply)
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        local glowMat = Material("sprites/glow04_noz")
        local pos = self:GetPos()
        render.SetMaterial(glowMat)
        render.DrawSprite(pos, 64, 64, self.GlowColor or Color(0, 150, 255, 200))
    end
end
