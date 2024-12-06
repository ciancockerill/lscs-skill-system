util.AddNetworkString("LSCS_RequestSkillDataFromServer")
util.AddNetworkString("LSCS_SendSkillDataToClient")

net.Receive("LSCS_RequestSkillDataFromServer", function(len, ply)
    local skillData = ply.SkillSystem and ply.SkillSystem:GetPlayerData() or {}

    net.Start("LSCS_SendSkillDataToClient")
        net.WriteTable(skillData)
    net.Send(ply)
end)
