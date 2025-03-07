local ban = console.AddCommand("rpa_ban", function(ply, steamID, length, reason)
	Access.AddBan(steamID, ply, length, reason)
end)

ban:SetCategory("Bans")
ban:SetDescription("Bans a player for a specified time, a length of 0 will ban them permanently")
ban:SetExecutionContext(console.Server)
ban:SetAccess(console.IsAdmin)

ban:AddParameter(console.SteamID({
	StrictImmunity = true,
	NoSelfTarget = true
}))

ban:AddParameter(console.Duration({
	AllowZero = true
}, "length"))
ban:AddOptional(console.String({
	Max = 256
}), nil, "No reason specified")

local unban = console.AddCommand("rpa_unban", function(ply, steamID)
	Access.LiftBan(steamID)
end)

unban:SetCategory("Bans")
unban:SetDescription("Unbans a player, does nothing if they're not")
unban:SetExecutionContext(console.Server)
unban:SetAccess(console.IsAdmin)

unban:AddParameter(console.SteamID())

local kick = console.AddCommand("rpa_kick", function(ply, target, reason)
	Access.Kick(ply, target, reason)
end)

kick:SetCategory("Bans")
kick:SetDescription("Kicks a player")
kick:SetExecutionContext(console.Server)
kick:SetAccess(console.IsAdmin)

kick:AddParameter(console.Player({
	SingleTarget = true,
	StrictImmunity = true,
	NoSelfTarget = true
}))

kick:AddOptional(console.String({
	Max = 256
}), nil, "No reason specified")
