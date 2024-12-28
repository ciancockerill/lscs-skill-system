util.AddNetworkString("LSCS_RequestSkillDataFromServer")
util.AddNetworkString("LSCS_SendSkillDataToClient")
util.AddNetworkString("LSCS_RequestTreeDataFromServer")
util.AddNetworkString("LSCS_SendTreeDataToClient")
util.AddNetworkString("LSCS_RequestAllSkillTreeNamesFromServer")
util.AddNetworkString("LSCS_SendAllSkillTreeNamesToClient")


net.Receive("LSCS_RequestSkillDataFromServer", function(len, ply)
    local skillData = ply.SkillSystem and ply.SkillSystem or {}

    net.Start("LSCS_SendSkillDataToClient")
        net.WriteTable(skillData)
    net.Send(ply)
end)

net.Receive("LSCS_RequestTreeDataFromServer", function(len,ply)
    local treeRequested = net.ReadString()
    net.Start("LSCS_SendTreeDataToClient")
        net.WriteTable(LSCS_SKILLSYSTEM.SkillTrees[treeRequested])
    net.Send(ply)
end)

net.Receive("LSCS_RequestAllSkillTreeNamesFromServer", function(len,ply)
    local skillKeys = table.GetKeys(LSCS_SKILLSYSTEM.SkillTrees)
    if not skillKeys then return end

    net.Start("LSCS_SendAllSkillTreeNamesToClient")
        net.WriteTable(skillKeys)
    net.Send(ply)
end)