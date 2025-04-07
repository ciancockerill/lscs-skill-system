AddCSLuaFile()

ENT.Base = "lscs_dg_holocronbase"
DEFINE_BASECLASS("lscs_dg_holocronbase")

ENT.PrintName = "[Small] XP Holocron"
ENT.Author = "Your Name"
ENT.Category = "[DG] LSCS"
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.Editable = true

ENT.XPValue = 10

ENT.GlowColor = Color(0, 195, 255, 255)

function ENT:Use(ply)
    if SERVER then
        local skillsystem = ply.SkillSystem
        if skillsystem then
            skillsystem.XP = skillsystem.XP + self.XPValue
            skillsystem:LevelUp()
            skillsystem:SavePlayerData()
            self:Remove()
        end
    end
end
