net.Receive("LSCS_SendSkillDataToClient", function()
    local skillData = net.ReadTable()
    LocalPlayer().SkillSystem = skillData
end)

function LSCS_SKILLSYSTEM:getDataOnClient()
    net.Start("LSCS_RequestSkillDataFromServer")
    net.SendToServer()
end