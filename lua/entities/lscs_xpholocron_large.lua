AddCSLuaFile()

ENT.Base = "lscs_dg_holocronbase"
DEFINE_BASECLASS("lscs_dg_holocronbase")

ENT.PrintName = "[Large] XP Holocron"
ENT.Author = "Your Name"
ENT.Category = "[DG] LSCS"
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.Editable = true

ENT.XPValue = 150

ENT.GlowColor = Color(30, 0, 255, 255)

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
