local masteryTree = LSCS_SKILLTREE:New("Arcane Dominion Tree")

local emberBlast = LSCS_SKILL:New("Ember Blast", "Launch a fiery explosion at your enemies.", 10, "materials/lscs_skill_station/icon_defaultpower.png", "entity_fireball")
local glacialBarrier = LSCS_SKILL:New("Glacial Barrier", "Erect a barrier of frost for defense.", 15, "materials/lscs_skill_station/icon_defaultpower.png", "entity_frost_shield")
local thunderClap = LSCS_SKILL:New("Thunder Clap", "Unleash a powerful lightning strike on your foes.", 20, "materials/lscs_skill_station/icon_defaultpower.png", "entity_lightning_strike")
local tectonicRumble = LSCS_SKILL:New("Tectonic Rumble", "Cause the ground to tremble, disorienting enemies.", 25, "materials/lscs_skill_station/icon_defaultpower.png", "entity_earthquake")

local infernoBlade = LSCS_STANCE:New("Inferno Blade", "A blazing and aggressive combat style.", 30, "materials/lscs_skill_station/icon_defaultstance.png", "entity_flame_dancer")
local iceSentinel = LSCS_STANCE:New("Ice Sentinel", "A steadfast and defensive fighting stance.", 30, "materials/lscs_skill_station/icon_defaultstance.png", "entity_frost_guardian")
local tempestRider = LSCS_STANCE:New("Tempest Rider", "An agile stance emphasizing speed and precision.", 30, "materials/lscs_skill_station/icon_defaultstance.png", "entity_storm_caller")
local mountainBastion = LSCS_STANCE:New("Mountain Bastion", "An unyielding and powerful combat form.", 40, "materials/lscs_skill_station/icon_defaultstance.png", "entity_earth_warden")

local hp = LSCS_BUFFNODE:New("HP 1", "HP", 1, "materials/lscs_skill_station/icon_defaultstance.png", function(ply)
    ply:SetMaxHealth(ply:GetMaxHealth() + 250)
    ply:SetHealth(ply:GetMaxHealth())
end)

local speed = LSCS_BUFFNODE:New("Speed 1", "HP", 1, "materials/lscs_skill_station/icon_defaultstance.png", function(ply)
    ply:SetRunSpeed(ply:GetRunSpeed() + 500)
end)

glacialBarrier:AddPrerequisite("Ember Blast")
thunderClap:AddPrerequisite("Ember Blast")
tectonicRumble:AddPrerequisite("Thunder Clap")
infernoBlade:AddPrerequisite("Tectonic Rumble")
iceSentinel:AddPrerequisite("Tectonic Rumble")
tempestRider:AddPrerequisite("Tectonic Rumble")
mountainBastion:AddPrerequisite("Tempest Rider")
hp:AddPrerequisite("Mountain Bastion")
speed:AddPrerequisite("HP 1")

masteryTree:AddRoot(emberBlast)
masteryTree:AddNode(glacialBarrier)
masteryTree:AddNode(thunderClap)
masteryTree:AddNode(tectonicRumble)
masteryTree:AddNode(infernoBlade)
masteryTree:AddNode(iceSentinel)
masteryTree:AddNode(tempestRider)
masteryTree:AddNode(mountainBastion)
masteryTree:AddNode(hp)
masteryTree:AddNode(speed)

masteryTree.JobAccess = {
    [TEAM_JEDIKNIGHT] = true,
    [TEAM_CITIZEN] = true
}

return masteryTree
