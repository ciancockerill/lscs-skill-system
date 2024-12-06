include("shared/sh_skill_classes.lua")

if SERVER then
    AddCSLuaFile("client/cl_skill_ui.lua")
    AddCSLuaFile("shared/sh_skill_classes.lua")

    include("server/sv_skill_data.lua")
    include("server/sv_skill_system.lua")
    include("server/sv_skill_networking.lua")
else
    include("client/cl_skill_ui.lua")
    include("client/cl_skill_networking.lua")
end

