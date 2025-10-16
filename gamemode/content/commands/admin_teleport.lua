local goTo = console.AddCommand("rpa_goto", function(ply, target)
	util.TeleportPlayers(target, ply)

	Log.Write("admin_teleport_goto", ply, target)
end)

goTo:SetCategory("Teleport Commands")
goTo:SetChatAlias("goto")
goTo:SetDescription("Teleports yourself to another player on the server")
goTo:SetExecutionContext(console.Server)
goTo:SetAccess(console.IsAdmin)
goTo:SetNoConsole()

goTo:AddParameter(console.Player({SingleTarget = true, NoSelfTarget = true}))





local bring = console.AddCommand("rpa_bring", function(ply, targets)
	util.TeleportPlayers(ply, targets)

	for _, target in ipairs(targets) do
		Log.Write("admin_teleport_bring", ply, target)
	end
end)

bring:SetCategory("Teleport Commands")
bring:SetChatAlias("bring")
bring:SetDescription("Teleports another player on the server to yourself")
bring:SetExecutionContext(console.Server)
bring:SetAccess(console.IsAdmin)
bring:SetNoConsole()

bring:AddParameter(console.Player({NoSelfTarget = true}))





local send = console.AddCommand("rpa_send", function(ply, targets, to)
	util.TeleportPlayers(to, targets)

	for _, target in ipairs(targets) do
		Log.Write("admin_teleport_send", ply, target, to)
	end
end)

send:SetCategory("Teleport Commands")
send:SetChatAlias("send")
send:SetDescription("Teleport players to another")
send:SetExecutionContext(console.Server)
send:SetAccess(console.IsAdmin)

send:AddParameter(console.Player())
send:AddParameter(console.Player({SingleTarget = true}))





local teleport = console.AddCommand("rpa_teleport", function(ply, targets)
	util.TeleportPlayers(ply:GetEyeTrace().HitPos, targets)

	for _, target in ipairs(targets) do
		Log.Write("admin_teleport_look", ply, target)
	end
end)

teleport:SetCategory("Teleport Commands")
teleport:SetChatAlias("teleport")
teleport:SetDescription("Teleports a player to the point you're looking at")
teleport:SetExecutionContext(console.Server)
teleport:SetAccess(console.IsAdmin)
teleport:SetNoConsole()

teleport:AddParameter(console.Player({NoSelfTarget = true}))
