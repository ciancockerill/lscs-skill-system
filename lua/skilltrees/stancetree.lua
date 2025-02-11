local stanceTree = LSCS_SKILLTREE:New("Lightsaber Stance Tree")

-- Define stances
local stanceEmbestida = LSCS_STANCE:New("Embestida Stance", "A strong, aggressive lightsaber stance.", 10, "materials/lscs_skill_station/icon_defaultpower.png", "item_stance_embestida")
local stanceAtaru = LSCS_STANCE:New("Ataru Stance", "An acrobatic and fast-paced lightsaber stance.", 15, "materials/lscs_skill_station/icon_defaultpower.png", "item_stance_ataru")
local stanceJuggernaut = LSCS_STANCE:New("Juggernaut Stance", "A powerful and resilient stance for defense and offense.", 20, "materials/lscs_skill_station/icon_defaultpower.png", "item_stance_juggernaut")

-- Set prerequisites
stanceAtaru:AddPrerequisite("Embestida Stance")
stanceJuggernaut:AddPrerequisite("Ataru Stance")

-- Add nodes to the stance tree
stanceTree:AddRoot(stanceEmbestida)
stanceTree:AddNode(stanceAtaru)
stanceTree:AddNode(stanceJuggernaut)

-- Restrict access to specific jobs
stanceTree.JobAccess = {
    [TEAM_JEDIKNIGHT] = true,
    [TEAM_CITIZEN] = true
}

return stanceTree
