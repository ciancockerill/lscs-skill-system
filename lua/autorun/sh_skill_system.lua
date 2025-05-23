include("shared/sh_skill_classes.lua")

if SERVER then
    AddCSLuaFile("client/cl_skill_networking.lua")
    AddCSLuaFile("client/cl_skill_ui.lua")
    AddCSLuaFile("client/cl_lscs_adminmenu.lua")
    AddCSLuaFile("client/cl_sabercrafting_ui.lua")
    AddCSLuaFile("shared/sh_skill_classes.lua")

    include("lscs_skillsystem_config.lua")
    include("server/sv_skill_data.lua")
    include("server/sv_skill_system.lua")
    include("server/sv_skill_networking.lua")
else
    include("client/cl_skill_networking.lua")
    include("client/cl_skill_ui.lua")
    include("client/cl_lscs_adminmenu.lua")
    include("client/cl_sabercrafting_ui.lua")

end

if CLIENT then -- Font init
    for i = 1, 100 do
        surface.CreateFont("sgb"..i, {
            font = "Space Grotesk Bold",
            size = i,
        })
        surface.CreateFont("sgr"..i, {
            font = "Space Grotesk Light",
            size = i,
        })
        surface.CreateFont("sgl"..i, {
            font = "Space Grotesk Regular",
            size = i,
        })
    end   
end 

SKILLPOINT_BIT_COUNT = 8 -- 255
LEVEL_BIT_COUNT = 7 -- 127
COOLDOWN_BIT_COUNT = 4 -- 15

