local setDelay = console.AddCommand("rpa_ooc_delay", function(ply, delay)
	GAMEMODE:SetOOCDelay(delay)

	Log.Write("admin_variable_set", ply, "OOCDelay", delay)

	Chat.Send("NOTICE", ply:Nick() .. " has set the OOC delay to " .. string.NiceTime(delay) .. ".")
end)

setDelay:SetCategory("Server Commands")
setDelay:SetDescription("Sets the global out-of-character chat delay")
setDelay:SetExecutionContext(console.Server)
setDelay:SetAccess(console.IsAdmin)

setDelay:AddParameter(console.Duration({
	Max = "1 Hour"
}))

local disable = console.AddCommand("rpa_ooc_disable", function(ply)
	GAMEMODE:SetOOCDelay(-1)

	Log.Write("admin_variable_set", ply, "OOCDelay", -1)

	Chat.Send("NOTICE", ply:Nick() .. " has disabled OOC chat.")
end)

disable:SetCategory("Server Commands")
disable:SetDescription("Disables global out-of-character chat")
disable:SetExecutionContext(console.Server)
disable:SetAccess(console.IsAdmin)

local oocMute = console.AddCommand("rpa_oocmute", function (ply, target, bool)
	local new

	if bool == nil then
		new = not target:OOCMuted()
	else
		new = bool
	end

	target:SetOOCMuted(new)

	console.Feedback(ply, "NOTICE", "You %s %s from OOC chat", new == 1 and "muted" or "unmuted", target)
	console.Feedback(target, "NOTICE", "%s has %s you from OOC chat", ply, new == 1 and "muted" or "unmuted")

	Log.Write("admin_player_set", ply, target, "OOCMuted", new)
end)

oocMute:SetCategory("Player Commands")
oocMute:SetChatAlias("mute")
oocMute:SetDescription("Mute or unmutes a player from OOC chat")
oocMute:SetExecutionContext(console.Server)
oocMute:SetAccess(console.IsAdmin)

oocMute:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true
}))

oocMute:AddOptional(console.Bool())
