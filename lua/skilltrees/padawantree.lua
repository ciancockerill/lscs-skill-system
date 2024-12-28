local skillTree = LSCS_SKILLTREE:New("Elemental Mastery Tree")

local fireball = LSCS_SKILL:New("Fireball", "Hurl a ball of fire at your enemies.", 10, "materials/lscs_skill_station/icon_defaultpower.png", "entity_fireball")
local frostShield = LSCS_SKILL:New("Frost Shield", "Create a shield of ice for protection.", 15, "materials/lscs_skill_station/icon_defaultpower.png", "entity_frost_shield")
local lightningStrike = LSCS_SKILL:New("Lightning Strike", "Summon a bolt of lightning to strike your target.", 20, "materials/lscs_skill_station/icon_defaultpower.png", "entity_lightning_strike")
local earthQuake = LSCS_SKILL:New("Earthquake", "Shake the ground to damage and disrupt foes.", 25, "materials/lscs_skill_station/icon_defaultpower.png", "entity_earthquake")

local flameDancer = LSCS_STANCE:New("Flame Dancer", "A fiery and aggressive combat style.", 30, "materials/lscs_skill_station/icon_defaultstance.png", "entity_flame_dancer")
local frostGuardian = LSCS_STANCE:New("Frost Guardian", "A defensive and sturdy fighting stance.", 30, "materials/lscs_skill_station/icon_defaultstance.png", "entity_frost_guardian")
local stormCaller = LSCS_STANCE:New("Storm Caller", "A dynamic stance focusing on speed and precision.", 30, "materials/lscs_skill_station/icon_defaultstance.png", "entity_storm_caller")
local earthWarden = LSCS_STANCE:New("Earth Warden", "A resilient and overpowering form.", 40, "materials/lscs_skill_station/icon_defaultstance.png", "entity_earth_warden")

frostShield:AddPrerequisite("Fireball")
lightningStrike:AddPrerequisite("Fireball")
earthQuake:AddPrerequisite("Lightning Strike")
flameDancer:AddPrerequisite("Earthquake")
frostGuardian:AddPrerequisite("Earthquake")
stormCaller:AddPrerequisite("Earthquake")
earthWarden:AddPrerequisite("Storm Caller")

skillTree:AddNode(fireball)
skillTree:AddNode(frostShield)
skillTree:AddNode(lightningStrike)
skillTree:AddNode(earthQuake)
skillTree:AddNode(flameDancer)
skillTree:AddNode(frostGuardian)
skillTree:AddNode(stormCaller)
skillTree:AddNode(earthWarden)

return skillTree
