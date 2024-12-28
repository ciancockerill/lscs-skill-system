include("shared/sh_skill_classes.lua")

if SERVER then
    AddCSLuaFile("client/cl_skill_networking.lua")
    AddCSLuaFile("client/cl_skill_ui.lua")
    AddCSLuaFile("shared/sh_skill_classes.lua")

    include("server/sv_skill_data.lua")
    include("server/sv_skill_system.lua")
    include("server/sv_skill_networking.lua")
else
    include("client/cl_skill_networking.lua")
    include("client/cl_skill_ui.lua")
end

if CLIENT then -- Font init
    for i = 1, 100 do
        surface.CreateFont("sgb"..i, {
            font = "Space Grotesk Bold",
            size = i,
        })
        surface.CreateFont("sgl"..i, {
            font = "Space Grotesk Light",
            size = i,
        })
        surface.CreateFont("sgr"..i, {
            font = "Space Grotesk Regular",
            size = i,
        })
    end   
end 

