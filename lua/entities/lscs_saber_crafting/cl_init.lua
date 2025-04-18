include("entities/lscs_saber_crafting/shared.lua")
include("client/cl_sabercrafting_ui.lua")

net.Receive("LSCS_SABERSTATION_OpenUI", function(len, ply)
    LSCS_SABERSTATION:CreatePanel()
end)

function ENT:Draw()
    self:DrawModel()

    local min, max = self:GetModelBounds()
    local height = max.z - min.z
    local pos = self:GetPos() + Vector(0, 0, height)
    local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleTextOutlined(
            "Lightsaber Crafting", "sgb50", 
            0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
            2, Color(0, 0, 0, 255)
        )
    cam.End3D2D()
end


