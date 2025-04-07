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

net.Receive("LSCS_SendLevelUpNotificationToClient", function(ply, len)
    local level = net.ReadUInt(LEVEL_BIT_COUNT)
    local time = net.ReadUInt(COOLDOWN_BIT_COUNT)

    SpawnLevelUpNotification(level, time)
end)

