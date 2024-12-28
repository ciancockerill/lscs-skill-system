net.Receive("LSCS_SendSkillDataToClient", function()
    local skillData = net.ReadTable()
    LocalPlayer().SkillSystem = skillData
end)

function LSCS_SKILLSYSTEM:getDataOnClient()
    net.Start("LSCS_RequestSkillDataFromServer")
    net.SendToServer()
end

net.Receive("LSCS_SendTreeDataToClient", function()
    local treeData = net.ReadTable()
    LSCS_SKILLTREE.CurrentSelected = treeData
    hook.Run("LSCS_SelectedSkillTreeDataReady")
end)

function LSCS_SKILLSYSTEM:GetSelectedSkillTree(skilltree)
    net.Start("LSCS_RequestTreeDataFromServer")
        net.WriteString(skilltree)
    net.SendToServer()
end

function LSCS_SKILLSYSTEM:GetAllSkillTreeNames()
    net.Start("LSCS_RequestAllSkillTreeNamesFromServer")
    net.SendToServer()
end

net.Receive("LSCS_SendAllSkillTreeNamesToClient", function()
    local skilltreeNames = net.ReadTable()
    LSCS_SKILLTREE.TreeNames = skilltreeNames
end)