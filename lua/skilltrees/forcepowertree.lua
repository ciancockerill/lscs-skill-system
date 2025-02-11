local masteryTree = LSCS_SKILLTREE:New("Force Mastery Tree")

local forceJump = LSCS_SKILL:New("Force Jump", "Leap great distances with the power of the Force.", 10, "materials/lscs_skill_station/icon_defaultpower.png", "item_force_jump")
local forceThrow = LSCS_SKILL:New("Force Throw", "Hurl objects with telekinetic precision.", 15, "materials/lscs_skill_station/icon_defaultpower.png", "item_force_throw")
local forceTeleport = LSCS_SKILL:New("Force Teleport", "Instantly move a short distance.", 20, "materials/lscs_skill_station/icon_defaultpower.png", "item_force_teleport")

forceThrow:AddPrerequisite("Force Jump")
forceTeleport:AddPrerequisite("Force Throw")

masteryTree:AddRoot(forceJump)
masteryTree:AddNode(forceThrow)
masteryTree:AddNode(forceTeleport)

masteryTree.JobAccess = {
    [TEAM_JEDIKNIGHT] = true,
    [TEAM_CITIZEN] = true
}

return masteryTree
