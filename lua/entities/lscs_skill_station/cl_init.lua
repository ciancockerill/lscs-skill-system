include("entities/lscs_skill_station/shared.lua")
include("client/cl_skill_ui.lua")

net.Receive("LSCS_SKILLSTATION_OpenUI", function(len, ply)
    LSCS_SKILLSYSTEM:getDataOnClient()
    LSCS_SKILLSYSTEM:GetAllSkillTreeNames()
    
    timer.Simple(0.05, function() -- Makes sure panel opens with right info, finicky workaround
        LSCS_SKILLSTATION:CreatePanel()
    end)
end)

function ENT:Draw()
    self:DrawModel() 
end


