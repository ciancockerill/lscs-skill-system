include("entities/lscs_skill_station/shared.lua")
include("client/cl_skill_ui.lua")

net.Receive("LSCS_SKILLSTATION_OpenUI", function(len, ply)
    LSCS_SKILLSTATION:CreatePanel()
end)

function ENT:Draw()
    self:DrawModel() 
end


